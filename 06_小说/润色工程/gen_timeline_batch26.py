# 从 218 章正文重建时间线对照表核心段 + 旧号脚注
# cwd = 仓库根
import pathlib, re, json

root = pathlib.Path("06_小说/小说正文润色0917")
chapters = sorted(root.glob("[0-9][0-9][0-9]_*.md"))
assert len(chapters) == 218

def season_val(s):
    # rough sort key year.month
    return s

rows = []
year_counts = {}
for p in chapters:
    text = p.read_text(encoding="utf-8")
    lines = text.splitlines()
    title = lines[0].strip() if lines else ""
    # first non-empty after title
    anchor = ""
    for ln in lines[1:8]:
        t = ln.strip()
        if t:
            anchor = t
            break
    m = re.match(r"^(\d{3})_(.+)_(.+)\.md$", p.name)
    num, bu, ti = m.group(1), m.group(2), m.group(3)
    # year from anchor
    ym = re.search(r"二〇(\d{2})年", anchor)
    year = None
    if ym:
        year = 2000 + int(ym.group(1))
    elif "二〇〇八年" in anchor:
        year = 2008
    if year:
        year_counts.setdefault(year, []).append(num)
    rows.append((num, bu, ti, anchor.replace("|", "｜"), year))

# old number mapping
def to_old(n):
    n = int(n)
    if n <= 139:
        return n
    if n == 140:
        return None
    if 141 <= n <= 199:
        return n - 1
    if n == 200:
        return None
    if 201 <= n <= 216:
        return n - 2
    if n == 217:
        return None
    if n == 218:
        return 215
    return None

out = []
out.append("# 全书时间线对照表（218 章 · 批 26 重建）")
out.append("")
out.append("> **生成**：2026-09-24 批 26 后脚本重建。章号＝现行 001—218。")
out.append("> **换算**：见 `_章号映射表_批26_218.md`。表中「批26前旧号」供登记文件旧引重定位。")
out.append("> **未改动任何正文。**时点由开篇锚点推定；词表沿用 `_时间锚点规范_0917草案.md`。")
out.append("> 标 ※ = 非严格两段式锚点（只有年/月或句号开篇）。")
out.append("")
out.append("## 一、编年分布（按锚点年）")
out.append("")
out.append("| 年份 | 章数 | 章号 |")
out.append("|---|---:|---|")

def yrange(nums):
    nums = sorted(nums, key=int)
    # compress
    parts = []
    i = 0
    while i < len(nums):
        j = i
        while j + 1 < len(nums) and int(nums[j+1]) == int(nums[j]) + 1:
            j += 1
        if i == j:
            parts.append(nums[i])
        else:
            parts.append(f"{nums[i]}–{nums[j]}")
        i = j + 1
    return "、".join(parts)

for y in sorted(year_counts):
    ns = year_counts[y]
    out.append(f"| {y} | {len(ns)} | {yrange(ns)} |")

no_y = [r[0] for r in rows if r[4] is None]
if no_y:
    out.append(f"| （无年） | {len(no_y)} | {yrange(no_y)} |")

out.append("")
out.append("## 二、全表（218 章）")
out.append("")
out.append("| 章 | 批26前旧号 | 部 | 章题 | 开篇锚点原文 | 章含年 |")
out.append("|---:|---:|---|---|---|---:|")
for num, bu, ti, anchor, year in rows:
    old = to_old(num)
    old_s = "—" if old is None else f"{old:03d}"
    mark = "" if anchor.endswith("。") and "｜" in anchor else " ※"
    if "｜" not in anchor and not re.match(r"^二〇.+年·.+｜", anchor):
        if not re.match(r"^二〇.+年·.+｜", anchor):
            mark = " ※"
    else:
        # check two-part
        if "｜" in anchor:
            mark = ""
        else:
            mark = " ※"
    out.append(f"| {num} | {old_s} | {bu} | {ti} | {anchor}{mark} | {year if year else '—'} |")

out.append("")
out.append("## 三、批 26 新章")
out.append("")
out.append("| 新号 | 题 | 锚点 |")
out.append("|---:|---|---|")
for num in ("140", "200", "217"):
    r = next(x for x in rows if x[0] == num)
    out.append(f"| {num} | {r[2]} | {r[3]} |")

path = pathlib.Path("06_小说/小说正文润色0917/过程归档/_全书时间线对照表_批26_218.md")
path.write_text("\n".join(out) + "\n", encoding="utf-8")
print("wrote", path, "rows", len(rows))
