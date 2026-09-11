# -*- coding: utf-8 -*-
"""把一张 App 图标设计稿处理成 iOS / Android / Web / macOS / Windows 图标套件。

用法：
    python make_app_icons.py --src "设计稿.png" [--out icon] [--project "D:\\work\\app"] [--install]

要点见同目录 ../SKILL.md。核心：
  * 非正方形设计稿先补成正方形（透明区用最近的不透明色填充）
  * 四角透明的设计稿 -> 补角时取色源必须先腐蚀，否则外沿 1px 浅色描边会扩散进四角
  * 抠主体（自适应图标前景）不要用全局色彩键控：当人物描边与底色同色系时，
    描边会被一起抠掉。改用「从画布边框连通扩散」判背景，判据是连通性而非纯颜色
  * iOS/商店/Android 用满幅方形不透明（RGB）；macOS/Windows 保留圆角与 alpha
  * Android 另出自适应图标（抠掉底色的前景 + 纯色背景，内容缩进安全区）
"""
import argparse
import os
import shutil
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

# 兜底底色（仅当检测失败时用于自适应背景色）
DEFAULT_BG = (253, 166, 165)
# 边框种子色量化步长 / 与种子色的最大色距（判定"像背景"）
QUANT = 8
DEFAULT_TOL = 32


