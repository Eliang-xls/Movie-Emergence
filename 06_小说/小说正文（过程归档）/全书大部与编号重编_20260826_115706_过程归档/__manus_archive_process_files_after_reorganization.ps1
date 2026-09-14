$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSCommandPath
$NovelRoot = Split-Path -Parent $Root
$ArchiveRoot = Join-Path $NovelRoot '小说正文（过程归档）'
$Stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$Archive = Join-Path $ArchiveRoot ("全书大部与编号重编_{0}_过程归档" -f $Stamp)
$Transaction = Join-Path $Root '__manus_全书重编实施事务.csv'
$SelfName = Split-Path -Leaf $PSCommandPath
if (-not (Test-Path -LiteralPath $Transaction -PathType Leaf)) { throw "缺少重编事务清单：$Transaction" }
$Rows = @(Import-Csv -LiteralPath $Transaction)
if ($Rows.Count -ne 186) { throw "事务清单行数异常：$($Rows.Count)" }
$BodyNames = @{} 
foreach ($Row in $Rows) { $BodyNames[$Row.NewFile] = $true }
$ActualBody = @(Get-ChildItem -LiteralPath $Root -File -Filter '*.md' | Where-Object { $BodyNames.ContainsKey($_.Name) })
if ($ActualBody.Count -ne 186) { throw "当前正文数量异常：$($ActualBody.Count)" }
if (Test-Path -LiteralPath $Archive) { throw "归档目录已存在：$Archive" }
New-Item -ItemType Directory -Path $Archive -Force | Out-Null

$Moved = New-Object System.Collections.Generic.List[object]
$Items = @(Get-ChildItem -LiteralPath $Root -Force | Where-Object { $_.Name -ne $SelfName -and -not ($_.PSIsContainer -eq $false -and $BodyNames.ContainsKey($_.Name)) })
foreach ($Item in $Items) {
  $Destination = Join-Path $Archive $Item.Name
  Move-Item -LiteralPath $Item.FullName -Destination $Destination -ErrorAction Stop
  $Moved.Add([PSCustomObject]@{ Name = $Item.Name; Type = if ($Item.PSIsContainer) { '目录' } else { '文件' } })
}
$Utf8 = [System.Text.UTF8Encoding]::new($false)
$Lines = New-Object System.Collections.Generic.List[string]
$Lines.Add('# 《涌现》全书大部与章节编号重编：过程归档清单')
$Lines.Add('')
$Lines.Add("> 归档时间：$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss K')")
$Lines.Add("> 来源目录：$Root")
$Lines.Add("> 正文保留：$($ActualBody.Count)个章节文件。")
$Lines.Add('')
$Lines.Add('## 已归档项目')
$Lines.Add('')
$Lines.Add('| 名称 | 类型 |')
$Lines.Add('|---|---|')
foreach ($Item in $Moved) { $Lines.Add('| ' + $Item.Name.Replace('|','\|') + ' | ' + $Item.Type + ' |') }
$Lines.Add('')
$Lines.Add('## 保留原则')
$Lines.Add('')
$Lines.Add('正文目录根部仅保留由已确认重编映射列出的186个正文章节。过程脚本、实施事务、P0／P1日志、验证报告、草稿、旧索引及目录内实施前备份均移动至本归档目录。跨目录的独立实施前重编备份仍位于小说正文（重编备份）目录。')
$Lines.Add('')
[System.IO.File]::WriteAllText((Join-Path $Archive 'README.md'), ($Lines -join [Environment]::NewLine) + [Environment]::NewLine, $Utf8)
Write-Output "过程文件已归档：$Archive"
Write-Output "当前脚本待由后续步骤移入归档：$SelfName"
