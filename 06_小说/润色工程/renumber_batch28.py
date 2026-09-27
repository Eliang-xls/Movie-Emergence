# 批 28：插入 901/902 并重排 001—221 → 001—223
# 锚点（插入前现行号）：125 后插《三线一夜》；128 后插《静音》
# 901 → 新 126；902 → 新 130
import pathlib, shutil

root = pathlib.Path("06_小说/小说正文润色0917")
all_files = sorted(root.glob("[0-9][0-9][0-9]_*.md"))
old = [p for p in all_files if int(p.name[:3]) <= 221]
inserts_list = [p for p in all_files if int(p.name[:3]) >= 900]
assert len(old) == 221, (len(old), [p.name for p in all_files if int(p.name[:3]) > 221])
assert len(inserts_list) == 2, inserts_list
by_num = {int(p.name[:3]): p for p in old}

inserts = {
    125: root / "901_出山_三线一夜.md",
    128: root / "902_出山_静音.md",
}
for src in inserts.values():
    assert src.exists(), src

seq = []
for n in range(1, 222):
    seq.append(by_num[n])
    if n in inserts:
        seq.append(inserts[n])
assert len(seq) == 223, len(seq)

tmp_dir = root / "_renumber_tmp_batch28"
if tmp_dir.exists():
    shutil.rmtree(tmp_dir)
tmp_dir.mkdir()
for i, p in enumerate(seq, 1):
    rest = p.name.split("_", 1)[1] if "_" in p.name else p.name
    shutil.copy2(p, tmp_dir / f"{i:03d}_{rest}")

for p in old:
    p.unlink()
for src in inserts.values():
    if src.exists():
        src.unlink()
for p in tmp_dir.iterdir():
    shutil.move(str(p), str(root / p.name))
tmp_dir.rmdir()
print("done", len(list(root.glob("[0-9][0-9][0-9]_*.md"))))
