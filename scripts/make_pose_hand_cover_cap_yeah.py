#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
把"素描-一手遮帽向前比耶.png"做成可叠加在相机预览上的透明 PNG。

目标文件:
  输入: C:\\Users\\81215\\WorkBuddy\\2026-08-27-23-38-23\\素描姿势图\\002_一手遮帽向前比耶.png
  输出: D:\\work\\photo-assistant\\assets\\poses\\pose_hand_cover_cap_yeah.png

处理策略（按像素颜色分类）:
  1) 近白（R,G,B 都 > 200）        -> 透明（白底 + 抖音浅灰水印）
  2) 黄色高亮（R-G>15 且 G-B>25）   -> 透明（4 处中文文字的黄色底色）
  3) 把黄色蒙版膨胀 12 像素          -> 吃掉深色中文文字本身
  4) 剩余（深灰线条、粉色腮红）      -> 不透明
"""
from PIL import Image
import numpy as np
from scipy.ndimage import binary_dilation


INPUT_PATH = r"C:\Users\81215\WorkBuddy\2026-08-27-23-38-23\素描姿势图\002_一手遮帽向前比耶.png"
OUTPUT_PATH = r"D:\work\photo-assistant\assets\poses\pose_hand_cover_cap_yeah.png"
PREVIEW_PATH = r"D:\work\photo-assistant\assets\poses\pose_hand_cover_cap_yeah_preview.png"


def main() -> None:
    img = Image.open(INPUT_PATH).convert("RGB")
    arr = np.array(img)
    h, w = arr.shape[:2]
    R = arr[:, :, 0].astype(np.int16)
    G = arr[:, :, 1].astype(np.int16)
    B = arr[:, :, 2].astype(np.int16)

    # 1) 近白（含白底 + 抖音浅灰水印 + 小柠檬灰色水印）
    is_near_white = (R > 200) & (G > 200) & (B > 200)

    # 2) 黄色高亮：黄底颜色 ≈ RGB(245,247,200)，特征是 min(R,G) 都 > 200、
    #    B 显著低于 R/G（G-B ≈ 30~52）。
    #    粉色腮红 R 高、G≈B 低（G-B 接近 0），不会被命中。
    is_yellow = (
        (np.minimum(R, G) > 200)
        & ((G - B) > 20)
        & ((R - B) > 15)
    )

    yellow_pixels = int(is_yellow.sum())
    print(f"[info] 黄色高亮像素数: {yellow_pixels} ({yellow_pixels / (h*w) / 100:.2f}%)")

    # 3) 膨胀 8 像素（够吃掉 2~3px 宽的文字笔画，不侵蚀下方线稿）
    if yellow_pixels > 0:
        is_yellow_dilated = binary_dilation(is_yellow, iterations=8)
    else:
        is_yellow_dilated = is_yellow

    # 3b) 强制清空顶部 130 行：覆盖"抖音 logo + 抖音号: BYN20180823 +
    #     小柠檬"以及右上角放大镜。人物线稿从 y≈200 起，安全。
    force_clear_top = np.zeros((h, w), dtype=bool)
    force_clear_top[:130, :] = True

    # 4) 综合背景蒙版
    is_bg = is_near_white | is_yellow_dilated | force_clear_top

    # 5) 输出 RGBA
    out = np.zeros((h, w, 4), dtype=np.uint8)
    out[:, :, :3] = arr
    out[:, :, 3] = np.where(is_bg, 0, 255)

    Image.fromarray(out, "RGBA").save(OUTPUT_PATH)

    total = h * w
    print(f"[info] 原图: {w}x{h}")
    print(f"[info] 透明像素: {int(is_bg.sum())} ({is_bg.sum()/total*100:.1f}%)")
    print(f"[info] 不透明像素: {int((~is_bg).sum())} ({(~is_bg).sum()/total*100:.1f}%)")
    print(f"[ok] 透明 PNG: {OUTPUT_PATH}")

    # 6) 预览图：叠在深色背景上，肉眼检查有没有漏
    bg = np.full((h, w, 3), 32, dtype=np.uint8)
    alpha = out[:, :, 3:4].astype(np.float32) / 255.0
    preview_rgb = (arr.astype(np.float32) * alpha + bg.astype(np.float32) * (1 - alpha)).astype(np.uint8)
    Image.fromarray(preview_rgb, "RGB").save(PREVIEW_PATH)
    print(f"[ok] 预览图: {PREVIEW_PATH}")


if __name__ == "__main__":
    main()