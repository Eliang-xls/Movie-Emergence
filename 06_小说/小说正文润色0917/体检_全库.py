#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
《涌现》润色工程·全库体检脚本（2026-09-20 批 19）

把这一轮会话里逐条手工做过的检查固化成一支可重复运行的脚本：**任何一次改动之后跑一遍**，
不必重新发明检查方法，也不必依赖上一次会话的记忆。

用法（在 `小说正文润色0917/` 内或 `06_小说/` 内均可）：
    python 体检_全库.py            # 人读输出
    python 体检_全库.py --json     # 机器可读

退出码：0 全绿；1 有硬违规（FAIL）；2 只有需人工判断的清单（WARN）。
每条白名单都是**有内证的判定**，理由写在行内，不要随手删除。
判定依据与 `_矛盾处理台账_0920.md` 各批结论一致；刻意保留项见 `_禁止改动清单_0920.md`。
"""
import io, os, re, sys, glob, json, collections, difflib

D = {'〇':0,'○':0,'零':0,'一':1,'二':2,'三':3,'四':4,'五':5,'六':6,'七':7,'八':8,'九':9}
SEASON = {'春':3.5,'夏':6.5,'秋':9.5,'冬':11.5,'正':1.5,'腊':12.5}
STRIP = re.compile(r'[\s「」『』“”"\'’‘。，、：；！？（）()——…·、\-_/｜|*＃#:：]+')
BANNED = ['极其','极度','极为','极尽','某种','彻底地','猛烈地']

NAMES = ['林屿','季深','顾清','江远','叶澄','韩霜','赵铭','孟怀山','季行','季遥','何迟','老方','深蓝',
         '陆昀','沈牧','方晓','周砚','秦敏','陈卫国','哈维','王远','老倪','阿楠','程岚','黎老师','苏晴',
         '陈默','陆远','石田直子','佐藤','小蓝','李响','赵晨','沈墨','郭志新','方蕙','陈维明','周倩','徐婷']
MOTIF = {'后颈':'林屿','涟漪':'林屿','重量':'韩霜','间隙':'顾清','共鸣':'老方'}   # 口吻标准 §3.3

BRANDS = ('推特 Twitter ThinkPad Mac IBM 戴尔 Google 联想 苹果 华为 小米 魅族 OPPO vivo 英特尔 英伟达 AMD '
          '华硕 三星 惠普 是德 Keysight 福禄克 Keithley 尼康 佳能 罗技 格力 宏碁 丰田 泰克 3M 红梅 五粮液 '
          '茅台 泸州老窖 二锅头 中华烟 玉溪 芙蓉王 健力宝 娃哈哈 康师傅 农夫山泉 星巴克 麦当劳 肯德基 可口可乐 '
          '松下 索尼 夏普 飞利浦 施耐德 三菱 博世 海尔 创维 康佳 TCL 顺丰 京东 拼多多 抖音 快手 微博 知乎 淘宝 '
          '天猫 钉钉 飞书 语雀 石墨 Notion').split()
SUBSTRING_FALSE = {'苹果','美的','统一','大众','石墨','钉钉','百度','Mac'}          # 字面撞词，非厂牌
BRAND_PRODUCT = r'[^，。、」]{0,6}(笔记本|电脑|手机|空调|便利贴|便签|车|烟|酒)'
KEEP_PERIOD_CH = {'102','145'}      # 五菱宏光 102:17、健力宝 145:122 → 判为"时代实物"保留（03 方案 §二）
FILE_EXT = re.compile(r'[\w.\-]+\.(?:pdf|txt|md|py|csv|json|docx?|xlsx?)\b', re.I)   # 书内文件名，合法

def norm(s): return STRIP.sub('', s)

def zh_num(s):
    if '十' in s:
        a, b = s.split('十')
        a = ''.join(c for c in a if c in D); b = ''.join(c for c in b if c in D)
        return (D.get(a, 1) if a else 1) * 10 + (D.get(b, 0) if b else 0)
    v = [D[c] for c in s if c in D]
    return int(''.join(map(str, v))) if v else None

def anchor_time(line):
    m = re.match(r'^二[〇○零一二三四五六七八九]+年', line.strip())
    if not m: return None
    y = int(''.join(str(D[c]) for c in m.group(0) if c in D))
    mo = re.search(r'·\s*(?:([正腊]|[一二三四五六七八九十]+)月(初|上旬|中旬|下旬|上|中|下|末|底)?|(春|夏|秋|冬))', line)
    if not mo: return y + 0.5/12.0                       # 只标到年 → 取年中
    if mo.group(3): return y + (SEASON[mo.group(3)] - 6.0)/12.0
    mon = zh_num(mo.group(1)) or 6
    # 2026-09-20 批 20 修口径 bug：旧写法取 s[-1] 判旬，而「上旬」的末字是「旬」，
    # 于是 zh_num(s[:2]) 把**任何 N月上旬/中旬/下旬**一律算成十月——凭空造倒挂也盖住真倒挂。
    frac = {'初':0.1,'上':0.1,'上旬':0.1,'中':0.5,'中旬':0.5,'下':0.9,'下旬':0.9,'末':0.9,'底':0.9,'':0.5}[mo.group(2) or '']
    return y + (mon + frac - 6.0)/12.0

class Book:
    def __init__(self, root):
        self.root, self.ch, self.name2num = root, {}, collections.defaultdict(list)
        for f in glob.glob(os.path.join(root, '*.md')):
            m = re.match(r'(\d{3})_([^_]+)_(.+)\.md$', os.path.basename(f))
            if not m: continue
            n, _part, title = m.groups()
            self.ch[n] = io.open(f, encoding='utf-8').read().split('\n')
            self.name2num[title].append(n)
    def lines(self, n): return self.ch.get(n, [])
    def anchor(self, n):
        for l in self.lines(n)[1:6]:
            if l.strip().startswith('二'): return anchor_time(l)
        return None

def main():
    here = os.path.dirname(os.path.abspath(__file__))
    root = here if glob.glob(os.path.join(here, '1??_*.md')) else os.path.join(here, '小说正文润色0917')
    bk = Book(root)
    R = []
    def add(name, ok, detail, warn=False):
        R.append((name, 'WARN' if (not ok and warn) else ('PASS' if ok else 'FAIL'), detail))

    nums = sorted(int(k) for k in bk.ch)
    gaps = [i for i in range(nums[0], nums[-1]+1) if i not in nums]
    add('章数与连号', len(nums) == 211 and not gaps, f'{len(nums)} 章，缺号 {gaps}')

    noanchor = [n for n in sorted(bk.ch) if bk.anchor(n) is None]
    add('时间锚点完备', set(noanchor) <= {'003','114'}, f'零锚点 {noanchor}（003 未润色区、114 刻意，既知例外）')

    ctrl = [n for n in bk.ch if any(c in '\n'.join(bk.lines(n)) for c in '\t\x08\x0c\ufffd')]
    add('控制字符与替换符', not ctrl, f'{ctrl}')

    half = []
    for n in sorted(bk.ch, key=int):
        if int(n) < 8: continue
        inc = False
        for i, l in enumerate(bk.lines(n), 1):
            if l.strip().startswith('```'): inc = not inc; continue
            if inc: continue
            s = re.sub(r'`[^`]*`', '', l)
            s = re.sub(r'\d[.,]\d', '', s)
            s = FILE_EXT.sub('', s)                      # 白名单：书内文件名后缀
            if re.search(r'[一-鿿][,.!?;:]|[,.!?;:][一-鿿]', s): half.append(f'{n}:{i}')
    add('半角标点', not half, f'{half}')

    words = []
    for n in bk.ch:
        if int(n) < 8: continue
        t = '\n'.join(bk.lines(n))
        c = {w: t.count(w) for w in BANNED if w in t}
        if c: words.append((n, c))
    add('禁用词（极其/极度/极为/极尽/某种/彻底地/猛烈地）', not words, f'{words}')
    sishi = [(n, '\n'.join(bk.lines(n)).count('死死')) for n in bk.ch if int(n) >= 8]
    add('`死死` 每章 ≤1', not [x for x in sishi if x[1] > 1], f'{[x for x in sishi if x[1] > 1]}')

    viol = []
    for n in bk.ch:
        if int(n) < 8: continue
        c = 0
        for l in bk.lines(n):
            for seg in re.split(r'「[^」]*」', l):          # 对白不计配额（口吻标准 §5.1）
                c += len(re.findall(r'不是[^，。；]{1,26}[，,]\s*(?:而)?是', seg))
        if c > 2: viol.append((n, c))
    add('叙述者「不是A，是B」≤2/章', not viol, f'{viol}', warn=True)

    brand = []
    for n in sorted(bk.ch, key=int):
        if int(n) < 8: continue
        for i, l in enumerate(bk.lines(n), 1):
            for b in BRANDS:
                if b not in l: continue
                if b in SUBSTRING_FALSE and not re.search(re.escape(b) + BRAND_PRODUCT, l): continue
                if n in KEEP_PERIOD_CH and b in ('健力宝','五菱宏光'): continue   # 时代实物，03 方案 §二
                brand.append(f'{n}:{i} {b}')
    add('真实消费品牌 008—199（2026-09-20 裁定：清洗暂停，此项仅提示）', not brand, f'{brand}', warn=True)

    seq = [(n, bk.anchor(n)) for n in sorted(bk.ch, key=int)]
    seq = [x for x in seq if x[1]]
    rev = [f'{a}->{b}' for (a, ta), (b, tb) in zip(seq, seq[1:]) if tb < ta - 1e-9]
    add('相邻章时间倒挂（与时间线表 §三对账）', True, f'{len(rev)} 处：{rev}', warn=True)

    rel = []
    for n in sorted(bk.ch, key=int):
        if int(n) < 8: continue
        t = bk.anchor(n)
        if not t: continue
        for i, l in enumerate(bk.lines(n), 1):
            for m in re.finditer(r'([一二两三四五六七八九十]{1,3})年前', l):
                v = zh_num(m.group(1))
                if v: rel.append(f'{n}:{i} {m.group(0)}（锚点 {t:.2f} → 所指 {t - v:.1f}）')
    add('相对时长清单（逐条按锚点复核）', True, f'{len(rel)} 处', warn=True)

    sents = collections.defaultdict(list)
    for n in bk.ch:
        for i, l in enumerate(bk.lines(n), 1):
            s = norm(l.strip())
            if len(s) >= 18: sents[s].append(f'{n}:{i}')
    cross = {k[:26]: v for k, v in sents.items() if len(v) > 1 and len({x.split(':')[0] for x in v}) > 1}
    add('跨章 ≥18 字同句', not cross, f'{list(cross.items())[:4]}', warn=True)

    spans = []
    for n in bk.ch:
        for i, l in enumerate(bk.lines(n), 1):
            for mm in re.finditer(r'[「『]([^」』]{12,120})[」』]', l):
                spans.append((n, i, norm(mm.group(1)), mm.group(1)))
    by = collections.defaultdict(set)
    for k, (n, i, t, raw) in enumerate(spans):
        for j in range(0, max(0, len(t)-10)): by[t[j:j+10]].add(k)
    near, seen = [], set()
    for g, idxs in by.items():
        if len(idxs) < 2: continue
        lst = sorted(idxs)
        for ii in range(len(lst)):
            for jj in range(ii + 1, len(lst)):
                a, b = lst[ii], lst[jj]
                if spans[a][0] == spans[b][0] or (a, b) in seen: continue
                seen.add((a, b))
                r = difflib.SequenceMatcher(None, spans[a][2], spans[b][2]).ratio()
                if 0.55 <= r < 0.999:
                    near.append((round(r, 3), f'{spans[a][0]}:{spans[a][1]}', f'{spans[b][0]}:{spans[b][1]}',
                                 spans[a][3][:22], spans[b][3][:22]))
    add('近重复引文（判刻意/缺陷；观察员三档、水的 maxim 已判刻意）', True, f'{near}', warn=True)

    susp = []
    for k, owner in MOTIF.items():
        for n in bk.ch:
            if int(n) < 8: continue
            ls = bk.lines(n)
            for i, l in enumerate(ls, 1):
                if k in l and owner not in '\n'.join(ls[max(0, i-7):i+3]):
                    susp.append(f'{n}:{i}:{k}')
    add('母题归属可疑（须逐条判：通用语／刻意设计）', True, f'{len(susp)} 处 {susp[:8]}', warn=True)

    ids = collections.defaultdict(list)
    for n in bk.ch:
        for i, l in enumerate(bk.lines(n), 1):
            for x in re.findall(r'\b[A-Z]{2,6}[-_][A-Z0-9][A-Z0-9\-]{2,16}|(?<![\w])#\d{3,5}|20\d\d-网安-\d+', l):
                ids[x].append((n, i))
    ybad = []
    for k, locs in ids.items():
        m = re.search(r'20(\d{2})', k)
        if not m: continue
        yr = 2000 + int(m.group(1))
        for n, i in locs:
            t = bk.anchor(n)
            if t and yr > t + 0.6: ybad.append(f'{k}@{n}:{i} 内嵌 {yr} 晚于锚点 {t:.2f}')
    add('编号内嵌年份不晚于所在章', not ybad, f'{ybad}')

    forb = {r'全纯|纯激活': '废止术语', r'约?\s*17\s*%|百分之十七': '已撤回数值', r'0\.1872': '未归一化旧值',
            r'S4[^A-Za-z]?(?:直接|便|就)?(?:变成|成为|升为).{0,4}A[₅5]': 'S₄ 直变 A₅',
            r'(?:证明|证实|读|测|量)(?:出|到)\s*(?:无限|∞)': '白盒读 ∞',
            r'(?:只有|唯有).{0,8}(?:湿核|活体|碳基).{0,10}(?:才|才能).{0,8}(?:意识|觉醒)': '材质决定论',
            r'硅基.{0,8}(?:不可能|无法|永远没有).{0,6}意识': '硅基不能有意识',
            r'R_orth[^\n]{0,40}非对易残差': 'R_orth 定义被改写（批 23）',
            r'多开了一维|第五维一开': '输入维增长旧口径（批 23）'}
    v = []
    for n in bk.ch:
        if int(n) < 8: continue
        for i, l in enumerate(bk.lines(n), 1):
            for p, why in forb.items():
                if re.search(p, l): v.append(f'{n}:{i} [{why}]')
    add('纯硅基 v1.0 禁则', not v, f'{v}')

    # 制度归属轴（2026-09-20 作者裁定；判据＝谁在主持、程序归属哪国制度。台账 §廿九）
    CN_MARK = ('深圳', '深大', '华强北', '南山', '罗湖', '北京', '象山', '东海之滨', '西南山区', '潮汕')
    FOREIGN_PROC = {'陪审团': '美英制度，中国为合议庭', '大陪审团': '仅美国', '终审判决': '法院专属，公安／调查组不得签发',
                    '弹劾': '美英制度', '宣誓作证': '美国程序', '禁制令': '美英制度', '人身保护令': '美英制度'}
    inst = []
    for n in sorted(bk.ch, key=int):
        if int(n) < 8: continue                                   # 001—006 按裁定不处理
        body = '\n'.join(bk.lines(n))
        if not any(w in body for w in CN_MARK): continue
        for i, l in enumerate(bk.lines(n), 1):
            for t, why in FOREIGN_PROC.items():
                if t in l: inst.append(f'{n}:{i} {t}〔{why}〕')
    add('制度归属：中国境内章出现仅对美英成立的程序词（台账 §廿九）', not inst, f'{inst}', warn=True)

    # 替换残渣（批 20 反查新增）：汉字之间夹半角空格＝品牌/修饰词替换后留下的叠修饰或断句残骸
    space = []
    SKIP_LATIN = re.compile(r'UI|AI|PPT|OKR|PCP|L\d|D_|I_sol|GHz|Skill|PDF|Diff|Markdown|B1|v\d')
    for n_ in sorted(bk.ch, key=int):
        if int(n_) < 8: continue
        for i, l in enumerate(bk.lines(n_), 1):
            for m in re.finditer(r'[一-鿿] [一-鿿]', l):
                seg = l[max(0, m.start()-14):m.end()+14]
                if SKIP_LATIN.search(seg): continue
                space.append(f'{n_}:{i} …{seg.strip()}…')
    add('汉字间半角空格（替换残渣／引号缺失）', not space, f'{space}', warn=True)

    meta = []
    for n in bk.ch:
        if int(n) < 8: continue
        for i, l in enumerate(bk.lines(n), 1):
            s = l
            for safe in ('未来全书','全书最具','这部全书','两本书','一本书','那本书','这本书','本书里','本书的','整本书'):
                s = s.replace(safe, '')
            if re.search(r'全书|上一章|下一章|正如前文|(?:^|[^两三四五六七八九该那这每])本书', s): meta.append(f'{n}:{i}')
    add('元引用（叙述层提到书自身）', not meta, f'{meta}')

    arity = []
    for f in glob.glob(os.path.join(bk.root, '*.md')) + glob.glob(os.path.join(bk.root, '过程归档', '*.md')) + glob.glob(os.path.join(bk.root, '..', '0*.md')):
        hdr = None
        for i, l in enumerate(io.open(f, encoding='utf-8').read().split('\n'), 1):
            s = l.strip().replace('\\|', '')
            if not (s.startswith('|') and s.endswith('|')): hdr = None; continue
            c = s.count('|') - 1
            if set(s) <= set('|-: '): continue
            if hdr is None: hdr = c; continue
            if c != hdr: arity.append(f'{os.path.basename(f)}:{i} {c}≠{hdr}')
    add('Markdown 表格列数一致', not arity, f'{arity[:6]}')

    docs = glob.glob(os.path.join(bk.root, '_*.md')) + glob.glob(os.path.join(bk.root, '卷首*.md')) \
        + glob.glob(os.path.join(bk.root, '过程归档', '_*.md'))
    tot, badq = 0, []
    for doc in docs:
        t = io.open(doc, encoding='utf-8').read()
        for m in re.finditer(r'(\d{3}):(\d{1,4})([^\n]{0,90})', t):
            n, l, tail = m.group(1), int(m.group(2)), m.group(3)
            if n not in bk.ch: continue
            q = re.search(r'[「『]([^」』]{6,60})[」』]', tail)
            if not q: continue
            needle = norm(q.group(1))[:14]
            if len(needle) < 6: continue
            tot += 1
            if needle in norm('\n'.join(bk.lines(n)[max(0, l-4):l+3])): continue
            where = [j+1 for j, ln in enumerate(bk.lines(n)) if needle in norm(ln)]
            if where: badq.append(f'{os.path.basename(doc)} 引 {n}:{l}，实为 {n}:{where[:3]}')
            elif any(x in q.group(1) for x in ('…','／','**')): pass          # 省略/并置/强调：非逐字
            else: badq.append(f'{os.path.basename(doc)} 引 {n}:{l}「{q.group(1)[:14]}」正文无（或为改前原句）')
    add(f'登记文件引文审计（{tot} 条带引文；改前原句属正常）', True, f'{badq[:8]}', warn=True)

    stale = []
    for doc in [os.path.join(bk.root, '..', '00_叙事口吻标准.md'),
                os.path.join(bk.root, '..', '00_《涌现》角色人物语言风格设计方案.md')]:
        if not os.path.exists(doc): continue
        for i, ln in enumerate(io.open(doc, encoding='utf-8').read().split('\n'), 1):
            if re.search(r'旧号|编号校正|→|范本句|换算|archive|改写前原稿|如 `?\d{3}_', ln): continue   # 白名单：讲旧编号／指向 archive 原稿的句子
            for n, name in re.findall(r'(\d{3})_(?:[一-鿿]{1,3}_)?([一-鿿A-Za-z0-9（）]{2,14})', ln):
                if name in bk.name2num and n not in bk.name2num[name]:
                    stale.append(f'{os.path.basename(doc)}:{i} {n}_{name} → 现 {bk.name2num[name]}')
    add('指引文档章节编号有效', not stale, f'{stale}')

    fails = [r for r in R if r[1] == 'FAIL']; warns = [r for r in R if r[1] == 'WARN']
    if '--json' in sys.argv:
        print(json.dumps([{'check': a, 'status': b, 'detail': str(c)} for a, b, c in R], ensure_ascii=False, indent=1))
    else:
        print(f'《涌现》全库体检 · {len(bk.ch)} 章 · {len(R)} 项检查')
        for name, st, detail in R:
            print({'PASS': '✅', 'FAIL': '❌', 'WARN': '⚠️ '}[st] + ' ' + name)
            print('    ' + str(detail)[:380])
        print(f'\n合计 PASS {len(R)-len(fails)-len(warns)} / WARN {len(warns)} / FAIL {len(fails)}')
    sys.exit(1 if fails else (2 if warns else 0))

if __name__ == '__main__':
    main()
