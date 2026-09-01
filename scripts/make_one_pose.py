"""
单张姿势图 -> 透明 PNG（保守算法，保留所有灰线稿，只去白底 + 右下角水印）

用法:
  python scripts/make_one_pose.py <源图路径> [输出目录]

设计要点（修复“线条断断续续”）：
  1. 自适应背景：取边框像素“最暗通道”中位数作为背景色（纯白=255，
     浅灰底如 005≈248），阈值 = 背景色 - TOL(3)。这样无论纯白底还是浅灰底
     都能正确去除，且浅灰线条的抗锯齿灰边(min<背景色)会被保留，不会断线。
  2. 水印只在右下角（豆包AI生成）。用连通域定位：落在右下角区域、是灰字
     (非深色线条)、面积不大的连通域 -> 删除。人物主体贯穿全图，不会被误删。
  3. 不再做“平均亮度高 + 小面积”的全局噪点清除（会把浅灰线条当噪点删掉）。
"""
import os
import sys
import numpy as np
from PIL import Image
from scipy.ndimage import label, find_objects, mean as ndi_mean, binary_dilation

SRC = sys.argv[1] if len(sys.argv) > 1 else None
DST = sys.argv[2] if len(sys.argv) > 2 else r"D:\work\photo-assistant\assets\poses"
os.makedirs(DST, exist_ok=True)

# 背景判定：自适应背景色（取图像边框像素的“最暗通道”中位数），
# 再容差 TOL 作为白底阈值。纯白底(255)与浅灰底(如005的~248)都能正确去除，
# 同时保留浅灰线条(抗锯齿灰边)不被误删成断线。
TOL = 3
# 水印区域（相对画布比例）：右下角
WM_X0_RATIO = 0.66
WM_Y0_RATIO = 0.82
WM_MAX_AREA = 80000


def process(path, out_path, preview_path):
    img = Image.open(path).convert("RGB")
    arr = np.array(img)
    h, w = arr.shape[:2]
    R = arr[:, :, 0].astype(np.int32)
    G = arr[:, :, 1].astype(np.int32)
    B = arr[:, :, 2].astype(np.int32)
    mn = np.minimum(np.minimum(R, G), B)
    bright = np.maximum(np.maximum(R, G), B).astype(np.float32)

    alpha = np.full((h, w), 255, dtype=np.uint8)

    # 1) 背景 -> 透明
    #    线稿核心为深色(min 0~242)，背景(纯白255 或 005 的浅灰底245~254)都在 min>=243。
    #    统一“min>=243 即背景 -> 透明”，同时正确处理纯白底与浅灰底，完整保留线条。
    is_bg = mn >= 243
    alpha[is_bg] = 0
    print(f"  [bg   ] min>=243 {int(is_bg.sum())} px ({is_bg.mean()*100:.2f}%) -> 透明")

    # 2) 右下角水印：连通域定位删除
    #    仅删除“落在右下角 且 是灰字(非深色线条) 且 面积不大”的连通域。
    #    这样即使人物腿/脚伸到右下角，只要它是深色线条就不会被误删。
    opaque = alpha > 0
    removed_wm = 0
    if opaque.sum() > 0:
        labeled, n_features = label(opaque)
        slices = find_objects(labeled)
        if n_features > 0:
            comp_means = ndi_mean(bright, labeled, index=np.arange(1, n_features + 1))
        else:
            comp_means = []
        for i, sl in enumerate(slices, start=1):
            if sl is None:
                continue
            ys, xs = sl
            y0, x0 = ys.start, xs.start
            y1, x1 = ys.stop, xs.stop
            comp_size = int((labeled[sl] == i).sum())
            in_wm = (x0 > w * WM_X0_RATIO) and (y0 > h * WM_Y0_RATIO)
            mb = float(comp_means[i - 1]) if i - 1 < len(comp_means) else 0.0
            is_gray_text = 208 < mb < 252   # 灰字(约229) vs 深色线条(<200)
            if in_wm and comp_size < WM_MAX_AREA and is_gray_text:
                alpha[labeled == i] = 0
                removed_wm += 1
    print(f"  [wm   ] 右下角水印连通域 {removed_wm} 个 -> 透明")

    # 写出透明 PNG：掩码与颜色分开降采样，避免 RGBA 直接 LANCZOS 产生椒盐噪点
    # （app 中按 designWidth/Height 缩放绘制，源分辨率无需 1728x2304 这么大）
    MAX_W = int(os.environ.get("MAKE_ONE_MAXW", "900"))
    scale = MAX_W / w
    out_w, out_h = MAX_W, int(round(h * scale))

    # 1) 掩码单独降采样后阈值化 -> 干净的二值 alpha（消除灰底/浅灰线条边界裂成的散点）
    mask_full = alpha.astype(np.float32) / 255.0
    mask_img = Image.fromarray((mask_full * 255).astype(np.uint8)).resize((out_w, out_h), Image.LANCZOS)
    mask_s = np.array(mask_img).astype(np.float32) / 255.0 > 0.5
    # 2) 颜色单独降采样（保留灰度线条本身的颜色）
    rgb_s = np.array(Image.fromarray(arr.astype(np.uint8)).resize((out_w, out_h), Image.LANCZOS))
    alpha_s = mask_s.astype(np.uint8) * 255
    rgba = np.dstack([rgb_s, alpha_s])
    Image.fromarray(rgba, "RGBA").save(out_path, optimize=True)

    # 预览：叠在深色背景上（同样缩小，便于查看）
    a = mask_s[:, :, None].astype(np.float32)
    bg = np.zeros((out_h, out_w, 3), dtype=np.uint8)
    bg[:] = (20, 20, 28)
    preview = (rgb_s.astype(np.float32) * a + bg.astype(np.float32) * (1 - a)).astype(np.uint8)
    Image.fromarray(preview).save(preview_path, optimize=True)

    keep = float(mask_s.mean() * 100)
    trans = float((1 - mask_s).mean() * 100)
    print(f"  -> 输出 {out_path} ({out_w}x{out_h}) 保留 {keep:.1f}% / 透明 {trans:.1f}%")


if __name__ == "__main__":
    if not SRC:
        print("用法: python scripts/make_one_pose.py <源图路径> [输出目录]")
        sys.exit(1)
    name = os.path.basename(SRC)
    import re
    m = re.match(r"(\d{3})_(.+)\.png", name)
    num = m.group(1) if m else os.path.splitext(name)[0]
    out = os.path.join(DST, f"pose_{num}.png")
    prev = os.path.join(DST, f"pose_{num}_preview.png")
    print(f"\n[{num}] {name}")
    process(SRC, out, prev)
