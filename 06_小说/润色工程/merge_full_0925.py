# -*- coding: utf-8 -*-
"""合并小说正文润色0917 → 项目根 涌现.md"""
from pathlib import Path

ROOT = Path(r"D:\Docker\Movie-Emergence\06_小说\小说正文润色0917")
OUT = Path(r"D:\Docker\Movie-Emergence\涌现.md")
BACKUP = Path(r"D:\Docker\Movie-Emergence\06_小说\小说正文润色0917\过程归档\_涌现_md_backup_221merge_0925.md")

parts = []

# 卷首
preface = ROOT / "卷首_体例说明.md"
if preface.exists():
    parts.append(preface.read_text(encoding="utf-8").rstrip() + "\n")

chapters = sorted(ROOT.glob("[0-9][0-9][0-9]_*.md"))
assert len(chapters) == 221, f"got {len(chapters)}"

for p in chapters:
    t = p.read_text(encoding="utf-8").replace("\r\n", "\n").rstrip()
    parts.append(t)

text = "\n\n---\n\n".join(parts) + "\n"

# backup old
if OUT.exists():
    BACKUP.write_bytes(OUT.read_bytes())
    print("backed up old 涌现.md ->", BACKUP.name, "bytes", OUT.stat().st_size)

OUT.write_text(text, encoding="utf-8")
print("wrote", OUT, "bytes", OUT.stat().st_size)
print("chapters", len(chapters), "first", chapters[0].name, "last", chapters[-1].name)
# quick sanity
assert "空屋语法" in text
assert "Ji Yao" in text or "空屋" in text
print("sanity ok")
