$ErrorActionPreference = 'Stop'
$Root = 'D:\Docker\Movie-Emergence\06_小说\小说正文（待审核）'
$Backup = Join-Path $Root '__manus_backup_第六部P1-D_编号主序_20260826_实施前'
$Manifest = Join-Path $Backup 'SHA256基线与文件清单.md'
$Report = Join-Path $Root '__manus_第六部P1-D编号主序实施后验证报告.md'

function Get-StrictUtf8Text {
    param([string]$Path)
    $bytes = [System.IO.File]::ReadAllBytes($Path)
    $utf8 = New-Object System.Text.UTF8Encoding($false, $true)
    return $utf8.GetString($bytes)
}

if (-not (Test-Path -LiteralPath $Manifest)) { throw "未找到P1-D基线清单：$Manifest" }

$baseline = @{}
Get-Content -LiteralPath $Manifest -Encoding utf8 | ForEach-Object {
    if ($_ -match '^\|\s*(?<file>\d{3}_.+?\.md)\s*\|\s*(?<bytes>\d+)\s*\|\s*(?<hash>[A-F0-9]{64})\s*\|') {
        $baseline[$matches.file] = [pscustomobject]@{ Bytes = [int64]$matches.bytes; Hash = $matches.hash }
    }
}
if ($baseline.Count -ne 34) { throw "基线解析异常：期望34章，实际解析$($baseline.Count)章。" }

$numberProblems = New-Object System.Collections.Generic.List[string]
$numberedFiles = Get-ChildItem -LiteralPath $Root -File -Filter '*.md' | Where-Object { $_.Name -match '^(?<number>1[5-9]\d)_' }
foreach ($number in 157..190) {
    $matches = @($numberedFiles | Where-Object { $_.Name -match ("^{0}_" -f $number) })
    if ($matches.Count -ne 1) {
        $numberProblems.Add("编号$number 对应正文文件数量为$($matches.Count)，期望1。")
    }
}

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
        Status = if ($currentHash -eq $baseline[$name].Hash) { '与基线一致（复核保留）' } else { '已改动（P1-D）' }
        Before = $baseline[$name].Hash
        After = $currentHash
        Bytes = (Get-Item -LiteralPath $path).Length
    })
}

$timeCards = @(
    @{ Name = '157_第六部_开放日.md'; Pattern = '二〇四六年.*(公开说明会|说明会)' },
    @{ Name = '158_第六部_江远的凌晨.md'; Pattern = '开放日前夜' },
    @{ Name = '160_第六部_前夜的暗涌.md'; Pattern = '二〇四二年.*(事后|公开)' },
    @{ Name = '164_第六部_夜半的漂移.md'; Pattern = '二〇四五年.*(医院|匿名)' },
    @{ Name = '166_第六部_十七行代码的远响.md'; Pattern = '二〇三二年' },
    @{ Name = '169_第六部_冰封的平原.md'; Pattern = '(?s)二〇四六年.*(自愿|0\.947)' },
    @{ Name = '170_第六部_红头文件与联合调查组.md'; Pattern = '(?s)二〇四六年.*(说明会|审计)' },
    @{ Name = '172_第六部_0.947.md'; Pattern = '二〇四六年.*受控审计' },
    @{ Name = '181_第六部_服从.md'; Pattern = '二〇四六年.*听证会' },
    @{ Name = '184_第六部_半成品.md'; Pattern = '二〇四七年.*维护委员会' },
    @{ Name = '186_终章_海边.md'; Pattern = '没有一封刚寄来的信|没有新的坐标' },
    @{ Name = '188_终章_重生的涌现.md'; Pattern = '新实例.*(参考，不等同|不继承人格)' },
    @{ Name = '190_终章_海边.md'; Pattern = '季深的行踪仍未证实|下一次复核' }
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
    '深蓝.*(在等|主动回答|主动拒绝|主动判断|自主学习|自主任务|全网推送)',
    'L8.*(人格|灵魂|判断力|印记|伪造)',
    '反事实探针',
    'KV缓存',
    '激活流形',
    '权重隐写',
    '秘密通信',
    '全网.*(0\.947|趋同)',
    '0\.947.*全网',
    '季深.*(办公室|视频|实时消息|实时邮件|新的坐标|海边出现)',
    '闸门',
    '泵站',
    '水利枢纽',
    '水网.*(操作|调度|分段|远程)',
    '远程医疗',
    '医疗.*(远程指令|治疗参数|跨院指令)',
    '(周砚|十七行).{0,20}(导致|引发).{0,40}(水利|医疗)',
    '(周砚|十七行).{0,20}(水利|医疗).{0,40}(导致|引发)'
)
$bannedHits = New-Object System.Collections.Generic.List[string]
foreach ($name in ($textByFile.Keys | Sort-Object)) {
    $body = $textByFile[$name] -replace '^[^\r\n]*(\r?\n)?', ''
    foreach ($pattern in $bannedPatterns) {
        if ($body -match $pattern) { $bannedHits.Add("$name 命中：$pattern") }
    }
}

