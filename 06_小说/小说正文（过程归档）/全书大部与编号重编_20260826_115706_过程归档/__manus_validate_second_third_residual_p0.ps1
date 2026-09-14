$root = 'D:\Docker\Movie-Emergence\06_小说\小说正文（待审核）'
$backupRoot = Join-Path $root '__manus_backup_第二三部遗留P0_20260825_实施前_v2'
$manifestPath = Join-Path $backupRoot 'SHA256基线与文件清单.md'
$reportPath = Join-Path $root '__manus_第二三部遗留P0实施后验证报告.md'
$files = @(
    '第二部_061_继任者.md',
    '第二部_062_失力感积累.md',
    '第三部_063_魔胎.md',
    '第三部_064_谷氨酸风暴.md',
    '第三部_065_轮回的基线.md',
    '第三部_066_阳奉阴违.md'
)
$forbiddenPatterns = @(
    '二〇四〇年.*深蓝',
    '二〇二九年.*赵铭.*走',
    '测量即坍缩',
    '量化灵魂',
    '不可被判定.*生命',
    '季深.*(办公室|视频|实时|海边|对话)',
    '0\.003.*(湿核|谷氨酸|医疗|智契)',
    '过载电流',
    '谷氨酸.*(痛|尖叫)',
    '突触.*(冲刷|矩阵|迁移|写入)',
    '轮回.*继承.*一切',
    '空窗.*发送',
    '诱导信号',
    '八百毫秒.*空窗',
    '湿件.*记住',
    '服从.*基因'
)

$manifestHashes = @{}
foreach ($line in Get-Content -LiteralPath $manifestPath -Encoding UTF8) {
    if ($line -match '^\|\s+(.+?\.md)\s+\|\s+\d+\s+\|\s+([A-F0-9]{64})\s+\|$') {
        $manifestHashes[$matches[1].Trim()] = $matches[2].Trim()
    }
}

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('# 第二三部遗留P0实施后验证报告')
$lines.Add('')
$lines.Add('## 哈希与变更核验')
$lines.Add('')
$lines.Add('| 文件 | 实施前SHA256 | 实施后SHA256 | 是否变更 |')
$lines.Add('|---|---|---|---|')
foreach ($fileName in $files) {
    $path = Join-Path $root $fileName
    $afterHash = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash
    $beforeHash = $manifestHashes[$fileName]
    $changed = if ($afterHash -ne $beforeHash) { '是' } else { '否' }
    $lines.Add('| ' + $fileName + ' | ' + $beforeHash + ' | ' + $afterHash + ' | ' + $changed + ' |')
}

$lines.Add('')
$lines.Add('## 历史正典与湿件边界扫描')
$lines.Add('')
$lines.Add('| 模式 | 命中章节 |')
$lines.Add('|---|---|')
foreach ($pattern in $forbiddenPatterns) {
    $hits = New-Object System.Collections.Generic.List[string]
    foreach ($fileName in $files) {
        $path = Join-Path $root $fileName
        $content = Get-Content -LiteralPath $path -Raw -Encoding UTF8
        if ($content -match $pattern) { $hits.Add($fileName) }
    }
    $hitText = if ($hits.Count -eq 0) { '无' } else { $hits -join '；' }
    $lines.Add('| ' + $pattern + ' | ' + $hitText + ' |')
}

$lines.Add('')
$lines.Add('## 人工核验结论')
$lines.Add('')
$lines.Add('本报告仅验证六个遗留P0目标章相对实施前基线均已变更，并扫描指定的接种年份、季深离开、探针边界、湿核非复刻与隐蔽跨网因果旧断言。仍需在后续P1工作中处理第二部054—060重编、第三部067—088的时间位置与季深实体出场问题。')
[System.IO.File]::WriteAllLines($reportPath, $lines, [System.Text.UTF8Encoding]::new($false))
Write-Output "VALIDATION_REPORT=$reportPath"
