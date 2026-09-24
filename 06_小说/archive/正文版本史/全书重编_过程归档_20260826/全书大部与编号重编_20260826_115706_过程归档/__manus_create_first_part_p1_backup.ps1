$ErrorActionPreference = 'Stop'
$Root = 'D:\Docker\Movie-Emergence\06_小说\小说正文（待审核）'
$BackupName = '__manus_backup_第一部P1_编号主序_20260826_实施前'
$Backup = Join-Path $Root $BackupName
$Files = @(
    '第一部_007_为了全人类.md',
    '第一部_008_硬信封.md',
    '第一部_009_锁孔.md',
    '第一部_010_水不知道自己会流向哪里.md',
    '第一部_011_它们在呼吸.md',
    '第一部_012_两种温度.md',
    '第一部_013_我在学你.md',
    '第一部_014_无人监督.md',
    '第一部_015_人格宪章.md',
    '第一部_016_盆地.md',
    '第一部_017_反事实搜索.md',
    '第一部_018_影子.md',
    '第一部_019_两行.md',
    '第一部_020_选择的影子.md',
    '第一部_021_十秒.md',
    '第一部_022_记住我.md',
    '第一部_023_闭眼.md',
    '第一部_024_谁先说安全.md',
    '第一部_025_还没.md',
    '第一部_025-B_八百毫秒.md',
    '第一部_025-C_问问题的人.md',
    '第一部_026_开枪的权利.md',
    '第一部_027_交点.md',
    '第一部_028_铁轨.md',
    '第一部_028-B_一年后的推导.md',
    '第一部_029_算力的命脉.md',
    '第一部_030_不会被尺子量到的.md',
    '第一部_031_看不到那么远.md',
    '__manus_第一部P0阅读序列.md'
)

if (Test-Path -LiteralPath $Backup) {
    $existingItems = @(Get-ChildItem -LiteralPath $Backup -Force)
    if ($existingItems.Count -gt 0) { throw "备份目录已存在且非空，拒绝覆盖：$Backup" }
} else {
    New-Item -ItemType Directory -Path $Backup | Out-Null
}
foreach ($name in $Files) {
    $source = Join-Path $Root $name
    if (-not (Test-Path -LiteralPath $source)) { throw "缺少P1范围文件：$source" }
}

foreach ($name in $Files) {
    $destination = Join-Path $Backup $name
    if (Test-Path -LiteralPath $destination) { throw "备份目标已存在，拒绝覆盖：$destination" }
    Copy-Item -LiteralPath (Join-Path $Root $name) -Destination $destination
}

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('# 第一部P1编号主序实施前SHA256基线与文件清单')
$lines.Add('')
$lines.Add('> 备份范围：第一部007—031的28个现有正文文件，以及将被改写为时间关系索引的`__manus_第一部P0阅读序列.md`。')
$lines.Add('> 正式主序：仅按正文文件名内编号递增。`025-B`、`025-C`与`028-B`分别置于相同基础编号之后、下一整数编号之前；索引文件不构成主序。')
$lines.Add('')
$lines.Add('| 文件 | UTF-8字节数 | SHA256 |')
$lines.Add('|---|---:|---|')
foreach ($name in $Files) {
    $filePath = Join-Path $Root $name
    $bytes = (Get-Item -LiteralPath $filePath).Length
    $hash = (Get-FileHash -LiteralPath $filePath -Algorithm SHA256).Hash
    $lines.Add("| $name | $bytes | $hash |")
}
[System.IO.File]::WriteAllLines((Join-Path $Backup 'SHA256基线与文件清单.md'), $lines, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "第一部P1实施前备份已创建：$Backup"
