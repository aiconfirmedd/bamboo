# Validation record — October 30, 2026

Executed from the repository after recovering the original checks:

| Check | Result | Meaning |
|---|---|---|
| npm ci --ignore-scripts | Installed locked PGlite 0.5.13 | No external database/account needed |
| npm run check:schema |92 tables applied;33 checks passed; engine 18.6 | In-memory constraint/RLS checks, not a production audit |
| python3 scripts/check_contrast.py |62 pairs per palette;0 failures | Default and merged optional likeness palettes |
| python3 scripts/verify_reference.py | Run after final catalogs | Local links/anchors, assets, hashes,80 features,39 IDs,215 contracts |
| git diff --check | Passed | Whitespace check on tracked changes |

Final extracted-ZIP and file counts are also recorded in the delivery summary.
No running application, browser automation suite, deployment, backend integration,
email delivery or real signature validation is claimed.

## Connection-handoff checks

The seven-connection manifest passes the offline contract checker. Checking .env.example as configuration correctly exits1 with missing/placeholder variable names; no values are printed and zero network calls are made. These results establish a usable configuration contract, not live provider connectivity.

## Setup intake form

Standalone HTML form and its43-field schema pass template validation and JavaScript syntax checks. Four input/configuration tests pass: normalized config with secret placeholders/deferred flags off; invalid/missing keys; token/credential URL rejection; choice/time-zone/budget validation. Preparation is offline and refuses existing output directories. Actual account provisioning remains outside this test.

## Standalone online intake

The separate [intake backend](../intake/README.md) has HTTP/authentication tests and
real PostgreSQL integration coverage for RLS isolation, idempotent submission,
operator export/review, deletion, expiry cleanup and rate limiting. Its two tables
are separate from the 92 proposed HR tables. CI runs an isolated PostgreSQL service.
No live identity-provider or hosted Neon connection is claimed verified.
