import os, glob
import numpy as np
from PIL import Image

src = r"D:\work\photo-assistant\image"
files = sorted(glob.glob(os.path.join(src, "*.png")))
print(f"共 {len(files)} 张\n")
for f in files:
    name = os.path.basename(f)
    img = np.array(Image.open(f).convert("RGB"))
    h, w = img.shape[:2]
    R, G, B = img[:,:,0].astype(int), img[:,:,1].astype(int), img[:,:,2].astype(int)
    mx = np.maximum(np.maximum(R,G), B).astype(float)
    mn = np.minimum(np.minimum(R,G), B).astype(float)
    bright = mx
    sat = (mx - mn) / np.maximum(mx, 1)
    # 背景：很亮
    bg = bright > 235
    # 彩色（字幕框/水印logo）：饱和度高
    colored = sat > 0.30
    # 线稿候选：偏暗且中性（灰）
    lineart = (bright < 190) & (sat < 0.22)
    # 角落背景色
    corners = [img[5,5], img[5,w-5], img[h-5,5], img[h-5,w-5]]
    corner_avg = np.mean(corners, axis=0).astype(int)
    # 彩色像素包围盒
    if colored.sum() > 0:
        ys, xs = np.where(colored)
        cb = f"x[{xs.min()}-{xs.max()}] y[{ys.min()}-{ys.max()}]"
    else:
        cb = "无彩色"
    # 检测文字条：在某水平带里，lineart 像素密集（可能是字幕黑字）
    # 计算每行 lineart 密度
    row_density = lineart.sum(axis=1)
    # 字幕通常在图的上/下 25% 区域，且形成窄带
    print(f"{name:32s} {w}x{h}  bg={bg.mean()*100:5.1f}%  colored={colored.mean()*100:4.1f}%  line={lineart.mean()*100:4.1f}%  角={corner_avg.tolist()}  {cb}")
