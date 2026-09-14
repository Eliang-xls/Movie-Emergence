$ErrorActionPreference = 'Stop'
$Archive = Split-Path -Parent $PSCommandPath
$NovelRoot = Split-Path -Parent (Split-Path -Parent $Archive)
$Root = Join-Path $NovelRoot '小说正文（待审核）'
$BackupRoot = Join-Path $NovelRoot '小说正文（重编备份）'
$Backup = Get-ChildItem -LiteralPath $BackupRoot -Directory -Filter '全书大部与编号重编_*_实施前' | Sort-Object Name -Descending | Select-Object -First 1
$Manifest = @(Import-Csv -LiteralPath (Join-Path $Backup.FullName 'SHA256基线与重编映射.csv'))
$Pattern = '^(前传|第一部|第二部|第三部|第四部|第五部|第六部|终章)_(\d{3})_.+\.md$'
$AllRootItems = @(Get-ChildItem -LiteralPath $Root -Force)
$BodyFiles = @($AllRootItems | Where-Object { -not $_.PSIsContainer -and [regex]::IsMatch($_.Name, $Pattern) })
$NonBody = @($AllRootItems | Where-Object { $_.PSIsContainer -or -not [regex]::IsMatch($_.Name, $Pattern) })
$Numbers = @($BodyFiles | ForEach-Object { [int][regex]::Match($_.Name, $Pattern).Groups[2].Value })
$Missing = @(1..186 | Where-Object { $_ -notin $Numbers })
$Duplicates = @($Numbers | Group-Object | Where-Object { $_.Count -ne 1 })
$HashErrors = New-Object System.Collections.Generic.List[string]
foreach ($Row in $Manifest) {
  $Path = Join-Path $Root $Row.ProposedFile
  if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { $HashErrors.Add('缺失：' + $Row.ProposedFile); continue }
  if ((Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash -ne $Row.SHA256) { $HashErrors.Add('哈希不一致：' + $Row.ProposedFile) }
}
$Pass = ($BodyFiles.Count -eq 186 -and $NonBody.Count -eq 0 -and $Missing.Count -eq 0 -and $Duplicates.Count -eq 0 -and $HashErrors.Count -eq 0)
$Report = Join-Path $Archive '__manus_全书重编归档后洁净性验证报告.md'
$Utf8 = [System.Text.UTF8Encoding]::new($false)
$Lines = @(
  '# 《涌现》全书重编：归档后正文目录洁净性验证报告',
  '',
  ('> 验证时间：' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss K')),
  ('> 正文目录：' + $Root),
  ('> 过程归档：' + $Archive),
  '',
  '## 结论',
  '',
  ('**' + $(if ($Pass) { '通过' } else { '未通过' }) + '。** 正文根目录保留' + $BodyFiles.Count + '个章节文件；非正文章节项目' + $NonBody.Count + '个；SHA256一致' + ($Manifest.Count - $HashErrors.Count) + '/' + $Manifest.Count + '章。'),
  '',
  '## 断言结果',
  '',
  '| 检查项 | 结果 |',
  '|---|---|',
  ('| 正文章节数 | ' + $BodyFiles.Count + ' / 186 |'),
  ('| 非正文根目录项目 | ' + $NonBody.Count + ' |'),
  ('| 编号缺失 | ' + $Missing.Count + ' |'),
  ('| 编号重复 | ' + $Duplicates.Count + ' |'),
  ('| SHA256不一致或缺失 | ' + $HashErrors.Count + ' |'),
  '',
  '## 异常明细',
  ''
)
if ($NonBody.Count -eq 0 -and $HashErrors.Count -eq 0 -and $Missing.Count -eq 0 -and $Duplicates.Count -eq 0) { $Lines += '无。' } else { foreach ($Item in $NonBody) { $Lines += ('- 非正文：' + $Item.Name) }; foreach ($Item in $HashErrors) { $Lines += ('- ' + $Item) }; foreach ($Item in $Missing) { $Lines += ('- 缺失编号：' + $Item) }; foreach ($Item in $Duplicates) { $Lines += ('- 重复编号：' + $Item.Name) } }
$Lines += @('', '## 回滚', '', '正文内容回滚依赖小说正文（重编备份）中的实施前基线；过程文件可从本归档目录恢复，但不应恢复到正文发布目录。','')
[System.IO.File]::WriteAllText($Report, ($Lines -join [Environment]::NewLine), $Utf8)
Write-Output "已生成：$Report"
if (-not $Pass) { exit 1 }
