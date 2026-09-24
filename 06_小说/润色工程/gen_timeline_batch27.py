# 批 27：重建 220 章时间线表
import pathlib, re

root = pathlib.Path("06_小说/小说正文润色0917")
chapters = sorted(root.glob("[0-9][0-9][0-9]_*.md"))
assert len(chapters) == 220

def to_old(n):
    n = int(n)
    if n <= 216:
        return n
    if n == 217:
        return None
    if n == 218:
        return 217
    if n == 219:
        return None
    if n == 220:
        return 218
    return None

rows = []
yc = {}
for p in chapters:
    text = p.read_text(encoding="utf-8")
    lines = text.splitlines()
    anchor = ""
    for ln in lines[1:8]:
        t = ln.strip()
        if t:
            anchor = t
            break
    num = p.name[:3]
    parts = p.name[:-3].split("_", 2)
    bu, ti = parts[1], parts[2]
    ym = re.search(r"二〇(\d{2})年", anchor)
    year = 2000 + int(ym.group(1)) if ym else None
    if year:
        yc.setdefault(year, []).append(num)
    rows.append((num, bu, ti, anchor.replace("|", "｜"), year))

def yrange(nums):
    nums = sorted(nums, key=int)
    parts = []
    i = 0
    while i < len(nums):
        j = i
        while j + 1 < len(nums) and int(nums[j + 1]) == int(nums[j]) + 1:
            j += 1
        parts.append(nums[i] if i == j else f"{nums[i]}–{nums[j]}")
        i = j + 1
    return "、".join(parts)

out = [
    "# 全书时间线对照表（220 章 · 批 27 重建）",
    "",
    "> **生成**：2026-09-24 批 27。现行号 001—220。换算：`_章号映射表_批27_220.md`（叠批 26）。",
    "",
    "## 一、编年分布",
    "",
    "| 年份 | 章数 | 章号 |",
    "|---|---:|---|",
]
for y in sorted(yc):
    out.append(f"| {y} | {len(yc[y])} | {yrange(yc[y])} |")
out += [
    "",
    "## 二、全表",
    "",
    "| 章 | 批27前旧号 | 部 | 章题 | 开篇锚点 | 年 |",
    "|---:|---:|---|---|---|---:|",
]
for num, bu, ti, anchor, year in rows:
    old = to_old(num)
    old_s = "—" if old is None else f"{old:03d}"
    mark = "" if "｜" in anchor else " ※"
    out.append(f"| {num} | {old_s} | {bu} | {ti} | {anchor}{mark} | {year or '—'} |")
out += ["", "## 三、批 27 新章", "", "| 新号 | 题 | 锚点 |", "|---:|---|---|"]
for num in ("217", "219"):
    r = next(x for x in rows if x[0] == num)
    out.append(f"| {num} | {r[2]} | {r[3]} |")

path = pathlib.Path("06_小说/小说正文润色0917/过程归档/_全书时间线对照表_批27_220.md")
path.write_text("\n".join(out) + "\n", encoding="utf-8")
print("wrote", path, len(rows))
