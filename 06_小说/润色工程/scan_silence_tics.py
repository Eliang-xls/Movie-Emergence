# 意象轮扫描：死寂族
import pathlib, re, collections

root = pathlib.Path("06_小说/小说正文润色0917")
chapters = sorted(root.glob("[0-9][0-9][0-9]_*.md"))

keys = [
    "死寂", "死静", "落针可闻", "令人窒息的死", "绝对死寂",
    "陷入.*死寂", "跌回.*死寂", "恢复了死寂", "一片死寂",
    "毛骨悚然", "令人窒息",
]

rows = []
for p in chapters:
    num = int(p.name[:3])
    text = p.read_text(encoding="utf-8")
    for i, ln in enumerate(text.splitlines(), 1):
        s = ln.strip()
        if not s:
            continue
        for k in ("死寂", "死静", "落针可闻", "毛骨悚然"):
            if k in s:
                rows.append((num, i, k, s[:90]))

print("total", len(rows))
c = collections.Counter(r[2] for r in rows)
print(c)
by = collections.Counter(r[0] for r in rows)
print("chapters with hits", len(by))
for n, i, k, s in sorted(rows):
    fr = "FREEZE" if n <= 6 else ""
    print(f"{n:03d}:{i} {fr} [{k}] {s}")
