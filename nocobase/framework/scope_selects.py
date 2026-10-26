"""表单里的关联下拉只列“这家公司”的记录（以及公用的宏观指标）。

弹窗表单按集合复用模板，五家公司共用一份，所以不能写死公司 id：数据范围读当前表单里选的公司
（{{ctx.formValues.company.id}}；按模型归属的表读所选模型的 company_id；数据表读所选指标的 company_id）。
flow-surfaces 不开放字段级数据范围（selectSettings 不在 update-settings 白名单），这里走 flowModels:save，
和在界面上点“设置数据范围”保存的是同一个位置。规则全部由 spec 推出，可重复执行；重建页面（build_pages.rebuild）后要重跑。

  python3 scope_selects.py           # 写入
  python3 scope_selects.py --dry     # 只列出将要写的规则
"""
import json, pathlib, subprocess, sys, urllib.request
import spec

ROOT = pathlib.Path(__file__).resolve().parent.parent
T = spec.all_tables()
MACRO = {'path': 'scope', 'operator': '$eq', 'value': '宏观'}
MACRO_ONLY = {('company', 'price_fx_metric'), ('company', 'macro_metrics')}   # 只能选宏观指标（汇率、订阅）


def company_var(code):
    """这张表的表单里，“当前公司”从哪里读。"""
    rels = {f['name'] for f in spec.m2o_fields(T[code])}
    if 'company' in rels:
        return '{{ctx.formValues.company.id}}'
    if 'model' in rels:
        return '{{ctx.formValues.model.company_id}}'
    if code == 'observation':
        return '{{ctx.formValues.metric.company_id}}'
    if code == 'company':
        return '{{ctx.formValues.id}}'


def rule(code, f):
    """(表, 关联字段) → 下拉的数据范围；None＝不限制。"""
    target, c = f['target'], company_var(code)
    if (code, f['name']) in MACRO_ONLY:
        return {'logic': '$and', 'items': [MACRO]}
    if target == 'scenario' and 'model' in {x['name'] for x in spec.m2o_fields(T[code])}:
        return {'logic': '$and', 'items': [{'path': 'model_id', 'operator': '$eq', 'value': '{{ctx.formValues.model.id}}'}]}
    if not c or target in ('company', 'raw_capture', 'collector', 'collect_run') or c.startswith(f"{{{{ctx.formValues.{f['name']}."):
        return None
    own = {'path': 'company_id', 'operator': '$eq', 'value': c}
    if target == 'metric':
        return {'logic': '$or', 'items': [own, MACRO]}
    if 'company' in {x['name'] for x in spec.m2o_fields(T[target])}:
        return {'logic': '$and', 'items': [own]}


def rules():
    out = {}
    for t in spec.TABLES:
        for f in t['fields']:
            if f['kind'] in ('m2o', 'm2m') and (r := rule(t['code'], f)):
                out[(f"vi_{t['code']}", f['name'])] = r
    return out


def psql(sql):
    return subprocess.run([str(ROOT / 'psql.sh'), '-At', '-c', sql], capture_output=True, text=True, check=True).stdout


def save(model):
    env = json.loads((pathlib.Path.home() / '.nocobase/config.json').read_text())['envs']['local']
    req = urllib.request.Request(f"{env['apiBaseUrl']}/flowModels:save", data=json.dumps(model, ensure_ascii=False).encode(),
                                 method='POST', headers={'Authorization': f"Bearer {env['auth']['accessToken']}",
                                                         'Content-Type': 'application/json'})
    urllib.request.urlopen(req).read()


def main(dry=False):
    want = rules()
    rows = psql("""SELECT coalesce(json_agg(json_build_object('uid', uid, 'options', options)), '[]') FROM "flowModels"
                   WHERE options->>'use' = 'RecordSelectFieldModel'
                     AND options->'stepParams'->'fieldSettings'->'init'->>'collectionName' LIKE 'vi\\_%'""")
    done = same = 0
    for row in json.loads(rows):
        opt = row['options']
        init = opt['stepParams']['fieldSettings']['init']
        scope = want.get((init['collectionName'], init['fieldPath']))
        if not scope:
            continue
        sel = opt['stepParams'].setdefault('selectSettings', {})
        if sel.get('dataScope') == {'filter': scope}:
            same += 1
            continue
        if dry:
            print(row['uid'], init['collectionName'], init['fieldPath'], json.dumps(scope, ensure_ascii=False))
        else:
            sel['dataScope'] = {'filter': scope}
            save({'uid': row['uid'], **opt})
        done += 1
    print(f"规则 {len(want)} 条；{'待写' if dry else '写入'} {done} 个下拉，已一致 {same} 个")


if __name__ == '__main__':
    if '--rules' in sys.argv:
        for (c, f), r in rules().items():
            print(c, f, json.dumps(r, ensure_ascii=False))
    else:
        main(dry='--dry' in sys.argv)
