#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""把实机截图等比缩放到 App Store 要求的尺寸。

用法：
    python scripts/resize_store_screenshots.py <源目录> [输出目录]

默认输出：
    <输出目录>/6.7/  1290 x 2796  (iPhone 15/14 Pro Max，App Store 主提交尺寸)
    <输出目录>/6.5/  1242 x 2688  (iPhone 11 Pro Max 等；上传 6.7" 后也可在后台勾选复用)

算法：cover（等比放大到铺满目标 + 中心裁切），保证不变形、不留黑边。
因为手机截屏与 App Store 尺寸宽高比几乎一致（≈0.462），裁切通常仅 0-2 px。
"""
import os
import sys
from PIL import Image

TARGETS = {
    "6.7": (1290, 2796),
    "6.5": (1242, 2688),
}
EXTS = (".png", ".jpg", ".jpeg", ".webp")
RESAMPLE = Image.LANCZOS


def process(src_dir: str, out_dir: str) -> None:
    files = sorted(
        f for f in os.listdir(src_dir) if f.lower().endswith(EXTS)
    )
    if not files:
        print(f"[!] {src_dir} 里没找到图片")
        return

    for sub, (tw, th) in TARGETS.items():
        dst = os.path.join(out_dir, sub)
        os.makedirs(dst, exist_ok=True)
        for i, f in enumerate(files, start=1):
            im = Image.open(os.path.join(src_dir, f)).convert("RGB")
            w, h = im.size
            scale = max(tw / w, th / h)  # cover
            nw, nh = int(round(w * scale)), int(round(h * scale))
            im = im.resize((nw, nh), RESAMPLE)
            left, top = (nw - tw) // 2, (nh - th) // 2
            im = im.crop((left, top, left + tw, top + th))
            out = os.path.join(dst, f"{i:02d}.png")
            im.save(out, "PNG")
            print(f"  {f}  {w}x{h}  ->  {out}  {im.size}  (crop x={left} y={top})")


def main() -> None:
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    src = sys.argv[1]
    out = sys.argv[2] if len(sys.argv) > 2 else os.path.join(
        os.path.dirname(os.path.abspath(src)) or ".", "real"
    )
    print(f"source : {src}")
    print(f"output : {out}")
    process(src, out)
    print("DONE")


if __name__ == "__main__":
    main()
