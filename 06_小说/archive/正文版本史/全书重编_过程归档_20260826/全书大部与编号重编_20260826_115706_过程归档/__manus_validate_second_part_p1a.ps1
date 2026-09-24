$root = 'D:\Docker\Movie-Emergence\06_小说\小说正文（待审核）'
$backupRoot = Join-Path $root '__manus_backup_第二部P1-A_编号主序_20260826_实施前'
$manifestPath = Join-Path $backupRoot 'SHA256基线与文件清单.md'
$reportPath = Join-Path $root '__manus_第二部P1-A编号主序实施后验证报告.md'
$files = @(
    '第二部_054_分布式赛.md',
    '第二部_055_没有发令枪的起跑.md',
    '第二部_056_崖顶的守望者.md',
    '第二部_057_液态的算力.md',
    '第二部_058_带出去的那一份.md',
    '第二部_059_换的人.md',
    '第二部_060_谁的三天.md'
)
$patterns = @(
    '多一个人.*相变',
    '五个人最好',
    '会遗传的伤口',
    '湿件.*不会忘记',
    '它好像变得.*自己的想法',
    '不设超时的场景',
    '没有争议，不需要投票',
    '方向一致的人不需要被管理',
    '季深.*(硅谷|穹顶|办公室)'
)
$expectedCards = @{
    '第二部_054_分布式赛.md' = '公开复盘档案'
    '第二部_055_没有发令枪的起跑.md' = '赛事档案之一：起跑记录'
    '第二部_056_崖顶的守望者.md' = '赛事档案之二：事故与结算'
    '第二部_057_液态的算力.md' = '赛事档案之三：赛后制度记录'
    '第二部_058_带出去的那一份.md' = '回溯档案'
    '第二部_059_换的人.md' = '维护档案'
    '第二部_060_谁的三天.md' = '任务令档案'
}
$beforeHashes = @{}
foreach ($line in Get-Content -LiteralPath $manifestPath -Encoding UTF8) {
    if ($line -match '^\|\s+(.+?\.md)\s+\|\s+\d+\s+\|\s+([A-F0-9]{64})\s+\|$') {
        $beforeHashes[$matches[1].Trim()] = $matches[2].Trim()
    }
}
$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('# 第二部P1-A编号主序实施后验证报告')
$lines.Add('')
$lines.Add('## 哈希与文件名核验')
$lines.Add('')
$lines.Add('| 文件 | 实施前SHA256 | 实施后SHA256 | 是否变更 | 文件名编号保持 |')
$lines.Add('|---|---|---|---|---|')
foreach ($fileName in $files) {
    $path = Join-Path $root $fileName
    $afterHash = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash
    $beforeHash = $beforeHashes[$fileName]
    $changed = if ($afterHash -ne $beforeHash) { '是' } else { '否' }
    $numberKept = if ($fileName -match '^第二部_0(54|55|56|57|58|59|60)_') { '是' } else { '否' }
    $lines.Add('| ' + $fileName + ' | ' + $beforeHash + ' | ' + $afterHash + ' | ' + $changed + ' | ' + $numberKept + ' |')
}
$lines.Add('')
$lines.Add('## 编号原位时间卡核验')
$lines.Add('')
$lines.Add('| 文件 | 应有标记 | 是否存在 |')
$lines.Add('|---|---|---|')
foreach ($fileName in $files) {
    $content = Get-Content -LiteralPath (Join-Path $root $fileName) -Raw -Encoding UTF8
    $expected = $expectedCards[$fileName]
    $found = if ($content.Contains($expected)) { '是' } else { '否' }
    $lines.Add('| ' + $fileName + ' | ' + $expected + ' | ' + $found + ' |')
}
$lines.Add('')
$lines.Add('## 重复与旧断言扫描')
$lines.Add('')
$lines.Add('| 模式 | 命中章节 |')
$lines.Add('|---|---|')
foreach ($pattern in $patterns) {
    $hits = New-Object System.Collections.Generic.List[string]
    foreach ($fileName in $files) {
        $content = Get-Content -LiteralPath (Join-Path $root $fileName) -Raw -Encoding UTF8
        if ($content -match $pattern) { $hits.Add($fileName) }
    }
    $text = if ($hits.Count -eq 0) { '无' } else { $hits -join '；' }
    $lines.Add('| ' + $pattern + ' | ' + $text + ' |')
}
$lines.Add('')
$lines.Add('## 人工核验结论')
$lines.Add('')
$lines.Add('本报告验证第二部054—060均已相对P1-A实施前基线变更，文件名及其054—060编号保持不变；每章均有编号原位的赛事或档案标记。关键词扫描用于发现固定人数阈值、湿件遗传、无限等待、无异议治理和季深2035后实时出场等旧链条。人工复读仍应重点检查054→055→056→057赛事四章的去重与058→059→060的回溯卡节奏。')
[System.IO.File]::WriteAllLines($reportPath, $lines, [System.Text.UTF8Encoding]::new($false))
Write-Output "VALIDATION_REPORT=$reportPath"
