# Completing the rebuild after handoff

This runbook defines work the recipient will perform. No application or live
integration is built by this repository. The detailed dependency order and tests
already exist in [architecture/build-order.md](architecture/build-order.md);
use that file as the implementation contract rather than a second competing plan.

## Stage A — accept a reproducible reference

- [ ] Pin the Git tag/commit using [GIT_HANDOFF.md](GIT_HANDOFF.md).
- [ ] Pass reference, contrast, connection-contract and33 schema checks.
- [ ] Review39 screens,80 feature rows, all gap dispositions and exclusions.
- [ ] Resolve required [owner decisions](OWNER_DECISIONS.csv); retain explicit deferrals.
- [ ] Assign provider/account owners and staging resources from [CONNECTIONS.md](CONNECTIONS.md).

Exit: another person can clone the exact reference, reproduce checks and explain
what is observed, documented, inferred and untested. This is the achievable full
handoff solution without building.

## Stage B — implement (separate authorization/stage)

1. Lock supported framework/provider versions, initialize the app and establish
   migration/auth-adapter compatibility. Build primitives/current shell with synthetic
   data. Prove the authorization boundary before adding sensitive flows (milestone0).
2. Implement People/Home, then Hiring and packet/task vertical slice in the detailed
   build order. Keep delivery/signing/jobs stubbed while domain logic is incomplete.
3. Implement reviews/goals/retention, reports/files and remaining in-scope flows.
   Preserve double-blind release, privacy, lifecycle and field projection rules.
4. Introduce provider adapters one at a time against staging: database/identity,
   private storage/scanning, durable jobs/mail, hosting/domain. Register callbacks only
   after handlers exist. Add contract and actual end-to-end tests for each adapter.
5. Keep deferred flags off until their own decision/tests pass. Complete owner-written
   branding, questions, documents, content and retention settings. No reference images
   or proprietary content ship in the app.

For every PR: linked feature rows; acceptance tests; empty/loading/validation/denied
and failure states; no secret logging; migration/rollback notes where relevant.
A feature's clone flag changes only after working behavior is verified.

## Stage C — staging integration acceptance

- [ ] Invited OIDC login, membership denial, signout and access revocation work.
- [ ] Database runtime has no migration-owner privilege; RLS/field/list/export rules tested.
- [ ] Private upload/scan/quarantine/download lifecycle and expiry verified.
- [ ] Outbox/job duplicate/retry/dead-letter behavior verified with controlled fixtures.
- [ ] Approved test mail delivered; webhook signatures/replay/bounces verified.
- [ ] Offer/signature and anonymous-survey assurance decisions pass before enablement.
- [ ] Public endpoint abuse controls, logs, audit redaction, accessibility and responsive states tested.
- [ ] Backup restore, rollback, retention/legal hold and secret rotation rehearsed.

Record resource IDs/environment, app commit, test result IDs and date in the release;
never record secret values. Set configured/live_verified in an implementation-owned
status record only with evidence; keep the reference manifest planned.

## Stage D — operational transfer

Owner accepts each must feature and remaining deferrals; takes ownership of GitHub,
provider organizations, DNS, billing, incident alerts and secret manager. Enable real
communications/jobs only for accepted flows. Production launch is a separate action
after implementation and staging acceptance. This package neither deploys nor
certifies the future app merely because its reference/schema checks pass.
