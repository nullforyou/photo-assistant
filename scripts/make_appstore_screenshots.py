#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""生成 App Store 商店截图（按 App 真实屏幕结构渲染）。

对照的真实实现：
  lib/main.dart                    → 首页 WelcomePage
  lib/shoot/shoot_page.dart        → 拍照页（全屏取景 + 顶部"按轮廓摆好姿势" + 光影方案条
                                     + 姿势缩略条 + 白色快门）
  lib/shoot/photo_preview_page.dart→ 预览页（黑色底 + AppBar"照片预览" + 重拍/保存）
  lib/l10n/intl_zh.arb             → 全部可见文案取真实 key

输出：
  store_screenshots/6.7/<n>_*.png  (1290x2796, iPhone 15/14 Pro Max)
  store_screenshots/6.5/<n>_*.png  (1242x2688, iPhone 11 Pro Max 等)

注意：这是依据真实设计与资源绘制的 UI 渲染图，非真机抓屏。
"""
import math, glob, os
from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = "D:/work/photo-assistant"
OUT = os.path.join(ROOT, "store_screenshots")
FONT_B = "C:/Windows/Fonts/msyhbd.ttc"
FONT_R = "C:/Windows/Fonts/msyh.ttc"

BRAND_PINK = (253, 173, 173)
BRAND_PINK_DEEP = (238, 129, 136)
CREAM = (253, 246, 242)
INK = (107, 58, 66)
MUTED = (176, 122, 130)
WHITE = (255, 255, 255)

# 真实文案（取自 lib/l10n/intl_zh.arb）
T_APP = "拍照助手"
T_SUB = "欢迎使用 Photo Assistant"
T_TAGLINE = "姿势引导 · 摆好 pose 一键出片"
T_START = "开始拍照"
T_POSE_TITLE = "按轮廓摆好姿势"
T_PREVIEW = "照片预览"
T_RETAKE = "重拍"
T_SAVE = "保存"
T_SAVED = "已保存到相册"
# 真实光影方案名（取自 lib/poses/pose_data.dart）
STYLES = ["极简单线", "蓝调描边", "霓虹", "柔光暖黄"]


def font(sz, bold=True):
    try:
        return ImageFont.truetype(FONT_B if bold else FONT_R, int(sz))
    except Exception:
        return ImageFont.truetype(FONT_R, int(sz))


def vgrad(w, h, top, bot):
    img = Image.new("RGBA", (int(w), int(h)))
    px = img.load()
    W, H = img.size
    for y in range(H):
        t = y / max(1, H - 1)
        c = tuple(int(top[i] + (bot[i] - top[i]) * t) for i in range(3)) + (255,)
        for x in range(W):
            px[x, y] = c
    return img


def vscrim(img, y0, y1, c0, c1):
    """在 img 的 [y0,y1] 区间叠一层垂直 alpha 渐变（用于顶部/底部遮罩）。"""
    W, H = img.size
    y0, y1 = int(y0), int(y1)
    layer = Image.new("RGBA", (W, y1 - y0))
    px = layer.load()
    for y in range(y1 - y0):
        t = y / max(1, y1 - y0 - 1)
        a = int(c0[3] + (c1[3] - c0[3]) * t)
        r, g, b = c0[0], c0[1], c0[2]
        for x in range(W):
            px[x, y] = (r, g, b, a)
    img.alpha_composite(layer, (0, y0))


def star(d, cx, cy, s, col):
    pts = []
    for i in range(8):
        ang = math.pi / 2 * i / 4 - math.pi / 2
        rad = s if i % 2 == 0 else s * 0.36
        pts.append((cx + rad * math.cos(ang), cy + rad * math.sin(ang)))
    d.polygon(pts, fill=col)


def dash_ring(d, cx, cy, r, col, width=2, dash=11, gap=9):
    circ = 2 * math.pi * r
    pos = 0.0
    while pos < circ:
        a0 = pos / r
        a1 = min(pos + dash, circ) / r
        d.line([(cx + r * math.cos(a0), cy + r * math.sin(a0)),
                (cx + r * math.cos(a1), cy + r * math.sin(a1))], fill=col, width=width)
        pos += dash + gap


def rr(d, box, radius, fill=None, outline=None, width=1):
    d.rounded_rectangle(box, radius=radius, fill=fill, outline=outline, width=width)


def load_icon(size):
    im = Image.open(os.path.join(ROOT, "assets/branding/app_icon_round.png")).convert("RGBA")
    return im.resize((int(size), int(size)), Image.LANCZOS)


def load_pose(idx, height):
    fs = sorted(glob.glob(os.path.join(ROOT, "assets/poses/pose_*.png")))
    im = Image.open(fs[idx % len(fs)]).convert("RGBA")
    h = int(height)
    w = max(1, int(im.width * h / im.height))
    return im.resize((w, h), Image.LANCZOS)


def tint(pose, color, alpha):
    a = pose.split()[-1].point(lambda v: int(v * alpha))
    out = Image.new("RGBA", pose.size, color + (0,))
    out.putalpha(a)
    return out


def status_bar(d, W, H, k, dark=True):
    y = 18 * k
    col = INK if dark else WHITE
    d.text((30 * k, y), "9:41", font=font(15 * k, True), fill=col, anchor="lm")
    rx = W - 30 * k
    for i, hh in enumerate((6, 4, 2)):
        d.rectangle([rx - 54 * k + i * 10 * k, y - hh * k, rx - 50 * k + i * 10 * k, y + 6 * k], fill=col)
    d.rectangle([rx - 27 * k, y - 7 * k, rx - 10 * k, y + 7 * k], outline=col, width=max(1, int(1.5 * k)))
    d.rectangle([rx - 8 * k, y - 4 * k, rx - 6 * k, y + 4 * k], fill=col)


def camera_scene(W, H, k, dark_bottom=True, dark_top=True):
    """模拟相机取景画面：暖调渐变 + 柔光斑。"""
    img = vgrad(W, H, (232, 226, 226), (206, 202, 208))
    glow = Image.new("RGBA", (int(W), int(H)), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    gd.ellipse([-W * 0.3, -H * 0.05, W * 0.9, H * 0.45], fill=(255, 246, 236, 90))
    glow = glow.filter(ImageFilter.GaussianBlur(W * 0.12))
    img.alpha_composite(glow)
    if dark_top:
        vscrim(img, 0, H * 0.18, (0, 0, 0, 70), (0, 0, 0, 0))
    if dark_bottom:
        vscrim(img, H * 0.62, H, (0, 0, 0, 0), (0, 0, 0, 165))
    return img


# ---------------- 白天首页 ----------------

def screen_home(W, H):
    k = W / 390.0
    img = vgrad(W, H, CREAM, (252, 228, 230))
    d = ImageDraw.Draw(img, "RGBA")
    status_bar(d, W, H, k, dark=True)
    cx, cy = W / 2, H * 0.352
    dash_ring(d, cx, cy, 150 * k, BRAND_PINK_DEEP + (90,), width=max(1, int(2 * k)))
    star(d, 59 * k, 113 * k, 12 * k, BRAND_PINK_DEEP + (128,))
    star(d, W - 60 * k, 185 * k, 8.5 * k, BRAND_PINK_DEEP + (107,))
    star(d, 72 * k, H - 110 * k, 10.5 * k, BRAND_PINK + (217,))
    star(d, W - 55 * k, H - 51 * k, 6.5 * k, BRAND_PINK_DEEP + (97,))
    sh = Image.new("RGBA", (int(260 * k), int(260 * k)), (0, 0, 0, 0))
    ImageDraw.Draw(sh).rounded_rectangle(
        [26 * k, 42 * k, 234 * k, 246 * k], radius=46 * k, fill=BRAND_PINK_DEEP + (72,))
    sh = sh.filter(ImageFilter.GaussianBlur(11 * k))
    img.alpha_composite(sh, (int(cx - sh.width / 2), int(cy - sh.height / 2)))
    icon = load_icon(200 * k)
    img.alpha_composite(icon, (int(cx - icon.width / 2), int(cy - icon.height / 2)))
    d.text((cx, H * 0.585), T_APP, font=font(34 * k, True), fill=INK, anchor="mm")
    d.text((cx, H * 0.635), T_SUB, font=font(16 * k, False), fill=MUTED, anchor="mm")
    bw, bh = 214 * k, 36 * k
    rr(d, [cx - bw / 2, H * 0.672, cx + bw / 2, H * 0.672 + bh], bh / 2, fill=BRAND_PINK + (140,))
    d.text((cx, H * 0.672 + bh / 2), T_TAGLINE, font=font(13 * k, False), fill=INK, anchor="mm")
    bw2, bh2 = 210 * k, 56 * k
    by = H * 0.768
    rr(d, [cx - bw2 / 2, by, cx + bw2 / 2, by + bh2], bh2 / 2, fill=BRAND_PINK_DEEP)
    cam = Image.new("RGBA", (int(28 * k), int(28 * k)), (0, 0, 0, 0))
    cd = ImageDraw.Draw(cam)
    cd.rounded_rectangle([1 * k, 7 * k, 27 * k, 24 * k], radius=4 * k, outline=WHITE, width=max(1, int(2 * k)))
    cd.rounded_rectangle([9 * k, 3 * k, 19 * k, 8 * k], radius=2 * k, outline=WHITE, width=max(1, int(2 * k)))
    cd.ellipse([9 * k, 11 * k, 19 * k, 21 * k], outline=WHITE, width=max(1, int(2 * k)))
    img.alpha_composite(cam, (int(cx - 92 * k), int(by + bh2 / 2 - 14 * k)))
    d.text((cx + 10 * k, by + bh2 / 2), T_START, font=font(18 * k, True), fill=WHITE, anchor="mm")
    return img


# ---------------- 拍照页（全屏取景） ----------------

def screen_shoot(W, H, pose_idx=3, style_sel=1, tips=None):
    k = W / 390.0
    img = camera_scene(W, H, k)
    d = ImageDraw.Draw(img, "RGBA")
    status_bar(d, W, H, k, dark=False)

    # 姿势轮廓叠加（白色光晕打底 + 品牌粉线，保证在取景画面上够醒目）
    pose = load_pose(pose_idx, H * 0.62)
    glow = tint(pose, WHITE, 0.85).filter(ImageFilter.GaussianBlur(max(1, 5 * k)))
    guide = tint(pose, BRAND_PINK_DEEP, 0.95)
    gx, gy = (W - guide.width) / 2, H * 0.225
    img.alpha_composite(glow, (int(gx), int(gy)))
    img.alpha_composite(guide, (int(gx), int(gy)))

    # 提示气泡
    f_tip = font(12.5 * k, True)
    for text, ax, ay in (tips or []):
        tw = d.textlength(text, font=f_tip)
        bw, bh = tw + 20 * k, 26 * k
        bx, by = W * ax - bw, H * ay
        rr(d, [bx, by, bx + bw, by + bh], 10 * k, fill=(0, 0, 0, 160),
           outline=BRAND_PINK + (230,), width=max(1, int(1.2 * k)))
        d.text((bx + bw / 2, by + bh / 2), text, font=f_tip, fill=BRAND_PINK, anchor="mm")

    # 顶部：返回 + 标题（真实为白色文字 + 黑色投影）
    d.text((20 * k, 56 * k), "‹", font=font(30 * k, True), fill=(255, 255, 255, 230), anchor="lm")
    th = font(15 * k, True)
    d.text((W / 2 + 1 * k, 57 * k), T_POSE_TITLE, font=th, fill=(0, 0, 0, 120), anchor="mm")
    d.text((W / 2, 56 * k), T_POSE_TITLE, font=th, fill=(255, 255, 255, 235), anchor="mm")

    # 光影方案条
    f_st = font(11 * k, False)
    widths = [d.textlength(s, font=f_st) + 16 * k for s in STYLES]
    total = sum(widths) + 6 * k * (len(STYLES) - 1)
    x = (W - total) / 2
    y = 82 * k
    for i, s in enumerate(STYLES):
        w = widths[i]
        sel = (i == style_sel)
        rr(d, [x, y, x + w, y + 22 * k], 11 * k,
           fill=(0, 0, 0, 115) if not sel else (0, 0, 0, 140),
           outline=BRAND_PINK if sel else (255, 255, 255, 60), width=max(1, int((2 if sel else 1) * k)))
        d.text((x + w / 2, y + 11 * k), s, font=f_st,
               fill=BRAND_PINK if sel else (255, 255, 255, 180), anchor="mm")
        x += w + 6 * k

    # 底部：姿势缩略条 + 快门
    sy = H * 0.905
    th_h = 54 * k
    offs = [-124 * k, -62 * k, 0, 62 * k, 124 * k]
    for i, off in enumerate(offs):
        sel = (i == 2)
        cxx = W / 2 + off
        box = [cxx - th_h * 0.75, sy - th_h, cxx + th_h * 0.75, sy]
        rr(d, box, 10 * k, fill=(0, 0, 0, 115),
           outline=BRAND_PINK if sel else (255, 255, 255, 60), width=max(1, int((2 if sel else 1) * k)))
        p = load_pose(pose_idx - 2 + i, th_h * 0.78)
        p = tint(p, WHITE, 0.92)  # 深色底上必须用浅色描边才看得见（与真实 App 一致）
        img.alpha_composite(p, (int(cxx - p.width / 2), int(sy - th_h / 2 - p.height / 2)))
    # 快门（真实：68 圆，白色 4px 环 + 白色实心内圆）
    sr = 34 * k
    cyy = H * 0.962
    rr(d, [W / 2 - sr, cyy - sr, W / 2 + sr, cyy + sr], sr, fill=None, outline=WHITE, width=max(1, int(4 * k)))
    rr(d, [W / 2 - sr + 4 * k, cyy - sr + 4 * k, W / 2 + sr - 4 * k, cyy + sr - 4 * k],
       sr - 4 * k, fill=WHITE)
    return img


# ---------------- 预览页 ----------------

def screen_preview(W, H, pose_idx=8, show_snackbar=True):
    k = W / 390.0
    img = Image.new("RGBA", (int(W), int(H)), (0, 0, 0, 255))
    d = ImageDraw.Draw(img, "RGBA")
    status_bar(d, W, H, k, dark=False)
    # AppBar
    d.text((20 * k, 56 * k), "‹", font=font(30 * k, True), fill=WHITE, anchor="lm")
    d.text((W / 2, 58 * k), T_PREVIEW, font=font(17 * k, True), fill=WHITE, anchor="mm")
    # 成片
    pw = W - 48 * k
    ph = pw * 1.32
    px0, py0 = 24 * k, H * 0.135
    photo = camera_scene(int(pw), int(ph), k, dark_bottom=False, dark_top=False)
    p = load_pose(pose_idx, ph * 0.76)
    photo.alpha_composite(p, (int((pw - p.width) / 2), int((ph - p.height) / 2)))
    img.paste(photo, (int(px0), int(py0)), photo)
    rr(d, [px0, py0, px0 + pw, py0 + ph], 18 * k, outline=(255, 255, 255, 40), width=max(1, int(1.5 * k)))
    # 底部按钮：重拍（描边）/ 保存（品牌粉实心）
    bw, bh = (W - 24 * k * 2 - 14 * k) / 2, 50 * k
    by = H * 0.885
    rr(d, [24 * k, by, 24 * k + bw, by + bh], bh / 2, fill=None,
       outline=(255, 255, 255, 90), width=max(1, int(2 * k)))
    d.text((24 * k + bw / 2, by + bh / 2), T_RETAKE, font=font(17 * k, True), fill=WHITE, anchor="mm")
    rx = 24 * k + bw + 14 * k
    rr(d, [rx, by, rx + bw, by + bh], bh / 2, fill=BRAND_PINK_DEEP)
    d.text((rx + bw / 2, by + bh / 2), T_SAVE, font=font(17 * k, True), fill=WHITE, anchor="mm")
    # 保存成功 SnackBar
    if show_snackbar:
        msg = T_SAVED
        f = font(14 * k, False)
        sw = d.textlength(msg, font=f) + 40 * k
        sh_ = 44 * k
        sx, syy = 24 * k, H * 0.775
        rr(d, [sx, syy, sx + sw, syy + sh_], 10 * k, fill=(50, 50, 52, 245))
        d.text((sx + sw / 2, syy + sh_ / 2), msg, font=f, fill=WHITE, anchor="mm")
    return img


SCREENS = [
    ("01_home", lambda W, H: screen_home(W, H)),
    ("02_shoot_pose1", lambda W, H: screen_shoot(
        W, H, pose_idx=3, style_sel=1,
        tips=[("肩线放松，微侧身", 0.62, 0.30), ("重心落在后脚", 0.42, 0.62)])),
    ("03_shoot_pose2", lambda W, H: screen_shoot(
        W, H, pose_idx=12, style_sel=3,
        tips=[("下巴微收，看镜头", 0.60, 0.28)])),
    ("04_preview", lambda W, H: screen_preview(W, H, pose_idx=8)),
]


def main():
    for tag, W, H in (("6.7", 1290, 2796), ("6.5", 1242, 2688)):
        outdir = os.path.join(OUT, tag)
        os.makedirs(outdir, exist_ok=True)
        for name, fn in SCREENS:
            im = fn(W, H).convert("RGB")
            im.save(os.path.join(outdir, f"{name}.png"), "PNG")
            print("✅", tag, name, im.size)
    print("\n输出目录:", OUT)


if __name__ == "__main__":
    main()
