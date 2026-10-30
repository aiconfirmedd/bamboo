-- Apply once using the migration/owner account, never the web-service login.
BEGIN;
CREATE ROLE intake_runtime LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOBYPASSRLS;
CREATE SCHEMA setup_intake;
REVOKE ALL ON SCHEMA setup_intake FROM PUBLIC;
CREATE TABLE setup_intake.submissions (
 id uuid PRIMARY KEY,
 subject text NOT NULL CHECK (length(subject) BETWEEN 1 AND 255),
 input_hash text NOT NULL,
 payload jsonb NOT NULL,
 status text NOT NULL DEFAULT 'received' CHECK(status IN ('received','reviewed','closed')),
 created_at timestamptz NOT NULL DEFAULT now(),
 expires_at timestamptz NOT NULL,
 UNIQUE(subject,input_hash),
 CHECK(expires_at > created_at AND expires_at <= created_at + interval '365 days')
);
CREATE TABLE setup_intake.audit (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 submission_id uuid,
 actor text NOT NULL,
 action text NOT NULL CHECK(action IN ('submit','export','reviewed','closed','received','delete')),
 created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON setup_intake.audit(actor,created_at);
CREATE INDEX ON setup_intake.submissions(expires_at);
ALTER TABLE setup_intake.submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE setup_intake.submissions FORCE ROW LEVEL SECURITY;
ALTER TABLE setup_intake.audit ENABLE ROW LEVEL SECURITY;
ALTER TABLE setup_intake.audit FORCE ROW LEVEL SECURITY;
CREATE POLICY read_submission ON setup_intake.submissions FOR SELECT TO intake_runtime
 USING (subject=current_setting('app.subject',true) OR current_setting('app.operator',true)='true');
CREATE POLICY insert_submission ON setup_intake.submissions FOR INSERT TO intake_runtime
 WITH CHECK (subject=current_setting('app.subject',true));
CREATE POLICY review_submission ON setup_intake.submissions FOR UPDATE TO intake_runtime
 USING (current_setting('app.operator',true)='true') WITH CHECK (current_setting('app.operator',true)='true');
CREATE POLICY delete_submission ON setup_intake.submissions FOR DELETE TO intake_runtime
 USING (subject=current_setting('app.subject',true) OR current_setting('app.operator',true)='true');
CREATE POLICY read_audit ON setup_intake.audit FOR SELECT TO intake_runtime
 USING (actor=current_setting('app.subject',true) OR current_setting('app.operator',true)='true');
CREATE POLICY append_audit ON setup_intake.audit FOR INSERT TO intake_runtime
 WITH CHECK (actor=current_setting('app.subject',true));
-- Maintenance uses the same restricted role, with explicit operator context.
CREATE POLICY purge_audit ON setup_intake.audit FOR DELETE TO intake_runtime
 USING (current_setting('app.operator',true)='true' AND created_at < now()-interval '90 days');
GRANT USAGE ON SCHEMA setup_intake TO intake_runtime;
GRANT SELECT,INSERT,DELETE ON setup_intake.submissions TO intake_runtime;
GRANT UPDATE(status) ON setup_intake.submissions TO intake_runtime;
GRANT SELECT,INSERT,DELETE ON setup_intake.audit TO intake_runtime;
GRANT USAGE ON SEQUENCE setup_intake.audit_id_seq TO intake_runtime;
COMMIT;
