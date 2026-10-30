-- Architecture baseline, not applied to any database. PostgreSQL 17+.
-- Clean-room: recon entities/flows only; no reference implementation code.
-- Assumptions A1: one organization per deployment; UUID org keys remain for isolation.
-- A2: Auth.js custom adapter, owner-managed OIDC IdP (MFA/SAML/passkeys upstream).
-- A3: server-only SQL. No browser SQL, PostgREST or untrusted SQL execution.
-- Authorization is a mandatory data-layer check on EVERY query (see api-plan.md).
-- RLS below enforces tenant isolation and read-only preview, NOT column masking.
-- can_access() is the common explicit grant evaluator; nested documents/history,
-- hiring collaborators, review disclosure and survey aggregates need their additional
-- resource rules in api-plan.md. Never expose SELECT * or raw JSON to a client.
-- Runtime role is neither owner nor BYPASSRLS; migration owner stays off the app.
-- SET LOCAL app.org_id / app.actor_id / app.effective_user_id is server-only, after
-- validating session and preview; use one transaction/connection, even with pooling.
-- Public packet/application/signing endpoints use a validated scoped capability,
-- never a user-controlled org context. Worker credentials never reach the browser.
-- Date-only birth dates are carried as UTC-midnight timestamptz and displayed
-- as calendar dates without timezone shifting. Hire/termination effective inputs
-- use organization-local midnight converted to UTC; never UTC midnight as cutoff.
-- Sensitive field values and table-row JSON must be envelope-encrypted by the
-- service (external KMS key), excluded from logs, and individually field-authorized.
-- Every table has UUID PK + timestamps; all tenant FKs include org_id.
BEGIN;
CREATE EXTENSION IF NOT EXISTS btree_gist;
CREATE SCHEMA hr;
REVOKE ALL ON SCHEMA hr FROM PUBLIC;
DO $$ BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname='hr_runtime') THEN
    CREATE ROLE hr_runtime NOLOGIN NOSUPERUSER NOBYPASSRLS;
  END IF;
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname='hr_survey_ingest') THEN
    CREATE ROLE hr_survey_ingest NOLOGIN NOSUPERUSER NOBYPASSRLS;
  END IF;
END $$;
SET LOCAL search_path = hr, public;
CREATE FUNCTION hr.context_uuid(setting_name text) RETURNS uuid
LANGUAGE sql STABLE SET search_path = pg_catalog AS $$
 SELECT nullif(current_setting(setting_name, true),'')::uuid
