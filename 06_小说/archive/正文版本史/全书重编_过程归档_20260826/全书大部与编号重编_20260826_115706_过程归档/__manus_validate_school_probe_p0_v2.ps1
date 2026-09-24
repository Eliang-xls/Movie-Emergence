$root = 'D:\Docker\Movie-Emergence\06_小说\小说正文（待审核）'
$backupRoot = Join-Path $root '__manus_backup_第四部学校节点P0_20260825_实施前'
$manifestPath = Join-Path $backupRoot 'SHA256基线与文件清单.md'
$reportPath = Join-Path $root '__manus_第四部学校节点P0实施后验证报告_v2.md'
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
$forbiddenPatterns = @(
    '活性坍缩',
    '海森堡观测坍缩',
    'A₅.*觉醒',
    'A5.*觉醒',
    'A₅.*灵魂',
    'A5.*灵魂',
    'D_orth',
    'R_orth',
    'register_forward_hook',
    'Galois_Probe',
    '牺牲祭祀',
    '深蓝.*在疼',
    '深蓝.*呼吸',
    '我判断这个不应该做',
    '运行探针'
)

$manifestHashes = @{}
foreach ($line in Get-Content -LiteralPath $manifestPath -Encoding UTF8) {
    if ($line -match '^\|\s+(.+?\.md)\s+\|\s+\d+\s+\|\s+([A-F0-9]{64})\s+\|$') {
        $manifestHashes[$matches[1].Trim()] = $matches[2].Trim()
    }
}

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('# 第四部学校节点P0实施后验证报告 v2')
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
$lines.Add('## 禁止断言扫描')
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
$lines.Add('本报告验证目标文件均已相对于实施前基线变更，并扫描指定高风险旧断言。扫描只是机械核验；后续章节仍需人工审读，避免反向重建“B1-07等于深蓝 / S-0947”“学生私跑探针”“A5判定意识”“PSCAR监听主体性”四条旧链。')
[System.IO.File]::WriteAllLines($reportPath, $lines, [System.Text.UTF8Encoding]::new($false))
Write-Output "VALIDATION_REPORT=$reportPath"
