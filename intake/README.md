# Deploy the online setup intake — no HR app required

This is a working standalone Flask/Gunicorn service. It serves the annotated form,
accepts validated responses, stores them in PostgreSQL, and gives approved operators
private JSON export and review status controls. The existing HR schema, HR endpoints,
R2 uploads, Resend, Inngest and HR application are not used or provisioned.

**Required:** GitHub checkout, Python 3.12 or Docker, an HTTPS host, a dedicated Neon
PostgreSQL database, and an OIDC provider emitting a verified email claim. This
implementation uses a container host such as Render for the intake service; the
future HR app's proposed Vercel deployment remains separate.

## 1. Prepare the database

Create a dedicated database/branch in the recipient's Neon account. Choose its region
and backup/restore settings with the owner. Do not reuse a production HR database.
Use the administrative connection only for this one-time migration:

```sh
psql "$INTAKE_MIGRATION_DATABASE_URL" -v ON_ERROR_STOP=1 -f intake/migration.sql
```

This creates only the `setup_intake` schema, two intake tables, RLS policies and an
`intake_runtime` login without a password. It deliberately fails if already applied;
do not rerun or drop existing objects as a deployment shortcut. The migration is
transactional. An administrator with SQL role-creation privileges is required.

Set a strong runtime password through a secure administrator session. With psql,
`\password intake_runtime` prompts without putting the value in command history.
Do not grant this role membership in owner/admin roles or access to other schemas.
Use this role, not the migration/admin account, in the service's DATABASE_URL.
The service refuses owner, superuser, bypass-RLS and differently named roles.

