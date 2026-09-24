$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSCommandPath
$Output = Join-Path $Root '__manus_全书现有正文编排基线索引.md'
$CompactOutput = Join-Path $Root '__manus_全书现有正文简明目录.md'
$Utf8 = [System.Text.UTF8Encoding]::new($false)
$Pattern = '^(?:(?<part>前传|第一部|第二部|第三部|第四部|第五部|第六部|终章)_)?(?<number>\d{3})(?<suffix>-[A-Z])?_(?:(?<partAfter>第一部|第二部|第三部|第四部|第五部|第六部|终章)_)?(?<title>.+)\.md$'
$AllMarkdown = @(Get-ChildItem -LiteralPath $Root -File -Filter '*.md' | Where-Object { $_.Name -notlike '__manus_*' -and $_.Name -notlike '章节重编号记录_*' })
$Rows = foreach ($File in $AllMarkdown) {
  if ($File.Name -like '__manus_*') { continue }
  $Match = [regex]::Match($File.Name, $Pattern)
  if (-not $Match.Success) { continue }
  $Part = if ($Match.Groups['part'].Success) { $Match.Groups['part'].Value } elseif ($Match.Groups['partAfter'].Success) { $Match.Groups['partAfter'].Value } else { '未标注大部' }
  $Number = [int]$Match.Groups['number'].Value
  $Title = $Match.Groups['title'].Value
  $Text = [System.IO.File]::ReadAllText($File.FullName, $Utf8)
  $Lines = $Text -split "`r?`n" | Where-Object { $_.Trim().Length -gt 0 }
  $Cue = ($Lines | Select-Object -First 4) -join ' ／ '
  [PSCustomObject]@{
    Number = $Number
    Suffix = $Match.Groups['suffix'].Value
    File = $File.Name
    CurrentPart = $Part
    Title = $Title
    OpeningCue = $Cue
    Bytes = $File.Length
  }
}
$Rows = @($Rows | Sort-Object Number, Suffix, File)
$Unparsed = @($AllMarkdown | Where-Object { -not [regex]::IsMatch($_.Name, $Pattern) })
$Duplicates = $Rows | Group-Object Number | Where-Object { $_.Count -ne 1 }
$Lines = New-Object System.Collections.Generic.List[string]
$Lines.Add('# 《涌现》现有正文：成书编排基线索引')
$Lines.Add('')
$Lines.Add('> 本索引仅记录当前正文文件名和开篇线索，用于重新设计大部与章节编号；不执行移动或改名。')
$Lines.Add('> 当前唯一正式阅读顺序仍为文件名三位编号递增，直至新的编排映射经确认并另行实施。')
$Lines.Add('')
$Lines.Add("- 识别正文：$($Rows.Count)章")
$Lines.Add("- 编号范围：$($Rows[0].Number.ToString('000'))—$($Rows[-1].Number.ToString('000'))")
$Lines.Add("- 编号重复：$($Duplicates.Count)")
$Lines.Add("- 未按常规三位编号识别的文件：$($Unparsed.Count)")
$Lines.Add('')
$Lines.Add('## 逐章索引')
$Lines.Add('')
$Lines.Add('| 现编号 | 现有大部 | 标题 | 当前文件名 | 开篇时间／来源线索 |')
$Lines.Add('|---:|---|---|---|---|')
foreach ($Row in $Rows) {
  $Cue = $Row.OpeningCue.Replace('|', '\|')
  $FileCell = '`' + $Row.File + '`'
  $DisplayNumber = $Row.Number.ToString('000') + $Row.Suffix
  $Lines.Add(('| {0} | {1} | {2} | {3} | {4} |' -f $DisplayNumber, $Row.CurrentPart, $Row.Title, $FileCell, $Cue))
}
$Lines.Add('')
$Lines.Add('## 编号异常')
$Lines.Add('')
if ($Duplicates.Count -eq 0) { $Lines.Add('无重复编号。') } else { foreach ($Group in $Duplicates) { $Lines.Add("- 编号$($Group.Name)：$((($Group.Group | Select-Object -ExpandProperty File) -join '；'))") } }
if ($Unparsed.Count -gt 0) {
  $Lines.Add('')
  $Lines.Add('### 未按常规三位编号识别的文件')
  foreach ($File in $Unparsed) { $Lines.Add('- ' + $File.Name) }
}
$Lines.Add('')
[System.IO.File]::WriteAllText($Output, ($Lines -join [Environment]::NewLine) + [Environment]::NewLine, $Utf8)
$CompactLines = New-Object System.Collections.Generic.List[string]
$CompactLines.Add('# 《涌现》现有正文简明目录')
$CompactLines.Add('')
$CompactLines.Add('> 用于成书编排诊断；未执行任何移动或改名。')
$CompactLines.Add('')
$CompactLines.Add('| 现编号 | 现有大部 | 标题 |')
$CompactLines.Add('|---:|---|---|')
foreach ($Row in $Rows) { $CompactLines.Add(('| {0} | {1} | {2} |' -f ($Row.Number.ToString('000') + $Row.Suffix), $Row.CurrentPart, $Row.Title)) }
$CompactLines.Add('')
[System.IO.File]::WriteAllText($CompactOutput, ($CompactLines -join [Environment]::NewLine) + [Environment]::NewLine, $Utf8)
Write-Output "已生成：$Output"
Write-Output "已生成：$CompactOutput"
