$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$stamp = '20260826'
$backupName = "__manus_backup_第二部P1-E_编号主序_${stamp}_实施前"
$backup = Join-Path $root $backupName
$targets = @(
'第二部_032_一个人的网络.md','第二部_033_十四天.md','第二部_034_甜蜜点.md','第二部_035_不需要我们了.md',
'第二部_036_越权.md','第二部_037_规则与庄稼.md','第二部_038_太平滑了.md','第二部_039_桥不走回头路.md',
'第二部_040_暗流.md','第二部_041_深蓝诞生.md','第二部_042_外公.md','第二部_043_顾清的告别.md',
'第二部_044_大迁徙.md','第二部_045_害怕自由.md','第二部_046_结冰.md','第二部_047_噪声低.md',
'第二部_048_理论的尽头.md','第二部_049_算力的切片.md','第二部_050_万物的呼吸.md','第二部_051_782ms.md',
'第二部_052_播种.md','第二部_053_设计翻译.md'
)
if(-not (Test-Path -LiteralPath $backup)){ New-Item -ItemType Directory -Path $backup | Out-Null }
$rows = New-Object System.Collections.Generic.List[string]
$rows.Add('# 第二部P1-E编号主序实施前SHA256基线与文件清单')
$rows.Add('')
$rows.Add('> 备份范围：第二部032—053的22个现有正文文件。正式阅读主序仅按文件名编号递增。')
$rows.Add('')
$rows.Add('| 文件 | UTF-8字节数 | SHA256 |')
$rows.Add('|---|---:|---|')
foreach($name in $targets){
  $source=Join-Path $root $name
  if(-not (Test-Path -LiteralPath $source)){ throw "缺失目标正文：$name" }
  $dest=Join-Path $backup $name
  Copy-Item -LiteralPath $source -Destination $dest -Force
  $hash=(Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash
  $bytes=(Get-Item -LiteralPath $source).Length
  $rows.Add("| $name | $bytes | $hash |")
}
$baseline=Join-Path $backup 'SHA256基线与文件清单.md'
[System.IO.File]::WriteAllLines($baseline,$rows,[System.Text.UTF8Encoding]::new($false))
Write-Host "第二部P1-E备份完成：$backup；正文文件数：$($targets.Count)"
