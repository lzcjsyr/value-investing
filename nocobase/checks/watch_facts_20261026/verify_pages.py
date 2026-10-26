import sys,json
from pathlib import Path
sys.path.insert(0,str(Path('framework').resolve()))
import build_pages as bp
out=Path('checks/watch_facts_20261026')
results=[]
def nodes(x):
 if isinstance(x,dict):
  if x.get('use'):yield x
  for v in x.values():yield from nodes(v)
 elif isinstance(x,list):
  for v in x:yield from nodes(v)
for co in bp.companies():
 tree=bp.page_tree(bp.page_key('watch',co));(out/('after_'+co['code']+'.json')).write_text(json.dumps(tree,ensure_ascii=False))
 fields=[]
 for n in nodes(tree):
  init=n.get('stepParams',{}).get('fieldSettings',{}).get('init',{})
  if init.get('collectionName')=='vi_watch' and init.get('fieldPath'):fields.append(init['fieldPath'])
 assert not set(fields)&bp.WATCH_HIDDEN,(co['code'],set(fields)&bp.WATCH_HIDDEN)
 for field in ['latest_fact','fact_as_of','fetch_method','frequency','state','fact_note','fact_date']:
  assert field in fields,(co['code'],field)
 results.append({'company':co['code'],'active_fields':sorted(set(fields)),'legacy_hidden':True})
(out/'page_verification.json').write_text(json.dumps(results,ensure_ascii=False,indent=1))
print('五家公司页面、详情及表单的实际字段验证通过')
