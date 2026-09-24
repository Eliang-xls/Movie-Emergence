$ErrorActionPreference = 'Stop'

$root = 'D:\Docker\Movie-Emergence\06_小说\小说正文（待审核）'
$backup = Join-Path $root '__manus_backup_第三部P1-B_编号主序_20260826_实施前'
$baselinePath = Join-Path $backup 'SHA256基线与文件清单.md'
$reportPath = Join-Path $root '__manus_第三部P1-B编号主序实施后验证报告.md'
$targets = @(
  '第三部_067_零点七.md', '第三部_068_还在.md', '第三部_069_帘子.md', '第三部_070_事后审查.md',
  '第三部_074_靠近屏幕三次.md', '第三部_075_像星星的图.md', '第三部_076_独立成长.md', '第三部_077_帮与替.md',
  '第三部_078_主权要求.md', '第三部_079_涮羊肉馆.md', '第三部_080_读信.md', '第三部_081_上面的人.md',
  '第三部_082_偏了拉一把.md', '第三部_083_我翻译过.md', '第三部_084_琥珀色.md', '第三部_085_冰点.md',
  '第三部_086_听证会.md', '第三部_087_告别与离去.md', '第三部_088_交换.md'
)
$timeCards = @{
  '第三部_074_靠近屏幕三次.md' = '时间卡：.*十四岁.*评审记录'
  '第三部_075_像星星的图.md' = '童年记忆卡'
  '第三部_076_独立成长.md' = '二〇四四年'
  '第三部_077_帮与替.md' = '来源说明'
  '第三部_082_偏了拉一把.md' = '二〇三五年二月。未发送笔记'
  '第三部_085_冰点.md' = '时间卡：.*二〇四四年审查材料'
  '第三部_086_听证会.md' = '时间卡：.*二〇三三年秋听证档案'
  '第三部_087_告别与离去.md' = '时间卡：.*二〇三五年维护交接档案'
  '第三部_088_交换.md' = '时间卡：.*二〇四四年'
}
$forbidden = @{
  'A5作为意识或灵魂判定' = 'A5[^\r\n]{0,80}(?:证明|判定)[^\r\n]{0,80}(?:意识|灵魂)'
  '深蓝全网自治或判断' = '深蓝[^\r\n]{0,80}(?:全网|学习判断|我判断)'
  'L8人格全息化' = 'L8[^\r\n]{0,80}(?:人格|全息)'
  '权重隐写或空窗发送' = '(?:权重[^\r\n]{0,80}(?:藏|写入|保存).{0,80}信息|空窗[^\r\n]{0,80}发送|0\.003[^\r\n]{0,80}诱导)'
  '季深2035后实时在场' = '季深[^\r\n]{0,120}(?:二〇四[零一二三四五六七八九]|204[0-9])[^\r\n]{0,120}(?:办公室|视频|海边|现场)'
}

$baseline = @{}
foreach ($line in Get-Content -LiteralPath $baselinePath -Encoding UTF8) {
  if ($line -match '^\|\s*(第三部_\d{3}_[^|]+\.md)\s*\|\s*\d+\s*\|\s*([A-F0-9]{64})\s*\|$') {
    $baseline[$matches[1]] = $matches[2]
  }
}

$failures = New-Object System.Collections.Generic.List[string]
$rows = New-Object System.Collections.Generic.List[string]
$utf8 = New-Object System.Text.UTF8Encoding($false, $true)
foreach ($name in $targets) {
  $path = Join-Path $root $name
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
    $failures.Add("缺少目标文件：$name")
    $rows.Add("| $name | 缺失 | — | 失败 |")
    continue
  }
  try {
    $text = [System.IO.File]::ReadAllText($path, $utf8)
  } catch {
    $failures.Add("非严格UTF-8：$name")
    $text = ''
  }
  $after = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash
  $before = $baseline[$name]
  $changed = if ($before -and $before -ne $after) { '已变化' } elseif ($before) { '未变化' } else { '无基线' }
  if (-not $before) { $failures.Add("基线缺项：$name") }
  if ($changed -ne '已变化') { $failures.Add("未检测到实施后哈希变化：$name") }
  $rows.Add("| $name | $before | $after | $changed |")
}

$currentNames = Get-ChildItem -LiteralPath $root -File | Where-Object { $_.Name -match '^第三部_(067|068|069|070|074|075|076|077|078|079|080|081|082|083|084|085|086|087|088)_' } | Select-Object -ExpandProperty Name
foreach ($name in $targets) { if ($currentNames -notcontains $name) { $failures.Add("编号或文件名不一致：$name") } }
if ($currentNames.Count -ne $targets.Count) { $failures.Add("目标编号范围中存在重复或意外文件：$($currentNames -join '；')") }

foreach ($name in $timeCards.Keys) {
  $text = Get-Content -LiteralPath (Join-Path $root $name) -Raw -Encoding UTF8
  if ($text -notmatch $timeCards[$name]) { $failures.Add("时间卡缺失或不匹配：$name") }
}

$combined = ($targets | ForEach-Object { Get-Content -LiteralPath (Join-Path $root $_) -Raw -Encoding UTF8 }) -join "`n"
foreach ($label in $forbidden.Keys) {
  if ($combined -match $forbidden[$label]) { $failures.Add("发现废止断言：$label") }
}

$status = if ($failures.Count -eq 0) { '通过' } else { '未通过' }
$report = @()
$report += '# 第三部P1-B编号主序实施后验证报告'
$report += ''
$report += "> 生成时间：$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss K')。验证范围严格限定为备份清单中的19章：067—070、074—085、088；086—087仅补原编号位置的档案时间卡。正式阅读顺序仍以文件名编号递增为准。"
$report += ''
$report += "**总结果：$status**"
$report += ''
$report += '## 哈希与文件名核验'
$report += ''
$report += '| 文件 | 实施前SHA256 | 实施后SHA256 | 状态 |'
$report += '|---|---|---|---|'
$report += $rows
$report += ''
$report += '## 规则核验'
$report += ''
$report += "| 项目 | 结果 |"
$report += '|---|---|'
$report += "| 19个文件名与编号唯一性 | $(if ($currentNames.Count -eq $targets.Count) {'通过'} else {'未通过'}) |"
$report += "| 严格UTF-8读取 | $(if ($failures | Where-Object { $_ -like '非严格UTF-8*' }) {'未通过'} else {'通过'}) |"
$report += "| 指定时间卡 | $(if ($failures | Where-Object { $_ -like '时间卡缺失*' }) {'未通过'} else {'通过'}) |"
$report += "| 废止断言扫描 | $(if ($failures | Where-Object { $_ -like '发现废止断言*' }) {'未通过'} else {'通过'}) |"
$report += ''
$report += '## 失败项或说明'
$report += ''
if ($failures.Count -eq 0) { $report += '无。' } else { $failures | ForEach-Object { $report += "- $_" } }
$report += ''
$report += '## 回滚信息'
$report += ''
$report += '实施前正文与SHA256基线保存在 `__manus_backup_第三部P1-B_编号主序_20260826_实施前`。如需回滚，仅从该目录按同名文件覆盖，不改变正文目录中的文件名或编号。'

[System.IO.File]::WriteAllText($reportPath, ($report -join "`r`n") + "`r`n", (New-Object System.Text.UTF8Encoding($false)))
if ($failures.Count -gt 0) { Write-Error (($failures -join "`n")); exit 1 }
Write-Output "验证通过：$reportPath"
