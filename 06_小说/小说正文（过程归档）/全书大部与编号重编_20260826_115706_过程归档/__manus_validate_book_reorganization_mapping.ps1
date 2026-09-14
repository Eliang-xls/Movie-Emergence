$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSCommandPath
$Csv = Join-Path $Root '__manus_全书大部与章节编号重编拟议映射.csv'
$Report = Join-Path $Root '__manus_全书大部与章节编号重编拟议映射验证.md'
$Utf8 = [System.Text.UTF8Encoding]::new($false)
$Rows = @(Import-Csv -LiteralPath $Csv)
$ExpectedTotal = 186
$ExpectedNumbers = 1..$ExpectedTotal
$ExpectedParts = @{
  '前传' = @(1..6)
  '第一部' = @(7..34)
  '第二部' = @(35..65)
  '第三部' = @(66..91)
  '第四部' = @(92..125)
  '第五部' = @(126..152)
  '第六部' = @(153..181)
  '终章' = @(182..186)
}
$Errors = New-Object System.Collections.Generic.List[string]
$Warnings = New-Object System.Collections.Generic.List[string]
if ($Rows.Count -ne $ExpectedTotal) { $Errors.Add("映射行数异常：$($Rows.Count)，预期$ExpectedTotal") }
$Numbers = @($Rows | ForEach-Object { [int]$_.NewNumber })
$Missing = @($ExpectedNumbers | Where-Object { $_ -notin $Numbers })
$Duplicate = @($Numbers | Group-Object | Where-Object { $_.Count -ne 1 } | ForEach-Object { $_.Name })
if ($Missing.Count -gt 0) { $Errors.Add('新编号缺失：' + ($Missing -join '、')) }
if ($Duplicate.Count -gt 0) { $Errors.Add('新编号重复：' + ($Duplicate -join '、')) }
$NewFileDuplicate = @($Rows | Group-Object NewFile | Where-Object { $_.Count -ne 1 } | ForEach-Object { $_.Name })
if ($NewFileDuplicate.Count -gt 0) { $Errors.Add('拟议文件名重复：' + ($NewFileDuplicate -join '、')) }
$NewFilePattern = '^(前传|第一部|第二部|第三部|第四部|第五部|第六部|终章)_\d{3}_.+\.md$'
foreach ($Row in $Rows) {
  $CurrentPath = Join-Path $Root $Row.CurrentFile
  if (-not (Test-Path -LiteralPath $CurrentPath -PathType Leaf)) { $Errors.Add("当前正文不存在：$($Row.CurrentFile)") }
  if (-not [regex]::IsMatch($Row.NewFile, $NewFilePattern)) { $Errors.Add("拟议文件名格式错误：$($Row.NewFile)") }
}
foreach ($Part in $ExpectedParts.Keys) {
  $Actual = @($Rows | Where-Object { $_.NewPart -eq $Part } | ForEach-Object { [int]$_.NewNumber } | Sort-Object)
  $Expected = @($ExpectedParts[$Part])
  if ((Compare-Object -ReferenceObject $Expected -DifferenceObject $Actual).Count -ne 0) { $Errors.Add("$Part 的编号范围与方案不一致") }
}
$DirectCollisions = @($Rows | Where-Object { $_.NewFile -ne $_.CurrentFile -and (Test-Path -LiteralPath (Join-Path $Root $_.NewFile) -PathType Leaf) })
if ($DirectCollisions.Count -gt 0) { $Warnings.Add("检测到$($DirectCollisions.Count)个目标文件名当前已被占用；正式实施必须使用两阶段临时改名，禁止逐个直接改名。") }
$Unchanged = @($Rows | Where-Object { $_.NewFile -eq $_.CurrentFile }).Count
$Changed = $Rows.Count - $Unchanged
$Pass = ($Errors.Count -eq 0)
$Now = Get-Date -Format 'yyyy-MM-dd HH:mm:ss K'
$Lines = New-Object System.Collections.Generic.List[string]
$Lines.Add('# 《涌现》全书大部与章节编号重编拟议映射：验证报告')
$Lines.Add('')
$Lines.Add("> 验证时间：$Now")
$Lines.Add('> 本验证仅检查拟议映射，未对正文文件执行任何改名、移动或内容改写。')
$Lines.Add('')
$Lines.Add('## 结论')
$Lines.Add('')
$Lines.Add("**$(if ($Pass) { '通过' } else { '未通过' })。** 映射覆盖$($Rows.Count)章；拟议改名${Changed}章，原样保留${Unchanged}章。")
$Lines.Add('')
$Lines.Add('## 断言结果')
$Lines.Add('')
$Lines.Add('| 检查项 | 结果 |')
$Lines.Add('|---|---|')
$Lines.Add("| 映射行数为186 | $(if ($Rows.Count -eq $ExpectedTotal) { '通过' } else { '失败' }) |")
$Lines.Add("| 新编号001—186无缺无重 | $(if ($Missing.Count -eq 0 -and $Duplicate.Count -eq 0) { '通过' } else { '失败' }) |")
$Lines.Add("| 拟议文件名唯一 | $(if ($NewFileDuplicate.Count -eq 0) { '通过' } else { '失败' }) |")
$Lines.Add("| 当前文件均存在 | $(if (-not ($Errors | Where-Object { $_ -like '当前正文不存在*' })) { '通过' } else { '失败' }) |")
$Lines.Add("| 新大部范围符合提案 | $(if (-not ($Errors | Where-Object { $_ -like '*编号范围与方案不一致' })) { '通过' } else { '失败' }) |")
$Lines.Add("| 直接改名碰撞 | $($DirectCollisions.Count)（须两阶段改名） |")
$Lines.Add('')
$Lines.Add('## 实施风险与控制')
$Lines.Add('')
if ($DirectCollisions.Count -gt 0) {
  $Lines.Add('现有文件与目标文件之间存在名称占用链，因此不得逐个直接执行`Rename-Item`。正式实施时，必须先将186个正文文件统一改为唯一临时名，再按拟议文件名写入；原名—临时名—新名三列均需记录。')
} else {
  $Lines.Add('本映射未发现目标文件名与其他现存正文文件的直接全名冲突。尽管如此，正式实施仍建议采用两阶段临时改名，以避免操作中断、同名恢复或人工调整映射时引入覆盖风险；原名—临时名—新名三列均需记录。')
}
$Lines.Add('历史审阅日志、验证报告和备份目录必须冻结为原名证据，不随正文改名。')
$Lines.Add('')
$Lines.Add('## 异常与警告')
$Lines.Add('')
if ($Errors.Count -eq 0 -and $Warnings.Count -eq 0) { $Lines.Add('无。') } else { foreach ($Item in @($Errors) + @($Warnings)) { $Lines.Add('- ' + $Item) } }
$Lines.Add('')
[System.IO.File]::WriteAllText($Report, ($Lines -join [Environment]::NewLine) + [Environment]::NewLine, $Utf8)
Write-Output "已生成：$Report"
if (-not $Pass) { exit 1 }
