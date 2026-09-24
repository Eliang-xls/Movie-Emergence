$root = 'D:\Docker\Movie-Emergence\06_小说\小说正文（待审核）'
$backupName = '__manus_backup_第二三部遗留P0_20260825_实施前_v2'
$backupRoot = Join-Path $root $backupName
$files = @(
    '第二部_061_继任者.md',
    '第二部_062_失力感积累.md',
    '第三部_063_魔胎.md',
    '第三部_064_谷氨酸风暴.md',
    '第三部_065_轮回的基线.md',
    '第三部_066_阳奉阴违.md'
)

if (Test-Path -LiteralPath $backupRoot) {
    throw "Backup directory already exists: $backupRoot"
}
New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
$manifest = New-Object System.Collections.Generic.List[string]
$manifest.Add('# 第二三部遗留P0实施前备份清单')
$manifest.Add('')
$manifest.Add('| 文件 | 原始字节数 | SHA256 |')
$manifest.Add('|---|---:|---|')
foreach ($fileName in $files) {
    $source = Join-Path $root $fileName
    if (-not (Test-Path -LiteralPath $source)) { throw "Missing source file: $source" }
    $destination = Join-Path $backupRoot $fileName
    Copy-Item -LiteralPath $source -Destination $destination -ErrorAction Stop
    $length = ([System.IO.FileInfo]$source).Length
    $hash = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash
    $manifest.Add('| ' + $fileName + ' | ' + $length + ' | ' + $hash + ' |')
}
$manifest.Add('')
$manifest.Add('> 本备份用于回滚第二部061—062的接种 / 继任 / 测量边界回收，以及第三部063—066的魔胎、湿核与维护者正典回收。')
$manifestPath = Join-Path $backupRoot 'SHA256基线与文件清单.md'
[System.IO.File]::WriteAllLines($manifestPath, $manifest, [System.Text.UTF8Encoding]::new($false))
Write-Output "BACKUP_ROOT=$backupRoot"
Write-Output "MANIFEST=$manifestPath"
