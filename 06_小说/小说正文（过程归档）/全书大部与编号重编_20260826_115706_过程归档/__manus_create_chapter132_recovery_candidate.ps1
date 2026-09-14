$sourcePath = 'D:\Docker\Movie-Emergence\06_小说\小说正文（待审核）\132_第五部_种子的树.md'
$candidatePath = 'D:\Docker\Movie-Emergence\06_小说\小说正文（待审核）\__manus_132_严格UTF8恢复候选_只读.md'
$recoveryLogPath = 'D:\Docker\Movie-Emergence\06_小说\小说正文（待审核）\__manus_132_恢复候选说明_只读.md'
$invalidIndex = 6243

$sourceBytes = [System.IO.File]::ReadAllBytes($sourcePath)
if ($sourceBytes.Length -le $invalidIndex -or $sourceBytes[$invalidIndex] -ne 0x82) {
    throw 'The expected isolated invalid byte was not found at the diagnosed index.'
}

$repairedBytes = New-Object byte[] ($sourceBytes.Length - 1)
[Array]::Copy($sourceBytes, 0, $repairedBytes, 0, $invalidIndex)
[Array]::Copy($sourceBytes, $invalidIndex + 1, $repairedBytes, $invalidIndex, $sourceBytes.Length - $invalidIndex - 1)

$strictUtf8 = [System.Text.UTF8Encoding]::new($false, $true)
$repairedText = $strictUtf8.GetString($repairedBytes)
[System.IO.File]::WriteAllText($candidatePath, $repairedText, [System.Text.UTF8Encoding]::new($false))

$candidateBytes = [System.IO.File]::ReadAllBytes($candidatePath)
[void]$strictUtf8.GetString($candidateBytes)
$sourceHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $sourcePath).Hash
$candidateHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $candidatePath).Hash

$log = @"
# 第132章严格UTF-8恢复候选说明（只读）

| 项目 | 结果 |
|---|---:|
| 原件路径 | `132_第五部_种子的树.md` |
| 恢复候选路径 | `__manus_132_严格UTF8恢复候选_只读.md` |
| 原件字节数 | $($sourceBytes.Length) |
| 候选字节数 | $($candidateBytes.Length) |
| 移除字节索引 | $invalidIndex |
| 移除字节十六进制值 | 82 |
| 严格UTF-8复验 | 通过 |
| 原件SHA256 | $sourceHash |
| 候选SHA256 | $candidateHash |

## 恢复范围

严格UTF-8诊断显示原件仅有一个无法解码的孤立字节：索引 $invalidIndex 的 `0x82`。其前方已有完整的 UTF-8 中文句号序列 `E3 80 82`，该孤立字节紧随其后，因此本候选仅移除该重复尾字节。候选通过严格UTF-8复验。

> 本候选仅用于后续人工比对、审阅与蓝图实施前确认；它不是对原第132章的直接改写，也不得替代实施前备份中的原件。
"@

[System.IO.File]::WriteAllText($recoveryLogPath, $log, [System.Text.UTF8Encoding]::new($false))
Write-Output "RECOVERY_CANDIDATE=$candidatePath"
Write-Output "RECOVERY_LOG=$recoveryLogPath"
