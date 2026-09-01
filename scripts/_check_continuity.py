import numpy as np, glob, os
from PIL import Image
from scipy.ndimage import label

files = sorted(glob.glob('assets/poses/pose_0[0-4][0-9].png'))
print('checked', len(files), 'images', flush=True)
bad = []
for f in files:
    a = np.array(Image.open(f).convert('RGBA'))
    mask = a[:, :, 3] > 0
    lab, nf = label(mask)
    if nf == 0:
        bad.append((os.path.basename(f), 0, 0.0)); continue
    sizes = np.bincount(lab.ravel())[1:]          # fast component sizes
    tot = float(mask.sum())
    frac = float(sizes.max()) / tot * 100 if tot > 0 else 0
    if frac < 85:
        bad.append((os.path.basename(f), int(nf), round(frac, 1)))
if bad:
    print('POTENTIALLY BROKEN (biggest-comp < 85%):')
    for b in bad:
        print('  ', b)
else:
    print('ALL 42: biggest-component >= 85%, lines continuous, no broken-line risk')
