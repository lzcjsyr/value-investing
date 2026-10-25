DROP VIEW IF EXISTS zt_a, zt_b CASCADE;
DROP TABLE IF EXISTS zt_a_base, zt_b_base, zt_lnk_a_b CASCADE;
CREATE TABLE zt_b_base (id bigserial PRIMARY KEY, title text);
CREATE TABLE zt_a_base (id bigserial PRIMARY KEY, name text, x numeric, b_id bigint);
CREATE TABLE zt_lnk_a_b (a_id bigint NOT NULL, b_id bigint NOT NULL, PRIMARY KEY (a_id, b_id));
INSERT INTO zt_b_base(title) VALUES ('B1'),('B2');
INSERT INTO zt_a_base(name,x,b_id) VALUES ('A1',1.5,1);
INSERT INTO zt_lnk_a_b VALUES (1,1),(1,2);
CREATE VIEW zt_b AS SELECT * FROM zt_b_base;
CREATE VIEW zt_a AS SELECT a.id, a.name, a.x, a.b_id, a.x*2 AS x2, (SELECT count(*) FROM zt_lnk_a_b l WHERE l.a_id=a.id) AS n_links FROM zt_a_base a JOIN LATERAL (SELECT 1) z ON true;
CREATE FUNCTION zt_a_dml() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP='INSERT' THEN
    INSERT INTO zt_a_base(name,x,b_id) VALUES (NEW.name,NEW.x,NEW.b_id) RETURNING id INTO NEW.id; RETURN NEW;
  ELSIF TG_OP='UPDATE' THEN
    UPDATE zt_a_base SET name=NEW.name,x=NEW.x,b_id=NEW.b_id WHERE id=OLD.id; RETURN NEW;
  ELSE DELETE FROM zt_a_base WHERE id=OLD.id; RETURN OLD; END IF;
END $$;
CREATE TRIGGER zt_a_dml INSTEAD OF INSERT OR UPDATE OR DELETE ON zt_a FOR EACH ROW EXECUTE FUNCTION zt_a_dml();
