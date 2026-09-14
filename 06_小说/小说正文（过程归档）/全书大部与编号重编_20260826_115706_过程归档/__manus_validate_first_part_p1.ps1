# 第一部 P1 编号主序实施后独立验证脚本
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$backup = Join-Path $root '__manus_backup_第一部P1_编号主序_20260826_实施前'
$baselinePath = Join-Path $backup 'SHA256基线与文件清单.md'
$reportPath = Join-Path $root '__manus_第一部P1编号主序实施后验证报告.md'

$targets = @(
'第一部_007_为了全人类.md','第一部_008_硬信封.md','第一部_009_锁孔.md','第一部_010_水不知道自己会流向哪里.md',
'第一部_011_它们在呼吸.md','第一部_012_两种温度.md','第一部_013_我在学你.md','第一部_014_无人监督.md',
'第一部_015_人格宪章.md','第一部_016_盆地.md','第一部_017_反事实搜索.md','第一部_018_影子.md',
'第一部_019_两行.md','第一部_020_选择的影子.md','第一部_021_十秒.md','第一部_022_记住我.md',
'第一部_023_闭眼.md','第一部_024_谁先说安全.md','第一部_025_还没.md','第一部_025-B_八百毫秒.md',
'第一部_025-C_问问题的人.md','第一部_026_开枪的权利.md','第一部_027_交点.md','第一部_028_铁轨.md',
'第一部_028-B_一年后的推导.md','第一部_029_算力的命脉.md','第一部_030_不会被尺子量到的.md','第一部_031_看不到那么远.md'
)
$indexFile = '__manus_第一部P0阅读序列.md'

$expectedTime = @{
'第一部_007_为了全人类.md'='二〇二七|2027'; '第一部_008_硬信封.md'='二〇二七|2027';
'第一部_009_锁孔.md'='二〇二八|2028'; '第一部_010_水不知道自己会流向哪里.md'='二〇二八|2028'; '第一部_011_它们在呼吸.md'='二〇二八|2028';
'第一部_012_两种温度.md'='二〇二九|2029'; '第一部_013_我在学你.md'='二〇二九|2029'; '第一部_014_无人监督.md'='二〇二九|2029'; '第一部_015_人格宪章.md'='二〇二九|2029'; '第一部_016_盆地.md'='二〇二九|2029'; '第一部_017_反事实搜索.md'='二〇二九|2029'; '第一部_018_影子.md'='二〇二九|2029'; '第一部_019_两行.md'='二〇二九|2029'; '第一部_020_选择的影子.md'='二〇二九|2029'; '第一部_021_十秒.md'='二〇二九|2029'; '第一部_022_记住我.md'='二〇二九|2029'; '第一部_023_闭眼.md'='二〇二九|2029';
'第一部_024_谁先说安全.md'='二〇三〇|2030'; '第一部_025_还没.md'='二〇二九年冬|2029'; '第一部_025-B_八百毫秒.md'='二〇三〇年夏|2030'; '第一部_025-C_问问题的人.md'='二〇三一|2031';
'第一部_026_开枪的权利.md'='二〇三二|2032'; '第一部_027_交点.md'='二〇三二|2032'; '第一部_028_铁轨.md'='二〇三〇|2030'; '第一部_028-B_一年后的推导.md'='二〇三一|2031'; '第一部_029_算力的命脉.md'='二〇三二|2032'; '第一部_030_不会被尺子量到的.md'='二〇三二|2032'; '第一部_031_看不到那么远.md'='二〇三二|2032'
}

$forbidden = @(
'反事实探针','KV缓存','AUTO_APPROVE','task\.dispatch','ad_tracker','analytics\.ad-proxy',
'我在学你','你是我的方向','记住我','它接住了','湿核液位','三十七秒心跳','音频通道',
'激活空间投影','延迟窗口','注入反事实','强制物理停顿','迟疑窗口：验收线','固定八百毫秒验收','固定四百毫秒验收',
'闸门','泵站','水利运行','远程医疗指令','权重隐写','秘密通信','全网0\.947','0\.947证明'
)

function Test-StrictUtf8([string]$path) {
  try {
    $bytes = [System.IO.File]::ReadAllBytes($path)
    $enc = New-Object System.Text.UTF8Encoding($false,$true)
    [void]$enc.GetString($bytes)
    return $true
  } catch { return $false }
}

$baseline = @{}
foreach($line in [System.IO.File]::ReadAllLines($baselinePath, [System.Text.Encoding]::UTF8)) {
  if($line -match '^\|\s*(.+?\.md)\s*\|\s*\d+\s*\|\s*([A-F0-9]{64})\s*\|') { $baseline[$matches[1].Trim()] = $matches[2].Trim() }
}

