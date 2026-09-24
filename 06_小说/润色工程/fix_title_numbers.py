# 将每章首行标题中的三位数字同步为文件名编号
import pathlib, re

root = pathlib.Path("06_小说/小说正文润色0917")
fixed = 0
for p in sorted(root.glob("[0-9][0-9][0-9]_*.md")):
    num = p.name[:3]
    text = p.read_text(encoding="utf-8")
    lines = text.splitlines()
    if not lines:
        continue
    title = lines[0]
    new = re.sub(r"(　)\d{3}(　)", r"\g<1>" + num + r"\g<2>", title, count=1)
    # also handle halfwidth or no fullwidth
    if new == title:
        new = re.sub(r"(\s)\d{3}(\s)", r"\g<1>" + num + r"\g<2>", title, count=1)
    if new != title:
        lines[0] = new
        p.write_text("\n".join(lines) + ("\n" if text.endswith("\n") else ""), encoding="utf-8")
        fixed += 1
        print(p.name, "->", new)
print("fixed", fixed)
