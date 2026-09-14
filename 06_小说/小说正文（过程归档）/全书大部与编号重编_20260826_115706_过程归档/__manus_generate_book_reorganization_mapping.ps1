$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSCommandPath
$MarkdownOutput = Join-Path $Root '__manus_全书大部与章节编号重编拟议映射.md'
$CsvOutput = Join-Path $Root '__manus_全书大部与章节编号重编拟议映射.csv'
$Utf8 = [System.Text.UTF8Encoding]::new($false)
$Pattern = '^(?:(?<part>前传|第一部|第二部|第三部|第四部|第五部|第六部|终章)_)?(?<number>\d{3})(?<suffix>-[A-Z])?_(?:(?<partAfter>第一部|第二部|第三部|第四部|第五部|第六部|终章)_)?(?<title>.+)\.md$'
$Files = @(Get-ChildItem -LiteralPath $Root -File -Filter '*.md' | Where-Object { $_.Name -notlike '__manus_*' -and $_.Name -notlike '章节重编号记录_*' })
$Source = foreach ($File in $Files) {
  $Match = [regex]::Match($File.Name, $Pattern)
  if (-not $Match.Success) { throw "未能识别正文文件名：$($File.Name)" }
  $CurrentPart = if ($Match.Groups['part'].Success) { $Match.Groups['part'].Value } elseif ($Match.Groups['partAfter'].Success) { $Match.Groups['partAfter'].Value } else { '未标注大部' }
  [PSCustomObject]@{
    CurrentNumber = [int]$Match.Groups['number'].Value
    CurrentSuffix = $Match.Groups['suffix'].Value
    CurrentPart = $CurrentPart
    CurrentFile = $File.Name
    Title = $Match.Groups['title'].Value
  }
}
$Source = @($Source | Sort-Object CurrentNumber, CurrentSuffix, CurrentFile)
if ($Source.Count -ne 186) { throw "正文计数异常：预期186章，实际$($Source.Count)章" }

function Get-ProposedPart([int]$Number) {
  if ($Number -le 6) { return '前传' }
  if ($Number -le 34) { return '第一部' }
  if ($Number -le 65) { return '第二部' }
  if ($Number -le 91) { return '第三部' }
  if ($Number -le 125) { return '第四部' }
  if ($Number -le 152) { return '第五部' }
  if ($Number -le 181) { return '第六部' }
  return '终章'
}
function Get-VolumeName([string]$Part) {
  switch ($Part) {
    '前传' { return '沉默的草稿' }
    '第一部' { return '穹顶' }
    '第二部' { return '离散的网络' }
    '第三部' { return '读错的信号' }
    '第四部' { return '方舟' }
    '第五部' { return '种子的树' }
    '第六部' { return '门与证据' }
    '终章' { return '海边之后' }
  }
}
$Rows = for ($Index = 0; $Index -lt $Source.Count; $Index++) {
  $Item = $Source[$Index]
  $NewNumber = $Index + 1
  $NewPart = Get-ProposedPart $NewNumber
  [PSCustomObject]@{
    NewNumber = $NewNumber
    NewPart = $NewPart
    NewVolumeName = Get-VolumeName $NewPart
    NewFile = '{0}_{1:000}_{2}.md' -f $NewPart, $NewNumber, $Item.Title
    CurrentNumber = $Item.CurrentNumber.ToString('000') + $Item.CurrentSuffix
    CurrentPart = $Item.CurrentPart
    CurrentFile = $Item.CurrentFile
    Title = $Item.Title
  }
}
$Lines = New-Object System.Collections.Generic.List[string]
$Lines.Add('# 《涌现》全书大部与章节编号重编：拟议映射')
$Lines.Add('')
$Lines.Add('> **性质：** 仅为编排提案与实施清单；尚未改名、移动或改写正文。')
$Lines.Add('> **排序依据：** 当前已验证的正文文件名主序；本方案将其转写为001—186连续编号。')
$Lines.Add('')
$Lines.Add('## 拟议成书结构')
$Lines.Add('')
$Lines.Add('| 大部 | 成书名 | 新章节范围 | 章节数 | 叙事职责 |')
$Lines.Add('|---|---|---:|---:|---|')
$Ranges = @(
  @('前传','沉默的草稿','001—006','6','创办前的个人、资本与方法阴影。'),
  @('第一部','穹顶','007—034','28','公司建立、宪章实验、探针前史与责任债。'),
  @('第二部','离散的网络','035—065','31','公开协作、人员退场、酿造扩散与维护经验。'),
  @('第三部','读错的信号','066—091','26','异常资料、有限表征、家族／监管档案与听证边界。'),
  @('第四部','方舟','092—125','34','林屿入校、方舟事件、学习与可解性的阶段成长。'),
  @('第五部','种子的树','126—152','27','种子、衰减、蜂群、深蓝受限维护与公共治理。'),
  @('第六部','门与证据','153—181','29','跨域审计、异常簇、公开复核与修复。'),
  @('终章','海边之后','182—186','5','克莱因瓶、新实例与非封闭的制度后记。')
)
foreach ($Range in $Ranges) { $Lines.Add('| ' + ($Range -join ' | ') + ' |') }
$Lines.Add('')
$Lines.Add('## 全章映射')
$Lines.Add('')
$Lines.Add('| 新编号 | 新大部 | 当前编号 | 当前大部 | 标题 | 当前文件名 | 拟议文件名 |')
$Lines.Add('|---:|---|---|---|---|---|---|')
foreach ($Row in $Rows) {
  $Lines.Add(('| {0:000} | {1} | {2} | {3} | {4} | `{5}` | `{6}` |' -f $Row.NewNumber, $Row.NewPart, $Row.CurrentNumber, $Row.CurrentPart, $Row.Title, $Row.CurrentFile, $Row.NewFile))
}
$Lines.Add('')
$Lines.Add('## 实施前提')
$Lines.Add('')
$Lines.Add('正式实施必须先建立独立备份、SHA256基线和两阶段改名清单；随后同步改写正文内显示的章节号／大部标识及专用目录，但不得回写历史P0／P1日志、验证报告或既有备份。完成后须验证186个新文件名唯一、编号001—186无缺无重、正文内容哈希除标题元数据外可追溯，并生成旧名—新名回滚清单。')
$Lines.Add('')
[System.IO.File]::WriteAllText($MarkdownOutput, ($Lines -join [Environment]::NewLine) + [Environment]::NewLine, $Utf8)
$Rows | Export-Csv -LiteralPath $CsvOutput -NoTypeInformation -Encoding utf8BOM
Write-Output "已生成：$MarkdownOutput"
Write-Output "已生成：$CsvOutput"
