$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$backup = Join-Path $root '__manus_backup_第二三部P1-F_编号主序_20260826_实施前'
$targets = @(
'第二部_061_继任者.md','第二部_062_失力感积累.md',
'第三部_063_魔胎.md','第三部_064_谷氨酸风暴.md','第三部_065_轮回的基线.md','第三部_066_阳奉阴违.md',
'第三部_071_来不及.md','第三部_072_782毫秒.md','第三部_073_播种.md','第三部_086_听证会.md','第三部_087_告别与离去.md'
)
if(-not(Test-Path -LiteralPath $backup)){New-Item -ItemType Directory -Path $backup | Out-Null}
$lines=New-Object 'System.Collections.Generic.List[string]';$lines.Add('# 第二三部P1-F编号主序实施前SHA256基线与文件清单');$lines.Add('');$lines.Add('> 备份范围：第二部061—062、第三部063—066、071—073、086—087共11章。正式阅读主序仅按文件名编号递增。');$lines.Add('');$lines.Add('| 文件 | UTF-8字节数 | SHA256 |');$lines.Add('|---|---:|---|')
foreach($name in $targets){$src=Join-Path $root $name;if(-not(Test-Path -LiteralPath $src)){throw "缺失目标正文：$name"};Copy-Item -LiteralPath $src -Destination (Join-Path $backup $name) -Force;$lines.Add("| $name | $((Get-Item -LiteralPath $src).Length) | $((Get-FileHash -LiteralPath $src -Algorithm SHA256).Hash) |")}
[IO.File]::WriteAllLines((Join-Path $backup 'SHA256基线与文件清单.md'),$lines,[Text.UTF8Encoding]::new($false));Write-Host "P1-F备份完成：$backup；文件数：$($targets.Count)"
