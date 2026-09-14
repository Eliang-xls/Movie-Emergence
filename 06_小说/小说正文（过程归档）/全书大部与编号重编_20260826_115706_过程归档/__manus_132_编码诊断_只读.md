# 第132章编码诊断（只读）

| 项目 | 结果 |
|---|---:|
| 原始字节数 | 13740 |
| 严格UTF-8状态 | Unable to translate bytes [82] at index 6243 from specified code page to Unicode. |
| 首个无效字节索引 | 6243 |
| 对应近似行号 | 118 |
| 替换解码中的 U+FFFD 数量 | 1 |
| 诊断窗口起点 | 6179 |

## 无效位置附近的原始十六进制窗口

`	ext
0A E5 AD A3 E6 B7 B1 E7 9A 84 53 6B 69 6C 6C E2 80 94 E2 80 94 E5 AE 83 E7 9A 84 E5 BC 95 E7 94 A8 E9 93 BE E6 8C 87 E5 90 91 E4 BA 86 E5 BE 88 E5 A4 9A E4 B8 8B E6 B8 B8 53 6B 69 6C 6C E3 80 82 82 E8 BF 99 E4 BA 9B E4 B8 8B E6 B8 B8 53 6B 69 6C 6C E5 8F 88 E6 8C 87 E5 90 91 E4 BA 86 E6 9B B4 E5 A4 9A E7 9A 84 53 6B 69 6C 6C E3 80 82 E5 BD A2 E6 88 90 E4 BA 86 E4 B8 80 E6 A3 B5 E5 B7 A8 E5 A4 A7 E7 9A 84 E6 A0 91 E3 80 82 0D 0A 0D 0A E6 A0 91 E7 9A 84 E6 A0 B9 E2 80 94 E2 80
`

> 本报告不改写第132章正文。严格UTF-8失败说明当前原文件含有至少一处混合或损坏字节；恢复前不得将替换字符版本作为正文底稿。