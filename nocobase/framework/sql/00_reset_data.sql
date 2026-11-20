-- 清空全部 vi_ 数据（表结构、视图、页面不变）。从零重灌所有公司前执行，之后按顺序灌入：
--   companies/600900_长江电力/seed.sql（使用固定 id，必须第一个）→ companies/002078_太阳纸业/seed.sql → 其他公司
-- 注意：会清掉自动采集来的市场观察、采集运行记录和你在界面里录入的数据，执行前先 ./backup.sh。
BEGIN;
DO $$ DECLARE r record; BEGIN
  FOR r IN SELECT tablename FROM pg_tables WHERE schemaname = 'public'
            AND (tablename LIKE 'vi\_%\_base' OR tablename LIKE 'vi\_lnk\_%') LOOP
    EXECUTE 'TRUNCATE ' || r.tablename || ' RESTART IDENTITY CASCADE';
  END LOOP;
END $$;
-- 统一设置的默认门槛（清空后补回，否则全部估值算不出）
INSERT INTO vi_setting_base (name, hurdle, note) VALUES ('全局', 0.06, '全部公司统一使用的投资回报率要求；在这里改，所有估值同时更新。');
COMMIT;
