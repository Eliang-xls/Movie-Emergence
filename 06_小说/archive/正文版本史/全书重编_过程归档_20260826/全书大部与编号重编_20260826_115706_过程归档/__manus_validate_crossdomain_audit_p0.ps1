$root = 'D:\Docker\Movie-Emergence\06_小说\小说正文（待审核）'
$backupRoot = Join-Path $root '__manus_backup_第六部跨域审计P0_20260825_实施前'
$manifestPath = Join-Path $backupRoot 'SHA256基线与文件清单.md'
$reportPath = Join-Path $root '__manus_第六部跨域审计P0实施后验证报告.md'
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
$forbiddenPatterns = @(
    '0\.003.*(医疗|给药|湿件|突触)',
    '(水网|医疗).*同一个源头',
    '全网.*0\.947',
    '0\.947.*全网',
    'SVD.*(天枢|深核|坐标)',
    'TEMPEST',
    '物理.*呼吸',
    '灵魂呼吸',
    '牺牲祭祀完成',
    'Galois_Probe',
    'register_forward_hook',
    '活性坍缩',
    '我判断这个不应该做',
    '全球所有 ICU',
    '手动阻尼模式',
    '私自.*跨网',
    '内置.*武器',
    '强制.*开门'
)

$manifestHashes = @{}
foreach ($line in Get-Content -LiteralPath $manifestPath -Encoding UTF8) {
    if ($line -match '^\|\s+(.+?\.md)\s+\|\s+\d+\s+\|\s+([A-F0-9]{64})\s+\|$') {
        $manifestHashes[$matches[1].Trim()] = $matches[2].Trim()
    }
}

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('# 第六部跨域审计P0实施后验证报告')
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
$lines.Add('## 旧高风险断言扫描')
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
$lines.Add('本报告仅验证第二批目标文件相对实施前基线已变更，且指定旧高风险断言未按原链条残留。它不能替代后续人工审读：尤其应检查183—190是否反向复活季深实体、湿核原样继承、深蓝导师化、天枢单一主脑和绝对判断论。')
[System.IO.File]::WriteAllLines($reportPath, $lines, [System.Text.UTF8Encoding]::new($false))
Write-Output "VALIDATION_REPORT=$reportPath"
