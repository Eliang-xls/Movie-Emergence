# 批 26：插入 901/902/903 并重排 001—218
# 锚点：901→139 后，902→198 后，903→214 后（按插入前的现行编号）
import pathlib, re, shutil

root = pathlib.Path("06_小说/小说正文润色0917")
all_files = sorted(root.glob("[0-9][0-9][0-9]_*.md"))
old = [p for p in all_files if int(p.name[:3]) <= 215]
inserts_list = [p for p in all_files if int(p.name[:3]) >= 900]
assert len(old) == 215, len(old)
assert len(inserts_list) == 3, inserts_list
by_num = {int(p.name[:3]): p for p in old}

inserts = {
    139: root / "901_出山_空着的署名.md",
    198: root / "902_解冻_第三十页.md",
    214: root / "903_海边_挂起的第四天.md",
}
for src in inserts.values():
    assert src.exists(), src

# build ordered list of (kind, path)
seq = []
for n in range(1, 216):
    seq.append(by_num[n])
    if n in inserts:
        seq.append(inserts[n])
assert len(seq) == 218

# rename into temp names to avoid collisions
tmp_dir = root / "_renumber_tmp_batch26"
if tmp_dir.exists():
    shutil.rmtree(tmp_dir)
tmp_dir.mkdir()
for i, p in enumerate(seq, 1):
    new_name = f"{i:03d}" + p.name[3:] if p.name[0].isdigit() and p.name[:3].isdigit() and int(p.name[:3]) <= 215 else f"{i:03d}" + re.sub(r"^[0-9]+", "", p.name)
    # keep 部_章名 from original: NNN_部_章名.md
    rest = p.name[4:] if re.match(r"^\d{3}_", p.name) else re.sub(r"^\d{3}_", "", p.name)
    # 901/902/903 also NNN_
    rest = p.name.split("_", 1)[1] if "_" in p.name else p.name
    target = tmp_dir / f"{i:03d}_{rest}"
    shutil.copy2(p, target)

# replace: delete originals, move tmp in
for p in old:
    p.unlink()
for src in inserts.values():
    if src.exists():
        src.unlink()
for p in tmp_dir.iterdir():
    shutil.move(str(p), str(root / p.name))
tmp_dir.rmdir()
print("done", len(list(root.glob('[0-9][0-9][0-9]_*.md'))))
