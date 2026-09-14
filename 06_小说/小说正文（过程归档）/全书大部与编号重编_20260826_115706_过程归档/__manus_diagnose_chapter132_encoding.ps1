$sourcePath = 'D:\Docker\Movie-Emergence\06_小说\小说正文（待审核）\132_第五部_种子的树.md'
$candidatePath = 'D:\Docker\Movie-Emergence\06_小说\小说正文（待审核）\__manus_132_严格UTF8恢复候选_只读.md'
$reportPath = 'D:\Docker\Movie-Emergence\06_小说\小说正文（待审核）\__manus_132_编码诊断_只读.md'

if (Test-Path -LiteralPath $candidatePath) {
    Remove-Item -LiteralPath $candidatePath -Force
}

$bytes = [System.IO.File]::ReadAllBytes($sourcePath)
$strictUtf8 = [System.Text.UTF8Encoding]::new($false, $true)
$invalidIndex = $null
$decodeStatus = 'valid UTF-8'

try {
    [void]$strictUtf8.GetString($bytes)
}
catch [System.Text.DecoderFallbackException] {
    $invalidIndex = $_.Exception.Index
    $decodeStatus = $_.Exception.Message
}

$windowStart = if ($null -eq $invalidIndex) { 0 } else { [Math]::Max(0, $invalidIndex - 64) }
$windowLength = [Math]::Min(160, $bytes.Length - $windowStart)
$window = New-Object byte[] $windowLength
[Array]::Copy($bytes, $windowStart, $window, 0, $windowLength)
$hexWindow = ($window | ForEach-Object { $_.ToString('X2') }) -join ' '

$replacementUtf8 = [System.Text.UTF8Encoding]::new($false, $false)
$lossyText = $replacementUtf8.GetString($bytes)
$replacementCount = ([regex]::Matches($lossyText, [char]0xFFFD)).Count
$lineBeforeInvalid = if ($null -eq $invalidIndex) { 'n/a' } else { (($replacementUtf8.GetString($bytes, 0, $invalidIndex) -split "`n").Count) }

$report = @"
# 第132章编码诊断（只读）

| 项目 | 结果 |
|---|---:|
| 原始字节数 | $($bytes.Length) |
| 严格UTF-8状态 | $decodeStatus |
| 首个无效字节索引 | $invalidIndex |
| 对应近似行号 | $lineBeforeInvalid |
| 替换解码中的 U+FFFD 数量 | $replacementCount |
| 诊断窗口起点 | $windowStart |

## 无效位置附近的原始十六进制窗口

```text
$hexWindow
```

> 本报告不改写第132章正文。严格UTF-8失败说明当前原文件含有至少一处混合或损坏字节；恢复前不得将替换字符版本作为正文底稿。
"@

[System.IO.File]::WriteAllText($reportPath, $report, [System.Text.UTF8Encoding]::new($false))
Write-Output "ENCODING_REPORT=$reportPath"
