"""Parse every SVG dumped by `node test/run.mjs <dir>` as XML.

usage: python3 test/wellformed.py <dir>
"""
import pathlib
import sys
import xml.etree.ElementTree as ET

d = pathlib.Path(sys.argv[1])
files = sorted(d.glob("*.svg"))
bad = 0
for f in files:
    try:
        root = ET.fromstring(f.read_text(encoding="utf-8"))
        if not root.tag.endswith("svg"):
            raise ValueError("root is not <svg>")
    except Exception as e:  # noqa: BLE001 - report every failure
        bad += 1
        print("NOT WELL-FORMED", f.name, e)
print(f"{len(files) - bad}/{len(files)} well-formed")
sys.exit(1 if bad or not files else 0)
