$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSCommandPath
$Csv = Join-Path $Root '__manus_全书大部与章节编号重编拟议映射.csv'
$Transaction = Join-Path $Root '__manus_全书重编实施事务.csv'
if (-not (Test-Path -LiteralPath $Csv -PathType Leaf)) { throw "缺少已确认映射：$Csv" }
$Rows = @(Import-Csv -LiteralPath $Csv)
if ($Rows.Count -ne 186) { throw "映射行数异常：$($Rows.Count)，预期186" }
if (@($Rows | Group-Object NewFile | Where-Object { $_.Count -ne 1 }).Count -ne 0) { throw '拟议新文件名存在重复' }

$TransactionRows = New-Object System.Collections.Generic.List[object]
$Index = 0
foreach ($Row in $Rows) {
  $SourcePath = Join-Path $Root $Row.CurrentFile
  if (-not (Test-Path -LiteralPath $SourcePath -PathType Leaf)) { throw "当前正文不存在：$($Row.CurrentFile)" }
  $TempFile = '__manus_tmp_重编_{0:000}_{1}.md' -f ($Index + 1), ([guid]::NewGuid().ToString('N').Substring(0,8))
  $TempPath = Join-Path $Root $TempFile
  if (Test-Path -LiteralPath $TempPath) { throw "临时文件名已存在：$TempFile" }
  $TransactionRows.Add([PSCustomObject]@{
    CurrentFile = $Row.CurrentFile
    TempFile = $TempFile
    NewFile = $Row.NewFile
    CurrentPart = $Row.CurrentPart
    NewPart = $Row.NewPart
    NewNumber = $Row.NewNumber
    Title = $Row.Title
  })
  $Index++
}
$TransactionRows | Export-Csv -LiteralPath $Transaction -NoTypeInformation -Encoding utf8BOM

$StageOneComplete = $false
try {
  foreach ($Item in $TransactionRows) {
    Rename-Item -LiteralPath (Join-Path $Root $Item.CurrentFile) -NewName $Item.TempFile -ErrorAction Stop
  }
  $StageOneComplete = $true
  foreach ($Item in $TransactionRows) {
    Rename-Item -LiteralPath (Join-Path $Root $Item.TempFile) -NewName $Item.NewFile -ErrorAction Stop
  }
} catch {
  $OriginalError = $_
  if ($StageOneComplete) {
    foreach ($Item in $TransactionRows) {
      $NewPath = Join-Path $Root $Item.NewFile
      $TempPath = Join-Path $Root $Item.TempFile
      if (Test-Path -LiteralPath $NewPath -PathType Leaf) {
        Rename-Item -LiteralPath $NewPath -NewName $Item.TempFile -ErrorAction SilentlyContinue
      }
    }
  }
  foreach ($Item in $TransactionRows) {
    $TempPath = Join-Path $Root $Item.TempFile
    $OriginalPath = Join-Path $Root $Item.CurrentFile
    if ((Test-Path -LiteralPath $TempPath -PathType Leaf) -and -not (Test-Path -LiteralPath $OriginalPath -PathType Leaf)) {
      Rename-Item -LiteralPath $TempPath -NewName $Item.CurrentFile -ErrorAction SilentlyContinue
    }
  }
  throw "重命名失败，已尝试回滚：$OriginalError"
}

$Missing = @($TransactionRows | Where-Object { -not (Test-Path -LiteralPath (Join-Path $Root $_.NewFile) -PathType Leaf) })
$ResidualTemp = @(Get-ChildItem -LiteralPath $Root -File -Filter '__manus_tmp_重编_*.md')
if ($Missing.Count -gt 0 -or $ResidualTemp.Count -gt 0) { throw '重命名后完整性检查失败，请依据事务清单回滚' }
Write-Output "重编完成：$($TransactionRows.Count)个正文章节已按映射重命名。"
Write-Output "事务清单：$Transaction"