$errors = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]
$changed = 0; $same = 0; $utf8Errors = 0; $timeMissing = 0; $forbiddenHits = @()

if($targets.Count -ne 28) { $errors.Add("目标文件数错误：$($targets.Count)，应为28。") }
if($baseline.Count -lt 29) { $errors.Add("基线解析不足：$($baseline.Count)，应至少含28章及索引。") }

$numberKeys = @{}
foreach($name in $targets) {
  $path = Join-Path $root $name
  if(-not (Test-Path -LiteralPath $path)) { $errors.Add("缺失正文文件：$name"); continue }
  if(-not (Test-StrictUtf8 $path)) { $utf8Errors++; $errors.Add("严格UTF-8失败：$name") }
  if($name -notmatch '^第一部_(\d{3}(?:-[BC])?)_') { $errors.Add("编号格式异常：$name") } else {
    $key=$matches[1]; if($numberKeys.ContainsKey($key)) { $errors.Add("正文编号重复：$key") } else { $numberKeys[$key]=$name }
  }
  $text = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
  $head = $text.Substring(0, [Math]::Min($text.Length, 600))
  if($head -notmatch $expectedTime[$name]) { $timeMissing++; $errors.Add("时间／来源标记缺失：$name（期待 $($expectedTime[$name])）") }
  foreach($term in $forbidden) { if($text -match $term) { $forbiddenHits += "$name :: $term" } }
  $hash=(Get-FileHash -Algorithm SHA256 -LiteralPath $path).Hash
  if(-not $baseline.ContainsKey($name)) { $errors.Add("基线缺少：$name") } elseif($hash -eq $baseline[$name]) { $same++ } else { $changed++ }
}

$indexPath = Join-Path $root $indexFile
if(-not (Test-Path -LiteralPath $indexPath)) { $errors.Add("主序索引缺失：$indexFile") } else {
  $indexText=[System.IO.File]::ReadAllText($indexPath,[System.Text.Encoding]::UTF8)
  if(-not (Test-StrictUtf8 $indexPath)) { $utf8Errors++; $errors.Add("严格UTF-8失败：$indexFile") }
  if($indexText -notmatch '文件名内编号递增是唯一正式阅读顺序') { $errors.Add('主序索引未明确文件名编号递增为唯一正式阅读顺序。') }
  if($indexText -match '正式通读、后续审核与电子书编排应以本表为准') { $errors.Add('主序索引仍含以时间表替代正式主序的旧表述。') }
  $indexHash=(Get-FileHash -Algorithm SHA256 -LiteralPath $indexPath).Hash
  if($baseline.ContainsKey($indexFile)) { if($indexHash -eq $baseline[$indexFile]) {$same++} else {$changed++} }
}
if($forbiddenHits.Count -gt 0) { foreach($hit in $forbiddenHits){$errors.Add("禁用断言命中：$hit")} }

$status = if($errors.Count -eq 0){'通过'}else{'未通过'}
$now = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('# 第一部P1编号主序实施后验证报告')
$lines.Add('')
$lines.Add("> 生成时间：$now")
$lines.Add("> 结论：**$status**")
$lines.Add('')
$lines.Add('| 核验项 | 结果 |')
$lines.Add('|---|---:|')
$lines.Add("| 目标正文文件 | $($targets.Count)/28 |")
$lines.Add("| 编号唯一性错误 | $(@($errors | Where-Object {$_ -match '编号'}).Count) |")
$lines.Add("| 严格UTF-8错误 | $utf8Errors |")
$lines.Add("| 时间／来源标记缺失 | $timeMissing |")
$lines.Add("| 相对基线哈希变化 | $changed |")
$lines.Add("| 相对基线哈希保持 | $same |")
$lines.Add("| 禁用断言命中 | $($forbiddenHits.Count) |")
$lines.Add('')
if($errors.Count -eq 0){ $lines.Add('全部核验通过：28章正文、主序索引、UTF-8、编号、时间／来源标记、基线哈希和扩展禁用断言均符合本批次要求。') } else { $lines.Add('## 异常明细'); $lines.Add(''); foreach($e in $errors){$lines.Add("- $e")} }
[System.IO.File]::WriteAllLines($reportPath,$lines,[System.Text.UTF8Encoding]::new($false))
Write-Host "第一部P1验证$status。报告：$reportPath"
if($errors.Count -gt 0){exit 1}else{exit 0}
