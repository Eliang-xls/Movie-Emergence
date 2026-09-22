# 从 06_小说/小说正文润色0917/ 的 199 章重建根目录 涌现.md
# 惯例（对现行文件实测）：每章 = "# " + 章文件首行标题 + 空行 + 正文（去章尾空白），章间空一行，LF 行尾，无卷首。
import re, sys, pathlib

root = pathlib.Path("06_小说/小说正文润色0917")
chapters = sorted(root.glob("[0-9][0-9][0-9]_*.md"))
nums = [c.name[:3] for c in chapters]
assert len(chapters) == 211, f"章数 {len(chapters)} != 211"
assert nums == [f"{i:03d}" for i in range(1, 212)], f"编号不连号: {nums[:5]}..."

blocks = []
for c in chapters:
    text = c.read_text(encoding="utf-8").replace("\r\n", "\n").replace("\r", "\n")
    lines = text.split("\n")
    title = lines[0].strip()
    assert re.match(r"^\S+\s*\u3000?\d{3}\u3000", title) or title[:3] == c.name[:3], f"{c.name} 首行不像标题: {title[:30]}"
    body = "\n".join(lines[1:]).strip("\n")
    blocks.append(f"# {title}\n\n{body}")

out = "\n\n".join(blocks) + "\n"
pathlib.Path("涌现.md").write_text(out, encoding="utf-8", newline="\n")

# 自检
n_h1 = len(re.findall(r"^# ", out, flags=re.M))
for probe in ["不得据此证明意识", "答辩会", "申请人：大一新生 林屿"]:
    in_corpus = sum(p.read_text(encoding="utf-8").count(probe) for p in chapters)
    print(f"{probe}: 合并稿 {out.count(probe)} / 语料 {in_corpus}")
print("H1 数:", n_h1, "| 总行数:", out.count("\n"))
