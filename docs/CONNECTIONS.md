# Connections: setup contract, not activated services

The canonical list is [config/connections.json](../config/connections.json).
Every connection is planned, unconfigured and unverified. Existing assistant/plugin
connections do not become the rebuilt app's production credentials. The recipient
owns provider accounts and supplies secrets through their environment manager.

## What is useful before a build

Choose account owners, environments, domains, providers and open decisions. Validate
the repository and environment contract offline. Do not register nonexistent callback
handlers, send messages or provision production access merely to tick a connection box.
GitHub can host this reference now; Vercel application deployment waits for app code.

```sh
python3 scripts/check_connections.py
# Later, inspect a recipient-owned local env file; values are never printed:
python3 scripts/check_connections.py --env-file /private/path/to/staging.env
```

The second command verifies presence/shape only. It makes zero network calls and
cannot certify authentication, DNS, permissions or working callbacks. Variable names
are our proposed application contract; implementation must map them to its SDKs.

## Recipient setup order

1. **Repository.** Follow [Git handoff](GIT_HANDOFF.md). Upload the current ZIP before
   asking the next person to clone the existing public repo, which may still have
   older content. Verify exact commit/tag and required files after cloning.
2. **Database.** Create isolated development/staging resources. Use separate runtime
   and migration identities. Neon documents pooled connections for concurrent app
   use; migrations/session requirements may require direct connections. The runtime
   identity must never inherit migration-owner/superuser privileges. Confirm managed
   service support for the baseline roles/extension before applying it. Run original
   schema checks locally first. Apply the one-time SQL baseline only to fresh disposable
   staging with DATABASE_MIGRATION_URL; do not run it as an upgrade on an existing DB.
3. **Identity.** Select the recipient's OIDC provider and provider ID. Register the
   exact staging origin plus /api/auth/callback/{provider}. Auth.js is the planned
   library; the proposed custom auth tables need an adapter/schema-mapping decision.
   A stock adapter is not assumed compatible. Implement invitation/membership checks,
   sessions, signout and revocation before claiming working sign-in.
4. **Private files.** Create private R2 storage and a bucket-scoped server credential.
   R2_ENDPOINT is the account's S3 endpoint. Match CORS origins to actual upload
   clients only if browser uploads are implemented. Select scanning/quarantine
   behavior before releasing any uploaded file; test unauthorized/expired downloads.
5. **Jobs.** Implement outbox and /api/inngest SDK handler, then register staging
   functions. Use separate environment-specific event and signing keys. Verify
   durable retries and deduplication without real HR data.
6. **Mail.** Verify recipient-owned sender DNS/domain and use an approved test recipient.
   Implement /api/integrations/resend/events before registering its webhook. Verify
   signatures against raw request bytes, enforce replay/deduplication, and test bounce
   handling. API accepted is distinct from delivered. Inbound replies remain off until
   the inbound domain and alias mapping are implemented and reviewed.
7. **Hosting/domain.** After a build exists, import the implementation repo into the
   recipient's Vercel team. Assign secrets separately to staging/preview/production.
   Avoid production HR secrets in untrusted previews. Configure HTTPS/canonical origin,
   then update OIDC/webhook/function endpoints and run end-to-end acceptance tests.

## Unselected/deferred connections

Anonymous surveys, signing assurance/provider, malware scanning, calendar OAuth,
rewards fulfillment and inbound mail decisions are recorded in
[OWNER_DECISIONS.csv](OWNER_DECISIONS.csv). Deferred feature flags default off;
a flag is not implementation or evidence of readiness. Never substitute a new
provider silently or invent a cryptographic protocol. Keep external actions stubbed
until the corresponding gate in [the runbook](REBUILD_RUNBOOK.md) passes.

## Primary implementation references

- [Auth.js Next.js](https://authjs.dev/reference/nextjs)
- [Neon pooling](https://neon.com/docs/connect/connection-pooling)
- [Cloudflare R2 S3 API](https://developers.cloudflare.com/r2/api/s3/api/)
- [Resend webhook verification](https://resend.com/docs/webhooks/verify-webhooks-requests)
- [Inngest keys/access](https://www.inngest.com/docs/platform-and-operations/keys-and-access)
- [Vercel environments](https://vercel.com/docs/environment-variables)

Provider APIs/versions must be rechecked and locked when implementation begins.
No costs, quotas or working integration are asserted by this reference package.

## Collect recipient inputs

Use [the setup form](../setup/form.html) and [submission procedure](../setup/README.md). Its exported JSON can be uploaded to the operator and converted into a setup plan plus environment template. Credentials remain in the recipient secret manager; unresolved decisions stay explicit.
