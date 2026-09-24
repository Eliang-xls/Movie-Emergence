# 批 26：承重句候选 + 「不是A，是B」+ 对白粗筛（218 章全覆盖）
import pathlib, re, collections

root = pathlib.Path("06_小说/小说正文润色0917")
chapters = sorted(root.glob("[0-9][0-9][0-9]_*.md"))

notA_isB = []
heavy = []
dialog_issues = []

# crude heavy-sentence heuristics
heavy_pat = re.compile(
    r"(完整版|一次性发布|承担的形状|谁也不打算吞掉谁|血统就断了|非我首创|例外必须有人签|"
    r"空着，比填上|夹板，比落在地上的刀|不报错|只能被承担|先问是谁|未完成|"
    r"原件不销毁|水不需要被告诉|服从没有分叉|邻接.*因果|没有谁的判断被抹掉)"
)

for p in chapters:
    text = p.read_text(encoding="utf-8")
    num = p.name[:3]
    bu = p.name.split("_", 1)[1].split("_", 1)[0] if p.name.count("_") >= 2 else ""
    lines = text.splitlines()
    for i, ln in enumerate(lines, 1):
        s = ln.strip()
        if not s or s.startswith("#"):
            continue
        # 不是A，是B
        if re.search(r"不是[^。！？\n]{1,20}[，,]\s*是", s):
            notA_isB.append((num, i, s[:80]))
        if heavy_pat.search(s) and not s.startswith("|") and "—" not in s[:2]:
            if len(s) < 80:
                heavy.append((num, i, s))
        # dialogue red flags: very long quoted line, or brand-like
        if s.startswith("「") and len(s) > 120:
            dialog_issues.append((num, i, "长对白>120", s[:60]))
        if re.search(r"(极其|极度|彻底地|猛烈地)", s) and "「" in s:
            dialog_issues.append((num, i, "对白叠词", s[:60]))

print("=== 不是A，是B ===")
by = collections.Counter(n for n, _, _ in notA_isB)
for n, c in by.most_common():
    print(f"  {n}: {c}")
print("total lines", len(notA_isB))
print("\n=== 承重句候选（短） ===")
for n, i, s in heavy:
    print(f"{n}:{i} {s}")
print("\n=== 对白粗筛 ===")
for n, i, tag, s in dialog_issues:
    print(f"{n}:{i} [{tag}] {s}")

# write report
out = pathlib.Path("06_小说/小说正文润色0917/过程归档/_金句对白扫描_批26_218.md")
with out.open("w", encoding="utf-8") as f:
    f.write("# 金句 / 对白粗筛报告（218 章 · 批 26）\n\n")
    f.write("> 只登记、不删改。政策同 `_重锤金句配额台账_0917.md`（前期松绑）。覆盖含 140/200/217 与 200 后收网/海边。\n\n")
    f.write("## 一、「不是A，是B」逐章计数\n\n| 章 | 次数 |\n|---:|---:|\n")
    for n, c in sorted(by.items()):
        f.write(f"| {n} | {c} |\n")
    f.write(f"\n合计行数：{len(notA_isB)}。标准参考 ≤2/章；超者留后轮审阅。\n\n")
    f.write("## 二、承重句候选（自动短句钩，需人工判）\n\n| 章:行 | 句 |\n|---|---|\n")
    for n, i, s in heavy:
        f.write(f"| {n}:{i} | {s.replace('|','｜')} |\n")
    f.write("\n## 三、对白粗筛\n\n| 章:行 | 标签 | 片段 |\n|---|---|---|\n")
    for n, i, tag, s in dialog_issues:
        f.write(f"| {n}:{i} | {tag} | {s.replace('|','｜')} |\n")
print("wrote", out)
