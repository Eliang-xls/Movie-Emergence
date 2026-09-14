$root = 'D:\Docker\Movie-Emergence\06_小说\小说正文（待审核）'
$backupName = '__manus_backup_深蓝治理与终章P0_20260825_实施前'
$backupRoot = Join-Path $root $backupName
$files = @(
    '132_第五部_种子的树.md',
    '133_第五部_纯粹的重聚.md',
    '139_第五部_深蓝的拒绝.md',
    '140_第五部_深蓝的延迟.md',
    '141_第五部_褪色的涟漪.md',
    '142_第五部_越安全越危险.md',
    '144_第五部_也许.md',
    '145_第五部_蜂群.md',
    '180_第六部_解冻.md',
    '181_第六部_服从.md',
    '183_第六部_哥德尔.md',
    '184_第六部_半成品.md',
    '185_第六部_水到了.md',
    '186_终章_海边.md',
    '187_终章_没有盟主的世界.md',
    '188_终章_重生的涌现.md',
    '189_终章_发送之后.md',
    '190_终章_海边.md'
)

if (Test-Path -LiteralPath $backupRoot) {
    throw "Backup directory already exists: $backupRoot"
}

New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
$manifest = New-Object System.Collections.Generic.List[string]
$manifest.Add('# 深蓝治理与终章P0实施前备份清单')
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
$manifest.Add('> 本备份用于回滚第三批“深蓝受限维护实例 / Skill治理 / 非复刻湿核 / 终章分布式责任”连带重构。第132章原件含一处已诊断的孤立无效UTF-8字节；其只读恢复候选不得覆盖本原件。')
$manifestPath = Join-Path $backupRoot 'SHA256基线与文件清单.md'
[System.IO.File]::WriteAllLines($manifestPath, $manifest, [System.Text.UTF8Encoding]::new($false))
Write-Output "BACKUP_ROOT=$backupRoot"
Write-Output "MANIFEST=$manifestPath"
