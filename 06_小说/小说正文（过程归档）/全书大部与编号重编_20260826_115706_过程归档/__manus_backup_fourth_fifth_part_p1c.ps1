$ErrorActionPreference = 'Stop'

$root = 'D:\Docker\Movie-Emergence\06_小说\小说正文（待审核）'
$backupName = '__manus_backup_第四五部P1-C_编号主序_20260826_实施前'
$backup = Join-Path $root $backupName
if (Test-Path -LiteralPath $backup) { throw "备份目录已存在：$backup" }

$targets = New-Object System.Collections.Generic.List[System.IO.FileInfo]
foreach ($i in 89..156) {
  $n = $i.ToString('000')
  $matches = Get-ChildItem -LiteralPath $root -File | Where-Object { $_.Name -match "^$n`_.*\.md$" }
  if ($matches.Count -gt 1) { throw "编号重复：$n -> $($matches.Name -join '；')" }
  if ($matches.Count -eq 1) { [void]$targets.Add($matches[0]) }
}
if ($targets.Count -ne 61) { throw "P1-C目标章数异常，预期61，实际$($targets.Count)" }

New-Item -ItemType Directory -Path $backup | Out-Null
$rows = @()
foreach ($file in $targets) {
  Copy-Item -LiteralPath $file.FullName -Destination (Join-Path $backup $file.Name) -Force
  $bytes = [System.IO.File]::ReadAllBytes($file.FullName).Length
  $hash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
  $rows += "| $($file.Name) | $bytes | $hash |"
}

$manifest = @()
$manifest += '# 第四、第五部P1-C编号主序实施前SHA256基线与文件清单'
$manifest += ''
$manifest += '> 备份范围严格按文件名编号递增收集089—156现有章节，共61章。编号123、124、126、127、129、130、143在当前目录中不存在，未被虚构补入。第四、第五部标签交错不构成重排理由。'
$manifest += ''
$manifest += '| 文件 | UTF-8字节数 | SHA256 |'
$manifest += '|---|---:|---|'
$manifest += $rows
$manifest += ''
[System.IO.File]::WriteAllText((Join-Path $backup 'SHA256基线与文件清单.md'), ($manifest -join "`r`n") + "`r`n", (New-Object System.Text.UTF8Encoding($false)))
Write-Output "P1-C备份完成：$backup；目标章节：$($targets.Count)"
