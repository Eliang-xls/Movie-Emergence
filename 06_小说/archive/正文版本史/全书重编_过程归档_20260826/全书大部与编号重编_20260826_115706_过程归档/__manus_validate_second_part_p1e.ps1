# 第二部 P1-E 编号主序实施后独立验证脚本
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$backup = Join-Path $root '__manus_backup_第二部P1-E_编号主序_20260826_实施前'
$baselinePath = Join-Path $backup 'SHA256基线与文件清单.md'
$reportPath = Join-Path $root '__manus_第二部P1-E编号主序实施后验证报告.md'
$targets = @(
'第二部_032_一个人的网络.md','第二部_033_十四天.md','第二部_034_甜蜜点.md','第二部_035_不需要我们了.md',
'第二部_036_越权.md','第二部_037_规则与庄稼.md','第二部_038_太平滑了.md','第二部_039_桥不走回头路.md',
'第二部_040_暗流.md','第二部_041_深蓝诞生.md','第二部_042_外公.md','第二部_043_顾清的告别.md',
'第二部_044_大迁徙.md','第二部_045_害怕自由.md','第二部_046_结冰.md','第二部_047_噪声低.md',
'第二部_048_理论的尽头.md','第二部_049_算力的切片.md','第二部_050_万物的呼吸.md','第二部_051_782ms.md',
'第二部_052_播种.md','第二部_053_设计翻译.md'
)
$expectedTime = @{
'第二部_032_一个人的网络.md'='二〇三三|2033'; '第二部_033_十四天.md'='二〇三三|2033';
'第二部_034_甜蜜点.md'='二〇三四|2034'; '第二部_035_不需要我们了.md'='二〇三四|2034'; '第二部_036_越权.md'='二〇三四|2034'; '第二部_037_规则与庄稼.md'='二〇三四|2034'; '第二部_038_太平滑了.md'='二〇三四|2034'; '第二部_039_桥不走回头路.md'='二〇三四|2034'; '第二部_040_暗流.md'='二〇三四|2034';
'第二部_041_深蓝诞生.md'='二〇三三|2033'; '第二部_042_外公.md'='二〇三四|2034'; '第二部_043_顾清的告别.md'='二〇三五|2035'; '第二部_044_大迁徙.md'='二〇三四|2034'; '第二部_045_害怕自由.md'='二〇三四|2034'; '第二部_046_结冰.md'='二〇三四|2034'; '第二部_047_噪声低.md'='二〇三四|2034'; '第二部_048_理论的尽头.md'='二〇三四|2034'; '第二部_049_算力的切片.md'='二〇三四|2034'; '第二部_050_万物的呼吸.md'='二〇三四|2034'; '第二部_051_782ms.md'='二〇四二|2042'; '第二部_052_播种.md'='二〇三〇|2030'; '第二部_053_设计翻译.md'='二〇三四|2034'
}
$forbidden = @(
'反事实探针','KV缓存','AUTO_APPROVE','task\.dispatch','ad_tracker','analytics\.ad-proxy',
'湿核液位','突触连接模式','记忆迁移','人格迁移','全网0\.947','固定相变','自动合并证明','自动资源倒灌',
'闸门','泵站','灌溉量','温度补偿系数','远程医疗指令','权重隐写','秘密通信',
'L8印记','声誉分','能证L','固定八百毫秒','固定四百毫秒','我在学你','你需要的不是一个答案'
)
function Test-StrictUtf8([string]$path){ try { $bytes=[IO.File]::ReadAllBytes($path); $enc=New-Object Text.UTF8Encoding($false,$true); [void]$enc.GetString($bytes); $true } catch { $false } }
$baseline=@{}
foreach($line in [IO.File]::ReadAllLines($baselinePath,[Text.Encoding]::UTF8)){ if($line -match '^\|\s*(.+?\.md)\s*\|\s*\d+\s*\|\s*([A-F0-9]{64})\s*\|'){ $baseline[$matches[1].Trim()]=$matches[2].Trim() } }
$errors=New-Object 'System.Collections.Generic.List[string]'; $changed=0; $same=0; $utf8=0; $timeMissing=0; $hits=@(); $numbers=@{}
if($targets.Count -ne 22){$errors.Add("目标数错误：$($targets.Count)，应为22")}
foreach($name in $targets){
  $path=Join-Path $root $name
  if(-not(Test-Path -LiteralPath $path)){$errors.Add("缺失正文：$name"); continue}
  if(-not(Test-StrictUtf8 $path)){$utf8++;$errors.Add("严格UTF-8失败：$name")}
  if($name -notmatch '^第二部_(\d{3})_'){$errors.Add("编号格式错误：$name")} elseif($numbers.ContainsKey($matches[1])){$errors.Add("编号重复：$($matches[1])")} else {$numbers[$matches[1]]=$name}
  $text=[IO.File]::ReadAllText($path,[Text.Encoding]::UTF8); $head=$text.Substring(0,[Math]::Min(600,$text.Length))
  if($head -notmatch $expectedTime[$name]){$timeMissing++;$errors.Add("时间／来源卡缺失：$name（期待 $($expectedTime[$name])）")}
  foreach($term in $forbidden){if($text -match $term){$hits += "$name :: $term"}}
  $hash=(Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash
  if(-not $baseline.ContainsKey($name)){$errors.Add("基线缺失：$name")}elseif($hash -eq $baseline[$name]){$same++}else{$changed++}
}
foreach($hit in $hits){$errors.Add("禁用断言命中：$hit")}
$status=if($errors.Count -eq 0){'通过'}else{'未通过'}
$lines=New-Object 'System.Collections.Generic.List[string]'; $lines.Add('# 第二部P1-E编号主序实施后验证报告');$lines.Add('');$lines.Add("> 生成时间：$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')");$lines.Add("> 结论：**$status**");$lines.Add('');$lines.Add('| 核验项 | 结果 |');$lines.Add('|---|---:|');$lines.Add("| 目标正文文件 | $($targets.Count)/22 |");$lines.Add("| 编号唯一性错误 | $(@($errors | ? {$_ -match '编号'}).Count) |");$lines.Add("| 严格UTF-8错误 | $utf8 |");$lines.Add("| 时间／来源标记缺失 | $timeMissing |");$lines.Add("| 相对基线哈希变化 | $changed |");$lines.Add("| 相对基线哈希保持 | $same |");$lines.Add("| 禁用断言命中 | $($hits.Count) |");$lines.Add('')
if($errors.Count -eq 0){$lines.Add('全部核验通过：22章正文的编号、严格UTF-8、时间／来源卡、SHA256变更和扩展禁用断言均符合第二部P1-E要求。')}else{$lines.Add('## 异常明细');$lines.Add('');foreach($e in $errors){$lines.Add("- $e")}}
[IO.File]::WriteAllLines($reportPath,$lines,[Text.UTF8Encoding]::new($false)); Write-Host "第二部P1-E验证$status。报告：$reportPath"; if($errors.Count -gt 0){exit 1}else{exit 0}
