package com.example.photo_assistant

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.DashPathEffect
import android.graphics.Matrix
import android.graphics.Paint
import android.graphics.Path
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.IBinder
import android.provider.Settings
import android.util.Log
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.LinearLayout
import android.widget.TextView

/**
 * 方案2 的透明悬浮蒙版服务：在系统相机之上叠加虚线人形姿势引导。
 *
 * 关键架构（修复“蒙版挡住相机操作”的核心）：
 *  - 绘制层 drawRoot：全屏 TYPE_APPLICATION_OVERLAY + FLAG_NOT_FOCUSABLE + FLAG_NOT_TOUCHABLE。
 *    只负责画虚线人形，永远不消费触摸，因此相机的快门/按键完全不受影响。
 *  - 控制层 ctrlRoot：只包住“切换姿势”按钮的小窗口（WRAP_CONTENT），
 *    TYPE_APPLICATION_OVERLAY + FLAG_NOT_FOCUSABLE + FLAG_NOT_TOUCH_MODAL。
 *    只有按钮这一小块可点；窗口之外的所有触摸穿透到下层相机。
 *  这样“全屏引导”与“可点击按钮”互不干扰。
 *
 * 本服务必须是【前台服务】：用户点拍照、系统相机被拉起、App 退到后台时，
 * 华为 EMUI 会立刻杀掉后台服务，蒙版就消失了。前台服务带常驻通知可抗住。
 */
class OverlayService : Service() {

    companion object {
        private const val TAG = "PoseOverlay"
        private const val NOTIF_ID = 1001
        private const val CHANNEL_ID = "pose_overlay_channel"
    }

    private lateinit var windowManager: WindowManager
    private var drawRoot: LinearLayout? = null
    private var ctrlRoot: LinearLayout? = null
    private var poseView: PoseOverlayView? = null
    private var fab: TextView? = null
    private var panel: LinearLayout? = null
    private var panelVisible = false
    private var foregroundStarted = false