$$;
CREATE FUNCTION hr.touch_updated_at() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at=now(); NEW.row_version=OLD.row_version+1; RETURN NEW; END $$;
CREATE TABLE hr.organizations (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
 row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
 singleton boolean NOT NULL DEFAULT true UNIQUE CHECK(singleton),
 name text NOT NULL, timezone text NOT NULL DEFAULT 'America/New_York',
 brand jsonb NOT NULL DEFAULT '{}' CHECK(jsonb_typeof(brand)='object'),
 settings jsonb NOT NULL DEFAULT '{}' CHECK(jsonb_typeof(settings)='object')
);
CREATE TABLE hr.org_units (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  kind text NOT NULL CHECK(kind IN ('department','division','location','team')), name text NOT NULL, parent_id uuid, UNIQUE(org_id,kind,name)
);
CREATE TABLE hr.employees (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  first_name text NOT NULL, last_name text NOT NULL, work_email text,
 phone text, job_title text, department_id uuid, division_id uuid, location_id uuid,
 supervisor_id uuid, employment_status text NOT NULL DEFAULT 'prehire'
 CHECK(employment_status IN ('prehire','active','leave','terminated')),
 employment_type text NOT NULL DEFAULT 'employee' CHECK(employment_type IN ('employee','contractor','intern','other')),
 hire_at timestamptz, termination_at timestamptz, termination_type text,
 termination_reason text, rehire_eligible boolean, regrettable boolean, photo_file_id uuid,
 access_not_before timestamptz,
 CHECK(supervisor_id IS DISTINCT FROM id),
 CHECK(termination_at IS NULL OR hire_at IS NULL OR termination_at>=hire_at),
 CHECK(termination_type IS NULL OR termination_type IN ('voluntary','involuntary','other'))
);
CREATE UNIQUE INDEX employee_email_unique ON hr.employees(org_id,lower(work_email)) WHERE work_email IS NOT NULL;
CREATE TABLE hr.employee_teams (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  employee_id uuid NOT NULL, team_id uuid NOT NULL, UNIQUE(org_id,employee_id,team_id)
);
CREATE TABLE hr.app_users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  email text NOT NULL, employee_id uuid, status text NOT NULL DEFAULT 'invited' CHECK(status IN ('invited','active','suspended','revoked')), non_employee boolean NOT NULL DEFAULT false, session_version integer NOT NULL DEFAULT 1, UNIQUE(org_id,employee_id), CHECK(NOT non_employee OR employee_id IS NULL)
);
CREATE UNIQUE INDEX user_email_unique ON hr.app_users(org_id,lower(email));
CREATE TABLE hr.auth_identities (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  user_id uuid NOT NULL, provider text NOT NULL, subject text NOT NULL, tokens_ciphertext bytea, UNIQUE(provider,subject)
);
CREATE TABLE hr.auth_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  user_id uuid NOT NULL, token_hash text NOT NULL UNIQUE, expires_at timestamptz NOT NULL, revoked_at timestamptz, session_version integer NOT NULL
);
CREATE TABLE hr.auth_challenges (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  user_id uuid, kind text NOT NULL CHECK(kind IN ('invite','verify','recovery')), token_hash text NOT NULL UNIQUE, expires_at timestamptz NOT NULL, consumed_at timestamptz
);
CREATE TABLE hr.access_levels (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  name text NOT NULL, kind text NOT NULL CHECK(kind IN ('employee','manager','admin','custom')), UNIQUE(org_id,name)
);
CREATE TABLE hr.user_access_levels (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  user_id uuid NOT NULL, access_level_id uuid NOT NULL, UNIQUE(org_id,user_id,access_level_id)
);
CREATE TABLE hr.permission_grants (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  access_level_id uuid NOT NULL, resource text NOT NULL,
 field_key text NOT NULL DEFAULT '*', action text NOT NULL CHECK(action IN ('read','write','manage','export')),
 scope text NOT NULL CHECK(scope IN ('self','reports','org','home')),
 UNIQUE(org_id,access_level_id,resource,field_key,action,scope)
);
CREATE TABLE hr.preview_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  actor_id uuid NOT NULL, target_user_id uuid NOT NULL, token_hash text NOT NULL UNIQUE, reason text NOT NULL, expires_at timestamptz NOT NULL, ended_at timestamptz, CHECK(actor_id<>target_user_id)
);
CREATE TABLE hr.profile_tabs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  key text NOT NULL, label text NOT NULL, position integer NOT NULL DEFAULT 0, visible boolean NOT NULL DEFAULT true, UNIQUE(org_id,key)
);
CREATE TABLE hr.employee_fields (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  key text NOT NULL, label text NOT NULL, data_type text NOT NULL CHECK(data_type IN ('text','select','multiselect','date','currency','number','boolean','file')), list_values jsonb NOT NULL DEFAULT '[]' CHECK(jsonb_typeof(list_values)='array'), tab_id uuid, position integer NOT NULL DEFAULT 0, custom boolean NOT NULL DEFAULT true, sensitive boolean NOT NULL DEFAULT false, approval_required boolean NOT NULL DEFAULT false, table_key text, storage text NOT NULL CHECK(storage IN ('column','value','history')), UNIQUE(org_id,key)
);
CREATE TABLE hr.employee_field_values (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  employee_id uuid NOT NULL, field_id uuid NOT NULL, value jsonb, ciphertext bytea, cents bigint, currency char(3), CHECK(num_nonnulls(value,ciphertext,cents)=1), CHECK((cents IS NULL)=(currency IS NULL)), CHECK(currency IS NULL OR currency ~ '^[A-Z]{3}$'), UNIQUE(org_id,employee_id,field_id)
);
CREATE TABLE hr.employee_table_rows (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  employee_id uuid NOT NULL, table_key text NOT NULL CHECK(table_key IN ('jobInfo','compensation','employmentStatus','dependents','contacts','emergencyContacts','bonus','commission','custom')), effective_at timestamptz NOT NULL, fields jsonb NOT NULL DEFAULT '{}' CHECK(jsonb_typeof(fields)='object'), encrypted_fields bytea, custom_table_key text, CHECK((table_key='custom')=(custom_table_key IS NOT NULL))
);
CREATE TABLE hr.employee_notes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  employee_id uuid NOT NULL, author_id uuid NOT NULL, body text NOT NULL, deleted_at timestamptz, visibility text NOT NULL CHECK(visibility IN ('author','hr','manager'))
);
CREATE TABLE hr.file_categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  name text NOT NULL, scope text NOT NULL CHECK(scope IN ('company','employee')), parent_id uuid, visibility text NOT NULL DEFAULT 'restricted' CHECK(visibility IN ('restricted','employees','all')), employee_uploads boolean NOT NULL DEFAULT false, UNIQUE(org_id,name,scope)
);
CREATE TABLE hr.files (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  employee_id uuid, category_id uuid, folder text NOT NULL, name text NOT NULL, object_key text NOT NULL UNIQUE, content_type text NOT NULL, size_bytes bigint NOT NULL CHECK(size_bytes BETWEEN 1 AND 20971520), sha256 text NOT NULL CHECK(sha256 ~ '^[a-f0-9]{64}$'), uploaded_by uuid, shared boolean NOT NULL DEFAULT false, status text NOT NULL DEFAULT 'quarantine' CHECK(status IN ('quarantine','clean','rejected','deleted')), signed boolean NOT NULL DEFAULT false, visibility text NOT NULL DEFAULT 'restricted' CHECK(visibility IN ('restricted','employees','all')), audience jsonb NOT NULL DEFAULT '{}' CHECK(jsonb_typeof(audience)='object')
);
CREATE TABLE hr.file_grants (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  file_id uuid NOT NULL, user_id uuid NOT NULL, action text NOT NULL CHECK(action IN ('read','write')), UNIQUE(org_id,file_id,user_id,action)
);
CREATE TABLE hr.esign_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  document_id uuid NOT NULL, signed_file_id uuid, provider_request_id text UNIQUE, status text NOT NULL DEFAULT 'draft' CHECK(status IN ('draft','sent','partial','signed','declined','expired','void')), document_sha256 text NOT NULL, expires_at timestamptz, completed_at timestamptz, evidence jsonb NOT NULL DEFAULT '{}' CHECK(jsonb_typeof(evidence)='object')
);
CREATE TABLE hr.esign_signers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  request_id uuid NOT NULL, user_id uuid, email text NOT NULL, signing_order integer NOT NULL DEFAULT 0 CHECK(signing_order>=0), token_hash text NOT NULL UNIQUE, expires_at timestamptz NOT NULL, status text NOT NULL DEFAULT 'pending' CHECK(status IN ('pending','signed','declined')), signed_at timestamptz, consent_version text, evidence_object_key text, UNIQUE(org_id,request_id,email)
);
CREATE TABLE hr.job_requisitions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  requested_by uuid NOT NULL, approver_id uuid, title text NOT NULL, department_id uuid, location_id uuid, justification text NOT NULL, employment_type text NOT NULL DEFAULT 'full_time' CHECK(employment_type IN ('full_time','part_time','contract','temporary','intern','other')), description text NOT NULL DEFAULT '', hiring_lead_id uuid, status text NOT NULL DEFAULT 'draft' CHECK(status IN ('draft','pending','approved','rejected','cancelled')), decided_at timestamptz, decision_note text
);
CREATE TABLE hr.job_openings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  requisition_id uuid UNIQUE, title text NOT NULL, department_id uuid, location_id uuid, employment_type text NOT NULL CHECK(employment_type IN ('full_time','part_time','contract','temporary','intern','other')), description text NOT NULL, hiring_lead_id uuid NOT NULL, status text NOT NULL DEFAULT 'draft' CHECK(status IN ('draft','open','closed','filled')), public_slug text, questions jsonb NOT NULL DEFAULT '[]' CHECK(jsonb_typeof(questions)='array'), published_at timestamptz, UNIQUE(org_id,public_slug)
);
CREATE TABLE hr.job_collaborators (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  job_id uuid NOT NULL, user_id uuid NOT NULL, permission text NOT NULL CHECK(permission IN ('read','review','manage')), UNIQUE(org_id,job_id,user_id)
);
CREATE TABLE hr.board_postings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  job_id uuid NOT NULL, board text NOT NULL, external_id text, url text, status text NOT NULL CHECK(status IN ('manual','pending','published','failed','closed')), last_error text, UNIQUE(org_id,job_id,board)
);
CREATE TABLE hr.candidate_statuses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  label text NOT NULL, position integer NOT NULL CHECK(position>=0), terminal_kind text CHECK(terminal_kind IN ('hired','rejected','withdrawn')), UNIQUE(org_id,label), UNIQUE(org_id,position) DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE hr.applications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  job_id uuid NOT NULL, status_id uuid NOT NULL, name text NOT NULL, email text NOT NULL, phone text, resume_file_id uuid, answers jsonb NOT NULL DEFAULT '{}' CHECK(jsonb_typeof(answers)='object'), source text NOT NULL, rating integer CHECK(rating BETWEEN 1 AND 5), applied_at timestamptz NOT NULL DEFAULT now(), withdrawn_at timestamptz, hired_employee_id uuid UNIQUE, privacy_consent_at timestamptz NOT NULL
);
CREATE TABLE hr.application_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  application_id uuid NOT NULL, from_status_id uuid, to_status_id uuid NOT NULL, actor_id uuid, occurred_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE hr.message_templates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  kind text NOT NULL CHECK(kind IN ('stage','offer','welcome','reminder')), name text NOT NULL, subject text NOT NULL, body text NOT NULL, merge_fields jsonb NOT NULL DEFAULT '[]' CHECK(jsonb_typeof(merge_fields)='array'), UNIQUE(org_id,kind,name)
);
CREATE TABLE hr.stage_automations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  status_id uuid NOT NULL, template_id uuid NOT NULL, enabled boolean NOT NULL DEFAULT false, UNIQUE(org_id,status_id,template_id)
);
CREATE TABLE hr.candidate_notes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  application_id uuid NOT NULL, author_id uuid, kind text NOT NULL CHECK(kind IN ('email','note','comment')), body text NOT NULL, subject text, direction text CHECK(direction IN ('inbound','outbound')), provider_message_id text UNIQUE, delivery_status text CHECK(delivery_status IN ('queued','sent','delivered','bounced','failed')), thread_id text
);
CREATE TABLE hr.interview_templates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  name text NOT NULL, duration_minutes integer NOT NULL CHECK(duration_minutes BETWEEN 5 AND 480), buffer_minutes integer NOT NULL DEFAULT 0 CHECK(buffer_minutes BETWEEN 0 AND 240), questions jsonb NOT NULL DEFAULT '[]' CHECK(jsonb_typeof(questions)='array')
);
CREATE TABLE hr.calendar_connections (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  user_id uuid NOT NULL, provider text NOT NULL, external_account text NOT NULL, credentials_ciphertext bytea NOT NULL, sync_cursor text, UNIQUE(org_id,user_id,provider)
);
CREATE TABLE hr.interview_invitations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  application_id uuid NOT NULL, template_id uuid NOT NULL, token_hash text NOT NULL UNIQUE, expires_at timestamptz NOT NULL, timezone text NOT NULL, consumed_at timestamptz
);
CREATE TABLE hr.interviews (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  application_id uuid NOT NULL, template_id uuid NOT NULL, invitation_id uuid UNIQUE, start_at timestamptz NOT NULL, end_at timestamptz NOT NULL, buffer_minutes integer NOT NULL DEFAULT 0 CHECK(buffer_minutes>=0), status text NOT NULL DEFAULT 'scheduled' CHECK(status IN ('scheduled','completed','cancelled','no_show')), external_event_id text, CHECK(end_at>start_at)
);
CREATE TABLE hr.interview_attendees (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  interview_id uuid NOT NULL, interviewer_id uuid NOT NULL, busy_range tstzrange NOT NULL CHECK(NOT isempty(busy_range) AND lower(busy_range) IS NOT NULL AND upper(busy_range) IS NOT NULL AND lower_inc(busy_range) AND NOT upper_inc(busy_range)), active boolean NOT NULL DEFAULT true, scorecard jsonb NOT NULL DEFAULT '{}' CHECK(jsonb_typeof(scorecard)='object'), submitted_at timestamptz, UNIQUE(org_id,interview_id,interviewer_id), EXCLUDE USING gist (interviewer_id WITH =, busy_range WITH &&) WHERE(active)
);
CREATE TABLE hr.offer_letters (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  application_id uuid NOT NULL, template_id uuid NOT NULL, fields jsonb NOT NULL DEFAULT '{}' CHECK(jsonb_typeof(fields)='object'), esign_request_id uuid UNIQUE, status text NOT NULL DEFAULT 'draft' CHECK(status IN ('draft','sent','accepted','declined','withdrawn','expired')), revision integer NOT NULL DEFAULT 1 CHECK(revision>0), supersedes_id uuid, UNIQUE(org_id,application_id,revision)
);
CREATE TABLE hr.task_lists (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  name text NOT NULL, kind text NOT NULL CHECK(kind IN ('onboarding','offboarding','it','manager')), UNIQUE(org_id,name)
);
CREATE TABLE hr.task_templates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  list_id uuid NOT NULL, title text NOT NULL, assignee_role text NOT NULL CHECK(assignee_role IN ('employee','manager','it','hr','specific_user')), assignee_id uuid, due_offset_days integer NOT NULL DEFAULT 0, position integer NOT NULL DEFAULT 0, required boolean NOT NULL DEFAULT true, CHECK((assignee_role='specific_user')=(assignee_id IS NOT NULL))
);
CREATE TABLE hr.packet_templates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  name text NOT NULL, welcome_body text NOT NULL DEFAULT '', get_to_know_you jsonb NOT NULL DEFAULT '[]' CHECK(jsonb_typeof(get_to_know_you)='array'), version integer NOT NULL DEFAULT 1 CHECK(version>0), UNIQUE(org_id,name,version)
);
CREATE TABLE hr.packet_template_fields (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  template_id uuid NOT NULL, field_id uuid NOT NULL, required boolean NOT NULL DEFAULT true, position integer NOT NULL DEFAULT 0, UNIQUE(org_id,template_id,field_id)
);
CREATE TABLE hr.packet_template_documents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  template_id uuid NOT NULL, document_id uuid NOT NULL, destination_folder text NOT NULL, required boolean NOT NULL DEFAULT true, UNIQUE(org_id,template_id,document_id)
);
CREATE TABLE hr.packet_template_lists (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  template_id uuid NOT NULL, list_id uuid NOT NULL, UNIQUE(org_id,template_id,list_id)
);
CREATE TABLE hr.packets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  employee_id uuid NOT NULL, template_id uuid NOT NULL, kind text NOT NULL CHECK(kind IN ('onboarding','rehire')), status text NOT NULL DEFAULT 'draft' CHECK(status IN ('draft','sent','in_progress','complete','cancelled')), template_snapshot jsonb NOT NULL CHECK(jsonb_typeof(template_snapshot)='object'), sensitive_snapshot_ciphertext bytea, due_at timestamptz NOT NULL, completed_at timestamptz, answers jsonb NOT NULL DEFAULT '{}' CHECK(jsonb_typeof(answers)='object'), sensitive_answers_ciphertext bytea, allow_portal_when_complete boolean NOT NULL DEFAULT false
);
CREATE TABLE hr.packet_signatures (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  packet_id uuid NOT NULL, request_id uuid NOT NULL UNIQUE, required boolean NOT NULL DEFAULT true, destination_folder text NOT NULL
);
CREATE TABLE hr.lifecycle_runs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  employee_id uuid NOT NULL, kind text NOT NULL CHECK(kind IN ('onboarding','offboarding','rehire')), packet_id uuid UNIQUE, effective_at timestamptz NOT NULL, status text NOT NULL CHECK(status IN ('pending','active','complete','cancelled')), UNIQUE(org_id,employee_id,kind,effective_at)
);
CREATE TABLE hr.tasks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  lifecycle_run_id uuid NOT NULL, packet_id uuid, list_id uuid, template_id uuid, employee_id uuid NOT NULL, assignee_id uuid, title text NOT NULL, assignee_role text NOT NULL CHECK(assignee_role IN ('employee','manager','it','hr','specific_user')), due_at timestamptz NOT NULL, position integer NOT NULL DEFAULT 0, required boolean NOT NULL DEFAULT true, status text NOT NULL DEFAULT 'todo' CHECK(status IN ('todo','done','waived')), completed_at timestamptz, completed_by uuid, CHECK((status='todo')=(completed_at IS NULL))
);
CREATE TABLE hr.capabilities (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  token_hash text NOT NULL UNIQUE, purpose text NOT NULL CHECK(purpose IN ('packet','application','former_employee','file_upload')), employee_id uuid, application_id uuid, packet_id uuid, expires_at timestamptz NOT NULL, revoked_at timestamptz, max_uses integer CHECK(max_uses>0), use_count integer NOT NULL DEFAULT 0 CHECK(use_count>=0)
);
CREATE TABLE hr.questions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  kind text NOT NULL CHECK(kind IN ('review','wellbeing','enps')), prompt text NOT NULL, response_type text NOT NULL CHECK(response_type IN ('text','rating','choice')), config jsonb NOT NULL DEFAULT '{}' CHECK(jsonb_typeof(config)='object'), version integer NOT NULL DEFAULT 1 CHECK(version>0)
);
CREATE TABLE hr.review_cycles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  name text NOT NULL, type text NOT NULL CHECK(type IN ('self','manager','peer','360','skip')), segments jsonb NOT NULL DEFAULT '{}' CHECK(jsonb_typeof(segments)='object'), opens_at timestamptz NOT NULL, closes_at timestamptz NOT NULL, double_blind boolean NOT NULL DEFAULT true, anonymous_peers boolean NOT NULL DEFAULT true, status text NOT NULL DEFAULT 'draft' CHECK(status IN ('draft','active','closed','released','cancelled')), source_cycle_id uuid, CHECK(closes_at>opens_at)
);
CREATE TABLE hr.review_cycle_questions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  cycle_id uuid NOT NULL, question_id uuid NOT NULL, position integer NOT NULL DEFAULT 0, employee_view boolean NOT NULL DEFAULT false, prompt_snapshot jsonb NOT NULL CHECK(jsonb_typeof(prompt_snapshot)='object'), UNIQUE(org_id,cycle_id,question_id)
);
CREATE TABLE hr.assessments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  cycle_id uuid NOT NULL, subject_id uuid NOT NULL, reviewer_id uuid NOT NULL, role text NOT NULL CHECK(role IN ('self','manager','peer','skip')), answers jsonb NOT NULL DEFAULT '{}' CHECK(jsonb_typeof(answers)='object'), draft boolean NOT NULL DEFAULT true, submitted_at timestamptz, released_at timestamptz, UNIQUE(org_id,cycle_id,subject_id,reviewer_id,role), CHECK(draft=(submitted_at IS NULL))
);
CREATE TABLE hr.goals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  owner_id uuid NOT NULL, department_id uuid, title text NOT NULL, description text NOT NULL DEFAULT '', visibility text NOT NULL DEFAULT 'private' CHECK(visibility IN ('private','shared')), level text NOT NULL DEFAULT 'individual' CHECK(level IN ('individual','department','company')), parent_goal_id uuid, progress integer NOT NULL DEFAULT 0 CHECK(progress BETWEEN 0 AND 100), status text NOT NULL DEFAULT 'active' CHECK(status IN ('active','completed','cancelled')), due_at timestamptz, CHECK(parent_goal_id IS DISTINCT FROM id)
);
CREATE TABLE hr.goal_members (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  goal_id uuid NOT NULL, employee_id uuid NOT NULL, can_edit boolean NOT NULL DEFAULT false, UNIQUE(org_id,goal_id,employee_id)
);
CREATE TABLE hr.goal_milestones (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  goal_id uuid NOT NULL, slot integer NOT NULL CHECK(slot BETWEEN 1 AND 10), title text NOT NULL, status text NOT NULL DEFAULT 'todo' CHECK(status IN ('todo','done')), UNIQUE(org_id,goal_id,slot)
);
CREATE TABLE hr.goal_comments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  goal_id uuid NOT NULL, author_id uuid NOT NULL, body text NOT NULL
);
CREATE TABLE hr.one_on_ones (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  manager_id uuid NOT NULL, employee_id uuid NOT NULL, scheduled_at timestamptz NOT NULL, end_at timestamptz NOT NULL, timezone text NOT NULL, agenda jsonb NOT NULL DEFAULT '[]' CHECK(jsonb_typeof(agenda)='array'), notes text NOT NULL DEFAULT '', status text NOT NULL CHECK(status IN ('scheduled','completed','cancelled')), CHECK(manager_id<>employee_id), CHECK(end_at>scheduled_at)
);
CREATE TABLE hr.core_values (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  name text NOT NULL, description text NOT NULL DEFAULT '', active boolean NOT NULL DEFAULT true, UNIQUE(org_id,name)
);
CREATE TABLE hr.recognition_allocations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  employee_id uuid NOT NULL, starts_at timestamptz NOT NULL, ends_at timestamptz NOT NULL, budget integer NOT NULL CHECK(budget>=0), CHECK(ends_at>starts_at), EXCLUDE USING gist(employee_id WITH =,tstzrange(starts_at,ends_at,'[)') WITH &&)
);
CREATE TABLE hr.recognition_posts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  author_id uuid NOT NULL, recipient_id uuid NOT NULL, allocation_id uuid, message text NOT NULL, core_value_id uuid, points integer NOT NULL DEFAULT 0 CHECK(points>=0), voided_at timestamptz, CHECK(author_id<>recipient_id), CHECK(points=0 OR allocation_id IS NOT NULL)
);
CREATE TABLE hr.survey_runs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  type text NOT NULL CHECK(type IN ('enps','wellbeing')), audience jsonb NOT NULL DEFAULT '{}' CHECK(jsonb_typeof(audience)='object'), opens_at timestamptz NOT NULL, closes_at timestamptz NOT NULL, anonymous boolean NOT NULL DEFAULT true CHECK(anonymous), reminders jsonb NOT NULL DEFAULT '[]' CHECK(jsonb_typeof(reminders)='array'), status text NOT NULL CHECK(status IN ('draft','active','closed','cancelled')), threshold integer NOT NULL DEFAULT 5 CHECK(threshold>=5), eligible_count integer NOT NULL CHECK(eligible_count>=0), CHECK(closes_at>opens_at)
);
CREATE TABLE hr.survey_questions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  run_id uuid NOT NULL, question_id uuid NOT NULL, position integer NOT NULL DEFAULT 0, snapshot jsonb NOT NULL CHECK(jsonb_typeof(snapshot)='object'), UNIQUE(org_id,run_id,question_id)
);
CREATE TABLE hr.survey_eligibility (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  run_id uuid NOT NULL, employee_id uuid NOT NULL, issued boolean NOT NULL DEFAULT false, UNIQUE(org_id,run_id,employee_id)
);
CREATE TABLE hr.survey_spent_tokens (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  run_id uuid NOT NULL, nonce_hash text NOT NULL, UNIQUE(org_id,run_id,nonce_hash)
);
CREATE TABLE hr.survey_responses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  run_id uuid NOT NULL, score integer CHECK(score BETWEEN 0 AND 10), answers jsonb NOT NULL DEFAULT '{}' CHECK(jsonb_typeof(answers)='object'), comment text, CHECK(score IS NOT NULL OR answers<>'{}'::jsonb)
);
CREATE TABLE hr.survey_aggregates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  run_id uuid NOT NULL UNIQUE, response_count integer NOT NULL CHECK(response_count>=0), eligible_count integer NOT NULL CHECK(eligible_count>=0), published jsonb NOT NULL DEFAULT '{}' CHECK(jsonb_typeof(published)='object'), suppressed boolean NOT NULL DEFAULT true
);
CREATE TABLE hr.announcements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  author_id uuid NOT NULL, title text NOT NULL, body text NOT NULL, audience jsonb NOT NULL DEFAULT '{}' CHECK(jsonb_typeof(audience)='object'), starts_at timestamptz NOT NULL, expires_at timestamptz, CHECK(expires_at IS NULL OR expires_at>starts_at)
);
CREATE TABLE hr.company_links (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  label text NOT NULL, url text NOT NULL CHECK(url ~ '^https://'), icon text, audience jsonb NOT NULL DEFAULT '{}' CHECK(jsonb_typeof(audience)='object'), position integer NOT NULL DEFAULT 0
);
CREATE TABLE hr.home_widgets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  key text NOT NULL, enabled boolean NOT NULL DEFAULT true, position integer NOT NULL DEFAULT 0, config jsonb NOT NULL DEFAULT '{}' CHECK(jsonb_typeof(config)='object'), UNIQUE(org_id,key)
);
CREATE TABLE hr.availability_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  employee_id uuid NOT NULL, starts_at timestamptz NOT NULL, ends_at timestamptz NOT NULL, label text NOT NULL DEFAULT 'Out', source text NOT NULL CHECK(source IN ('manual','import')), CHECK(ends_at>starts_at)
);
CREATE TABLE hr.community_posts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  author_id uuid NOT NULL, parent_id uuid, title text, body text NOT NULL, audience jsonb NOT NULL DEFAULT '{}' CHECK(jsonb_typeof(audience)='object'), deleted_at timestamptz
);
CREATE TABLE hr.notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  user_id uuid NOT NULL, kind text NOT NULL, payload jsonb NOT NULL DEFAULT '{}' CHECK(jsonb_typeof(payload)='object'), read_at timestamptz, dedupe_key text NOT NULL, UNIQUE(org_id,user_id,dedupe_key)
);
CREATE TABLE hr.reports (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  owner_id uuid NOT NULL, name text NOT NULL, kind text NOT NULL CHECK(kind IN ('standard','custom')), dataset text NOT NULL CHECK(dataset IN ('people','hiring','onboarding','reviews','goals','turnover','survey_aggregate')), fields jsonb NOT NULL CHECK(jsonb_typeof(fields)='array'), filters jsonb NOT NULL DEFAULT '[]' CHECK(jsonb_typeof(filters)='array'), archived_at timestamptz, sharing text NOT NULL DEFAULT 'private' CHECK(sharing IN ('private','org'))
);
CREATE TABLE hr.report_runs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  report_id uuid NOT NULL, requested_by uuid NOT NULL, status text NOT NULL CHECK(status IN ('queued','running','complete','failed','expired')), file_id uuid, expires_at timestamptz NOT NULL, filters_snapshot jsonb NOT NULL CHECK(jsonb_typeof(filters_snapshot)='object'), permission_version text NOT NULL
);
CREATE TABLE hr.report_schedules (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  report_id uuid NOT NULL, owner_id uuid NOT NULL, cron text NOT NULL, timezone text NOT NULL, enabled boolean NOT NULL DEFAULT false, next_run_at timestamptz
);
CREATE TABLE hr.api_keys (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  user_id uuid NOT NULL, name text NOT NULL, prefix text NOT NULL, secret_hash text NOT NULL UNIQUE, scopes jsonb NOT NULL DEFAULT '[]' CHECK(jsonb_typeof(scopes)='array'), expires_at timestamptz NOT NULL, revoked_at timestamptz
);
CREATE TABLE hr.webhooks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  owner_id uuid NOT NULL, target text NOT NULL CHECK(target ~ '^https://'), events jsonb NOT NULL CHECK(jsonb_typeof(events)='array'), monitor_fields jsonb NOT NULL DEFAULT '[]' CHECK(jsonb_typeof(monitor_fields)='array'), secret_ciphertext bytea NOT NULL, enabled boolean NOT NULL DEFAULT false
);
CREATE TABLE hr.webhook_deliveries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  webhook_id uuid NOT NULL, event_id uuid NOT NULL, payload_ciphertext bytea NOT NULL, status text NOT NULL CHECK(status IN ('queued','delivered','failed','dead')), attempt integer NOT NULL DEFAULT 0 CHECK(attempt>=0), next_attempt_at timestamptz, response_code integer, UNIQUE(org_id,webhook_id,event_id)
);
CREATE TABLE hr.training_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  name text NOT NULL, type text NOT NULL, category text NOT NULL, description text NOT NULL DEFAULT '', owner_content_file_id uuid
);
CREATE TABLE hr.training_records (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  item_id uuid NOT NULL, employee_id uuid NOT NULL, assigned_at timestamptz NOT NULL, due_at timestamptz, expires_at timestamptz, completed_at timestamptz, status text NOT NULL CHECK(status IN ('assigned','completed','expired')), evidence_file_id uuid
);
CREATE TABLE hr.approval_rules (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  name text NOT NULL, trigger_kind text NOT NULL CHECK(trigger_kind IN ('requisition','employee_field')), field_key text, approver_id uuid NOT NULL, enabled boolean NOT NULL DEFAULT false, config jsonb NOT NULL DEFAULT '{}' CHECK(jsonb_typeof(config)='object')
);
CREATE TABLE hr.approval_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  rule_id uuid NOT NULL, requested_by uuid NOT NULL, employee_id uuid, requisition_id uuid, changes_ciphertext bytea NOT NULL, status text NOT NULL DEFAULT 'pending' CHECK(status IN ('pending','approved','rejected','cancelled')), decided_by uuid, decided_at timestamptz, expected_version integer NOT NULL, CHECK(num_nonnulls(employee_id,requisition_id)=1)
);
CREATE TABLE hr.audit_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  actor_id uuid, effective_user_id uuid, preview_session_id uuid, action text NOT NULL, resource text NOT NULL, resource_id uuid, changed_field_keys text[] NOT NULL DEFAULT '{}', detail_ciphertext bytea, correlation_id uuid NOT NULL, occurred_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE hr.idempotency_keys (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  actor_id uuid, namespace text NOT NULL, key text NOT NULL, request_hash text NOT NULL, result_ciphertext bytea, status text NOT NULL CHECK(status IN ('started','completed','failed')), expires_at timestamptz NOT NULL, UNIQUE(org_id,namespace,key)
);
CREATE TABLE hr.outbox_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  kind text NOT NULL, aggregate_id uuid NOT NULL, dedupe_key text NOT NULL, payload_ciphertext bytea NOT NULL, status text NOT NULL DEFAULT 'pending' CHECK(status IN ('pending','processing','sent','failed')), attempts integer NOT NULL DEFAULT 0 CHECK(attempts>=0), next_attempt_at timestamptz NOT NULL DEFAULT now(), UNIQUE(org_id,dedupe_key)
);
CREATE TABLE hr.interview_availability (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  invitation_id uuid NOT NULL, interviewer_id uuid NOT NULL, starts_at timestamptz NOT NULL, ends_at timestamptz NOT NULL, CHECK(ends_at>starts_at)
);
CREATE TABLE hr.report_schedule_recipients (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  schedule_id uuid NOT NULL, user_id uuid NOT NULL, UNIQUE(org_id,schedule_id,user_id)
);
CREATE TABLE hr.inbox_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  provider text NOT NULL, external_event_id text NOT NULL, payload_ciphertext bytea NOT NULL, status text NOT NULL DEFAULT 'pending' CHECK(status IN ('pending','processed','failed')), UNIQUE(org_id,provider,external_event_id)
);
CREATE TABLE hr.jobs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  requested_by uuid NOT NULL, kind text NOT NULL, resource text NOT NULL, resource_id uuid NOT NULL, outbox_event_id uuid, status text NOT NULL DEFAULT 'queued' CHECK(status IN ('queued','running','complete','failed','cancelled')), result_file_id uuid, safe_error text, expires_at timestamptz NOT NULL
);
CREATE TABLE hr.retention_policies (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  resource text NOT NULL UNIQUE, retain_days integer NOT NULL CHECK(retain_days>=0), enabled boolean NOT NULL DEFAULT false
);
CREATE TABLE hr.legal_holds (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES hr.organizations(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  row_version bigint NOT NULL DEFAULT 1 CHECK(row_version>0),
  UNIQUE (org_id,id),
  resource text NOT NULL, resource_id uuid NOT NULL, reason text NOT NULL, placed_by uuid NOT NULL, released_at timestamptz, UNIQUE(org_id,resource,resource_id)
);
ALTER TABLE hr.org_units ADD FOREIGN KEY (org_id,parent_id) REFERENCES hr.org_units(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.employees ADD FOREIGN KEY (org_id,department_id) REFERENCES hr.org_units(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.employees ADD FOREIGN KEY (org_id,division_id) REFERENCES hr.org_units(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.employees ADD FOREIGN KEY (org_id,location_id) REFERENCES hr.org_units(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.employees ADD FOREIGN KEY (org_id,supervisor_id) REFERENCES hr.employees(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.employees ADD FOREIGN KEY (org_id,photo_file_id) REFERENCES hr.files(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.employee_teams ADD FOREIGN KEY (org_id,employee_id) REFERENCES hr.employees(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.employee_teams ADD FOREIGN KEY (org_id,team_id) REFERENCES hr.org_units(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.app_users ADD FOREIGN KEY (org_id,employee_id) REFERENCES hr.employees(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.auth_identities ADD FOREIGN KEY (org_id,user_id) REFERENCES hr.app_users(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.auth_sessions ADD FOREIGN KEY (org_id,user_id) REFERENCES hr.app_users(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.auth_challenges ADD FOREIGN KEY (org_id,user_id) REFERENCES hr.app_users(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.user_access_levels ADD FOREIGN KEY (org_id,user_id) REFERENCES hr.app_users(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.user_access_levels ADD FOREIGN KEY (org_id,access_level_id) REFERENCES hr.access_levels(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.permission_grants ADD FOREIGN KEY (org_id,access_level_id) REFERENCES hr.access_levels(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.preview_sessions ADD FOREIGN KEY (org_id,actor_id) REFERENCES hr.app_users(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.preview_sessions ADD FOREIGN KEY (org_id,target_user_id) REFERENCES hr.app_users(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.employee_fields ADD FOREIGN KEY (org_id,tab_id) REFERENCES hr.profile_tabs(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.employee_field_values ADD FOREIGN KEY (org_id,employee_id) REFERENCES hr.employees(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.employee_field_values ADD FOREIGN KEY (org_id,field_id) REFERENCES hr.employee_fields(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.employee_table_rows ADD FOREIGN KEY (org_id,employee_id) REFERENCES hr.employees(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.employee_notes ADD FOREIGN KEY (org_id,employee_id) REFERENCES hr.employees(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.employee_notes ADD FOREIGN KEY (org_id,author_id) REFERENCES hr.app_users(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.file_categories ADD FOREIGN KEY (org_id,parent_id) REFERENCES hr.file_categories(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.files ADD FOREIGN KEY (org_id,employee_id) REFERENCES hr.employees(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.files ADD FOREIGN KEY (org_id,category_id) REFERENCES hr.file_categories(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.files ADD FOREIGN KEY (org_id,uploaded_by) REFERENCES hr.app_users(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.file_grants ADD FOREIGN KEY (org_id,file_id) REFERENCES hr.files(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.file_grants ADD FOREIGN KEY (org_id,user_id) REFERENCES hr.app_users(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.esign_requests ADD FOREIGN KEY (org_id,document_id) REFERENCES hr.files(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.esign_requests ADD FOREIGN KEY (org_id,signed_file_id) REFERENCES hr.files(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.esign_signers ADD FOREIGN KEY (org_id,request_id) REFERENCES hr.esign_requests(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.esign_signers ADD FOREIGN KEY (org_id,user_id) REFERENCES hr.app_users(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.job_requisitions ADD FOREIGN KEY (org_id,requested_by) REFERENCES hr.app_users(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.job_requisitions ADD FOREIGN KEY (org_id,approver_id) REFERENCES hr.app_users(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.job_requisitions ADD FOREIGN KEY (org_id,hiring_lead_id) REFERENCES hr.app_users(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.job_requisitions ADD FOREIGN KEY (org_id,department_id) REFERENCES hr.org_units(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.job_requisitions ADD FOREIGN KEY (org_id,location_id) REFERENCES hr.org_units(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.job_openings ADD FOREIGN KEY (org_id,requisition_id) REFERENCES hr.job_requisitions(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.job_openings ADD FOREIGN KEY (org_id,department_id) REFERENCES hr.org_units(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.job_openings ADD FOREIGN KEY (org_id,location_id) REFERENCES hr.org_units(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.job_openings ADD FOREIGN KEY (org_id,hiring_lead_id) REFERENCES hr.app_users(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.job_collaborators ADD FOREIGN KEY (org_id,job_id) REFERENCES hr.job_openings(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.job_collaborators ADD FOREIGN KEY (org_id,user_id) REFERENCES hr.app_users(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.board_postings ADD FOREIGN KEY (org_id,job_id) REFERENCES hr.job_openings(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.applications ADD FOREIGN KEY (org_id,job_id) REFERENCES hr.job_openings(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.applications ADD FOREIGN KEY (org_id,status_id) REFERENCES hr.candidate_statuses(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.applications ADD FOREIGN KEY (org_id,resume_file_id) REFERENCES hr.files(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.applications ADD FOREIGN KEY (org_id,hired_employee_id) REFERENCES hr.employees(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.application_events ADD FOREIGN KEY (org_id,application_id) REFERENCES hr.applications(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.application_events ADD FOREIGN KEY (org_id,from_status_id) REFERENCES hr.candidate_statuses(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.application_events ADD FOREIGN KEY (org_id,to_status_id) REFERENCES hr.candidate_statuses(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.application_events ADD FOREIGN KEY (org_id,actor_id) REFERENCES hr.app_users(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.stage_automations ADD FOREIGN KEY (org_id,status_id) REFERENCES hr.candidate_statuses(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.stage_automations ADD FOREIGN KEY (org_id,template_id) REFERENCES hr.message_templates(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.candidate_notes ADD FOREIGN KEY (org_id,application_id) REFERENCES hr.applications(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.candidate_notes ADD FOREIGN KEY (org_id,author_id) REFERENCES hr.app_users(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.calendar_connections ADD FOREIGN KEY (org_id,user_id) REFERENCES hr.app_users(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.interview_invitations ADD FOREIGN KEY (org_id,application_id) REFERENCES hr.applications(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.interview_invitations ADD FOREIGN KEY (org_id,template_id) REFERENCES hr.interview_templates(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.interviews ADD FOREIGN KEY (org_id,application_id) REFERENCES hr.applications(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.interviews ADD FOREIGN KEY (org_id,template_id) REFERENCES hr.interview_templates(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.interviews ADD FOREIGN KEY (org_id,invitation_id) REFERENCES hr.interview_invitations(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.interview_attendees ADD FOREIGN KEY (org_id,interview_id) REFERENCES hr.interviews(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.interview_attendees ADD FOREIGN KEY (org_id,interviewer_id) REFERENCES hr.app_users(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.offer_letters ADD FOREIGN KEY (org_id,application_id) REFERENCES hr.applications(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.offer_letters ADD FOREIGN KEY (org_id,template_id) REFERENCES hr.message_templates(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.offer_letters ADD FOREIGN KEY (org_id,esign_request_id) REFERENCES hr.esign_requests(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.offer_letters ADD FOREIGN KEY (org_id,supersedes_id) REFERENCES hr.offer_letters(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.task_templates ADD FOREIGN KEY (org_id,list_id) REFERENCES hr.task_lists(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.task_templates ADD FOREIGN KEY (org_id,assignee_id) REFERENCES hr.app_users(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.packet_template_fields ADD FOREIGN KEY (org_id,template_id) REFERENCES hr.packet_templates(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.packet_template_fields ADD FOREIGN KEY (org_id,field_id) REFERENCES hr.employee_fields(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.packet_template_documents ADD FOREIGN KEY (org_id,template_id) REFERENCES hr.packet_templates(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.packet_template_documents ADD FOREIGN KEY (org_id,document_id) REFERENCES hr.files(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.packet_template_lists ADD FOREIGN KEY (org_id,template_id) REFERENCES hr.packet_templates(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.packet_template_lists ADD FOREIGN KEY (org_id,list_id) REFERENCES hr.task_lists(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.packets ADD FOREIGN KEY (org_id,employee_id) REFERENCES hr.employees(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.packets ADD FOREIGN KEY (org_id,template_id) REFERENCES hr.packet_templates(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.packet_signatures ADD FOREIGN KEY (org_id,packet_id) REFERENCES hr.packets(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.packet_signatures ADD FOREIGN KEY (org_id,request_id) REFERENCES hr.esign_requests(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.lifecycle_runs ADD FOREIGN KEY (org_id,employee_id) REFERENCES hr.employees(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.lifecycle_runs ADD FOREIGN KEY (org_id,packet_id) REFERENCES hr.packets(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.tasks ADD FOREIGN KEY (org_id,lifecycle_run_id) REFERENCES hr.lifecycle_runs(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.tasks ADD FOREIGN KEY (org_id,packet_id) REFERENCES hr.packets(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.tasks ADD FOREIGN KEY (org_id,list_id) REFERENCES hr.task_lists(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.tasks ADD FOREIGN KEY (org_id,template_id) REFERENCES hr.task_templates(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.tasks ADD FOREIGN KEY (org_id,employee_id) REFERENCES hr.employees(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.tasks ADD FOREIGN KEY (org_id,assignee_id) REFERENCES hr.app_users(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.tasks ADD FOREIGN KEY (org_id,completed_by) REFERENCES hr.app_users(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.capabilities ADD FOREIGN KEY (org_id,employee_id) REFERENCES hr.employees(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.capabilities ADD FOREIGN KEY (org_id,application_id) REFERENCES hr.applications(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.capabilities ADD FOREIGN KEY (org_id,packet_id) REFERENCES hr.packets(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.review_cycles ADD FOREIGN KEY (org_id,source_cycle_id) REFERENCES hr.review_cycles(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.review_cycle_questions ADD FOREIGN KEY (org_id,cycle_id) REFERENCES hr.review_cycles(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.review_cycle_questions ADD FOREIGN KEY (org_id,question_id) REFERENCES hr.questions(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.assessments ADD FOREIGN KEY (org_id,cycle_id) REFERENCES hr.review_cycles(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.assessments ADD FOREIGN KEY (org_id,subject_id) REFERENCES hr.employees(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.assessments ADD FOREIGN KEY (org_id,reviewer_id) REFERENCES hr.app_users(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.goals ADD FOREIGN KEY (org_id,owner_id) REFERENCES hr.employees(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.goals ADD FOREIGN KEY (org_id,department_id) REFERENCES hr.org_units(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.goals ADD FOREIGN KEY (org_id,parent_goal_id) REFERENCES hr.goals(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.goal_members ADD FOREIGN KEY (org_id,goal_id) REFERENCES hr.goals(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.goal_members ADD FOREIGN KEY (org_id,employee_id) REFERENCES hr.employees(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.goal_milestones ADD FOREIGN KEY (org_id,goal_id) REFERENCES hr.goals(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.goal_comments ADD FOREIGN KEY (org_id,goal_id) REFERENCES hr.goals(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.goal_comments ADD FOREIGN KEY (org_id,author_id) REFERENCES hr.app_users(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.one_on_ones ADD FOREIGN KEY (org_id,manager_id) REFERENCES hr.employees(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.one_on_ones ADD FOREIGN KEY (org_id,employee_id) REFERENCES hr.employees(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.recognition_allocations ADD FOREIGN KEY (org_id,employee_id) REFERENCES hr.employees(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.recognition_posts ADD FOREIGN KEY (org_id,author_id) REFERENCES hr.employees(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.recognition_posts ADD FOREIGN KEY (org_id,recipient_id) REFERENCES hr.employees(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.recognition_posts ADD FOREIGN KEY (org_id,allocation_id) REFERENCES hr.recognition_allocations(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.recognition_posts ADD FOREIGN KEY (org_id,core_value_id) REFERENCES hr.core_values(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.survey_questions ADD FOREIGN KEY (org_id,run_id) REFERENCES hr.survey_runs(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.survey_questions ADD FOREIGN KEY (org_id,question_id) REFERENCES hr.questions(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.survey_eligibility ADD FOREIGN KEY (org_id,run_id) REFERENCES hr.survey_runs(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.survey_eligibility ADD FOREIGN KEY (org_id,employee_id) REFERENCES hr.employees(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.survey_spent_tokens ADD FOREIGN KEY (org_id,run_id) REFERENCES hr.survey_runs(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.survey_responses ADD FOREIGN KEY (org_id,run_id) REFERENCES hr.survey_runs(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.survey_aggregates ADD FOREIGN KEY (org_id,run_id) REFERENCES hr.survey_runs(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.announcements ADD FOREIGN KEY (org_id,author_id) REFERENCES hr.app_users(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.availability_events ADD FOREIGN KEY (org_id,employee_id) REFERENCES hr.employees(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.community_posts ADD FOREIGN KEY (org_id,author_id) REFERENCES hr.app_users(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.community_posts ADD FOREIGN KEY (org_id,parent_id) REFERENCES hr.community_posts(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.notifications ADD FOREIGN KEY (org_id,user_id) REFERENCES hr.app_users(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.reports ADD FOREIGN KEY (org_id,owner_id) REFERENCES hr.app_users(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.report_runs ADD FOREIGN KEY (org_id,report_id) REFERENCES hr.reports(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.report_runs ADD FOREIGN KEY (org_id,requested_by) REFERENCES hr.app_users(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.report_runs ADD FOREIGN KEY (org_id,file_id) REFERENCES hr.files(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.report_schedules ADD FOREIGN KEY (org_id,report_id) REFERENCES hr.reports(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.report_schedules ADD FOREIGN KEY (org_id,owner_id) REFERENCES hr.app_users(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.api_keys ADD FOREIGN KEY (org_id,user_id) REFERENCES hr.app_users(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.webhooks ADD FOREIGN KEY (org_id,owner_id) REFERENCES hr.app_users(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.webhook_deliveries ADD FOREIGN KEY (org_id,webhook_id) REFERENCES hr.webhooks(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.training_items ADD FOREIGN KEY (org_id,owner_content_file_id) REFERENCES hr.files(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.training_records ADD FOREIGN KEY (org_id,item_id) REFERENCES hr.training_items(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.training_records ADD FOREIGN KEY (org_id,employee_id) REFERENCES hr.employees(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.training_records ADD FOREIGN KEY (org_id,evidence_file_id) REFERENCES hr.files(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.approval_rules ADD FOREIGN KEY (org_id,approver_id) REFERENCES hr.app_users(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.approval_requests ADD FOREIGN KEY (org_id,rule_id) REFERENCES hr.approval_rules(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.approval_requests ADD FOREIGN KEY (org_id,requested_by) REFERENCES hr.app_users(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.approval_requests ADD FOREIGN KEY (org_id,employee_id) REFERENCES hr.employees(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.approval_requests ADD FOREIGN KEY (org_id,requisition_id) REFERENCES hr.job_requisitions(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.approval_requests ADD FOREIGN KEY (org_id,decided_by) REFERENCES hr.app_users(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.audit_events ADD FOREIGN KEY (org_id,actor_id) REFERENCES hr.app_users(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.audit_events ADD FOREIGN KEY (org_id,effective_user_id) REFERENCES hr.app_users(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.audit_events ADD FOREIGN KEY (org_id,preview_session_id) REFERENCES hr.preview_sessions(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.idempotency_keys ADD FOREIGN KEY (org_id,actor_id) REFERENCES hr.app_users(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.interview_availability ADD FOREIGN KEY (org_id,invitation_id) REFERENCES hr.interview_invitations(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.interview_availability ADD FOREIGN KEY (org_id,interviewer_id) REFERENCES hr.app_users(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.report_schedule_recipients ADD FOREIGN KEY (org_id,schedule_id) REFERENCES hr.report_schedules(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.report_schedule_recipients ADD FOREIGN KEY (org_id,user_id) REFERENCES hr.app_users(org_id,id) ON DELETE CASCADE;
ALTER TABLE hr.jobs ADD FOREIGN KEY (org_id,requested_by) REFERENCES hr.app_users(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.jobs ADD FOREIGN KEY (org_id,outbox_event_id) REFERENCES hr.outbox_events(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.jobs ADD FOREIGN KEY (org_id,result_file_id) REFERENCES hr.files(org_id,id) ON DELETE RESTRICT;
ALTER TABLE hr.legal_holds ADD FOREIGN KEY (org_id,placed_by) REFERENCES hr.app_users(org_id,id) ON DELETE RESTRICT;
CREATE INDEX app_users_query_1 ON hr.app_users (org_id,status,created_at);
CREATE INDEX training_items_query_1 ON hr.training_items (org_id,category,name);
CREATE INDEX survey_questions_query_1 ON hr.survey_questions (org_id,run_id,position);
CREATE INDEX review_cycle_questions_query_1 ON hr.review_cycle_questions (org_id,cycle_id,position);
CREATE INDEX org_units_query_1 ON hr.org_units (org_id,kind,name);
CREATE INDEX employees_query_1 ON hr.employees USING gin (to_tsvector('simple',first_name||' '||last_name));
CREATE INDEX employees_query_2 ON hr.employees (org_id,last_name,first_name,id);
CREATE INDEX employees_query_3 ON hr.employees (org_id,employment_status,hire_at);
CREATE INDEX employees_query_4 ON hr.employees (org_id,termination_at);
CREATE INDEX employees_query_5 ON hr.employees (org_id,job_title);
CREATE INDEX jobs_query_1 ON hr.jobs (org_id,status,expires_at);
CREATE INDEX inbox_events_query_1 ON hr.inbox_events (org_id,status,created_at);
CREATE INDEX interview_availability_query_1 ON hr.interview_availability (org_id,starts_at,ends_at);
CREATE INDEX employee_fields_query_1 ON hr.employee_fields (org_id,tab_id,position);
CREATE INDEX employee_table_rows_query_1 ON hr.employee_table_rows (org_id,employee_id,table_key,effective_at DESC);
CREATE INDEX files_query_1 ON hr.files (org_id,category_id,name);
CREATE INDEX files_query_2 ON hr.files (org_id,employee_id,folder,created_at DESC);
CREATE INDEX files_query_3 ON hr.files (org_id,status,created_at);
CREATE INDEX job_requisitions_query_1 ON hr.job_requisitions (org_id,status,created_at DESC);
CREATE INDEX job_openings_query_1 ON hr.job_openings USING gin (to_tsvector('simple',title||' '||description));
CREATE INDEX job_openings_query_2 ON hr.job_openings (org_id,status,title);
CREATE INDEX job_openings_query_3 ON hr.job_openings (org_id,published_at DESC);
CREATE INDEX applications_query_1 ON hr.applications USING gin (to_tsvector('simple',name||' '||email));
CREATE INDEX applications_query_2 ON hr.applications (org_id,job_id,status_id,applied_at DESC);
CREATE INDEX applications_query_3 ON hr.applications (org_id,source,applied_at);
CREATE INDEX applications_query_4 ON hr.applications (org_id,lower(email));
CREATE INDEX applications_query_5 ON hr.applications (org_id,job_id,rating);
CREATE INDEX applications_query_6 ON hr.applications USING gin (answers);
CREATE INDEX candidate_notes_query_1 ON hr.candidate_notes (org_id,application_id,kind,created_at DESC);
CREATE INDEX interviews_query_1 ON hr.interviews (org_id,status,start_at);
CREATE INDEX packets_query_1 ON hr.packets (org_id,status,due_at);
CREATE INDEX lifecycle_runs_query_1 ON hr.lifecycle_runs (org_id,status,effective_at);
CREATE INDEX tasks_query_1 ON hr.tasks (org_id,assignee_id,status,due_at);
CREATE INDEX review_cycles_query_1 ON hr.review_cycles (org_id,status,opens_at,closes_at);
CREATE INDEX assessments_query_1 ON hr.assessments (org_id,cycle_id,draft,submitted_at);
CREATE INDEX goals_query_1 ON hr.goals (org_id,status,due_at);
CREATE INDEX goal_comments_query_1 ON hr.goal_comments (org_id,goal_id,created_at);
CREATE INDEX one_on_ones_query_1 ON hr.one_on_ones (org_id,employee_id,scheduled_at);
CREATE INDEX recognition_posts_query_1 ON hr.recognition_posts (org_id,created_at DESC);
CREATE INDEX survey_runs_query_1 ON hr.survey_runs (org_id,status,closes_at);
CREATE INDEX announcements_query_1 ON hr.announcements (org_id,starts_at,expires_at);
CREATE INDEX home_widgets_query_1 ON hr.home_widgets (org_id,enabled,position);
CREATE INDEX company_links_query_1 ON hr.company_links (org_id,position);
CREATE INDEX availability_events_query_1 ON hr.availability_events (org_id,starts_at,ends_at);
CREATE INDEX community_posts_query_1 ON hr.community_posts (org_id,created_at DESC);
CREATE INDEX notifications_query_1 ON hr.notifications (org_id,user_id,read_at,created_at DESC);
CREATE INDEX reports_query_1 ON hr.reports (org_id,kind,name);
CREATE INDEX reports_query_2 ON hr.reports (org_id,dataset,name);
CREATE INDEX report_runs_query_1 ON hr.report_runs (org_id,status,expires_at);
CREATE INDEX report_schedules_query_1 ON hr.report_schedules (org_id,enabled,next_run_at);
CREATE INDEX webhook_deliveries_query_1 ON hr.webhook_deliveries (org_id,status,next_attempt_at);
CREATE INDEX training_records_query_1 ON hr.training_records (org_id,status,due_at);
CREATE INDEX approval_requests_query_1 ON hr.approval_requests (org_id,status,created_at);
CREATE INDEX audit_events_query_1 ON hr.audit_events (org_id,occurred_at DESC);
CREATE INDEX audit_events_query_2 ON hr.audit_events (org_id,resource,resource_id,occurred_at DESC);
CREATE INDEX outbox_events_query_1 ON hr.outbox_events (org_id,status,next_attempt_at);
CREATE INDEX auth_sessions_query_1 ON hr.auth_sessions (org_id,expires_at);
CREATE INDEX auth_challenges_query_1 ON hr.auth_challenges (org_id,expires_at);
CREATE INDEX preview_sessions_query_1 ON hr.preview_sessions (org_id,expires_at);
CREATE INDEX interview_invitations_query_1 ON hr.interview_invitations (org_id,expires_at);
CREATE INDEX capabilities_query_1 ON hr.capabilities (org_id,expires_at);
CREATE INDEX api_keys_query_1 ON hr.api_keys (org_id,expires_at);
CREATE INDEX idempotency_keys_query_1 ON hr.idempotency_keys (org_id,expires_at);

-- Add an index on every FK tuple (org indexes included), without relying on
-- implicit PK/UNIQUE coverage. Small deliberate redundancy keeps audit simple.
DO $$ DECLARE r record; cols text; BEGIN
 FOR r IN SELECT c.oid,c.conrelid,c.conkey,c.conname FROM pg_constraint c
 JOIN pg_namespace n ON n.oid=c.connamespace WHERE n.nspname='hr' AND c.contype='f'
 LOOP
  SELECT string_agg(quote_ident(a.attname),',' ORDER BY k.ord) INTO cols
  FROM unnest(r.conkey) WITH ORDINALITY k(attnum,ord)
  JOIN pg_attribute a ON a.attrelid=r.conrelid AND a.attnum=k.attnum;
  EXECUTE format('CREATE INDEX %I ON %s (%s)', 'fk_'||r.oid, r.conrelid::regclass,cols);
 END LOOP;
END $$;
-- All standard fields including structural columns have employee_fields keys.
-- SSN/dateOfBirth/payRate/payType live in employee_field_values; cents+currency
-- for payRate, encrypted payload for SSN. No plaintext SSN column or SQL search.
-- Sensitive packet answers/snapshot values use the ciphertext companions only;
-- redacted JSON carries field keys, never the sensitive values themselves.
-- History JSON keys must resolve to registered employee_fields for that table.
-- No arbitrary JSON mutation route. Money inside history uses cents+currency too.
-- ETag/version in the API is row_version, auto-incremented on every update.
-- Template/question version columns are immutable content revisions, not ETags.
-- Before building, implement centralized checks for field types/enum values,
-- approval-required edits, privilege escalation/last-admin protection, resource
-- shares, review release/anonymity, terminated-record immutability and holds.
CREATE FUNCTION hr.can_access(p_resource text, p_action text, p_employee uuid DEFAULT NULL,
                             p_field text DEFAULT '*') RETURNS boolean
LANGUAGE sql STABLE SET search_path=hr,pg_catalog AS $$
 SELECT EXISTS (
 SELECT 1 FROM hr.app_users u
 JOIN hr.user_access_levels ul ON ul.org_id=u.org_id AND ul.user_id=u.id
 JOIN hr.access_levels l ON l.org_id=ul.org_id AND l.id=ul.access_level_id
 LEFT JOIN hr.permission_grants g ON g.org_id=l.org_id AND g.access_level_id=l.id
 WHERE u.org_id=hr.context_uuid('app.org_id')
 AND u.id=hr.context_uuid('app.effective_user_id') AND u.status='active'
 AND (p_action='read' OR hr.context_uuid('app.actor_id')=u.id)
 AND (l.kind='admin' OR (g.resource=p_resource AND g.action=p_action
 AND g.field_key IN ('*',p_field) AND (
 g.scope='org' OR (g.scope='home' AND p_resource='home')
 OR (g.scope='self' AND p_employee=u.employee_id)
 OR (g.scope='reports' AND EXISTS (SELECT 1 FROM hr.employees e
 WHERE e.org_id=u.org_id AND e.id=p_employee AND e.supervisor_id=u.employee_id))
 )))
 )
$$;
-- Built-in names alone confer no power except Admin. Seed explicit grants in the
-- first implementation migration: Employee self + permitted directory/home fields;
-- Manager additionally direct reports, never salary/SSN by default. Custom starts
-- empty. Multiple levels union allow grants; absence denies, no implicit deny rules.
-- Admin is tenant-wide except raw surveys / unreleased blind assessment identities.
-- Non-employee recruiters get custom hiring grants AND explicit job collaborator rows.
-- A payroll-admin label is Custom; payroll functionality remains excluded.
-- Field write does not imply read/export/manage. Field '*' is an intentional grant.
-- Prevent employee/goal/org-unit hierarchy cycles with a serialized recursive check.
CREATE FUNCTION hr.prevent_cycle() RETURNS trigger LANGUAGE plpgsql SET search_path=hr,pg_catalog AS $$
DECLARE parent uuid; hit boolean; BEGIN
 parent=(to_jsonb(NEW)->>TG_ARGV[0])::uuid;
 IF parent IS NULL THEN RETURN NEW; END IF;
 -- One organization-scoped transaction lock also closes concurrent A->B / B->A.
 PERFORM pg_advisory_xact_lock(hashtextextended(NEW.org_id::text,0));
 EXECUTE format('WITH RECURSIVE ancestors(id,parent,path) AS (
 SELECT id,%1$I,ARRAY[id] FROM hr.%2$I WHERE org_id=$1 AND id=$2
 UNION ALL SELECT e.id,e.%1$I,a.path||e.id FROM hr.%2$I e JOIN ancestors a ON e.id=a.parent
 WHERE e.org_id=$1 AND NOT e.id=ANY(a.path))
 SELECT EXISTS(SELECT 1 FROM ancestors WHERE id=$3)',TG_ARGV[0],TG_TABLE_NAME)
 INTO hit USING NEW.org_id,parent,NEW.id;
 IF hit THEN RAISE EXCEPTION 'hierarchy cycle' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER employee_no_cycle BEFORE INSERT OR UPDATE OF supervisor_id ON hr.employees
 FOR EACH ROW EXECUTE FUNCTION hr.prevent_cycle('supervisor_id');
CREATE TRIGGER goal_no_cycle BEFORE INSERT OR UPDATE OF parent_goal_id ON hr.goals
 FOR EACH ROW EXECUTE FUNCTION hr.prevent_cycle('parent_goal_id');
CREATE TRIGGER org_unit_no_cycle BEFORE INSERT OR UPDATE OF parent_id ON hr.org_units
 FOR EACH ROW EXECUTE FUNCTION hr.prevent_cycle('parent_id');
-- Recognition allocation spend is serialized on its allocation row, including
-- amendments/voids, so concurrent posts cannot overspend the budget.
CREATE FUNCTION hr.check_recognition_budget() RETURNS trigger LANGUAGE plpgsql SET search_path=hr,pg_catalog AS $$
DECLARE b integer; spent bigint; alloc_employee uuid; BEGIN
 IF TG_OP='UPDATE' AND (NEW.allocation_id IS DISTINCT FROM OLD.allocation_id
 OR NEW.author_id IS DISTINCT FROM OLD.author_id) THEN
 RAISE EXCEPTION 'allocation and author are immutable'; END IF;
 IF NEW.allocation_id IS NULL THEN RETURN NEW; END IF;
 SELECT budget,employee_id INTO b,alloc_employee FROM hr.recognition_allocations
 WHERE org_id=NEW.org_id AND id=NEW.allocation_id
 AND NEW.created_at>=starts_at AND NEW.created_at<ends_at FOR UPDATE;
 IF b IS NULL OR alloc_employee<>NEW.author_id THEN RAISE EXCEPTION 'invalid points allocation'; END IF;
 SELECT coalesce(sum(points),0) INTO spent FROM hr.recognition_posts
 WHERE org_id=NEW.org_id AND allocation_id=NEW.allocation_id AND id<>NEW.id AND voided_at IS NULL;
 IF spent+(CASE WHEN NEW.voided_at IS NULL THEN NEW.points ELSE 0 END)>b THEN
 RAISE EXCEPTION 'points budget exceeded' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER recognition_budget BEFORE INSERT OR UPDATE ON hr.recognition_posts
 FOR EACH ROW EXECUTE FUNCTION hr.check_recognition_budget();
-- Derive reservation ranges; clients cannot understate the interview or buffers.
CREATE FUNCTION hr.sync_attendee_range() RETURNS trigger LANGUAGE plpgsql SET search_path=hr,pg_catalog AS $$
DECLARE i hr.interviews%ROWTYPE; BEGIN
 SELECT * INTO STRICT i FROM hr.interviews WHERE org_id=NEW.org_id AND id=NEW.interview_id FOR UPDATE;
 NEW.busy_range=tstzrange(i.start_at-make_interval(mins=>i.buffer_minutes),
                         i.end_at+make_interval(mins=>i.buffer_minutes),'[)');
 NEW.active=(i.status<>'cancelled'); RETURN NEW;
END $$;
CREATE TRIGGER attendee_range BEFORE INSERT OR UPDATE ON hr.interview_attendees
 FOR EACH ROW EXECUTE FUNCTION hr.sync_attendee_range();
CREATE FUNCTION hr.reschedule_attendees() RETURNS trigger LANGUAGE plpgsql SET search_path=hr,pg_catalog AS $$
BEGIN
 UPDATE hr.interview_attendees SET active=(NEW.status<>'cancelled')
 WHERE org_id=NEW.org_id AND interview_id=NEW.id;
 RETURN NEW;
END $$;
CREATE TRIGGER interview_ranges AFTER UPDATE OF start_at,end_at,buffer_minutes,status ON hr.interviews
 FOR EACH ROW EXECUTE FUNCTION hr.reschedule_attendees();
-- One transaction reserves all interviewers; exclusion enforces buffer collisions.
-- Concurrent sign/hire/packet callbacks: lock parent row + unique idempotency key;
-- accepted offer + status transition + one employee + packet snapshot + outbox
-- commit atomically. Packet progress is derived from required fields/tasks/signers.
-- Effective termination is checked on EVERY request, not only by a scheduled job;
-- terminated rows are read-only except the explicit audited rehire/correction path.
-- History, reviews, offers, signed files and sent packet templates become immutable
-- snapshots in the data layer; corrections append revisions, never rewrite evidence.
DO $$ DECLARE r record; predicate text; BEGIN
 FOR r IN SELECT tablename FROM pg_tables WHERE schemaname='hr' LOOP
  EXECUTE format('ALTER TABLE hr.%I ENABLE ROW LEVEL SECURITY',r.tablename);
  EXECUTE format('ALTER TABLE hr.%I FORCE ROW LEVEL SECURITY',r.tablename);
  predicate=CASE WHEN r.tablename='organizations'
   THEN 'id=hr.context_uuid(''app.org_id'')'
   ELSE 'org_id=hr.context_uuid(''app.org_id'')' END;
  EXECUTE format('CREATE POLICY tenant_read ON hr.%I FOR SELECT USING (%s)',r.tablename,predicate);
  EXECUTE format('CREATE POLICY tenant_insert ON hr.%I FOR INSERT WITH CHECK (%s AND hr.context_uuid(''app.actor_id'')=hr.context_uuid(''app.effective_user_id''))',r.tablename,predicate);
  EXECUTE format('CREATE POLICY tenant_update ON hr.%I FOR UPDATE USING (%s AND hr.context_uuid(''app.actor_id'')=hr.context_uuid(''app.effective_user_id'')) WITH CHECK (%s AND hr.context_uuid(''app.actor_id'')=hr.context_uuid(''app.effective_user_id''))',r.tablename,predicate,predicate);
  EXECUTE format('CREATE POLICY tenant_delete ON hr.%I FOR DELETE USING (%s AND hr.context_uuid(''app.actor_id'')=hr.context_uuid(''app.effective_user_id''))',r.tablename,predicate);
  EXECUTE format('CREATE TRIGGER touch BEFORE UPDATE ON hr.%I FOR EACH ROW EXECUTE FUNCTION hr.touch_updated_at()',r.tablename);
 END LOOP;
END $$;
-- Anonymity A4: audited blind-signed one-use run tokens. Eligibility records
-- token issuance only; never completion, nonce, response ID, score or comment.
-- Spend nonce and insert response atomically, but never store their relationship.
-- Strip IP, user agent, auth context, request correlation, precise arrival time,
-- and traces at the dedicated ingestion boundary. Respondents must avoid names
-- in free text; redact identifiers before any aggregate comment release.
-- Required timestamps are coarsened to the fixed run opens_at for BOTH anonymous
-- tables, eliminating per-response arrival timestamps in application tables.
CREATE FUNCTION hr.coarsen_survey_time() RETURNS trigger LANGUAGE plpgsql SET search_path=hr,pg_catalog AS $$
DECLARE opened timestamptz; BEGIN
 SELECT opens_at INTO opened FROM hr.survey_runs WHERE org_id=NEW.org_id AND id=NEW.run_id;
 NEW.created_at=opened; NEW.updated_at=opened; RETURN NEW;
END $$;
CREATE TRIGGER z_anonymous_time BEFORE INSERT OR UPDATE ON hr.survey_responses
 FOR EACH ROW EXECUTE FUNCTION hr.coarsen_survey_time();
CREATE TRIGGER z_anonymous_time BEFORE INSERT OR UPDATE ON hr.survey_spent_tokens
 FOR EACH ROW EXECUTE FUNCTION hr.coarsen_survey_time();
-- No SQL role gets raw response access through the web runtime, including Admin.
-- Privileged survey worker verifies signature/run window/answer types, ingests,
-- and refreshes aggregate counts. Full score/comment release only after close
-- and >=threshold; participation only in delayed/coarse batches. No arbitrary
-- segmentation/drilldown/export of anonymous responses. Remind ALL eligible.
-- Database operator/backups/WAL remain a trust boundary; this is anonymity from
-- portal users/admins, not a claim of anonymity from infrastructure operators.
REVOKE ALL ON ALL TABLES IN SCHEMA hr FROM PUBLIC;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA hr FROM PUBLIC;
GRANT USAGE ON SCHEMA hr TO hr_runtime,hr_survey_ingest;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA hr TO hr_runtime,hr_survey_ingest;
GRANT SELECT,INSERT,UPDATE,DELETE ON ALL TABLES IN SCHEMA hr TO hr_runtime;
REVOKE ALL ON hr.survey_responses,hr.survey_spent_tokens FROM hr_runtime;
GRANT SELECT ON hr.survey_runs,hr.survey_questions,hr.questions TO hr_survey_ingest;
GRANT SELECT,INSERT ON hr.survey_spent_tokens,hr.survey_responses TO hr_survey_ingest;
GRANT SELECT,INSERT,UPDATE ON hr.survey_aggregates TO hr_survey_ingest;
REVOKE UPDATE,DELETE ON hr.audit_events,hr.application_events FROM hr_runtime;
-- Jobs use their own active service principal with least-privilege custom grants;
-- no generic Admin credential. Audit writer uses separate non-preview context,
-- records actor+effective IDs, and must never return its credential/context.
-- Bootstrap organization/user/levels through owner-run migration, not public signup.
-- To apply: a fresh disposable DB first; migration owner must have CREATE ROLE /
-- extension permission. Production app login may SET ROLE hr_runtime only, never
-- SET ROLE migration owner or survey_ingest. Secrets belong in deployment config.
-- Small repeatable schema self-check; no fixtures or external calls.
DO $$ BEGIN
 ASSERT NOT EXISTS (SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
 WHERE n.nspname='hr' AND c.relkind='r' AND (NOT c.relrowsecurity OR NOT c.relforcerowsecurity)), 'all HR tables require forced RLS';
 ASSERT NOT EXISTS (SELECT 1 FROM pg_tables t WHERE t.schemaname='hr' AND
 (SELECT count(*) FROM information_schema.columns c WHERE c.table_schema=t.schemaname
 AND c.table_name=t.tablename AND c.column_name IN ('id','created_at','updated_at','row_version'))<>4), 'missing base columns';
 ASSERT NOT EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_namespace n ON n.oid=c.connamespace
 WHERE n.nspname='hr' AND c.contype='f' AND NOT EXISTS
 (SELECT 1 FROM pg_index i WHERE i.indrelid=c.conrelid AND
 (i.indkey::smallint[])[0:cardinality(c.conkey)-1]=c.conkey)), 'unindexed FK';
 ASSERT NOT has_table_privilege('hr_runtime','hr.survey_responses','SELECT'), 'raw survey leak';
 ASSERT NOT has_table_privilege('hr_runtime','hr.survey_spent_tokens','SELECT'), 'survey nonce leak';
 ASSERT NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname IN ('hr_runtime','hr_survey_ingest')
 AND (rolbypassrls OR rolsuper)), 'runtime role bypasses RLS';
END $$;
COMMIT;
