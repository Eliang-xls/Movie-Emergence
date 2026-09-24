$root = 'D:\Docker\Movie-Emergence\06_小说\小说正文（待审核）'
$backupName = '__manus_backup_第三部P1-B_编号主序_20260826_实施前'
$backupRoot = Join-Path $root $backupName
$files = @(
    '第三部_067_零点七.md', '第三部_068_还在.md', '第三部_069_帘子.md', '第三部_070_事后审查.md',
    '第三部_074_靠近屏幕三次.md', '第三部_075_像星星的图.md', '第三部_076_独立成长.md', '第三部_077_帮与替.md',
    '第三部_078_主权要求.md', '第三部_079_涮羊肉馆.md', '第三部_080_读信.md', '第三部_081_上面的人.md',
    '第三部_082_偏了拉一把.md', '第三部_083_我翻译过.md', '第三部_084_琥珀色.md', '第三部_085_冰点.md',
    '第三部_086_听证会.md', '第三部_087_告别与离去.md', '第三部_088_交换.md'
)
if (Test-Path -LiteralPath $backupRoot) { throw "Backup directory already exists: $backupRoot" }
New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
$rows = New-Object System.Collections.Generic.List[string]
$rows.Add('# 第三部P1-B编号主序实施前SHA256基线与文件清单')
$rows.Add('')
$rows.Add('> 备份范围：第三部067—070、074—085、088。086—087虽已有P0内容，仍纳入本批以补齐原编号位置的档案时间卡。所有改写均保留文件名与编号。')
$rows.Add('')
$rows.Add('| 文件 | UTF-8字节数 | SHA256 |')
$rows.Add('|---|---:|---|')
foreach ($fileName in $files) {
    $source = Join-Path $root $fileName
    if (!(Test-Path -LiteralPath $source)) { throw "Missing source file: $source" }
    Copy-Item -LiteralPath $source -Destination (Join-Path $backupRoot $fileName) -Force
    $bytes = (Get-Item -LiteralPath $source).Length
    $hash = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash
    $rows.Add('| ' + $fileName + ' | ' + $bytes + ' | ' + $hash + ' |')
}
$manifest = Join-Path $backupRoot 'SHA256基线与文件清单.md'
[System.IO.File]::WriteAllLines($manifest, $rows, [System.Text.UTF8Encoding]::new($false))
Write-Output "BACKUP_ROOT=$backupRoot"
Write-Output "MANIFEST=$manifest"
