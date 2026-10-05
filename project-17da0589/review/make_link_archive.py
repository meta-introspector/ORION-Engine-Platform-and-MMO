"""Build ORION_LINK_ARCHIVE.md: every link shared on the ORION pages, kept even if it can no longer be opened.

Sources: every Markdown/text file in this project (page copies, replies, notes) plus the
links listed in the original request. Usage: python3 review/make_link_archive.py
"""
import os, re, collections

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ORIGINAL_REQUEST = """
https://docs.google.com/document/d/1RMRxorwCsE5SVtqT-nyoCquaeEJRjghKbS904vDjWLM/edit?usp=drivesdk
https://docs.google.com/document/d/1OkmZq05T-Yllk3Ptx7XsuyDDPNjabnqL--rleLtMQss/edit?usp=drivesdk
https://docs.google.com/document/d/1Qh-Zwu22k3RAQc1jrHvaebSjHwLcA3w9jXEydpZS22Q/edit?usp=drivesdk
https://docs.google.com/document/d/1w9bVr2SZ_tKwaDSWpp5aR4slRo8dBDQvllHEvp5y3YE/edit?usp=drivesdk
https://docs.google.com/document/d/1AmcVE16RKPk2AIN_-XTeHBQvvATW40ldDECCAmUv9NU/edit?usp=drivesdk
https://www.tgsate.com/cosmic-sandbox-master-summary/cst-volume-iii-theoretical-philosophical-proofs/cuneiform-mechanics-a-dual-paradigm-analysis
https://www.tgsate.com/cosmic-sandbox-master-summary/cst-volume-iii-theoretical-philosophical-proofs/cuneiform-mechanics-a-dual-paradigm-analysis/cuneiform-the-toroidal-temporal-translator
https://www.tgsate.com/cosmic-sandbox-master-summary/cst-volume-iii-theoretical-philosophical-proofs/cuneiform-mechanics-a-dual-paradigm-analysis/the-avian-key
https://www.tgsate.com/cosmic-sandbox-master-summary/cst-volume-iii-theoretical-philosophical-proofs/cuneiform-mechanics-a-dual-paradigm-analysis/the-languanauts-manifesto
https://www.tgsate.com/cosmic-sandbox-master-summary/cst-volume-iii-theoretical-philosophical-proofs/cuneiform-mechanics-a-dual-paradigm-analysis/the-languanauts-myth-to-mechanics
https://www.tgsate.com/cosmic-sandbox-master-summary/cst-volume-iii-theoretical-philosophical-proofs/cuneiform-mechanics-a-dual-paradigm-analysis/linguistic-topology-and-the-mechanics-of-the-universal-engine
https://tgsate.blogspot.com/2025/08/our-tower-of-babel.html
https://tgsate.blogspot.com/2025/09/beyond-apocalypse-co-creating-harmony.html
https://tgsate.blogspot.com/2025/10/from-punishment-to-purpose-reimagining.html
https://tgsate.blogspot.com/2025/10/in-beginning-deeper-look-at-creation.html
https://tgsate.blogspot.com/2025/10/the-illusion-of-separation-embracing.html
https://tgsate.blogspot.com/2025/10/the-symphony-of-connection-unifying.html
https://tgsate.blogspot.com/2026/01/revelation-reimagined-grand-awakening.html
https://app.notion.com/p/ORION-R9-Live-3ef5aabf6a118094ada7eec4bd31e9b6?source=copy_link
https://app.notion.com/p/ORION-R10-3ef5aabf6a118081afd9c90d1322d3bc?source=copy_link
"""
# Notion pages that no longer open for someone without access (checked 2026-10-04).
NOTION_LOCKED = {"3ee5aabf6a118094b252f9172b3ac1fa": "ORION R7💎",
                 "3ee5aabf6a1180a6859cf8c4c0cb1f8a": "ORION Engine SoB R6",
                 "3ee5aabf6a1180d9a1c4f16dae097772": "CONCEPT GALLERY",
                 "3ee5aabf6a1180439321e0e133178eea": "ORION R6 LIVE",
                 "3ee5aabf6a1180d59cfefab11f6492f5": "ORION Round 4",
                 "3ee5aabf6a1180cb961dfb8a9063686f": "ORION R5 Ryan's Links"}
URL = re.compile(r'https?://[^\s)\]>"`\'*|]+')
SKIP = ('file.notion.so', 'prod-files', 'amazonaws.com', 'favicon', 'fbcdn.net', 'localhost', '127.0.0.1',
        'example.com', 'example.org', 'aristotle.harmonic.fun')

def clean(u):
    return u.rstrip('.,;:!?')

def category(u):
    h = re.sub(r'^https?://', '', u).split('/')[0].lower()
    for key, name in [('notion', 'Notion pages'), ('docs.google', 'Google Docs'), ('tgsate', 'TGSATE site and blog'),
                      ('github', 'GitHub'), ('x.com', 'X posts'), ('twitter', 'X posts'), ('meta.ai', 'Meta AI shares'),
                      ('claude.ai', 'Claude shares'), ('chatgpt', 'ChatGPT shares'), ('gemini', 'Gemini shares'),
                      ('grok', 'Grok shares'), ('youtube', 'YouTube'), ('youtu.be', 'YouTube'),
                      ('spotify', 'Spotify')]:
        if key in h:
            return name
    return 'Other sites'

found = collections.OrderedDict()
for u in URL.findall(ORIGINAL_REQUEST):
    found.setdefault(clean(u), 'original request')
skip_files = {'ORION_LINK_ARCHIVE.md'}
for dirpath, dirs, files in os.walk(ROOT):
    dirs[:] = sorted(d for d in dirs if d not in ('.lake', '.git', 'node_modules'))
    for f in sorted(files):
        if not f.endswith(('.md', '.txt')) or f in skip_files:
            continue
        p = os.path.join(dirpath, f)
        rel = os.path.relpath(p, ROOT)
        try:
            text = open(p, encoding='utf-8', errors='replace').read()
        except OSError:
            continue
        for u in URL.findall(text):
            u = clean(u)
            if any(s in u for s in SKIP) or len(u) < 12:
                continue
            found.setdefault(u, rel)

groups = collections.defaultdict(list)
for u, where in found.items():
    groups[category(u)].append((u, where))

out = ["# ORION link archive", "",
       "Every link shared on the ORION pages or in the original request, kept even if it can no longer be opened.",
       "Rebuild with `python3 review/make_link_archive.py`. \"First saved in\" is the first project file holding the link;",
       "where that file is a page copy (`PAGE_TRANSCRIPT.md`), it keeps the text around the link as it was when read.", "",
       f"Total: {len(found)} links.", ""]
for cat in sorted(groups):
    out += [f"## {cat} ({len(groups[cat])})", "", "| Link | First saved in | Note |", "|---|---|---|"]
    for u, where in sorted(groups[cat]):
        note = ''
        m = re.search(r'([0-9a-f]{32})', u)
        if cat == 'Notion pages' and m and m.group(1) in NOTION_LOCKED:
            note = f"{NOTION_LOCKED[m.group(1)]}: no longer opens without access (2026-10-04)"
        elif cat in ('Meta AI shares', 'Claude shares', 'Spotify', 'X posts'):
            note = 'needs an app or sign-in to read'
        out.append(f"| {u} | `{where}` | {note} |")
    out.append("")
open(os.path.join(ROOT, 'ORION_LINK_ARCHIVE.md'), 'w', encoding='utf-8').write('\n'.join(out))
print(len(found), 'links')
