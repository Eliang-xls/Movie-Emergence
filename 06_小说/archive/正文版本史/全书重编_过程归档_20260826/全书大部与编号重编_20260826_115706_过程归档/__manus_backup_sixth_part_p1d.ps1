$ErrorActionPreference = 'Stop'
$Root = 'D:\Docker\Movie-Emergence\06_小说\小说正文（待审核）'
$Stamp = '20260826_实施前'
$Backup = Join-Path $Root "__manus_backup_第六部P1-D_编号主序_$Stamp"

if (Test-Path -LiteralPath $Backup) { throw "备份目录已存在：$Backup" }

$targets = Get-ChildItem -LiteralPath $Root -File |
    Where-Object { $_.Name -match '^(1(5[7-9]|[6-8][0-9]|90))_.+\.md$' } |
    Sort-Object { [int]$_.Name.Substring(0, 3) }

if ($targets.Count -ne 34) { throw "P1-D目标章数量异常：期望34，实际$($targets.Count)。" }

New-Item -ItemType Directory -Path $Backup | Out-Null
$rows = New-Object System.Collections.Generic.List[string]
$rows.Add('# 第六部P1-D编号主序实施前SHA256基线与文件清单')
$rows.Add('')
$rows.Add('> 备份范围严格按文件名编号递增收集157—190现有章节，共34章。终章标签不构成重排理由；正式主序仍为157→…→190。')
$rows.Add('')
$rows.Add('| 文件 | UTF-8字节数 | SHA256 |')
$rows.Add('|---|---:|---|')

foreach ($item in $targets) {
    $dest = Join-Path $Backup $item.Name
    Copy-Item -LiteralPath $item.FullName -Destination $dest -Force
    $hash = (Get-FileHash -LiteralPath $item.FullName -Algorithm SHA256).Hash
    $rows.Add("| $($item.Name) | $($item.Length) | $hash |")
}

$manifest = Join-Path $Backup 'SHA256基线与文件清单.md'
[System.IO.File]::WriteAllLines($manifest, $rows, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "P1-D备份完成：$Backup"
Write-Host "目标章：$($targets.Count)"
