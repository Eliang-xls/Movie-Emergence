# -*- coding: utf-8 -*-
"""全书重编号：插入 N1-N4，生成映射并重命名章文件、更新章内标题。"""
from pathlib import Path
import re
import shutil

ROOT = Path(r"D:\Docker\Movie-Emergence\06_小说\小说正文润色0917")
MAP_OUT = ROOT / "过程归档" / "_章号映射表_重编号_0924.md"

# 插入位（旧号之后）
# N1,N2 插在 108 后；N3 插在 156 后；N4 插在 160 后
INSERTS = {
    108: [("N1_出山_名额表.md", "出山", "名额表"), ("N2_出山_挂靠税.md", "出山", "挂靠税")],
    156: [("N3_出山_保留资格.md", "出山", "保留资格")],
    160: [("N4_出山_金色水位.md", "出山", "金色水位")],
}

def old_num(name: str):
    m = re.match(r"^(\d{3})_", name)
    return int(m.group(1)) if m else None

# 构建旧文件 -> (新号, 新文件名) 映射
files = sorted([p for p in ROOT.iterdir() if p.is_file() and p.suffix == ".md"])
chapters = []
for p in files:
    n = old_num(p.name)
    if n is not None:
        chapters.append((n, p))
chapters.sort()

# 计算新号
mapping = {}  # old_num -> new_num
new_name = {}  # old_filename -> new_filename
seq = []  # list of (new_num, kind, old_path_or_N, title_part)

cur = 0
n_counter = 0
pending_n = []

for n, p in chapters:
    # 先插入挂在「上一章号 n 之后」的新章（对 108/156/160）
    # 实际插入点：在输出完 old n 之后
    cur += 1
    mapping[n] = cur
    m = re.match(r"^(\d{3})_(.+)\.md$", p.name)
    rest = m.group(2)  # e.g. 出山_注册表
    new_filename = f"{cur:03d}_{rest}.md"
    new_name[p.name] = new_filename
    seq.append((cur, "old", p, rest))

    if n in INSERTS:
        for nfile, part, title in INSERTS[n]:
            cur += 1
            n_counter += 1
            new_filename_n = f"{cur:03d}_{part}_{title}.md"
            seq.append((cur, "new", ROOT / nfile, f"{part}_{title}"))
            new_name[nfile] = new_filename_n

print(f"Total chapters: {len(seq)}")
print(f"Old count: {len(chapters)}, New inserts: {n_counter}")
print(f"Last number: {cur}")

# 打印关键映射
for k in [107, 108, 109, 110, 111, 155, 156, 157, 158, 159, 160, 161, 162, 211]:
    if k in mapping:
        print(f"  old {k} -> new {mapping[k]}")

# 写映射表
lines = []
lines.append("# 章号映射表 · 重编号 2026-09-24\n")
lines.append("> 触发：CONC 概念释放扩章（N1–N4 工作名）写完后全书统编。")
lines.append("> 规则：N1/N2 插在旧 108 后；N3 插在旧 156 后；N4 插在旧 160 后。")
lines.append("> 台账历史锚点 `旧号:行` 读法：旧号 → 查本表 → 新号。\n")
lines.append("| 旧号/工作名 | 新号 | 部 | 原文件名 | 新文件名 |")
lines.append("|---|---|---|---|---|")
for newn, kind, path, rest in seq:
    if kind == "old":
        oldn = old_num(path.name)
        part = rest.split("_")[0]
        lines.append(f"| {oldn:03d} | {newn:03d} | {part} | `{path.name}` | `{new_name[path.name]}` |")
    else:
        part = rest.split("_")[0]
        lines.append(f"| {path.stem} | {newn:03d} | {part} | `{path.name}` | `{new_name[path.name]}` |")

MAP_OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
print(f"Map written: {MAP_OUT}")

# 重命名：两阶段，避免碰撞
tmp_dir = ROOT / "_renumber_tmp"
tmp_dir.mkdir(exist_ok=True)

# Phase 1: 移到临时目录
for old_name, new_filename in new_name.items():
    src = ROOT / old_name
    if not src.exists():
        print(f"MISSING {old_name}")
        continue
    shutil.move(str(src), str(tmp_dir / old_name))

# Phase 2: 移回新名 + 更新标题行
title_pat = re.compile(r"^([^\d]{0,6})(\d{1,3}|N\d)([　\s]+)(.+)$")

for newn, kind, path, rest in seq:
    old_name = path.name
    src = tmp_dir / old_name
    dst = ROOT / new_name[old_name]
    text = src.read_text(encoding="utf-8")
    lines_t = text.splitlines(keepends=True)
    if lines_t:
        first = lines_t[0].rstrip("\n")
        # 标题形如：出山　107　注册表 / 出山　N1　名额表
        m = re.match(r"^(.+?)[　\s]+(?:N\d+|\d{1,3})[　\s]+(.+)$", first)
        if m:
            part, title = m.group(1), m.group(2)
            lines_t[0] = f"{part}　{newn:03d}　{title}\n"
        else:
            # 尝试替换首个独立数字/Nx
            lines_t[0] = re.sub(r"(?<![A-Za-z0-9_])(?:N\d+|\d{1,3})(?=[　\s])", f"{newn:03d}", first, count=1) + "\n"
    dst.write_text("".join(lines_t), encoding="utf-8")
    print(f"{old_name} -> {dst.name}")

# 清理
tmp_dir.rmdir()
print("DONE")
