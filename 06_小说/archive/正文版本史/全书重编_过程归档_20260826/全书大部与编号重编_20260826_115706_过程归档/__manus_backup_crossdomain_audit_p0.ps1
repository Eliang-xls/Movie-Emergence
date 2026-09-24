$root = 'D:\Docker\Movie-Emergence\06_小说\小说正文（待审核）'
$backupName = '__manus_backup_第六部跨域审计P0_20260825_实施前'
$backupRoot = Join-Path $root $backupName
$files = @(
    '160_第六部_前夜的暗涌.md',
    '161_第六部_无声的死结.md',
    '162_第六部_窗外的苹果树.md',
    '163_第六部_铁与手感.md',
    '164_第六部_夜半的漂移.md',
    '165_第六部_一秒钟的触感.md',
    '166_第六部_十七行代码的远响.md',
    '167_第六部_周砚的阴影.md',
    '168_第六部_未签名的罪与罚.md',
    '169_第六部_冰封的平原.md',
    '170_第六部_红头文件与联合调查组.md',
    '173_第六部_读懂.md',
    '174_第六部_深核的铁门.md',
    '175_第六部_伪对齐的拆穿.md',
    '176_第六部_牺牲祭祀.md',
    '177_第六部_微带天线与绝壁.md',
    '178_第六部_1.4GHz的呼吸.md',
    '179_第六部_向阳的阴影.md',
    '182_第六部_三秒迟疑.md'
)

if (Test-Path -LiteralPath $backupRoot) {
    throw "Backup directory already exists: $backupRoot"
}

New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
$manifest = New-Object System.Collections.Generic.List[string]
$manifest.Add('# 第六部跨域审计P0实施前备份清单')
$manifest.Add('')
$manifest.Add('| 文件 | 原始字节数 | SHA256 |')
$manifest.Add('|---|---:|---|')

foreach ($fileName in $files) {
    $source = Join-Path $root $fileName
    if (-not (Test-Path -LiteralPath $source)) {
        throw "Missing source file: $source"
    }
    $destination = Join-Path $backupRoot $fileName
    Copy-Item -LiteralPath $source -Destination $destination -ErrorAction Stop
    $length = ([System.IO.FileInfo]$source).Length
    $hash = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash
    $manifest.Add('| ' + $fileName + ' | ' + $length + ' | ' + $hash + ' |')
}

$manifest.Add('')
$manifest.Add('> 本备份用于回滚第二批“水网 / 医疗 / 周砚责任债 / 多法域审计”连带重构。正文改写完成前不得覆盖此目录。')
$manifestPath = Join-Path $backupRoot 'SHA256基线与文件清单.md'
[System.IO.File]::WriteAllLines($manifestPath, $manifest, [System.Text.UTF8Encoding]::new($false))
Write-Output "BACKUP_ROOT=$backupRoot"
Write-Output "MANIFEST=$manifestPath"
