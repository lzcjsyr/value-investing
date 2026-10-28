-- 核心论点去掉“壁垒”类别，原壁垒类论点并入“经营”（2026-10-28）。
-- 壁垒与经营大量重复：壁垒最终都体现在经营结果上。竞争壁垒页改为：关联了经营类论点即算专门论证过（build_bizviews.py）。
-- 只改数据与 NocoBase 下拉选项，不必重跑 register.py；执行后重建各公司壁垒页（build_bizviews.py <代码> moat thesis）。
BEGIN;
UPDATE vi_thesis_base SET category = '经营' WHERE category = '壁垒';
COMMENT ON COLUMN vi_thesis_base.category IS '类别：不利事件本身写在风险分析；这里只放有争议、决定价值的判断（可选：经营、财务、治理、估值）';
UPDATE fields
   SET options = jsonb_set(options::jsonb, '{uiSchema,enum}',
                           (SELECT jsonb_agg(e) FROM jsonb_array_elements(options::jsonb->'uiSchema'->'enum') e WHERE e->>'value' <> '壁垒'))::json
 WHERE "collectionName" = 'vi_thesis' AND name = 'category';
COMMIT;
