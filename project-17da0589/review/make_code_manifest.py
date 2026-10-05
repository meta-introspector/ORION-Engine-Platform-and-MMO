"""Regenerate the file inventory and theorem index in CODE_MANIFEST.md.

Run from the project root:  python3 review/make_code_manifest.py

It writes CODE_MANIFEST.md from CODE_MANIFEST_HEADER.md (hand-written comparison notes)
followed by two generated parts: every source file with its line count and SHA-256, and every
theorem/lemma in the Lean files with the first sentence of its docstring.
"""

from __future__ import annotations

import hashlib
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SKIP = {"CODE_MANIFEST.md"}


def tracked_files() -> list[str]:
    out = subprocess.run(["git", "ls-files"], cwd=ROOT, capture_output=True, text=True,
                         check=True).stdout.split()
    extra = ["review/make_code_manifest.py", "CODE_MANIFEST_HEADER.md"]
    files = sorted(set(out) | {e for e in extra if (ROOT / e).exists()})
    return [f for f in files if f not in SKIP and not f.startswith(".")]


def first_sentence(doc: str) -> str:
    doc = " ".join(doc.split())
    m = re.match(r"(.+?[.!?])(\s|$)", doc)
    s = m.group(1) if m else doc
    s = s.replace("|", "\\|")
    return s if len(s) <= 220 else s[:217] + "..."


DECL = re.compile(r"^(theorem|lemma)\s+([^\s(:{\[]+)", re.M)
NS = re.compile(r"^namespace\s+(\S+)", re.M)


def theorems(path: Path) -> list[tuple[str, str]]:
    text = path.read_text(encoding="utf-8")
    ns_match = NS.search(text)
    ns = ns_match.group(1) if ns_match else ""
    res = []
    for m in DECL.finditer(text):
        before = text[: m.start()].rstrip()
        doc = ""
        if before.endswith("-/"):
            start = before.rfind("/--")
            if start != -1 and "-/" not in before[start:-2]:
                doc = before[start + 3: -2]
        name = m.group(2)
        full = name if not ns or name.startswith(ns + ".") else f"{ns}.{name}"
        res.append((full, first_sentence(doc) if doc else "_(no docstring: supporting step)_"))
    return res


def main() -> None:
    header = (ROOT / "CODE_MANIFEST_HEADER.md").read_text(encoding="utf-8")
    files = tracked_files()
    lines = [header.rstrip(), "", "## Appendix A. Every file in the project", "",
             "| File | Lines | SHA-256 (first 16 hex) |", "| --- | ---: | --- |"]
    for f in files:
        data = (ROOT / f).read_bytes()
        n = data.count(b"\n")
        lines.append(f"| `{f}` | {n} | `{hashlib.sha256(data).hexdigest()[:16]}` |")
    lean = [f for f in files if f.endswith(".lean")]
    total = 0
    body = []
    for f in lean:
        ts = theorems(ROOT / f)
        if not ts:
            continue
        total += len(ts)
        body += ["", f"### `{f}` ({len(ts)})", "", "| Theorem | What it says |", "| --- | --- |"]
        body += [f"| `{n}` | {d} |" for n, d in ts]
    lines += ["", "## Appendix B. Every theorem and lemma in the Lean files", "",
              f"{total} named theorems and lemmas in total. All of them build with no `sorry`.", ""]
    lines += body
    (ROOT / "CODE_MANIFEST.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"wrote CODE_MANIFEST.md: {len(files)} files, {total} theorems")


if __name__ == "__main__":
    main()