Use `sslmode=verify-full&sslrootcert=system` in the Neon runtime connection string.
Production startup rejects weaker SSL modes. URL-encode any special characters in
the password. Keep the complete URL in hosting secrets, never this form or GitHub.
[Neon SQL role guidance](https://neon.com/docs/manage/roles) explains why SQL-created
roles differ from console-created administrative roles.

## 2. Register a dedicated OIDC client

Register a confidential web application with your organization identity provider:

- Exact callback: `https://YOUR_INTAKE_HOST/auth/callback`.
- Authorization-code flow, PKCE S256, scopes `openid email`.
- Discovery at `OIDC_ISSUER/.well-known/openid-configuration`.
- Signed ID token with matching issuer/audience/nonce, stable `sub`, email and
  boolean `email_verified: true`. A provider missing this claim is denied; do not
  disable verification to make it work. Confirm provider compatibility first.
- Enable MFA/account policies in the identity provider. Use a separate client from
  any future HR application, with no wildcard callback URLs.

Copy issuer/client ID and securely transfer the client secret to hosting settings.
Only exact verified addresses in ALLOWED_EMAILS or OPERATOR_EMAILS can sign in.
Operator addresses get access to all submissions: keep that list small and approved.
There is no self-registration, domain-wide admission or local password fallback.

## 3. Deploy the container

In Render: **New → Web Service → connect this GitHub repository**. Select Docker,
repository root build context, Dockerfile path `intake/Dockerfile`. Set health-check
path `/healthz`. Choose a service plan/region with the owner; this guide authorizes
no purchase. GitHub Actions runs tests but does not deploy any service.

Set every variable shown in [the blank environment template](.env.example) in the
host's private environment settings. Do not upload that file with actual values.

| Setting | Exact input |
| --- | --- |
| APP_ORIGIN | Canonical HTTPS origin, e.g. https://intake.example.com, no path/query |
| SECRET_KEY | Fresh random secret: generate with `python -c "import secrets; print(secrets.token_hex(32))"` and store privately |
| DATABASE_URL | Dedicated intake_runtime connection with certificate-verified TLS |
| OIDC_ISSUER | Exact issuer from the provider's discovery document |
| OIDC_CLIENT_ID | Dedicated intake application's client identifier |
| OIDC_CLIENT_SECRET | Dedicated client secret, from the secret manager |
| ALLOWED_EMAILS | Comma-separated exact verified submitter addresses |
| OPERATOR_EMAILS | Comma-separated exact verified operator addresses; at least one |
| RETENTION_DAYS | Owner-approved integer 1–365; 30 is a starting proposal |

Use the final HTTPS hostname in APP_ORIGIN and the OIDC callback before inviting
users. Render supplies PORT; the container binds to it. The secure cookie requires
HTTPS; plain HTTP localhost is not a supported login deployment. Do not run Flask's
debug server publicly. Keep request/body/debug tracing disabled; access logs can
expose callback codes or receipt IDs. Limit access to hosting/database dashboards.

For another container platform:

```sh
docker build -f intake/Dockerfile -t bamboo-intake .
# Inject secrets through your platform; this local file must stay outside Git.
docker run --env-file /private/path/intake.env -p 10000:10000 bamboo-intake
```

Put HTTPS termination in front of the container. Restrict direct container exposure,
apply edge rate limits to `/login` and `/auth/callback`, and configure provider MFA.
No proxy-supplied identity or operator flag is trusted by this application.
See [Render Flask deployment](https://render.com/docs/deploy-flask) and
[health checks](https://render.com/docs/health-checks) for host configuration.

## 4. Schedule retention cleanup

Run daily from a private scheduler with the same runtime secrets and checkout/image:

```sh
flask --app 'intake.app:create_app()' purge-expired
```

This physically deletes expired submissions and audit events older than 90 days.
Submissions expire RETENTION_DAYS after receipt, regardless of review status, and
are excluded from the API after expiry. Merely setting status to closed does not
shorten retention. Changing RETENTION_DAYS affects new submissions only.
There is deliberately no public cron endpoint or GitHub Action carrying DB secrets.
Confirm scheduler success/alerts. Manual user deletion is immediate in the active
DB; backup copies and downloaded exports require their own expiry policy. Choose
and test Neon backup retention/restore before collecting personal contact details.

## 5. Acceptance before inviting users

1. `/healthz` returns 200. This checks the process, not storage readiness.
2. Sign in as an approved verified user at `/`. Submit synthetic choices at `/form`.
   Receive a UUID receipt; retrying unchanged answers returns the same receipt.
3. Sign in as another approved user. The first user's receipt/export/delete URLs
   must return 404. Unlisted accounts and unverified email claims must be rejected.
4. Sign in as an operator at `/operator`. Download the JSON, mark reviewed/closed,
   and verify the receipt status. Ordinary users must receive 403 from operator UI.
5. Run the existing configuration preparation workflow against the exported JSON:

```sh
python3 scripts/prepare_setup.py /private/path/bamboo-setup-submission.json --check-only
python3 scripts/prepare_setup.py /private/path/bamboo-setup-submission.json --output work/prepared-setup
```

6. Confirm CSRF failures, the 1 MB body limit, the 30 accepted-submission attempts per
   user/hour limit, audit records, deletion, expiry cleanup and a backup restore.
7. Remove synthetic records, record deployed commit/owners/region/retention, then
   invite approved users. Do not mark HR integrations verified from intake success.

OIDC sessions last one hour. Removing an address from the environment allowlist and
restarting/redeploying revokes its access on the next request. Rotate SECRET_KEY to
invalidate all sessions, and rotate it when changing identity providers. Do not
expose environment settings or database credentials through support screenshots.

## Routes and boundaries

- `/`: login entry; `/login`, `/auth/callback`: OIDC; `POST /logout`: CSRF-protected.
- `/form`: the canonical 43-field form with secure online submission added at runtime.
- `/api/session`: CSRF token and operator flag for the authenticated browser.
- `GET/POST /api/submissions`: own receipts/validated submission; operators see all.
- `GET /api/submissions/<uuid>/export`: private attachment, compatible with prepare_setup.py.
- `POST /api/submissions/<uuid>/delete`: owner/operator deletion with audit event.
- `POST /api/submissions/<uuid>/status`: operator-only received/reviewed/closed.
- `/operator`: latest 100 active receipts with export and status controls.

Every mutation requires the signed session's CSRF token and exact Origin. Runtime
queries use parameterized SQL, transaction-local identity and forced PostgreSQL RLS.
RLS isolates owners/operators; explicit API expiry predicates hide expired records,
and the scheduled purge removes stored payloads. The trusted server sets DB context;
RLS does not protect against theft of the server's database credentials.

The form prohibits credentials and HR records. Validation reuses the offline form
specification and Python validator, including common token-pattern rejection. This
is not a complete DLP scanner. No arbitrary attachments, public buckets, provisioning,
automatic purchases, HR endpoints or email delivery are implemented.

## Local checks

```sh
python3.12 -m venv work/intake-venv
work/intake-venv/bin/pip install --require-hashes -r intake/requirements.txt
work/intake-venv/bin/python -m unittest discover -s tests -p test_online_intake.py
```

Without an isolated PostgreSQL test database, three integration tests are skipped.
For full tests, provision an empty disposable PostgreSQL instance, apply migration.sql,
set the runtime test password securely, then set INTAKE_TEST_DATABASE_URL (runtime)
and INTAKE_TEST_ADMIN_URL (test admin). The admin test URL is used only to simulate
expiry in synthetic records, never deployed. Never use a shared/production database.
GitHub Actions provisions a disposable PostgreSQL service and runs all these tests.
