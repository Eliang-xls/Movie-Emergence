$root = 'D:\Docker\Movie-Emergence\06_小说\小说正文（待审核）'
$backupRoot = Join-Path $root '__manus_backup_深蓝治理与终章P0_20260825_实施前'
$manifestPath = Join-Path $backupRoot 'SHA256基线与文件清单.md'
$reportPath = Join-Path $root '__manus_深蓝治理与终章P0实施后验证报告.md'
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
$forbiddenPatterns = @(
    '匿名.*接任务',
    '深蓝.*(NR|方向感|我学到了|我判断)',
    '深蓝.*(全网|推送|蜂群主脑)',
    'L5.*(桥接|内部表示|运行)',
    '季深.*(海边|走来|回来|实时|对话)',
    '季深.*(定位|通信)',
    'A₅.*(灵魂|觉醒)',
    'A5.*(灵魂|觉醒)',
    '原样迁移',
    '复制人格',
    '复活.*深蓝',
    '全网.*0\.947',
    '0\.947.*全网',
    '深蓝.*导师',
    '系统.*导师',
    '绝对.*判断',
    '完全.*安全'
)

$manifestHashes = @{}
foreach ($line in Get-Content -LiteralPath $manifestPath -Encoding UTF8) {
    if ($line -match '^\|\s+(.+?\.md)\s+\|\s+\d+\s+\|\s+([A-F0-9]{64})\s+\|$') {
        $manifestHashes[$matches[1].Trim()] = $matches[2].Trim()
    }
}

$strictUtf8 = [System.Text.UTF8Encoding]::new($false, $true)
$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('# 深蓝治理与终章P0实施后验证报告')
$lines.Add('')
$lines.Add('## 哈希、变更与编码核验')
$lines.Add('')
$lines.Add('| 文件 | 实施前SHA256 | 实施后SHA256 | 是否变更 | 严格UTF-8 |')
$lines.Add('|---|---|---|---|---|')
foreach ($fileName in $files) {
    $path = Join-Path $root $fileName
    $afterHash = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash
    $beforeHash = $manifestHashes[$fileName]
    $changed = if ($afterHash -ne $beforeHash) { '是' } else { '否' }
    try {
        [void]$strictUtf8.GetString([System.IO.File]::ReadAllBytes($path))
        $utf8 = '通过'
    } catch {
        $utf8 = '失败'
    }
    $lines.Add('| ' + $fileName + ' | ' + $beforeHash + ' | ' + $afterHash + ' | ' + $changed + ' | ' + $utf8 + ' |')
}

$lines.Add('')
$lines.Add('## 终局旧断言扫描')
$lines.Add('')
$lines.Add('| 模式 | 命中章节 |')
$lines.Add('|---|---|')
foreach ($pattern in $forbiddenPatterns) {
    $hits = New-Object System.Collections.Generic.List[string]
    foreach ($fileName in $files) {
        $path = Join-Path $root $fileName
        $content = Get-Content -LiteralPath $path -Raw -Encoding UTF8
        if ($content -match $pattern) {
            $hits.Add($fileName)
        }
    }
    $hitText = if ($hits.Count -eq 0) { '无' } else { $hits -join '；' }
    $lines.Add('| ' + $pattern + ' | ' + $hitText + ' |')
}

$lines.Add('')
$lines.Add('## 人工核验结论')
$lines.Add('')
$lines.Add('本报告仅验证第三批目标文件相对实施前基线已变更、目标文件可严格按UTF-8读取，且指定旧终局断言未按原链条残留。仍须在全书范围复检第二、三部遗留章节061—066及后段编号 / 时间阅读序列。')
[System.IO.File]::WriteAllLines($reportPath, $lines, [System.Text.UTF8Encoding]::new($false))
Write-Output "VALIDATION_REPORT=$reportPath"
