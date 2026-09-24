# 全书扫描：比…更 / 比…还 / 不比…更 等比较格
import pathlib, re

root = pathlib.Path("06_小说/小说正文润色0917")
chapters = sorted(root.glob("[0-9][0-9][0-9]_*.md"))

# broader patterns
pats = [
    re.compile(r"比[^。！？\n]{1,40}更"),
    re.compile(r"比[^。！？\n]{1,40}还[^。！？\n]{0,8}"),
]

rows = []
for p in chapters:
    num = int(p.name[:3])
    text = p.read_text(encoding="utf-8")
    for i, ln in enumerate(text.splitlines(), 1):
        s = ln.strip()
        if not s or s.startswith("#"):
            continue
        for pat in pats:
            for m in pat.finditer(s):
                frag = m.group(0)
                if len(frag) > 50:
                    frag = frag[:50] + "…"
                rows.append((num, i, frag, s[:100]))

print("hits", len(rows))
for num, i, frag, s in rows:
    flag = "FREEZE" if num <= 6 else ""
    print(f"{num:03d}:{i} {flag} [{frag}] || {s}")
