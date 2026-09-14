$root = 'D:\Docker\Movie-Emergence\06_小说\小说正文（待审核）'
$backupName = '__manus_backup_第二部P1-A_编号主序_20260826_实施前'
$backupRoot = Join-Path $root $backupName
$files = @(
    '第二部_054_分布式赛.md',
    '第二部_055_没有发令枪的起跑.md',
    '第二部_056_崖顶的守望者.md',
    '第二部_057_液态的算力.md',
    '第二部_058_带出去的那一份.md',
    '第二部_059_换的人.md',
    '第二部_060_谁的三天.md'
)
if (Test-Path -LiteralPath $backupRoot) { throw "Backup directory already exists: $backupRoot" }
New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
$rows = New-Object System.Collections.Generic.List[string]
$rows.Add('# 第二部P1-A编号主序实施前SHA256基线与文件清单')
$rows.Add('')
$rows.Add('> 备份范围：第二部054—060。该批仅在原编号位置去重、添加档案时间卡并收束技术边界，不移动文件、不重命名文件。')
$rows.Add('')
$rows.Add('| 文件 | UTF-8字节数 | SHA256 |')
$rows.Add('|---|---:|---|')
foreach ($fileName in $files) {
    $source = Join-Path $root $fileName
    if (!(Test-Path -LiteralPath $source)) { throw "Missing source file: $source" }
    $dest = Join-Path $backupRoot $fileName
    Copy-Item -LiteralPath $source -Destination $dest -Force
    $bytes = (Get-Item -LiteralPath $source).Length
    $hash = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash
    $rows.Add('| ' + $fileName + ' | ' + $bytes + ' | ' + $hash + ' |')
}
$manifest = Join-Path $backupRoot 'SHA256基线与文件清单.md'
[System.IO.File]::WriteAllLines($manifest, $rows, [System.Text.UTF8Encoding]::new($false))
Write-Output "BACKUP_ROOT=$backupRoot"
Write-Output "MANIFEST=$manifest"
