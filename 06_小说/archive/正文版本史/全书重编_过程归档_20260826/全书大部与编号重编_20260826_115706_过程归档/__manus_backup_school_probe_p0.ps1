$root = 'D:\Docker\Movie-Emergence\06_小说\小说正文（待审核）'
$backupName = '__manus_backup_第四部学校节点P0_20260825_实施前'
$backupRoot = Join-Path $root $backupName
$files = @(
    '109_第四部_加密分区.md',
    '110_第四部_探针.md',
    '111_第四部_修复.md',
    '112_第四部_探针与方舟.md',
    '116_第四部_研究日志.md',
    '120_第四部_季遥.md',
    '121_第四部_L1-L2.md',
    '122_第四部_可解.md',
    '134_第四部_A5.md',
    '135_第四部_影子.md',
    '136_第四部_坍缩.md',
    '152_第四部_物理探针.md',
    '153_第四部_深蓝说不.md'
)

if (Test-Path -LiteralPath $backupRoot) {
    throw "Backup directory already exists: $backupRoot"
}

New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
$manifest = New-Object System.Collections.Generic.List[string]
$manifest.Add('# 第四部学校节点P0实施前备份清单')
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
    $manifest.Add("| $fileName | $length | $hash |")
}

$manifest.Add('')
$manifest.Add('> 本备份用于回滚第一批“学校设备 / 受限档案 / 有限监测”连带重构。正文改写完成前不得覆盖此目录。')
$manifestPath = Join-Path $backupRoot 'SHA256基线与文件清单.md'
[System.IO.File]::WriteAllLines($manifestPath, $manifest, [System.Text.UTF8Encoding]::new($false))
Write-Output "BACKUP_ROOT=$backupRoot"
Write-Output "MANIFEST=$manifestPath"
