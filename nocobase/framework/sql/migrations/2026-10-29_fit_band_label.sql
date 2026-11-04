-- 模板文案调整：中间档 22—31 分从“可研究”改为“合适”，分数和检查规则不变。
BEGIN;
DO $migration$
DECLARE definition text;
BEGIN
  SELECT pg_get_viewdef('public.vi_check'::regclass, true) INTO definition;
  EXECUTE 'CREATE OR REPLACE VIEW public.vi_check AS ' || replace(definition, '可研究', '合适');
END
$migration$;
COMMENT ON TABLE vi_fit_score_base IS '价投适配度：按八个维度打分，看公司适不适合价值投资；引用【核心论点】；被【质量自检】引用。长坡、厚雪、慢变、护城河、再投资、财务质量、治理配置、可估值性，各 0—5 分。总分 32—40 适合复利框架，22—31 合适，21 以下通常不符合价值投资标准。';
COMMIT;
