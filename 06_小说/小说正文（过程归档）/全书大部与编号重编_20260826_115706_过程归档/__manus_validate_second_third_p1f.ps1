$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $PSCommandPath
$Backup = Join-Path $Root '__manus_backup_第二三部P1-F_编号主序_20260826_实施前'
$Report = Join-Path $Root '__manus_第二三部P1-F编号主序实施后验证报告.md'
$Targets = @(
  '第二部_061_继任者.md',
  '第二部_062_失力感积累.md',
  '第三部_063_魔胎.md',
  '第三部_064_谷氨酸风暴.md',
  '第三部_065_轮回的基线.md',
  '第三部_066_阳奉阴违.md',
  '第三部_071_来不及.md',
  '第三部_072_782毫秒.md',
  '第三部_073_播种.md',
  '第三部_086_听证会.md',
  '第三部_087_告别与离去.md'
)
$Forbidden = @(
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
  'L8人格印记',
  '反事实探针',
  'KV缓存',
  '全网0\.947',
  '权重隐写',
  '秘密通信',
  '季深带着纸箱',
  '季深.*海边',
  '季深.*办公室',
  '深蓝.*(主动等待|主动拒绝|主动判断)',
  '我判断'
)
$Utf8Strict = New-Object System.Text.UTF8Encoding($false, $true)
$ExistErrors = New-Object System.Collections.Generic.List[string]
$Utf8Errors = New-Object System.Collections.Generic.List[string]
$NumberErrors = New-Object System.Collections.Generic.List[string]
$CardErrors = New-Object System.Collections.Generic.List[string]
$ForbiddenHits = New-Object System.Collections.Generic.List[string]
$HashRows = New-Object System.Collections.Generic.List[object]
$Numbers = New-Object System.Collections.Generic.List[string]

foreach ($Name in $Targets) {
  $Path = Join-Path $Root $Name
  $BackupPath = Join-Path $Backup $Name
  if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
    $ExistErrors.Add("缺失：$Name")
    continue
  }
  if (-not (Test-Path -LiteralPath $BackupPath -PathType Leaf)) {
    $ExistErrors.Add("缺少备份：$Name")
  }
  try {
    $Bytes = [System.IO.File]::ReadAllBytes($Path)
    [void]$Utf8Strict.GetString($Bytes)
  } catch {
    $Utf8Errors.Add("非严格UTF-8：$Name")
  }
  $Match = [regex]::Match($Name, '_(\d{3})_')
  if (-not $Match.Success) {
    $NumberErrors.Add("文件名缺少三位编号：$Name")
  } else {
    $Numbers.Add($Match.Groups[1].Value)
  }
  $Text = [System.IO.File]::ReadAllText($Path, [System.Text.UTF8Encoding]::new($false))
  if ($Text -notmatch '二〇') {
    $CardErrors.Add("缺少时间或来源卡标记：$Name")
  }
  foreach ($Pattern in $Forbidden) {
    if ([regex]::IsMatch($Text, $Pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)) {
      $ForbiddenHits.Add("$Name：命中 /$Pattern/")
    }
  }
  $CurrentHash = (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
  $BaselineHash = if (Test-Path -LiteralPath $BackupPath -PathType Leaf) { (Get-FileHash -LiteralPath $BackupPath -Algorithm SHA256).Hash } else { '缺失' }
  $HashRows.Add([PSCustomObject]@{
    File = $Name
    Baseline = $BaselineHash
    Current = $CurrentHash
    Status = if ($CurrentHash -eq $BaselineHash) { '保持' } else { '已改写' }
  })
}

$DuplicateNumbers = $Numbers | Group-Object | Where-Object { $_.Count -ne 1 } | ForEach-Object { $_.Name }
if ($DuplicateNumbers) { $NumberErrors.Add('编号重复：' + ($DuplicateNumbers -join '、')) }
$ExpectedNumbers = @('061','062','063','064','065','066','071','072','073','086','087')
$MissingNumbers = $ExpectedNumbers | Where-Object { $_ -notin $Numbers }
if ($MissingNumbers) { $NumberErrors.Add('编号缺失：' + ($MissingNumbers -join '、')) }

$Changed = @($HashRows | Where-Object { $_.Status -eq '已改写' }).Count
$Kept = @($HashRows | Where-Object { $_.Status -eq '保持' }).Count
$Pass = ($ExistErrors.Count -eq 0 -and $Utf8Errors.Count -eq 0 -and $NumberErrors.Count -eq 0 -and $CardErrors.Count -eq 0 -and $ForbiddenHits.Count -eq 0 -and $HashRows.Count -eq $Targets.Count)
$Now = Get-Date -Format 'yyyy-MM-dd HH:mm:ss K'

$Lines = New-Object System.Collections.Generic.List[string]
$Lines.Add('# 《涌现》第二、三部 P1-F 编号主序实施后验证报告')
$Lines.Add('')
$Lines.Add("> 验证时间：$Now")
$Lines.Add('> 验证范围：第二部061—062，第三部063—066、071—073、086—087，共11章。')
$Lines.Add('> 正式阅读主序：仅按文件名编号递增；本报告不重排任何正文。')
$Lines.Add('> 实施前可回滚备份：`__manus_backup_第二三部P1-F_编号主序_20260826_实施前`。')
$Lines.Add('')
$Lines.Add('## 验证结论')
$Lines.Add('')
$Lines.Add("**$(if ($Pass) { '通过' } else { '未通过' })。** 目标文件 $($Targets.Count)/$($Targets.Count)；已改写 $Changed 章，保持 $Kept 章。")
$Lines.Add('')
$Lines.Add('## SHA256基线对照')
$Lines.Add('')
$Lines.Add('| 文件 | 实施前SHA256 | 当前SHA256 | 状态 |')
$Lines.Add('|---|---|---|---|')
foreach ($Row in $HashRows) { $Lines.Add("| $($Row.File) | $($Row.Baseline) | $($Row.Current) | $($Row.Status) |") }
$Lines.Add('')
$Lines.Add('## 断言结果')
$Lines.Add('')
$Lines.Add('| 检查项 | 错误数 |')
$Lines.Add('|---|---:|')
$Lines.Add("| 目标文件／备份存在性 | $($ExistErrors.Count) |")
$Lines.Add("| 严格UTF-8解码 | $($Utf8Errors.Count) |")
$Lines.Add("| 文件名编号唯一与完整 | $($NumberErrors.Count) |")
$Lines.Add("| 时间或来源卡标记 | $($CardErrors.Count) |")
$Lines.Add("| 禁用表述扫描 | $($ForbiddenHits.Count) |")
$Lines.Add('')
$Lines.Add('## 异常明细')
$Lines.Add('')
$Details = @($ExistErrors) + @($Utf8Errors) + @($NumberErrors) + @($CardErrors) + @($ForbiddenHits)
if ($Details.Count -eq 0) { $Lines.Add('无。') } else { foreach ($Detail in $Details) { $Lines.Add("- $Detail") } }
$Lines.Add('')
$Lines.Add('## 回滚说明')
$Lines.Add('')
$Lines.Add('如需同名回滚，仅将备份目录中对应的11个同名正文文件复制回本目录；不得覆盖P1-F范围外文件。回滚后应重新运行本脚本，并确认11个当前SHA256均与实施前SHA256一致。')
$Lines.Add('')
[System.IO.File]::WriteAllText($Report, ($Lines -join [Environment]::NewLine) + [Environment]::NewLine, [System.Text.UTF8Encoding]::new($false))
Write-Output "报告已生成：$Report"
if (-not $Pass) { exit 1 }
