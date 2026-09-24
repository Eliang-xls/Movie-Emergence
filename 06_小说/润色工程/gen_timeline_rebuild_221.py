# 重建 221 章全书时间线对照表（0925 重编号后）
# 用法：python 06_小说/润色工程/gen_timeline_rebuild_221.py
import pathlib, re, collections

root = pathlib.Path(r"D:\Docker\Movie-Emergence\06_小说\小说正文润色0917")
chapters = sorted(root.glob("[0-9][0-9][0-9]_*.md"))
assert len(chapters) == 221, f"章数 {len(chapters)} != 221"

D = {"〇": 0, "○": 0, "零": 0, "一": 1, "二": 2, "三": 3, "四": 4, "五": 5, "六": 6, "七": 7, "八": 8, "九": 9}
YEAR_RE = re.compile(r"二[〇○零]([〇○零一二三四五六七八九]{2})年")


def parse_year(s: str):
    m = YEAR_RE.search(s or "")
    if not m:
        return None
    digits = "".join(str(D[c]) for c in m.group(1))
    return 2000 + int(digits) if digits else None


def to_old(n: int):
    """0925：087 空屋语法为插入；087+ 的旧号 = 新号-1。"""
    if n < 87:
        return n
    if n == 87:
        return "086b"
    return n - 1


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
    anchor = ""
    for ln in lines[1:12]:
        t = ln.strip()
        if t:
            anchor = t
            break
    num = p.name[:3]
    parts = p.name[:-3].split("_", 2)
    bu, ti = parts[1], parts[2]
    year = parse_year(anchor) or parse_year(lines[0] if lines else "")
    has_year_in_anchor = bool(YEAR_RE.search(anchor))
    if not has_year_in_anchor and not year:
        no_anchor.append(num)
        year = None
    elif year:
        yc[year].append(num)
    rows.append((num, bu, ti, anchor.replace("|", "｜"), year))

out = [
    "# 全书时间线对照表（221 章 · 重建 0925）",
    "",
    "> **生成**：`06_小说/润色工程/gen_timeline_rebuild_221.py`。现行号 001—221（087《空屋语法》插入后）。",
    "> 旧号映射：`过程归档/_章号映射表_重编号_0925.md`。换算：新号<87 同旧号；087=旧086b；新号≥88 旧号=新号−1。",
    "> **未改动正文**；※ = 开篇非 `年份·季节｜地点` 两段式锚点。",
    "",
    "## 一、编年分布",
    "",
    "| 年份 | 章数 | 章号 |",
    "|---|---:|---|",
]
for y in sorted(yc):
    out.append(f"| {y} | {len(yc[y])} | {yrange(yc[y])} |")
if no_anchor:
    out.append("")
    out.append(f"> 无年份可解析：{yrange(no_anchor)}。")

out += [
    "",
    "## 二、全表",
    "",
    "| 章 | 0925前旧号 | 部 | 章题 | 开篇锚点 | 年 |",
    "|---:|---:|---|---|---|---:|",
]
for num, bu, ti, anchor, year in rows:
    old = to_old(int(num))
    y = year if year else "※"
    out.append(f"| {num} | {old} | {bu} | {ti} | {anchor} | {y} |")

out += [
    "",
    "## 三、季深家庭线锚点（本轮）",
    "",
    "| 年 | 章 | 事件 |",
    "|---:|---:|---|",
    "| 2029 | 012 | 顾清疏导：第一任妻病逝手不抖、顺序/非对易 |",
    "| 2029 | 023–024 | Jackie 关停；顺序病在造物上预演 |",
    "| 2032 | 033、036 | 平滑曲线=遗言（一）；拒「绝对可预测」 |",
    "| 2034 | 044 | 季行辞职；作业本第十四页 |",
    "| 2034冬–2035初 | 072 | 第二任妻病逝；接送表；曲线=遗言（二） |",
    "| 2035.02 | 094 | 未寄信：家殇+想去看海 |",
    "| 2035.03 | 086、099 | 离家拧灯；离职只带海的明信片 |",
    "| 2035春 | 052 | 顾清离任；禁神话行踪 |",
    "| 2036 | 087 | 空屋语法：I don't know / 第三栏 |",
    "| 2044 | 088 | 美高论文；拒代笔；Ji Yao |",
    "| 2045–46 | 136 | 迁深；深大附中；五角星蜡笔 |",
    "| 2047 | 202 | 海边重逢；不点亮星星；信封仍封 |",
    "| 2048 | 221 | 一年后；行踪死链；下一次复核 |",
]

pathlib.Path(r"D:\Docker\Movie-Emergence\06_小说\小说正文润色0917\过程归档\_全书时间线对照表_重建_221.md").write_text(
    "\n".join(out) + "\n", encoding="utf-8"
)
print("wrote timeline 221")
print("years", {y: len(v) for y, v in sorted(yc.items())})
print("no_anchor", no_anchor)