    private var currentPose = 0
    private var poseNames: ArrayList<String> = arrayListOf()
    private var allPolylines: ArrayList<ArrayList<ArrayList<Double>>> = arrayListOf()

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "onStartCommand action=${intent?.action} pid=${android.os.Process.myPid()}")
        when (intent?.action) {
            "START" -> {
                currentPose = intent.getIntExtra("pose", 0)
                @Suppress("UNCHECKED_CAST")
                poseNames = (intent.getSerializableExtra("names")
                        as? ArrayList<String>) ?: arrayListOf()
                @Suppress("UNCHECKED_CAST")
                allPolylines = (intent.getSerializableExtra("allPolylines")
                        as? ArrayList<ArrayList<ArrayList<Double>>>) ?: arrayListOf()
                ensureForeground()
                if (drawRoot == null || ctrlRoot == null) buildOverlay()
                refreshPose()
            }
            "UPDATE" -> {
                currentPose = intent.getIntExtra("pose", currentPose)
                @Suppress("UNCHECKED_CAST")
                allPolylines = (intent.getSerializableExtra("allPolylines")
                        as? ArrayList<ArrayList<ArrayList<Double>>>) ?: allPolylines
                if (drawRoot == null || ctrlRoot == null) {
                    ensureForeground()
                    buildOverlay()
                }
                refreshPose()
            }
            "STOP" -> {
                Log.d(TAG, "STOP received, removing overlay")
                removeOverlay()
                stopSelf()
            }
        }
        return START_NOT_STICKY
    }

    private fun ensureForeground() {
        if (foregroundStarted) return
        try {
            startForeground(NOTIF_ID, buildNotification())
            foregroundStarted = true
            Log.d(TAG, "startForeground OK")
        } catch (e: Exception) {
            Log.e(TAG, "startForeground failed: ${e.message}")
        }
    }

    private fun buildNotification(): Notification {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val chan = NotificationChannel(
                CHANNEL_ID, "姿势蒙版", NotificationManager.IMPORTANCE_LOW
            ).apply { description = "拍照时叠加姿势引导蒙版" }
            getSystemService(NotificationManager::class.java).createNotificationChannel(chan)
        }
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            Notification.Builder(this)
        }
        return builder
            .setContentTitle("姿势蒙版运行中")
            .setContentText("点击右上角「切换姿势」选择姿势")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setPriority(Notification.PRIORITY_LOW)
            .build()
    }

    private fun refreshPose() {
        val list = if (currentPose in allPolylines.indices) {
            allPolylines[currentPose]
        } else {
            arrayListOf()
        }
        poseView?.setPolylines(list)
        poseView?.postInvalidate()
        Log.d(TAG, "refreshPose idx=$currentPose polylines=${list.size}")
    }

    private fun buildOverlay() {
        Log.d(TAG, "buildOverlay start, canDrawOverlays=${Settings.canDrawOverlays(this)}")
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager

        // ---------- 绘制层：全屏 + 完全穿透 ----------
        drawRoot = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            isClickable = false
            isFocusable = false
        }
        poseView = PoseOverlayView(this).apply {
            isClickable = false
            isFocusable = false
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
        }
        drawRoot!!.addView(poseView)

        val drawParams = WindowManager.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT
        )
        drawParams.gravity = Gravity.TOP or Gravity.START
        try {
            windowManager.addView(drawRoot, drawParams)
            Log.d(TAG, "addView(draw) OK — 绘制层已挂上，触摸完全穿透")
        } catch (e: Exception) {
            Log.e(TAG, "addView(draw) FAILED: ${e.message}")
            e.printStackTrace()
        }

        // ---------- 控制层：只包住按钮的小窗口，可点 ----------
        ctrlRoot = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            isClickable = false
            isFocusable = false
        }

        fab = TextView(this).apply {
            text = "切换姿势"
            setTextColor(Color.WHITE)
            textSize = 15f
            setPadding(36, 16, 36, 16)
            background = roundedBg(Color.parseColor("#3A3F4B"))
            isClickable = true
            setOnClickListener { togglePanel() }
        }
        ctrlRoot!!.addView(fab)

        panel = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            setPadding(20, 14, 20, 14)
            background = roundedBg(Color.parseColor("#222831"))
            isClickable = true
            visibility = View.GONE
        }
        ctrlRoot!!.addView(panel)

        val ctrlParams = WindowManager.LayoutParams(
            ViewGroup.LayoutParams.WRAP_CONTENT,
            ViewGroup.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT
        )
        // 右上角，避开相机快门（多数在底部）
        ctrlParams.gravity = Gravity.TOP or Gravity.END
        ctrlParams.x = 24
        ctrlParams.y = 80
        try {
            windowManager.addView(ctrlRoot, ctrlParams)
            Log.d(TAG, "addView(ctrl) OK — 控制层已挂上，仅按钮可点")
        } catch (e: Exception) {
            Log.e(TAG, "addView(ctrl) FAILED: ${e.message}")
            e.printStackTrace()
        }
    }

    private fun togglePanel() {
        if (panel == null) return
        panelVisible = !panelVisible
        panel!!.visibility = if (panelVisible) View.VISIBLE else View.GONE
        if (panelVisible) rebuildPanel()
    }

    private fun rebuildPanel() {
        panel!!.removeAllViews()
        poseNames.forEachIndexed { idx, name ->
            val chip = TextView(this).apply {
                text = name
                setTextColor(if (idx == currentPose) Color.YELLOW else Color.WHITE)
                textSize = 14f
                setPadding(26, 12, 26, 12)
                background = roundedBg(Color.parseColor("#3A3F4B"))
                isClickable = true
                setOnClickListener {
                    currentPose = idx
                    refreshPose()
                    panelVisible = false
                    panel!!.visibility = View.GONE
                    try {
                        MainActivity.overlayChannel?.invokeMethod("onPoseChanged", idx)
                        Log.d(TAG, "onPoseChanged -> Flutter idx=$idx")
                    } catch (e: Exception) {
                        Log.e(TAG, "onPoseChanged failed: ${e.message}")
                    }
                }
            }
            val lp = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply { setMargins(6, 0, 6, 0) }
            panel!!.addView(chip, lp)
        }
    }

    private fun removeOverlay() {
        try {
            if (foregroundStarted) stopForeground(true)
        } catch (e: Exception) {
            Log.e(TAG, "stopForeground failed: ${e.message}")
        }
        try {
            if (drawRoot != null) windowManager.removeView(drawRoot)
        } catch (e: Exception) {
            Log.e(TAG, "removeView(draw) failed: ${e.message}")
        }
        try {
            if (ctrlRoot != null) windowManager.removeView(ctrlRoot)
        } catch (e: Exception) {
            Log.e(TAG, "removeView(ctrl) failed: ${e.message}")
        }
        drawRoot = null
        ctrlRoot = null
        foregroundStarted = false
    }

    private fun roundedBg(color: Int): GradientDrawable {
        return GradientDrawable().apply {
            setColor(color)
            cornerRadius = 40f
        }
    }

    override fun onDestroy() {
        Log.d(TAG, "onDestroy")
        removeOverlay()
        super.onDestroy()
    }
}

/** 用 Canvas 把虚线人形画在最上层（背景透明，本身不接收触摸）。 */
class PoseOverlayView(context: android.content.Context) : View(context) {
    private var polylines: ArrayList<ArrayList<Double>> = arrayListOf()

    fun setPolylines(p: ArrayList<ArrayList<Double>>) {
        polylines = p
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        if (polylines.isEmpty()) return
        val w = width.toFloat()
        val h = height.toFloat()

        val paint = Paint().apply {
            color = Color.WHITE
            alpha = 235
            style = Paint.Style.STROKE
            strokeWidth = (3f * (w / 1080f)).coerceAtLeast(2.5f)
            strokeJoin = Paint.Join.ROUND
            strokeCap = Paint.Cap.ROUND
            pathEffect = DashPathEffect(floatArrayOf(20f, 16f), 0f)
            isAntiAlias = true
        }

        // 设计空间 240x380，按比例缩放并居中，保持人形比例
        val s = minOf(w / 240f, h / 380f) * 0.92f
        val ox = (w - 240f * s) / 2f
        val oy = (h - 380f * s) / 2f
        val m = Matrix().apply {
            setScale(s, s)
            postTranslate(ox, oy)
        }

        val path = Path()
        for (poly in polylines) {
            if (poly.size >= 4) {
                path.moveTo(poly[0].toFloat() * 240f, poly[1].toFloat() * 380f)
                var i = 2
                while (i + 1 < poly.size) {
                    path.lineTo(poly[i].toFloat() * 240f, poly[i + 1].toFloat() * 380f)
                    i += 2
                }
            }
        }
        path.transform(m)
        canvas.drawPath(path, paint)
    }
}
