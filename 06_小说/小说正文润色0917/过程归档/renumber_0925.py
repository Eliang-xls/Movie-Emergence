# -*- coding: utf-8 -*-
"""重编号 0925：插入 086b《空屋语法》为 087，其后旧章号 +1。"""
from pathlib import Path
import re

ROOT = Path(r"D:\Docker\Movie-Emergence\06_小说\小说正文润色0917")
ARCHIVE = ROOT / "过程归档"
INSERT_AFTER = 86
INSERT_FILE = "086b_听证_空屋语法.md"
INSERT_PART = "听证"
INSERT_TITLE = "空屋语法"
MAP_OUT = ARCHIVE / "_章号映射表_重编号_0925.md"
BACKUP = ARCHIVE / "_filenames_before_renumber_0925.txt"

def old_num(name: str):
    m = re.match(r"^(\d{3})_", name)
    return int(m.group(1)) if m else None

files = sorted([p for p in ROOT.iterdir() if p.is_file() and p.suffix == ".md"])
chapters = []
for p in files:
    n = old_num(p.name)
    if n is not None:
        chapters.append((n, p))
chapters.sort()

# snapshot
BACKUP.write_text("\n".join(p.name for _, p in chapters) + "\n" + INSERT_FILE + "\n", encoding="utf-8")

mapping = {}
new_names = {}  # old_name -> new_name
seq = []
cur = 0
inserted = False

for n, p in chapters:
    cur += 1
    mapping[n] = cur
    m = re.match(r"^(\d{3})_(.+)\.md$", p.name)
    rest = m.group(2)
    new_filename = f"{cur:03d}_{rest}.md"
    new_names[p.name] = new_filename
    seq.append((cur, "old", n, p.name, new_filename, rest))

    if n == INSERT_AFTER and not inserted:
        cur += 1
        inserted = True
        nf = f"{cur:03d}_{INSERT_PART}_{INSERT_TITLE}.md"
        seq.append((cur, "new", "086b", INSERT_FILE, nf, f"{INSERT_PART}_{INSERT_TITLE}"))
        new_names[INSERT_FILE] = nf

assert inserted, "insert point missing"
print(f"chapters={len(chapters)} last={cur} inserted={inserted}")
print(f"old 086 -> {mapping[86]}, insert -> {mapping[86]+1}, old 087 -> {mapping[87]}")

# write map first (before rename)
lines = [
    "# 章号映射表 · 重编号 2026-09-25\n",
    "> 触发：Y4《空屋语法》独立成章，插在旧 086 之后；旧 087 起全体 +1。",
    "> 台账旧锚点 `旧号:行` → 查本表 → 新号。\n",
    "| 旧号 | 新号 | 部 | 原文件名 | 新文件名 |",
    "|---|---|---|---|---|",
]
for newn, kind, old, oldname, newname, rest in seq:
    part = rest.split("_")[0]
    lines.append(f"| {old} | {newn:03d} | {part} | `{oldname}` | `{newname}` |")
MAP_OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
print("map written", MAP_OUT)

# Phase 1: rename to temp to avoid collisions (e.g. 087->088 while 088 exists)
tmp_map = {}
for oldname, newname in new_names.items():
    src = ROOT / oldname
    tmp = ROOT / (newname + ".tmp_renumber")
    src.rename(tmp)
    tmp_map[tmp] = ROOT / newname

# Phase 2: tmp -> final
for tmp, final in tmp_map.items():
    tmp.rename(final)
print("renamed", len(tmp_map))

# Phase 3: update in-file titles of form 「听证　087　独立成长」 or 「听证 087 独立成长」
# Only update number tokens at start of first title line
updated = 0
for newn, kind, old, oldname, newname, rest in seq:
    path = ROOT / newname
    text = path.read_text(encoding="utf-8")
    # first line often: 部　旧号　标题
    first, nl, tail = text.partition("\n")
    if not nl:
        first, tail = text, ""
        nl = ""
    # replace leading number in first line
    def repl_line(line, newn, rest):
        # rest like 听证_空屋语法 -> title 空屋语法
        title = rest.split("_", 1)[-1] if "_" in rest else rest
        part = rest.split("_")[0]
        # match 部 + sep + digits + sep + title
        new_line = re.sub(
            r"^([^0-9\n]{1,8})[　\s]*\d{3}[　\s]+.*$",
            lambda m: f"{m.group(1)}{newn:03d}　{title}",
            line,
            count=1,
        )
        return new_line
    new_first = repl_line(first, newn, rest)
    if new_first != first:
        text = new_first + nl + tail
        path.write_text(text, encoding="utf-8")
        updated += 1

print("titles updated", updated)
print("DONE")
