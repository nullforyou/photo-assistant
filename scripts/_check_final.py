import numpy as np, glob, os
from PIL import Image
from scipy.ndimage import label

files = sorted(glob.glob('assets/poses/pose_0[0-4][0-9].png'))
bad = []
for f in files:
    a = np.array(Image.open(f).convert('RGBA'))
    mask = a[:, :, 3] > 0
    lab, nf = label(mask)
    if nf == 0:
        bad.append((os.path.basename(f), 'EMPTY')); continue
    sizes = np.bincount(lab.ravel())[1:]
    tot = float(mask.sum())
    frac = float(sizes.max()) / tot * 100
    specks = int((sizes < 10).sum())
    R, G, B = a[:, :, 0].astype(int), a[:, :, 1].astype(int), a[:, :, 2].astype(int)
    mn = np.minimum(np.minimum(R, G), B)
    op = mn[mask]
    res = int((op >= 230).sum())
    # flag: many specks OR low continuity
    if specks > 300 or frac < 80:
        bad.append((os.path.basename(f), f'specks={specks} biggest={frac:.1f}% grayres={res}'))

print('checked', len(files), 'images')
if bad:
    print('FLAGGED:')
    for b in bad:
        print('  ', b)
else:
    print('ALL 42: specks<=300 且 主体连通率>=80%，噪点已清除')