# ---------------------------------------------------------------- 基础处理
def pad_to_square(src):
    """非正方形设计稿补齐成正方形（居中，新增区域透明，后续统一填色）。

    直接 resize 成正方形会拉伸变形；先补边再缩放才不变形。
    """
    im = Image.open(src).convert("RGBA")
    w, h = im.size
    if w == h:
        return im
    s = max(w, h)
    canvas = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    canvas.paste(im, ((s - w) // 2, (s - h) // 2))
    return canvas


def fill_transparent(im, erode=4):
    """透明区域用最近的不透明像素颜色补齐，返回满幅不透明 RGBA。

    erode：取色源向内腐蚀的像素数。设计稿最外沿通常有 1~2px 抗锯齿浅色描边，
           不腐蚀的话会被放射状扩散进四角（表现为明显条纹）。一般 4 足够。
    """
    from scipy.ndimage import binary_erosion, distance_transform_edt

    a = np.array(im.convert("RGBA"))
    hole = a[..., 3] < 8
    if hole.any():
        src_ok = binary_erosion(~hole, iterations=erode) if erode else ~hole
        if not src_ok.any():
            src_ok = ~hole
        idx = distance_transform_edt(~src_ok, return_distances=False, return_indices=True)
        a = a[idx[0], idx[1]].copy()
    a[..., 3] = 255
    return Image.fromarray(a, "RGBA")


def rim_depth(size):
    """外沿"假色"环的宽度：取画布短边的 0.7%（下限 3px）。

    设计稿导出时边缘会有 1~4px 抗锯齿环，其颜色常被混成发白/发浅的"假色"，
    与主体填充色极其接近。这圈既不标定底色，也不能算主体，必须先剥掉。
    """
    return max(3, int(round(size * 0.007)))


def _seed_colors(rgb, inner, band, quant=QUANT):
    """在 rim 内侧 band 宽的一圈里取样，作为背景种子色。

    不能直接取画布最外圈：那儿正是上面说的"假色"环。
    """
    from scipy.ndimage import binary_erosion

    ring = inner & ~binary_erosion(inner, iterations=band)
    sel = rgb[ring]
    if len(sel) == 0:
        return np.zeros((0, 3), np.float32)
    q = (sel // quant * quant).astype(np.float32)
    return np.unique(q.reshape(-1, 3), axis=0)


def bg_region(im, tol=DEFAULT_TOL, band=8):
    """背景区域 = 与边框内侧种子色相近、且经"外部区域"连通到画布边缘的像素。

    为什么不用全局色彩键控：底色常是多个色阶（主色圆 + 浅色边角 + 浅色辅助线），
    而主体描边往往与底色同色系、只是更深。纯颜色阈值要么漏掉浅色阶，
    要么把描边一起抠掉。用"与外部连通"这个条件，描边因为被主体隔断、
    且色距足够大，会被完整保留为主体；主体内部即使有同色底色的细节也不会被误抠。

    返回 (bg, seeds, raw, depth)。
    """
    from scipy import ndimage as ndi
    from scipy.ndimage import binary_erosion

    raw = np.array(im.convert("RGBA")).astype(np.int16)
    rgb, opaque = raw[..., :3], raw[..., 3] > 8
    depth = rim_depth(max(im.size))
    inner = binary_erosion(opaque, iterations=depth)
    if not inner.any():                       # 设计稿太小，退化为不剥环
        inner, depth = opaque, 0
    rim = opaque & ~inner
    outside = (~opaque) | rim                 # 外部区域：画布透明区 + 外沿假色环

    seeds = bg = None
    for b in (band, band + 10, band + 25):
        seeds = _seed_colors(rgb, inner, b)
        if len(seeds) == 0:
            continue
        dmin = np.full(opaque.shape, np.inf, np.float32)
        for s in seeds:
            d = np.sqrt(((rgb - s) ** 2).sum(-1))
            np.minimum(dmin, d, out=dmin)
        ok = (dmin <= tol) & opaque & ~rim
        lab, n = ndi.label(ok | outside)
        if n:
            edge = np.concatenate([lab[0, :], lab[-1, :], lab[:, 0], lab[:, -1]])
            edge = np.unique(edge[edge > 0])
            bg = ok & np.isin(lab, edge)
        else:
            bg = np.zeros(opaque.shape, bool)
        # 背景至少要占不透明部分的 25%，否则说明种子没覆盖到主色阶，加宽取样带重试
        if bg.sum() >= 0.25 * opaque.sum():
            break
    return bg, seeds, raw, depth


def bg_color(raw, bg, quant=4):
    """自适应图标纯色底：取"被抠掉那层"里出现最多的颜色。

    不要用四角取样 —— 四角常是浅色边角，而主体实际坐在中间主色上。
    也不要盲目用中位数 —— 底色是多色阶时会落在两阶之间（糊成一坨中间色）。
    用众数最贴合主体所处的那层底色。
    """
    if not bg.any():
        return DEFAULT_BG
    sel = raw[..., :3][bg]
    q = sel // quant * quant
    vals, counts = np.unique(q.reshape(-1, 3), axis=0, return_counts=True)
    mode = vals[counts.argmax()]
    near = sel[(np.abs(sel - mode) <= quant * 2).all(axis=1)]
    return tuple(int(v) for v in np.median(near if len(near) else sel, axis=0))


def extract_subject(im, bg, depth=None, min_area=200, dilate=1, close=1, alpha_blur=0.6):
    """把背景区域与外沿假色环挖掉，得到透明底主体（用于 Android 自适应前景）。"""
    from scipy import ndimage as ndi

    raw = np.array(im.convert("RGBA"))
    opaque = raw[..., 3] > 8
    if depth is None:
        depth = rim_depth(max(im.size))
    rim = opaque & ~ndi.binary_erosion(opaque, iterations=depth) if depth else np.zeros_like(opaque)
    fg = opaque & ~bg & ~rim
    if close:
        fg = ndi.binary_closing(fg, np.ones((3, 3), bool), iterations=close)
    fg = ndi.binary_fill_holes(fg)          # 封闭边缘的 1px 发丝缝
    lab, n = ndi.label(fg)
    if n:
        sizes = ndi.sum(fg, lab, range(1, n + 1))
        fg = np.isin(lab, np.where(sizes >= min_area)[0] + 1)
    if dilate:
        # 主体边缘的抗锯齿像素颜色偏向底色，会被判成背景而吃掉 1px，回补
        fg = ndi.binary_dilation(fg, np.ones((3, 3), bool), iterations=dilate)
    fg &= opaque & ~rim
    mask = Image.fromarray(np.where(fg, 255, 0).astype(np.uint8), "L")
    if alpha_blur:
        mask = mask.filter(ImageFilter.GaussianBlur(alpha_blur))
    out = im.copy()
    out.putalpha(mask)
    return out


def resize(im, size):
    return im.resize((size, size), Image.LANCZOS)


def save_rgb(im, path):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    im.convert("RGB").save(path, "PNG", optimize=True)


def save_rgba(im, path):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    im.convert("RGBA").save(path, "PNG", optimize=True)


def fit_into_square(im, canvas, ratio=0.64):
    """内容等比缩放并居中，最长边占 canvas 的 ratio（Android 自适应安全区）。"""
    content = im.crop(im.getbbox())
    w, h = content.size
    s = canvas * ratio / max(w, h)
    content = content.resize((max(1, round(w * s)), max(1, round(h * s))), Image.LANCZOS)
    out = Image.new("RGBA", (canvas, canvas), (0, 0, 0, 0))
    out.paste(content, ((canvas - content.width) // 2, (canvas - content.height) // 2), content)
    return out


def hex_of(rgb):
    return "#%02X%02X%02X" % tuple(rgb[:3])


# ---------------------------------------------------------------- 各平台导出
def export_android(out, square, subject, bg):
    for dpi, px in {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}.items():
        save_rgb(resize(square, px), os.path.join(out, "android", f"mipmap-{dpi}", "ic_launcher.png"))
    for dpi, px in {"mdpi": 108, "hdpi": 162, "xhdpi": 216, "xxhdpi": 324, "xxxhdpi": 432}.items():
        save_rgba(fit_into_square(subject, px), os.path.join(out, "android", f"mipmap-{dpi}", "ic_launcher_foreground.png"))
    vd = os.path.join(out, "android", "values")
    os.makedirs(vd, exist_ok=True)
    with open(os.path.join(vd, "ic_launcher_background.xml"), "w", encoding="utf-8") as f:
        f.write('<?xml version="1.0" encoding="utf-8"?>\n<resources>\n'
                f'    <color name="ic_launcher_background">{hex_of(bg)}</color>\n</resources>\n')
    ad = os.path.join(out, "android", "mipmap-anydpi-v26")
    os.makedirs(ad, exist_ok=True)
    with open(os.path.join(ad, "ic_launcher.xml"), "w", encoding="utf-8") as f:
        f.write('<?xml version="1.0" encoding="utf-8"?>\n'
                '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
                '    <background android:drawable="@color/ic_launcher_background" />\n'
                '    <foreground android:drawable="@mipmap/ic_launcher_foreground" />\n'
                '</adaptive-icon>\n')


IOS_ITEMS = [("Icon-App-20x20@1x.png", 20), ("Icon-App-20x20@2x.png", 40), ("Icon-App-20x20@3x.png", 60),
             ("Icon-App-29x29@1x.png", 29), ("Icon-App-29x29@2x.png", 58), ("Icon-App-29x29@3x.png", 87),
             ("Icon-App-40x40@1x.png", 40), ("Icon-App-40x40@2x.png", 80), ("Icon-App-40x40@3x.png", 120),
             ("Icon-App-60x60@2x.png", 120), ("Icon-App-60x60@3x.png", 180),
             ("Icon-App-76x76@1x.png", 76), ("Icon-App-76x76@2x.png", 152),
             ("Icon-App-83.5x83.5@2x.png", 167), ("Icon-App-1024x1024@1x.png", 1024)]


def export_ios(out, square, project=None):
    d = os.path.join(out, "ios", "AppIcon.appiconset")
    for name, px in IOS_ITEMS:
        save_rgb(resize(square, px), os.path.join(d, name))
    # 若工程里已有 Contents.json 就沿用，避免尺寸定义不一致
    if project:
        cs = os.path.join(project, "ios", "Runner", "Assets.xcassets", "AppIcon.appiconset", "Contents.json")
        if os.path.exists(cs):
            shutil.copy2(cs, os.path.join(d, "Contents.json"))


def export_web(out, square):
    for px in (192, 512):
        save_rgb(resize(square, px), os.path.join(out, "web", f"Icon-{px}.png"))
        save_rgb(resize(square, px), os.path.join(out, "web", f"Icon-maskable-{px}.png"))
    save_rgb(resize(square, 48), os.path.join(out, "web", "favicon.png"))


def export_desktop(out, rounded):
    for px in (16, 32, 64, 128, 256, 512, 1024):
        save_rgba(resize(rounded, px), os.path.join(out, "macos", f"app_icon_{px}.png"))
    os.makedirs(os.path.join(out, "windows"), exist_ok=True)
    rounded.save(os.path.join(out, "windows", "app_icon.ico"), format="ICO",
                 sizes=[(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)])


def export_adaptive_preview(out, subject, bg):
    """把自适应前景叠到纯色底上、套圆形遮罩，按多档尺寸渲染。

    自适应图标最容易翻车的地方是"内容被圆形遮罩裁掉"，光看 PNG 是看不出来的，
    必须按实际遮罩裁剪后才能肉眼验收。
    """
    sizes = (192, 144, 96, 72, 48, 32)
    W, H = 60 + sum(s + 22 for s in sizes), 300
    p = Image.new("RGB", (W, H), (247, 247, 249))
    dr = ImageDraw.Draw(p)
    try:
        from PIL import ImageFont
        f = ImageFont.truetype(r"C:\Windows\Fonts\msyh.ttc", 14)
    except Exception:
        f = None
    dr.text((24, 16), "Android 自适应图标 · 圆形遮罩下的实际观感（内容应完整不裁切）", fill=(32, 34, 38), font=f)

    base, x = 230, 30
    for px in sizes:
        layer = Image.new("RGBA", (px, px), tuple(bg) + (255,))
        layer.alpha_composite(fit_into_square(subject, px))
        m = Image.new("L", (px * 4, px * 4), 0)
        ImageDraw.Draw(m).ellipse((0, 0, px * 4 - 1, px * 4 - 1), fill=255)
        layer.putalpha(m.resize((px, px), Image.LANCZOS))
        p.paste(layer, (x, base - px), layer)
        tw = dr.textlength(str(px), font=f)
        dr.text((x + (px - tw) / 2, base + 8), str(px), fill=(122, 126, 134), font=f)
        x += px + 22
    p.save(os.path.join(out, "android", "adaptive_preview.png"))


def export_preview(out, square, rounded, subject):
    W, H = 1020, 780
    bgc, fg, sub = (247, 247, 249), (32, 34, 38), (122, 126, 134)
    try:
        from PIL import ImageFont
        f_title = ImageFont.truetype(r"C:\Windows\Fonts\msyhbd.ttc", 24)
        f_body = ImageFont.truetype(r"C:\Windows\Fonts\msyh.ttc", 16)
        f_small = ImageFont.truetype(r"C:\Windows\Fonts\msyh.ttc", 14)
    except Exception:
        f_title = f_body = f_small = None

    p = Image.new("RGB", (W, H), bgc)
    dr = ImageDraw.Draw(p)

    def checker(x, y, size, step=10):
        for i in range(0, size, step):
            for j in range(0, size, step):
                c = (232, 232, 236) if ((i // step + j // step) % 2 == 0) else (250, 250, 252)
                dr.rectangle([x + i, y + j, x + min(i + step, size) - 1, y + min(j + step, size) - 1], fill=c)

    dr.text((36, 26), "App Icon 预览", fill=fg, font=f_title)
    dr.text((36, 60), "设计稿 → 各平台图标套件", fill=sub, font=f_body)

    box, y0 = 224, 108
    dr.text((36, y0), "① 母版（1024）", fill=fg, font=f_body)
    yy = y0 + 34
    dr.text((36, yy + box + 10), "满幅方形 · 不透明", fill=fg, font=f_small)
    dr.text((36, yy + box + 30), "iOS / Android / 商店", fill=sub, font=f_small)
    p.paste(resize(square, box), (36, yy))
    dr.rectangle([36, yy, 36 + box - 1, yy + box - 1], outline=(210, 210, 216))
    x2 = 300
    dr.text((x2, yy + box + 10), "保留圆角 · 带透明", fill=fg, font=f_small)
    dr.text((x2, yy + box + 30), "macOS / Windows（系统不裁切）", fill=sub, font=f_small)
    checker(x2, yy, box)
    p.paste(resize(rounded, box), (x2, yy), resize(rounded, box))
    x3 = 600
    dr.text((x3, y0), "② 抠出主体（自适应前景 · Android）", fill=fg, font=f_body)
    checker(x3, yy, box)
    fgimg = resize(fit_into_square(subject, 1024), box)
    p.paste(fgimg, (x3, yy), fgimg)
    dr.text((x3, yy + box + 10), "透明底 · 已缩进安全区", fill=fg, font=f_small)
    dr.text((x3, yy + box + 30), "配纯色底 = 圆形遮罩下不丢内容", fill=sub, font=f_small)

    y3 = yy + box + 84
    dr.text((36, y3), "③ 实际尺寸下的辨识度", fill=fg, font=f_body)
    baseline, x = y3 + 190, 36
    for size in (192, 144, 96, 72, 48, 32, 24, 16):
        img = resize(square, size)
        p.paste(img, (x, baseline - size))
        dr.rectangle([x, baseline - size, x + size - 1, baseline - 1], outline=(214, 214, 220))
        tw = dr.textlength(str(size), font=f_small)
        dr.text((x + max(0, (size - tw) / 2), baseline + 8), str(size), fill=sub, font=f_small)
        x += size + 26
    dr.text((36, baseline + 36), "16 / 24 / 32px 时细节装饰会糊掉；如需极致清晰可另做一版简化图。",
            fill=sub, font=f_small)
    p.save(os.path.join(out, "preview.png"))


# ---------------------------------------------------------------- 安装进工程
def install(out, project):
    bak = os.path.join(out, "_original_backup")
    jobs = []
    for dpi in ("mdpi", "hdpi", "xhdpi", "xxhdpi", "xxxhdpi"):
        s_dir = os.path.join(out, "android", f"mipmap-{dpi}")
        d_dir = os.path.join(project, "android", "app", "src", "main", "res", f"mipmap-{dpi}")
        for name in ("ic_launcher.png", "ic_launcher_foreground.png"):
            jobs.append((os.path.join(s_dir, name), os.path.join(d_dir, name)))
    jobs += [
        (os.path.join(out, "android", "mipmap-anydpi-v26", "ic_launcher.xml"),
         os.path.join(project, "android", "app", "src", "main", "res", "mipmap-anydpi-v26", "ic_launcher.xml")),
        (os.path.join(out, "android", "values", "ic_launcher_background.xml"),
         os.path.join(project, "android", "app", "src", "main", "res", "values", "ic_launcher_background.xml")),
    ]
    for sub, rel in (("ios/AppIcon.appiconset", r"ios\Runner\Assets.xcassets\AppIcon.appiconset"),
                     ("macos", r"macos\Runner\Assets.xcassets\AppIcon.appiconset"),
                     ("web", r"web\icons")):
        s_dir = os.path.join(out, *sub.split("/"))
        if os.path.isdir(s_dir):
            for f in os.listdir(s_dir):
                if sub.startswith("web") or f.lower().endswith((".png", ".jpg")):
                    jobs.append((os.path.join(s_dir, f), os.path.join(project, rel, f)))
    jobs += [
        (os.path.join(out, "web", "favicon.png"), os.path.join(project, "web", "favicon.png")),
        (os.path.join(out, "windows", "app_icon.ico"), os.path.join(project, "windows", "runner", "resources", "app_icon.ico")),
    ]

    done = skipped = 0
    for s, d in jobs:
        if not os.path.exists(s):
            skipped += 1
            continue
        if os.path.exists(d):
            b = os.path.join(bak, os.path.relpath(d, project))
            if not os.path.exists(b):
                # 备份只在首次生成：重复安装时不能把"已换成新图标"的文件当原件再备份一遍
                os.makedirs(os.path.dirname(b), exist_ok=True)
                shutil.copy2(d, b)
        os.makedirs(os.path.dirname(d), exist_ok=True)
        shutil.copy2(s, d)
        done += 1
    print(f"已安装 {done} 个文件（跳过 {skipped}），原文件备份在 {os.path.join(out, '_original_backup')}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", required=True, help="设计稿路径（PNG/JPG，正方形最佳，非正方形会自动补边）")
    ap.add_argument("--out", default="icon", help="产物目录，默认 ./icon")
    ap.add_argument("--project", default=None, help="工程根目录（配合 --install 使用）")
    ap.add_argument("--install", action="store_true", help="把产物覆盖到各平台目录（会先备份）")
    ap.add_argument("--bg", default=None, help="自适应图标背景色，#RRGGBB；默认自动检测")
    ap.add_argument("--tol", type=float, default=DEFAULT_TOL, help="背景色距阈值，默认 32")
    ap.add_argument("--min-area", type=int, default=200, help="抠图时丢弃的碎屑面积阈值")
    args = ap.parse_args()

    out = os.path.abspath(args.out)
    os.makedirs(out, exist_ok=True)

    src_im = Image.open(args.src)
    padded = pad_to_square(args.src)

    bg, seeds, raw, depth = bg_region(padded, tol=args.tol)
    subject = extract_subject(padded, bg, depth=depth, min_area=args.min_area)
    square = fill_transparent(padded)
    rounded = padded
    bgc = tuple(int(args.bg.lstrip("#")[i:i + 2], 16) for i in (0, 2, 4)) if args.bg else bg_color(raw, bg)

    save_rgb(resize(square, 1024), os.path.join(out, "master", "icon-1024.png"))
    save_rgba(resize(rounded, 1024), os.path.join(out, "master", "icon-1024-rounded.png"))
    save_rgba(resize(subject, 1024), os.path.join(out, "master", "icon-figure-transparent.png"))

    export_android(out, square, subject, bgc)
    export_ios(out, square, args.project)
    export_web(out, square)
    export_desktop(out, rounded)
    export_preview(out, square, rounded, subject)
    export_adaptive_preview(out, subject, bgc)

    op = raw[..., 3] > 8
    sbb = subject.getbbox()
    print("源图:", src_im.size, "| 补边后:", padded.size, "| 外沿剥环:", depth, "px | 种子色 %d 个" % len(seeds))
    print("背景占不透明面积: %.1f%% | 自适应背景色: %s" % (100 * bg.sum() / op.sum(), hex_of(bgc)))
    print("主体 bbox:", sbb, "-> 占幅 %.0f%% x %.0f%%" % (
        100 * (sbb[2] - sbb[0]) / padded.width, 100 * (sbb[3] - sbb[1]) / padded.height))
    print("补角后四角色:", np.array(square)[3, 3][:3])
    print("产物目录:", out)

    if args.install:
        if not args.project:
            sys.exit("--install 需要同时指定 --project")
        install(out, os.path.abspath(args.project))


if __name__ == "__main__":
    main()
