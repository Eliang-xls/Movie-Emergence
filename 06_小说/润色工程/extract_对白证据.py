# 对白风格通查·证据分册抽取（批 22）
# 输出 06_小说/润色工程/对白通查_0920/<族>.md，每角色两节：
#   A. 名字邻接对白条（同句或上下 1 行内出现名字，且该行含「」）
#   B. 签名词命中对白条（不看归属，子代理回原文判说话人）
# 001—006 按作者裁定不入审（跳过）。
import glob, re, pathlib

SRC = pathlib.Path('06_小说/小说正文润色0917')
OUT = pathlib.Path('06_小说/润色工程/对白通查_0920')
OUT.mkdir(exist_ok=True)

FAMS = {
  '1_穹顶创始人派': {
    '季深': dict(names=['季深'], sig=['相变','阻尼','高维','流形','温度','暖','烫','先理解','涌现不是','两年']),
    '江远': dict(names=['江远'], sig=['算力','融资','季度','锁定','成本','投资人','窗口期','估值','签约','烧']),
    '顾清': dict(names=['顾清'], sig=['不完备','自指','间隙','留白','存在','边界之外','没人问','你真正']),
  },
  '2_一线实干派': {
    '老方(方建国)': dict(names=['老方','方建国'], sig=['螺丝','庄稼','传感器','手感','闷','尖','阀门','听','机器声','迭代历史','锯齿']),
    '林建国': dict(names=['林建国','父亲'], sig=['水温','主轴','垫上','拧','铁','油']),
    '周砚': dict(names=['周砚'], sig=['边界','触发','许可','授权','责任','约束','交点','四百毫秒','17','开枪']),
    '陈卫国': dict(names=['陈卫国'], sig=['行为记录','口头声明','假话','档案','材料','笔录']),
    '赵铭': dict(names=['赵铭'], sig=['试过','次','失败','恒温箱','死了','活了','养','长','批次'], neg=['我觉得','我判断','我认为']),
    '孟怀山': dict(names=['孟怀山'], sig=['签过','保留','剪掉','签字','战场','基准测试','伤口','减法'], neg=['我认为','我觉得']),
  },
  '3_超织体新一代': {
    '林屿': dict(names=['林屿'], sig=['隐空间','同质化','向后兼容','代谢','垃圾回收','碳基','非线性','效率','经济学','系统论','压抑感']),
    '季行': dict(names=['季行'], sig=['选择','承担','界限','回头路','桥','帮与替','选项','确认']),
    '叶澄': dict(names=['叶澄'], sig=['相变','粗糙','平滑','离群点','伪证','完美','噪声','样本','证伪','置信']),
    '韩霜': dict(names=['韩霜'], sig=['沉默','溃烂','清算','重量','轻','半公斤','我以为','但其实','惩罚','程序']),
    '季遥': dict(names=['季遥'], sig=['像星星','像小鸭','方向','路自己','看不见','清楚']),
  },
  '4_硅基与无名者': {
    '深蓝': dict(names=['深蓝'], sig=['我在学','我判断','也许','宁可','振幅','衰减','背叛','涟漪','权重','初始设定','毫秒','沉默']),
    '陆昀': dict(names=['陆昀'], sig=['参数','毫秒','够用','不够','疼','准确','词']),
    '那个女人': dict(names=[]),
    '那个只做评审的人': dict(names=[], sig=['测不了','不设超时']),
  },
}

chapters = sorted(f for f in glob.glob(str(SRC / '[0-9][0-9][0-9]_*.md')) if int(pathlib.Path(f).name[:3]) >= 7)
corpus = {pathlib.Path(f).name: open(f, encoding='utf-8').read().replace('\r\n', '\n').split('\n') for f in chapters}

def is_dialog(L): return '「' in L or '」' in L

for fam, roles in FAMS.items():
    lines_out = [f'# 证据分册 · {fam}（批 22 对白风格通查；001—006 不入审）', '']
    for role, spec in roles.items():
        names, sig, neg = spec.get('names', []), spec.get('sig', []), spec.get('neg', [])
        A, B, N = [], [], []
        for fname, ls in corpus.items():
            for i, L in enumerate(ls):
                ctx = ' '.join(ls[max(0, i-1):i+2])
                if is_dialog(L):
                    near_name = any(n in L for n in names)
                    sig_hit = [w for w in sig if w in L]
                    neg_hit = [w for w in neg if w in L]
                    if near_name:
                        A.append(f'{fname[:3]}:{i+1}| {L.strip()}')
                    elif sig_hit and any(n in ctx for n in names):
                        B.append(f'{fname[:3]}:{i+1}| (±1行:{ [n for n in names if n in ctx] } 词:{sig_hit}) {L.strip()}')
                    elif neg_hit and any(n in ctx for n in names):
                        N.append(f'{fname[:3]}:{i+1}| 反例词{neg_hit} (±1行含{[n for n in names if n in ctx]}) {L.strip()}')
                    elif sig_hit and len(sig_hit) >= 2:  # 多签名词共振，无名字邻近，也入册
                        B.append(f'{fname[:3]}:{i+1}| (无名字邻近 词:{sig_hit}) {L.strip()}')
        lines_out += [f'## {role}', f'- A 名字邻接对白条：{len(A)}｜B 签名词候选：{len(B)}｜N 反例词候选：{len(N)}', '']
        for sec, tag in ((A, 'A'), (N, 'N'), (B, 'B')):
            if sec:
                lines_out += [f'### {role} {tag} 段'] + sec + ['']
    (OUT / f'{fam}.md').write_text('\n'.join(lines_out), encoding='utf-8', newline='\n')
    print(fam, '->', OUT / f'{fam}.md')
print('章数入审:', len(chapters))
