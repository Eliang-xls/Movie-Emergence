# -*- coding: utf-8 -*-
"""重编号后同步：时间线表、卷首、过程锚点中的旧章号 → 新章号。"""
from pathlib import Path
import re

ROOT = Path(r"D:\Docker\Movie-Emergence\06_小说\小说正文润色0917")
MAP_MD = ROOT / "过程归档" / "_章号映射表_重编号_0924.md"

# 解析映射：旧号 -> 新号
text = MAP_MD.read_text(encoding="utf-8")
mapping = {}
n_map = {}
for line in text.splitlines():
    # | 107 | 107 | ... | `107_出山_注册表.md` | ... |
    # | N1_出山_名额表 | 109 | ... |
    m = re.match(r"\|\s*`?(\d{3})`?\s*\|\s*`?(\d{3})`?\s*\|", line)
    if m:
        mapping[int(m.group(1))] = int(m.group(2))
        continue
    m = re.match(r"\|\s*(N\d)_([^\s|]+)\s*\|\s*`?(\d{3})`?\s*\|", line)
    if m:
        n_map[m.group(1)] = int(m.group(3))

# 仅当旧号 != 新号才需替换
shift = {o: n for o, n in mapping.items() if o != n}
print(f"shift entries: {len(shift)}, n_map: {n_map}")

# 从大到小替换，避免连锁
old_nums_desc = sorted(shift.keys(), reverse=True)

def remap_num(n: int) -> int:
    return shift.get(n, n)

def remap_token(s: str) -> str:
    """替换 N1-N4 与三位章号（仅当在 shift 中）。保守：只动反引号内章号。"""
    for k, v in n_map.items():
        s = re.sub(rf"\b{k}\b", f"{v:03d}", s)
    def repl_str(nstr: str) -> str:
        n = int(nstr)
        return f"{remap_num(n):03d}" if n in shift else nstr
    # 只替换反引号包裹的三位数章号，避免误伤「199 章」「2045」等
    s = re.sub(r"`(\d{3})`", lambda m: f"`{repl_str(m.group(1))}`", s)
    return s

# --- 1) 时间线对照表：重写章号列并插入新章行 ---
tl = ROOT / "过程归档" / "_全书时间线对照表_0920.md"
t = tl.read_text(encoding="utf-8")
# 表行形如 | 107 | 出山 | 注册表 | ... |
def fix_row(m):
    old = int(m.group(2))
    new = remap_num(old)
    return f"| {new:03d} |{m.group(1)}|{m.group(3)}|{m.group(4)}|"
t2 = re.sub(r"^\|\s*(\d{3})\s*\|(.+)$", lambda m: f"| {remap_num(int(m.group(1))):03d} |{m.group(2)}", t, flags=re.M)
# 插入四条新章（插在映射后新号位置：在对应表行后不好做，追加到表末并注明）
insert_rows = """
| 109 | 出山 | 名额表 | 二〇四五年·十月下旬｜深大第一食堂公告屏 | 2045.10·下 |
| 110 | 出山 | 挂靠税 | 二〇四五年·十月下旬｜图书馆 B102 侧厅 | 2045.10·下 |
| 159 | 出山 | 保留资格 | 二〇四六年·十二月上旬｜门派季帐篷区东侧 | 2046.12·上 |
| 164 | 出山 | 金色水位 | 二〇四七年·六月｜开源协作中心公示屏 | 2047.06·中 |
"""
if "| 109 | 出山 | 名额表 |" not in t2:
    # 插到表格结束前：找第一个空行 after table or append note
    t2 = t2.replace("\n\n", insert_rows + "\n", 1) if "\n\n" in t2 else t2 + insert_rows
tl.write_text(t2, encoding="utf-8")
print("timeline updated")

# --- 2) 卷首 ---
pref = ROOT / "卷首_体例说明.md"
p = pref.read_text(encoding="utf-8")
p2 = remap_token(p)
# 显式处理卷首里 `025→026` 这类箭头对
p2 = re.sub(r"`(\d{3})→(\d{3})`", lambda m: f"`{remap_num(int(m.group(1))):03d}→{remap_num(int(m.group(2))):03d}`", p2)
pref.write_text(p2, encoding="utf-8")
print("preface updated")

# --- 3) 过程归档关键文件：`旧号:行` / `旧号` / N1-N4 ---
targets = [
    ROOT / "过程归档" / "_矛盾处理台账_0920.md",
    ROOT / "过程归档" / "_禁止改动清单_0920.md",
    ROOT / "过程归档" / "_扩写清单_分级_0920.md",
    ROOT / "过程归档" / "_待解决问题优先级清单_0917.md",
    ROOT / "过程归档" / "00_CONC概念释放与校园线扩章落地方案_0924.md",
    ROOT / "过程归档" / "_指称分层规范_0917草案.md",
    ROOT / "过程归档" / "_时间锚点规范_0917草案.md",
]
# 只替换三种形态，降低误伤：
#   `NNN:  `NNN:LL`  `NNN`  N1-N4  NNN_部_
pat_colon = re.compile(r"`(\d{3}):(\d+(?:—\d+)?)`")
pat_bare = re.compile(r"`(\d{3})`")
pat_file = re.compile(r"\b(\d{3})_(出山|解冻|收网|海边|穹顶|屋外|听证|账本)_")

for fp in targets:
    if not fp.exists():
        print(f"skip {fp.name}")
        continue
    s = fp.read_text(encoding="utf-8")
    for k, v in n_map.items():
        s = re.sub(rf"\b{k}\b", f"{v:03d}", s)
    s = pat_colon.sub(lambda m: f"`{remap_num(int(m.group(1))):03d}:{m.group(2)}`", s)
    s = pat_file.sub(lambda m: f"{remap_num(int(m.group(1))):03d}_{m.group(2)}_", s)
    s = pat_bare.sub(lambda m: f"`{remap_num(int(m.group(1))):03d}`" if int(m.group(1)) in shift else m.group(0), s)
    fp.write_text(s, encoding="utf-8")
    print(f"remapped {fp.name}")

# --- 4) 映射表补一行读法说明 ---
note = MAP_MD.read_text(encoding="utf-8")
if "历史锚点读法" not in note:
    note = note.replace(
        "> 台账历史锚点 `旧号:行` 读法：旧号 → 查本表 → 新号。\n",
        "> 台账历史锚点读法：`旧号:行` → 查本表得新号 → `新号:行`（行号未变）。**2026-09-24 起过程文档中 `NNN:` 已批量改写为新号**；若发现残留旧号，以本表为准。\n> 章文件内标题已改为新号。\n",
    )
    MAP_MD.write_text(note, encoding="utf-8")

print("ALL DONE")
