import re, sys, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
files = [
  r'D:\Docker\Movie-Emergence\06_小说\小说正文_润色版\第六部_153_开放日.md',
  r'D:\Docker\Movie-Emergence\06_小说\小说正文_润色版\第六部_154_江远的凌晨.md',
]
for f in files:
    t = open(f, encoding='utf-8').read()
    han = len(re.findall(r'[\u4e00-\u9fff]', t))
    print(f.split('\\')[-1] + ': ' + str(han) + ' hanzi')
