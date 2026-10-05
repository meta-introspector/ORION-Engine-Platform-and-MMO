"""Decode the GIF written by test_core.mjs with Pillow and compare every pixel."""
import json
from PIL import Image, ImageSequence

pal = [(round((i >> 5) * 255 / 7), round(((i >> 2) & 7) * 255 / 7), round((i & 3) * 255 / 3)) for i in range(256)]
im = Image.open('/tmp/orion-test.gif')
frames = json.load(open('/tmp/orion-test-frames.json'))
n = 0
for i, f in enumerate(ImageSequence.Iterator(im)):
    assert list(f.convert('RGB').get_flattened_data()) == [pal[x] for x in frames[i]], f'frame {i} differs'
    n += 1
assert n == len(frames)
print(f'GIF decoded by Pillow: {n} frames match pixel for pixel')