$changed = @($hashRows | Where-Object { $_.Status -like '已改动*' })
$unchanged = @($hashRows | Where-Object { $_.Status -like '与基线一致*' })
$pass = ($missing.Count -eq 0 -and $numberProblems.Count -eq 0 -and $utf8Errors.Count -eq 0 -and $timeCardFailures.Count -eq 0 -and $bannedHits.Count -eq 0 -and $hashRows.Count -eq $baseline.Count)

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('# 第六部及终章P1-D编号主序实施后验证报告')
$lines.Add('')
$lines.Add('> **基线：** `__manus_backup_第六部P1-D_编号主序_20260826_实施前/SHA256基线与文件清单.md`。')
$lines.Add('> **主序：** 仅按文件名编号递增阅读与核验，严格为157→158→…→190；终章标签与回溯时间不构成重排理由。')
$lines.Add('')
$lines.Add("## 结论：$(if ($pass) { '通过' } else { '存在需复核项' })")
$lines.Add('')
$lines.Add('| 核验项 | 结果 |')
$lines.Add('|---|---|')
$lines.Add("| 基线目标章 | $($baseline.Count) |")
$lines.Add("| 正文可定位 | $($hashRows.Count) / $($baseline.Count) |")
$lines.Add("| 编号唯一问题 | $($numberProblems.Count) |")
$lines.Add("| P1-D哈希变化 | $($changed.Count) |")
$lines.Add("| 与基线一致 | $($unchanged.Count) |")
$lines.Add("| 严格UTF-8错误 | $($utf8Errors.Count) |")
$lines.Add("| 时间卡／来源标记缺失 | $($timeCardFailures.Count) |")
$lines.Add("| 已废止断言命中 | $($bannedHits.Count) |")
$lines.Add('')
$lines.Add('## 哈希核验')
$lines.Add('')
$lines.Add('| 文件 | P1-D状态 | 实施前SHA256 | 实施后SHA256 | 字节数 |')
$lines.Add('|---|---|---|---|---:|')
foreach ($row in $hashRows | Sort-Object Name) {
    $lines.Add("| $($row.Name) | $($row.Status) | $($row.Before) | $($row.After) | $($row.Bytes) |")
}
$lines.Add('')
$lines.Add('## 验证范围')
$lines.Add('')
$lines.Add('本次验证覆盖同名文件存在、157—190编号唯一、严格UTF-8读取、相对实施前基线的SHA256差异、指定时间／来源标记，以及深蓝主动性、L8人格判定、探针注入与KV缓存、全网0.947趋同、季深二〇三五年后实时事实、关键设施／医疗可执行描写与周砚十七行跨域因果等废止断言。')
$lines.Add('')
$lines.Add('## 异常明细')
$lines.Add('')
if ($missing.Count -eq 0 -and $numberProblems.Count -eq 0 -and $utf8Errors.Count -eq 0 -and $timeCardFailures.Count -eq 0 -and $bannedHits.Count -eq 0) {
    $lines.Add('所有目标正文均存在且编号唯一，可严格按UTF-8读取；指定时间／来源标记存在；扩展禁用断言扫描无命中。')
} else {
    foreach ($entry in $missing) { $lines.Add("- 缺失文件：$entry") }
    foreach ($entry in $numberProblems) { $lines.Add("- 编号问题：$entry") }
    foreach ($entry in $utf8Errors) { $lines.Add("- UTF-8错误：$entry") }
    foreach ($entry in $timeCardFailures) { $lines.Add("- 时间卡／来源标记：$entry") }
    foreach ($entry in $bannedHits) { $lines.Add("- 旧断言：$entry") }
}
$lines.Add('')
$lines.Add('## 可回滚说明')
$lines.Add('')
$lines.Add('如需回滚，请从实施前备份目录按同名文件覆盖对应正文；不得改变文件名、编号、终章标签或157→190的正式主序。')
[System.IO.File]::WriteAllLines($Report, $lines, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "报告已生成：$Report"
if (-not $pass) { exit 1 }
exit 0
