from pathlib import Path
import sys,json
sys.path.insert(0,str(Path('framework').resolve()))
import build_pages as b
out=Path('checks/page_names_20261026')
def dump(name,obj):
 (out/(name+'.json')).write_text(json.dumps(obj,ensure_ascii=False,indent=1))
def nodes(x):
 if isinstance(x,dict):
  if 'use' in x: yield x
  for v in x.values(): yield from nodes(v)
 elif isinstance(x,list):
  for v in x: yield from nodes(v)
def configure(uid,changes):
 return b.nb_json('flow-surfaces','configure','--target',json.dumps({'uid':uid}),'--changes',json.dumps(changes,ensure_ascii=False))
results=[]
for co in b.companies():
 code=co['code']; name=co['name']
 if code not in {'600900.SH','002078.SZ','601668.SH','01698.HK','01810.HK'}: continue
 trees={key:b.page_tree(key+'@'+code) for key in ['observation','fact']}
 dump('before_'+code,trees)
 business=trees['observation']['tree']; fact=trees['fact']['tree']
 tab=next(t for t in business['subModels']['tabs'] if t['props']['title'] in ['公司披露','定期经营数据'])
 b.nb_json('flow-surfaces','update-tab','--target',json.dumps({'uid':tab['uid']}),'--title','定期经营数据')
 configure(fact['uid'],{'title':'重要事实','documentTitle':name+' · 重要事实'})
 b.nb_json('flow-surfaces','update-menu','--menu-route-id',str(b.state()['pages']['fact@'+code]['routeId']),'--title','重要事实')
 for ft in fact['subModels']['tabs']:
  if ft['props']['title'] in ['事实摘录','重要事实']:
   b.nb_json('flow-surfaces','update-tab','--target',json.dumps({'uid':ft['uid']}),'--title','重要事实','--document-title',name+' · 重要事实')
 for node in nodes(fact):
  ov=node.get('stepParams',{}).get('popupSettings',{}).get('openView',{})
  if '事实摘录' in ov.get('title',''):
   configure(node['uid'],{'openView':{**ov,'title':ov['title'].replace('事实摘录','重要事实')}})
 after={key:b.page_tree(key+'@'+code) for key in ['observation','fact']}
 dump('after_'+code,after)
 newbiz=after['observation']['tree']; newfact=after['fact']['tree']
 assert [t['props']['title'] for t in newbiz['subModels']['tabs']]==['定期经营数据','高频业务数据']
 assert newfact['props']['title']=='重要事实'
 assert all(t['props']['title']=='重要事实' for t in newfact['subModels']['tabs'])
 oldgrids=[n for n in nodes(business) if n['use']=='BlockGridModel']
 newgrids=[n for n in nodes(newbiz) if n['use']=='BlockGridModel']
 assert oldgrids==newgrids, '业务表格内容发生意外变化'
 oldtables={n['uid']:n.get('stepParams',{}).get('tableSettings') for n in nodes(fact) if n['use']=='TableBlockModel'}
 newtables={n['uid']:n.get('stepParams',{}).get('tableSettings') for n in nodes(newfact) if n['use']=='TableBlockModel'}
 assert oldtables==newtables, '重要事实筛选或表格设置发生意外变化'
 results.append({'company':name,'business_tabs':['定期经营数据','高频业务数据'],'fact_page':'重要事实','layout_preserved':True})
 print(name+'：改名与回读通过',flush=True)
routes=b.routes(); dump('routes_after',routes)
def walk(ns):
 for n in ns:
  yield n
  yield from walk(n.get('children') or [])
byid={r['id']:r for r in walk(routes)}
for co in b.companies():
 if co['name'] not in {x['company'] for x in results}:continue
 assert byid[b.state()['pages']['fact@'+co['code']]['routeId']]['title']=='重要事实'
dump('verification',{'passed':True,'companies':results})
