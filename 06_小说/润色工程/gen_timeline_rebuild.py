# 重建 220 章全书时间线对照表（含编年分布与中文年号）
# 用法（仓库根）：python 06_小说/润色工程/gen_timeline_rebuild.py
import pathlib, re, collections

root = pathlib.Path("06_小说/小说正文润色0917")
chapters = sorted(root.glob("[0-9][0-9][0-9]_*.md"))
assert len(chapters) == 220, f"章数 {len(chapters)} != 220"

D = {"〇": 0, "○": 0, "零": 0, "一": 1, "二": 2, "三": 3, "四": 4, "五": 5, "六": 6, "七": 7, "八": 8, "九": 9}
YEAR_RE = re.compile(r"二[〇○零]([〇○零一二三四五六七八九]{2})年")


def parse_year(s: str):
    m = YEAR_RE.search(s or "")
    if not m:
        return None
    digits = "".join(str(D[c]) for c in m.group(1))
    return 2000 + int(digits) if digits else None


def to_old(n: str):
    """批 27 插入 217/219 后的旧号映射（叠批 26）。"""
    n = int(n)
    if n <= 216:
        return n
    return {217: None, 218: 217, 219: None, 220: 218}.get(n)


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


rows = []
yc = collections.defaultdict(list)
no_anchor = []
for p in chapters:
    lines = p.read_text(encoding="utf-8").replace("\r\n", "\n").split("\n")
    # 标题在首行；锚点取正文前几行第一段非空
    anchor = ""
    for ln in lines[1:8]:
        t = ln.strip()
        if t:
            anchor = t
            break
    num = p.name[:3]
    parts = p.name[:-3].split("_", 2)
    bu, ti = parts[1], parts[2]
    year = parse_year(anchor) or parse_year(lines[0] if lines else "")
    # 003/116 等：正文首段不是年份锚点时仍记原文
    has_year_in_anchor = bool(YEAR_RE.search(anchor))
    if not has_year_in_anchor and not year:
        no_anchor.append(num)
        year = None
    elif year:
        yc[year].append(num)
    rows.append((num, bu, ti, anchor.replace("|", "｜"), year))

out = [
    "# 全书时间线对照表（220 章 · 重建）",
    "",
    "> **生成**：脚本 `06_小说/润色工程/gen_timeline_rebuild.py` 从现行正文重建。现行号 001—220。",
    "> 旧号映射：`_章号映射表_批27_220.md`（叠批 26）。换算口径沿用 `_时间锚点规范_0917草案.md` §二。",
    "> **未改动正文**；标 ※ = 开篇非 `年份·季节｜地点` 两段式锚点。",
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
    f"> 无年份可解析：{('、'.join(no_anchor) if no_anchor else '无')}（003 未润色区、116 全书唯一零锚点章·刻意）。",
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

out += [
    "",
    "## 三、批 27 新章",
    "",
    "| 新号 | 题 | 锚点 |",
    "|---:|---|---|",
]
for num in ("217", "219"):
    r = next(x for x in rows if x[0] == num)
    out.append(f"| {num} | {r[2]} | {r[3]} |")

path = pathlib.Path("06_小说/小说正文润色0917/过程归档/_全书时间线对照表_重建_220.md")
path.write_text("\n".join(out) + "\n", encoding="utf-8")
print("wrote", path, "rows", len(rows), "years", len(yc), "no_year", no_anchor)
