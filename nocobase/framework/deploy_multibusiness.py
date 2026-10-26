"""局部登记结构、更新小米的商业模式、估值与驾驶舱；先执行已核验的 migration.sql。

python3 framework/deploy_multibusiness.py --register
docker compose restart app
python3 framework/deploy_multibusiness.py --pages
"""
import json
import sys
from pathlib import Path
import spec
import register
import build_pages as bp
import align_companies as align

OUT=bp.ROOT/'checks/multibusiness_20261026'
WRITABLE={'business','biz_model','sotp_segment','sotp_item'}
REPORTS={'sotp','sotp_segment_val'}

def register_collections():
    all_tables=spec.all_tables() | {r['code']:r for r in spec.REPORTS}
    for code in ['business','biz_model','sotp_segment','sotp_item','sotp_segment_val','sotp']:
        view=register.nb('db-views','get','--filter-by-tk','vi_'+code,'--schema','public')
        if not view.get('data'): raise RuntimeError('上游视图未找到：'+code)
        (OUT/f'view_{code}.json').write_text(json.dumps(view,ensure_ascii=False,indent=1))
        result=register.nb('collections','apply',body=register.collection_body(all_tables[code],report=code in REPORTS))
        (OUT/f'register_{code}.json').write_text(json.dumps(result,ensure_ascii=False,indent=1))
        print('已登记',code,flush=True)
    register.register_relations(WRITABLE)
    register.mark_relation_source(WRITABLE)
    print('关系字段已建立；页面更新前执行 docker compose restart app',flush=True)

def pages():
    co=next(c for c in bp.companies() if c['code']=='01810.HK')
    # 这三个页面原地更新；其他公司和小米其余页面不重建。
    align.business(co,only={'biz_model'})
    align.finance(co,only={'val'})
    align.dashboard(co)
    register.describe(WRITABLE|REPORTS)
    print('小米商业模式、估值和驾驶舱已更新',flush=True)

if __name__=='__main__':
    OUT.mkdir(parents=True,exist_ok=True)
    if '--register' in sys.argv: register_collections()
    elif '--pages' in sys.argv: pages()
    else: raise SystemExit('选择 --register 或 --pages')
