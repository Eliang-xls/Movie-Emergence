$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSCommandPath
$NovelRoot = Split-Path -Parent $Root
$BackupRoot = Join-Path $NovelRoot '小说正文（重编备份）'
$Backup = Get-ChildItem -LiteralPath $BackupRoot -Directory -Filter '全书大部与编号重编_*_实施前' | Sort-Object Name -Descending | Select-Object -First 1
if ($null -eq $Backup) { throw "未找到实施前备份：$BackupRoot" }
$ManifestPath = Join-Path $Backup.FullName 'SHA256基线与重编映射.csv'
$Report = Join-Path $Root '__manus_全书大部与章节编号重编实施后验证报告.md'
$Utf8 = [System.Text.UTF8Encoding]::new($false)
$Rows = @(Import-Csv -LiteralPath $ManifestPath)
$Errors = New-Object System.Collections.Generic.List[string]
$HashErrors = New-Object System.Collections.Generic.List[string]
$Pattern = '^(前传|第一部|第二部|第三部|第四部|第五部|第六部|终章)_(\d{3})_.+\.md$'
$BodyFiles = @(Get-ChildItem -LiteralPath $Root -File -Filter '*.md' | Where-Object { [regex]::IsMatch($_.Name, $Pattern) })
$AllNumbers = @($BodyFiles | ForEach-Object { [int][regex]::Match($_.Name, $Pattern).Groups[2].Value })
$Expected = 1..186
$MissingNumbers = @($Expected | Where-Object { $_ -notin $AllNumbers })
$DuplicateNumbers = @($AllNumbers | Group-Object | Where-Object { $_.Count -ne 1 } | ForEach-Object { $_.Name })
if ($Rows.Count -ne 186) { $Errors.Add("备份基线行数异常：$($Rows.Count)") }
if ($BodyFiles.Count -ne 186) { $Errors.Add("当前正文章节数量异常：$($BodyFiles.Count)") }
if ($MissingNumbers.Count -gt 0) { $Errors.Add('新编号缺失：' + ($MissingNumbers -join '、')) }
if ($DuplicateNumbers.Count -gt 0) { $Errors.Add('新编号重复：' + ($DuplicateNumbers -join '、')) }
foreach ($Row in $Rows) {
  $CurrentPath = Join-Path $Root $Row.ProposedFile
  if (-not (Test-Path -LiteralPath $CurrentPath -PathType Leaf)) {
    $Errors.Add("缺失：$($Row.ProposedFile)")
    continue
  }
  $Hash = (Get-FileHash -LiteralPath $CurrentPath -Algorithm SHA256).Hash
  if ($Hash -ne $Row.SHA256) { $HashErrors.Add("$($Row.ProposedFile)：$Hash") }
}
$ResidualOld = @($Rows | Where-Object { $_.CurrentFile -ne $_.ProposedFile -and (Test-Path -LiteralPath (Join-Path $Root $_.CurrentFile) -PathType Leaf) })
if ($ResidualOld.Count -gt 0) { $Errors.Add("仍存在$($ResidualOld.Count)个应已改名的旧正文文件") }
$ProcessFiles = @(Get-ChildItem -LiteralPath $Root -File | Where-Object { $_.Name -like '__manus_*' -or $_.Name -like '章节重编号记录_*' })
$MissingFileErrorCount = @($Errors | Where-Object { $_ -like '缺失：*' }).Count
$Pass = ($Errors.Count -eq 0 -and $HashErrors.Count -eq 0)
$StatusText = if ($Pass) { '通过' } else { '未通过' }
$HashMatchCount = $Rows.Count - $HashErrors.Count
$AllIssues = @($Errors) + @($HashErrors)
$Lines = New-Object System.Collections.Generic.List[string]
$Lines.Add('# 《涌现》全书大部与章节编号重编：实施后验证报告')
$Lines.Add('')
$Lines.Add("> 验证时间：$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss K')")
$Lines.Add('> 实施前基线：' + $Backup.FullName)
$Lines.Add('> 本验证确认正文文件内容仅发生文件名／大部标签变化；未改写正文文本。')
$Lines.Add('')
$Lines.Add('## 结论')
$Lines.Add('')
$Lines.Add(('**{0}。** 当前识别正文章节{1}章；SHA256一致{2}/{3}章。' -f $StatusText, $BodyFiles.Count, $HashMatchCount, $Rows.Count))
$Lines.Add('')
$Lines.Add('## 断言结果')
$Lines.Add('')
$Lines.Add('| 检查项 | 错误数／结果 |')
$Lines.Add('|---|---|')
$Lines.Add(('| 正文章节数量 | {0} / 186 |' -f $BodyFiles.Count))
$Lines.Add(('| 编号001—186缺失 | {0} |' -f $MissingNumbers.Count))
$Lines.Add(('| 编号重复 | {0} |' -f $DuplicateNumbers.Count))
$Lines.Add(('| 拟议新文件缺失 | {0} |' -f $MissingFileErrorCount))
$Lines.Add(('| SHA256不一致 | {0} |' -f $HashErrors.Count))
$Lines.Add(('| 残留旧正文文件 | {0} |' -f $ResidualOld.Count))
$Lines.Add(('| 待归档过程文件 | {0} |' -f $ProcessFiles.Count))
$Lines.Add('')
$Lines.Add('## 异常明细')
$Lines.Add('')
if ($AllIssues.Count -eq 0) { $Lines.Add('无。') } else { foreach ($Item in $AllIssues) { $Lines.Add('- ' + $Item) } }
$Lines.Add('')
$Lines.Add('## 回滚')
$Lines.Add('')
$Lines.Add('回滚请参照实施前备份目录中的SHA256基线与重编映射.csv，并按拟议新名回到原名的方向执行反向两阶段改名。')
$Lines.Add('')
[System.IO.File]::WriteAllText($Report, ($Lines -join [Environment]::NewLine) + [Environment]::NewLine, $Utf8)
Write-Output "已生成：$Report"
if (-not $Pass) { exit 1 }
