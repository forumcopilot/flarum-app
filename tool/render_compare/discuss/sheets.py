"""Pairs each sample's app render with the web's: one row per sample (label, app, web), both at
412 CSS pixels wide, cut at a height limit. Writes sheet_NN.png files of a few rows each, for
looking at, and pair_<name>.png for each sample."""
import json, os, sys
from PIL import Image, ImageDraw

R = os.path.dirname(os.path.abspath(__file__))
APP = os.path.normpath(os.path.join(R, '../../../packages/flarum_ui/build/render'))
names = list(json.load(open(f'{R}/web_samples.json')).keys())
only = set(sys.argv[1:])
W, CUT, GAP = 412, 1100, 12
os.makedirs(f'{R}/sheets', exist_ok=True)


def load(path):
    if not os.path.exists(path):
        im = Image.new('RGB', (W, 60), (255, 230, 230))
        ImageDraw.Draw(im).text((8, 20), 'missing', fill=(160, 0, 0))
        return im
    im = Image.open(path).convert('RGB')
    im = im.resize((W, max(1, int(im.size[1] * W / im.size[0]))), Image.LANCZOS)
    if im.size[1] > CUT:
        im = im.crop((0, 0, W, CUT))
        ImageDraw.Draw(im).rectangle((0, CUT - 6, W, CUT), fill=(255, 0, 255))
    return im


pairs = []
for name in names:
    if only and name not in only:
        continue
    app = load(f'{APP}/app_discuss_{name}.png')
    web = load(f'{R}/out/web_{name}.png')
    h = max(app.size[1], web.size[1]) + 24
    row = Image.new('RGB', (W * 2 + GAP, h), (255, 255, 255))
    d = ImageDraw.Draw(row)
    d.text((4, 4), f'{name}  app', fill=(0, 0, 200))
    d.text((W + GAP + 4, 4), 'web', fill=(0, 120, 0))
    row.paste(app, (0, 22))
    row.paste(web, (W + GAP, 22))
    d.line((W + GAP // 2, 0, W + GAP // 2, h), fill=(180, 180, 180), width=2)
    row.save(f'{R}/sheets/pair_{name}.png')
    pairs.append(row)

sheet, n, h = [], 0, 0
for row in pairs + [None]:
    if row is None or (sheet and h + row.size[1] > 2600):
        if sheet:
            im = Image.new('RGB', (W * 2 + GAP, h), (120, 120, 120))
            y = 0
            for r in sheet:
                im.paste(r, (0, y))
                y += r.size[1] + 6
            im.save(f'{R}/sheets/sheet_{n:02d}.png')
            n += 1
        sheet, h = [], 0
    if row is not None:
        sheet.append(row)
        h += row.size[1] + 6
print(n, 'sheets,', len(pairs), 'pairs')
