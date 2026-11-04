-- 定性事实分两层：事项（一件事：短名称＋简介）→ 定性事实（这件事的一个侧面，各自有日期、来源、核验状态）（2026-11-04）。
-- 顺序：本迁移 → 02_calc.sql（vi_event_calc）→ 03_ui.sql → register.py → 重启 app → register.py --describe；腾讯音乐数据见 companies/01698_腾讯音乐/events_20261104.sql。
BEGIN;
CREATE TABLE IF NOT EXISTS vi_event_base (
  id bigserial PRIMARY KEY,
  name text,
  category text,
  status text,
  period text,
  summary text,
  company_id bigint,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE vi_event_base IS '事项：一件事一行（并购、监管变化、竞争格局、资本运作等），短名称加简介；具体的可核验侧面是挂在它下面的定性事实；被【定性事实】引用。名称用短名词短语，不带数字；简介三五句讲清来龙去脉、关键条款和现状。每个侧面（日期、来源、核验状态各自独立）记在定性事实里，上层判断引用侧面；零散的一次性事实可以不挂事项。';
COMMENT ON COLUMN vi_event_base.name IS '事项：短名称，不带数字，如“喜马拉雅收购”';
COMMENT ON COLUMN vi_event_base.category IS '类别（可选：经营、财务、资本开支、分红、债务、政策、治理、竞争、估值方法、其他）';
COMMENT ON COLUMN vi_event_base.status IS '状态（可选：进行中、已完成、持续、待观察）';
COMMENT ON COLUMN vi_event_base.period IS '时间：发生或持续的时间，如 2026、2018—2025';
COMMENT ON COLUMN vi_event_base.summary IS '简介：三五句讲清来龙去脉、关键条款和现状；细节看下面的各个侧面';
COMMENT ON COLUMN vi_event_base.company_id IS '公司（关联 公司）';
CREATE OR REPLACE TRIGGER vi_event_base_touch BEFORE UPDATE ON vi_event_base FOR EACH ROW EXECUTE FUNCTION vi_touch_updated_at();
ALTER TABLE vi_event_base ADD FOREIGN KEY (company_id) REFERENCES vi_company_base(id) ON DELETE SET NULL;
CREATE INDEX ON vi_event_base (company_id);
ALTER TABLE vi_event_base ADD CONSTRAINT vi_event_uniq UNIQUE (company_id, name);
ALTER TABLE vi_fact_base ADD COLUMN IF NOT EXISTS event_id bigint;
COMMENT ON COLUMN vi_fact_base.event_id IS '所属事项（关联 事项）';
ALTER TABLE vi_fact_base ADD FOREIGN KEY (event_id) REFERENCES vi_event_base(id) ON DELETE SET NULL;
CREATE INDEX ON vi_fact_base (event_id);
COMMENT ON TABLE vi_fact_base IS '定性事实：数字以外、会改变判断的事实：制度监管、合作授权、并购与资本运作、人事、诉讼、管理层表态、竞争对手动作，以及外部观点与估值参照；引用【来源文档】【事项】；被【商业模式拆解】【产业链与五力】【竞争对手】【竞争壁垒】【核心论点】【风险分析】【假设依据】【资产估值与调整】【经营分部估值】【逐年假设】引用。一条可核验的定性事实，通常是某个事项的一个侧面。按期重复的数字不放这里：它们在「指标／数据」里，上层判断用“依据指标”引用；一次性的数字（并购对价、回购额度）可以写进事实。';
COMMENT ON COLUMN vi_fact_base.title IS '侧面：短名称，说明是事项的哪个侧面，如“交易对价与商誉”';
COMMENT ON COLUMN vi_fact_base.statement IS '陈述：写清这个侧面发生了什么、关键数字与出处';
COMMENT ON COLUMN vi_fact_base.event_id IS '所属事项（关联 事项）';
COMMIT;
