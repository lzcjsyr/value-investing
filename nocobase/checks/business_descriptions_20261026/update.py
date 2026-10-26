from pathlib import Path
from copy import deepcopy
import sys,json
sys.path.insert(0,str(Path('framework').resolve()))
import build_pages as b
from data_domains import business_description
out=Path('checks/business_descriptions_20261026')
def dump(name,obj):
 (out/(name+'.json')).write_text(json.dumps(obj,ensure_ascii=False,indent=1))
results=[]
for co in b.companies():
 if co['code'] not in {'600900.SH','002078.SZ','601668.SH','01698.HK','01810.HK'}:continue
 key='observation@'+co['code']; before=b.page_tree(key);dump('before_'+co['code'],before)
 expected=deepcopy(before['tree'])
 for tab in expected['subModels']['tabs']:
  name=tab['props']['title']; assert name in ['定期经营数据','高频业务数据']
  block=next(n for n in tab['subModels']['grid']['subModels']['items'] if n['use']=='TableBlockModel')
  desc=business_description(automatic=name=='高频业务数据')
  b.nb_json('flow-surfaces','configure','--target',json.dumps({'uid':block['uid']}),'--changes',json.dumps({'description':desc},ensure_ascii=False))
  block['stepParams']['cardSettings']['titleDescription']['description']=desc
 after=b.page_tree(key);dump('after_'+co['code'],after)
 assert after['tree']==expected, '简介之外出现意外变更：'+co['name']
 p=Path('framework/blueprints')/('observation_'+co['code']+'.json')
 if p.exists():
  blueprint=json.loads(p.read_text())
  for tab in blueprint['tabs']:
   for block in tab['blocks']:
    block.setdefault('settings',{})['description']=business_description(automatic=tab['title']=='高频业务数据')
  p.write_text(json.dumps(blueprint,ensure_ascii=False,indent=1))
 results.append({'company':co['name'],'tabs':{t['props']['title']:next(n for n in t['subModels']['grid']['subModels']['items'] if n['use']=='TableBlockModel')['stepParams']['cardSettings']['titleDescription']['description'] for t in after['tree']['subModels']['tabs']},'only_description_changed':True})
 print(co['name']+'：两个简介更新并回读通过',flush=True)
dump('verification',{'passed':True,'companies':results})
