$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSCommandPath
$NovelRoot = Split-Path -Parent $Root
$BackupRoot = Join-Path $NovelRoot '小说正文（重编备份）'
$Stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$Backup = Join-Path $BackupRoot ("全书大部与编号重编_{0}_实施前" -f $Stamp)
$Csv = Join-Path $Root '__manus_全书大部与章节编号重编拟议映射.csv'
$Utf8 = [System.Text.UTF8Encoding]::new($false)

if (-not (Test-Path -LiteralPath $Csv -PathType Leaf)) { throw "缺少映射文件：$Csv" }
$Rows = @(Import-Csv -LiteralPath $Csv)
if ($Rows.Count -ne 186) { throw "映射行数异常：$($Rows.Count)" }
if (Test-Path -LiteralPath $Backup) { throw "备份目录已存在：$Backup" }
New-Item -ItemType Directory -Path $Backup -Force | Out-Null

$Manifest = New-Object System.Collections.Generic.List[object]
foreach ($Row in $Rows) {
  $Source = Join-Path $Root $Row.CurrentFile
  if (-not (Test-Path -LiteralPath $Source -PathType Leaf)) { throw "当前正文不存在：$($Row.CurrentFile)" }
  $Target = Join-Path $Backup $Row.CurrentFile
  Copy-Item -LiteralPath $Source -Destination $Target -ErrorAction Stop
  $Info = Get-Item -LiteralPath $Source
  $Manifest.Add([PSCustomObject]@{
    CurrentFile = $Row.CurrentFile
    ProposedFile = $Row.NewFile
    CurrentPart = $Row.CurrentPart
    ProposedPart = $Row.NewPart
    SHA256 = (Get-FileHash -LiteralPath $Source -Algorithm SHA256).Hash
    Bytes = $Info.Length
  })
}
$Manifest | Export-Csv -LiteralPath (Join-Path $Backup 'SHA256基线与重编映射.csv') -NoTypeInformation -Encoding utf8BOM
Copy-Item -LiteralPath $Csv -Destination (Join-Path $Backup '__manus_全书大部与章节编号重编拟议映射.csv')
$MappingMarkdown = Join-Path $Root '__manus_全书大部与章节编号重编拟议映射.md'
if (Test-Path -LiteralPath $MappingMarkdown -PathType Leaf) { Copy-Item -LiteralPath $MappingMarkdown -Destination (Join-Path $Backup '__manus_全书大部与章节编号重编拟议映射.md') }
$Readme = @(
  '# 《涌现》全书大部与章节编号重编：实施前独立备份',
  '',
  "> 建立时间：$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss K')",
  '> 范围：按已确认映射覆盖186个现有正文文件。',
  '> 用途：用于重编失败或需要撤回时的同名内容回滚；正文重编后需依据映射将相应备份文件恢复为原名。',
  '',
  '## 内容',
  '',
  '- 186个实施前正文文件，保留原文件名与原字节。',
  '- `SHA256基线与重编映射.csv`：原名、拟议新名、大部映射、字节数与SHA256。',
  '- 已确认的拟议映射副本。',
  '',
  '## 回滚原则',
  '',
  '回滚必须使用`SHA256基线与重编映射.csv`按“拟议新名 → 原名”逆向处理，不得触碰过程归档或本批次范围外文件。回滚后应重新计算SHA256，确认每个原名正文均与基线一致。',
  ''
) -join [Environment]::NewLine
[System.IO.File]::WriteAllText((Join-Path $Backup 'README.md'), $Readme + [Environment]::NewLine, $Utf8)
Write-Output "实施前备份已建立：$Backup"
