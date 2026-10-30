# Private setup intake backend — proposed, not deployed

Use the existing **Neon PostgreSQL** service behind a server-only Next.js endpoint
and organization OIDC login. Keep GitHub for source and blank templates, never
completed submissions. No second database provider is needed.

Neon documents AES-256 encryption at rest and TLS in transit in its
[security overview](https://neon.com/security). These protections do not replace
application authorization, credential management or a tested recovery plan.

## Minimal storage design

Store validated setup answers directly in a dedicated `setup_intake` schema,
separate from HR records. This is a proposed schema, not an addition to the
reference HR migrations or a claim that storage is configured.

- Submission: UUID, authenticated submitting user ID, schema version, validated
  answers JSON, server receipt timestamp, status, input hash and expiry timestamp.
- Audit events: submission ID, operator ID, action and timestamp. Do not log
  answers, tokens, raw request bodies or generated environment files.
- Only the submitting user and explicitly assigned setup operators may access a
  submission. Enforce this on every read/write and with tested database RLS.
- Use a non-owner runtime database role without BYPASSRLS; separate migration
  credentials. Keep database credentials exclusively on the server.
- Keep API keys, passwords and connection strings in the recipient's secret
  manager. Store references only. Contact details and account IDs remain private.

No object storage is needed for the small JSON form itself. If later accepting
other attachments, use the existing private R2 service with authenticated access,
short-lived download authorization, file limits, quarantine and scanning before
release. Do not enable public bucket access.

## Implementation handoff

1. Owner chooses data region, permitted operators and intake retention period.
   Suggested starting proposal: delete intake answers 30 days after setup closes,
   subject to owner approval. The form's HR retention field is a separate policy.
2. Implement authenticated submission and operator review endpoints. Validate with
   the same field specification in setup/form.html; reject unknown keys, oversized
   payloads and credentials. Use server timestamps and parameterized SQL. Enforce
   CSRF protection for cookie sessions, rate limits and upload-size limits.
3. Allow authenticated JSON upload/import or form submission only after review;
   never ship a database password to the browser. Return a receipt ID without
   echoing answers. Repeated submissions must not trigger duplicate provisioning.
4. Provision least-privilege database roles and RLS policies. Verify that another
   user cannot read, change or delete a submission, including by guessing its ID.
5. Set up automatic expiry, owner-requested deletion, audit retention and backup
   expiry handling. Document any delay before deleted data expires from backups.
6. Test restore, unauthorized access, invalid inputs and deletion. Confirm actual
   backup recovery targets and provider-plan limitations before accepting data.
7. Only then connect the form to that endpoint. Keep setup provisioning a reviewed
   operator step; a submitted form is not authorization to spend or deploy.

## Current usable procedure

The shipped form is offline: it downloads JSON and sends nothing. Upload the JSON
through an agreed private channel, then run the validator/configuration preparation
commands in [setup instructions](../setup/README.md). The checks detect common
credential patterns, not every possible secret. Live storage and upload endpoints
remain implementation work for the recipient.
