$ErrorActionPreference = 'Stop'
$Root = 'D:\Docker\Movie-Emergence\06_小说\小说正文（待审核）'
$Backup = Join-Path $Root '__manus_backup_第四五部P1-C_编号主序_20260826_实施前'
$Manifest = Join-Path $Backup 'SHA256基线与文件清单.md'
$Report = Join-Path $Root '__manus_第四五部P1-C编号主序实施后验证报告.md'

function Get-StrictUtf8Text {
    param([string]$Path)
    $bytes = [System.IO.File]::ReadAllBytes($Path)
    $utf8 = New-Object System.Text.UTF8Encoding($false, $true)
    return $utf8.GetString($bytes)
}

if (-not (Test-Path -LiteralPath $Manifest)) { throw "未找到P1-C基线清单：$Manifest" }

$baseline = @{}
Get-Content -LiteralPath $Manifest -Encoding utf8 | ForEach-Object {
    if ($_ -match '^\|\s*(?<file>\d{3}_.+?\.md)\s*\|\s*(?<bytes>\d+)\s*\|\s*(?<hash>[A-F0-9]{64})\s*\|') {
        $baseline[$matches.file] = [pscustomobject]@{ Bytes = [int64]$matches.bytes; Hash = $matches.hash }
    }
}
if ($baseline.Count -ne 61) { throw "基线解析异常：期望61章，实际解析$($baseline.Count)章。" }

$missing = New-Object System.Collections.Generic.List[string]
$utf8Errors = New-Object System.Collections.Generic.List[string]
$hashRows = New-Object System.Collections.Generic.List[object]
$textByFile = @{}

foreach ($name in ($baseline.Keys | Sort-Object)) {
    $path = Join-Path $Root $name
    if (-not (Test-Path -LiteralPath $path)) { $missing.Add($name); continue }
    try { $text = Get-StrictUtf8Text -Path $path } catch { $utf8Errors.Add("$name：$($_.Exception.Message)"); continue }
    $textByFile[$name] = $text
    $currentHash = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash
    $hashRows.Add([pscustomobject]@{
        Name = $name
        Status = if ($currentHash -eq $baseline[$name].Hash) { '未改动（保留或最小修订前一致）' } else { '已改动（P1-C）' }
        Before = $baseline[$name].Hash
        After = $currentHash
        Bytes = (Get-Item -LiteralPath $path).Length
    })
}

$timeCards = @(
    @{ Name = '120_第四部_季遥.md'; Pattern = '二〇四六年' },
    @{ Name = '125_第五部_能证衰减.md'; Pattern = '编号承接卡' },
    @{ Name = '131_第五部_种子的壳.md'; Pattern = '编号承接卡' },
    @{ Name = '133_第五部_纯粹的重聚.md'; Pattern = '二〇四五年' },
    @{ Name = '153_第四部_深蓝说不.md'; Pattern = '外层隔离网关|外层规则' },
    @{ Name = '156_第四部_方向.md'; Pattern = '二〇四八年|2048年' }
)
$timeCardFailures = New-Object System.Collections.Generic.List[string]
foreach ($item in $timeCards) {
    if (-not $textByFile.ContainsKey($item.Name) -or $textByFile[$item.Name] -notmatch $item.Pattern) {
        $timeCardFailures.Add("$($item.Name) 缺少验证标记：$($item.Pattern)")
    }
}

$bannedPatterns = @(
    'ad_tracker',
    'analytics\.ad-proxy',
    'AUTO_APPROVE',
    'task\.dispatch',
    '我判断这个不应该做',
    '湿核液位',
    '像一首歌',
    '音频通道',
    '分叉协议触发',
    '48小时评估',
    '深蓝.*(在等|拒绝了|判断)',
    'L8.*(伪造|人格印记)',
    '第⑧层.*印章',
    '触控板.*(阻力|光滑|粗糙)',
    '半衰期',
    '有效能证',
    '三十七秒.*(心跳|唱)'
)
$bannedHits = New-Object System.Collections.Generic.List[string]
foreach ($name in ($textByFile.Keys | Sort-Object)) {
    $body = $textByFile[$name] -replace '^[^\r\n]*(\r?\n)?', ''
    foreach ($pattern in $bannedPatterns) {
        if ($body -match $pattern) { $bannedHits.Add("$name 命中：$pattern") }
    }
}

$changed = @($hashRows | Where-Object { $_.Status -like '已改动*' })
$unchanged = @($hashRows | Where-Object { $_.Status -like '未改动*' })
$pass = ($missing.Count -eq 0 -and $utf8Errors.Count -eq 0 -and $timeCardFailures.Count -eq 0 -and $bannedHits.Count -eq 0 -and $hashRows.Count -eq $baseline.Count)

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('# 第四、第五部P1-C编号主序实施后验证报告')
$lines.Add('')
$lines.Add('> **基线：** `__manus_backup_第四五部P1-C_编号主序_20260826_实施前/SHA256基线与文件清单.md`。')
$lines.Add('> **主序：** 仅按文件名编号递增；第五部标签交错不构成重排。')
$lines.Add('')
$lines.Add("## 结论：$(if ($pass) { '通过' } else { '存在需复核项' })")
$lines.Add('')
$lines.Add('| 核验项 | 结果 |')
$lines.Add('|---|---|')
$lines.Add("| 基线目标章 | $($baseline.Count) |")
$lines.Add("| 正文可定位 | $($hashRows.Count) / $($baseline.Count) |")
$lines.Add("| P1-C哈希变化 | $($changed.Count) |")
$lines.Add("| 与基线一致 | $($unchanged.Count) |")
$lines.Add("| 严格UTF-8错误 | $($utf8Errors.Count) |")
$lines.Add("| 时间卡／承接标记缺失 | $($timeCardFailures.Count) |")
$lines.Add("| 已废止断言命中 | $($bannedHits.Count) |")
$lines.Add('')
$lines.Add('## 哈希核验')
$lines.Add('')
$lines.Add('| 文件 | P1-C状态 | 实施前SHA256 | 实施后SHA256 | 字节数 |')
$lines.Add('|---|---|---|---|---:|')
foreach ($row in $hashRows | Sort-Object Name) {
    $lines.Add("| $($row.Name) | $($row.Status) | $($row.Before) | $($row.After) | $($row.Bytes) |")
}
$lines.Add('')
$lines.Add('## 异常明细')
$lines.Add('')
if ($missing.Count -eq 0 -and $utf8Errors.Count -eq 0 -and $timeCardFailures.Count -eq 0 -and $bannedHits.Count -eq 0) {
    $lines.Add('所有目标正文均存在、可严格按UTF-8读取；指定时间卡／编号承接标记存在；已废止断言扫描无命中。')
} else {
    foreach ($entry in $missing) { $lines.Add("- 缺失文件：$entry") }
    foreach ($entry in $utf8Errors) { $lines.Add("- UTF-8错误：$entry") }
    foreach ($entry in $timeCardFailures) { $lines.Add("- 时间卡：$entry") }
    foreach ($entry in $bannedHits) { $lines.Add("- 旧断言：$entry") }
}
$lines.Add('')
$lines.Add('## 可回滚说明')
$lines.Add('')
$lines.Add('如需回滚，请从实施前备份目录以同名文件覆盖对应正文；不得改变文件名、编号或第四／第五部标签。')
[System.IO.File]::WriteAllLines($Report, $lines, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "报告已生成：$Report"
if (-not $pass) { exit 1 }
exit 0
