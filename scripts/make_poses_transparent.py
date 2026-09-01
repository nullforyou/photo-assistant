import os, glob, re
import numpy as np
from PIL import Image
from scipy.ndimage import binary_dilation, label, find_objects, mean as ndi_mean

SRC = r"D:\work\photo-assistant\image"
DST = r"D:\work\photo-assistant\assets\poses"
os.makedirs(DST, exist_ok=True)

# Watermark / 小连通域清除参数
SMALL_COMP_THRESHOLD = 25000   # 像素数 < 此值的连通域被视为水印/小噪点
TOP_ROW_RATIO = 0.10           # 顶部此比例以内的区域
LEFT_COL_RATIO = 0.35          # 左侧此比例以内的区域
BOTTOM_ROW_RATIO = 0.78        # 底部此比例以下的区域
PALE_DILATE_ITER = 14          # 浅色字幕框的膨胀（吃掉框内深色文字）
# 背景浅色噪点：单连通域平均亮度 > 此值 且 像素数 < 此值 -> 视为 AI 背景杂色
NOISE_MEAN_BRIGHT = 200
NOISE_MAX_AREA = 80000


def process(path, out_path, preview_path):
    img = Image.open(path).convert("RGB")
    arr = np.array(img)
    h, w = arr.shape[:2]
    R = arr[:, :, 0].astype(np.int32)
    G = arr[:, :, 1].astype(np.int32)
    B = arr[:, :, 2].astype(np.int32)
    bright = np.maximum(np.maximum(R, G), B)
    mn = np.minimum(np.minimum(R, G), B).astype(np.float32)
    sat = (bright - mn) / np.maximum(bright, 1)

    alpha = np.full((h, w), 255, dtype=np.uint8)

    # 1) 浅色字幕框 / 水印底色：亮度高 且 B 明显低于 R 或 G（淡黄/淡绿等）。
    #    灰线稿 R≈G≈B 不会被命中；纯白 R=B=255 也不会（差值=0）。
    pale_colored = (bright > 150) & (((R - B) > 10) | ((G - B) > 10))
    pale_px = int(pale_colored.sum())
    if pale_px > 0:
        pale_dilated = binary_dilation(pale_colored, iterations=PALE_DILATE_ITER)
        alpha[pale_dilated] = 0
        print(f"  [pale] {pale_px} px ({pale_px / (h*w) * 100:.2f}%) -> 透明")

    # 2) 白底（仅去除纯白及极近白像素，保留线稿的抗锯齿灰边）
    is_white = bright > 248
    alpha[is_white] = 0
    print(f"  [white] {int(is_white.sum())} px ({is_white.mean()*100:.2f}%) -> 透明")

    # 3) 基于连通域的角落水印清除（豆包底/抖音顶） + 背景浅色噪点清除
    opaque = alpha > 0
    if opaque.sum() > 0:
        labeled, n_features = label(opaque)
        slices = find_objects(labeled)
        # 计算每个连通域的平均亮度，用于识别"很亮"的背景噪点
        if n_features > 0:
            mean_brights = ndi_mean(bright, labeled, index=np.arange(1, n_features + 1))
        else:
            mean_brights = []
        removed_wm = 0
        removed_noise = 0
        for i, sl in enumerate(slices, start=1):
            if sl is None:
                continue
            ys, xs = sl
            y0, y1 = ys.start, ys.stop
            x0, x1 = xs.start, xs.stop
            comp_size = int((labeled[sl] == i).sum())
            in_topleft = (y1 < h * TOP_ROW_RATIO) and (x0 < w * LEFT_COL_RATIO)
            in_bottom = (y0 > h * BOTTOM_ROW_RATIO)
            is_small = comp_size < SMALL_COMP_THRESHOLD
            mb = float(mean_brights[i - 1]) if i - 1 < len(mean_brights) else 0.0

            if is_small and (in_topleft or in_bottom):
                # 角落小连通域 = 水印
                alpha[labeled == i] = 0
                removed_wm += 1
            elif mb > NOISE_MEAN_BRIGHT and comp_size < NOISE_MAX_AREA:
                # 平均很亮的小/中连通域 = 背景 AI 杂色噪点（线稿核心是暗色，不会被命中）
                alpha[labeled == i] = 0
                removed_noise += 1
        print(f"  [wm  ] 角落水印 {removed_wm} 个  [noise] 浅色背景噪点 {removed_noise} 个")

    # 写出透明 PNG
    rgba = np.dstack([arr, alpha])
    Image.fromarray(rgba, "RGBA").save(out_path, optimize=True)
    # 预览：叠在深色背景上方便肉眼检查
    bg = np.zeros((h, w, 3), dtype=np.uint8)
    bg[:] = (20, 20, 28)
    a = alpha[:, :, None].astype(np.float32) / 255.0
    preview = (arr.astype(np.float32) * a + bg.astype(np.float32) * (1 - a)).astype(np.uint8)
    Image.fromarray(preview).save(preview_path, optimize=True)

    keep = float((alpha > 0).mean() * 100)
    trans = float((alpha == 0).mean() * 100)
    print(f"  -> 输出 {out_path}  保留 {keep:.1f}% / 透明 {trans:.1f}%")


files = sorted(glob.glob(os.path.join(SRC, "*.png")))
print(f"共 {len(files)} 张待处理\n" + "=" * 60)
for path in files:
    name = os.path.basename(path)
    m = re.match(r"(\d{3})_(.+)\.png", name)
    if not m:
        print(f"[skip] {name}")
        continue
    num = m.group(1)
    pose_name = m.group(2)
    out = os.path.join(DST, f"pose_{num}.png")
    prev = os.path.join(DST, f"pose_{num}_preview.png")
    print(f"\n[{num}] {pose_name}")
    process(path, out, prev)

print("\n" + "=" * 60 + "\n全部完成。")
