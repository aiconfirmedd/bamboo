# Bamboo — HR portal reference

A self-contained AI Confirmed reference package for an independent agency HR
portal. **HR specifications, evidence and schema checks; the HR application is not built.**
A standalone online setup intake backend is included and ready for recipient deployment.

[Start here: setup takeover, no rebuild](START_HERE.md) · [Gallery](index.html) · [Upload instructions](UPLOAD.md)

## What is included

- 39 stable screens,12 flows,80 prioritized features and29 inferred entities.
- Current-trial and historical public visual evidence, labelled by environment.
- Original OpenCode capture comparison, corrected claims, explicit gap dispositions.
- Design tokens/CSS/component specs; a 92-table proposed schema and 215 authored API contracts.
- Recovered source metrics, portable executable schema checks, source/route/file catalogs.
- Offline gallery, Python integrity/contrast checks and GitHub Actions.

Scope: Home, People, Hiring/ATS, Onboarding, Performance/Retention. Requisition
approval is an independent addition. Payroll/benefits/attendance and proprietary
AI/licensed content/partner rails/native apps remain excluded.

## Read and verify

Start at [START_HERE.md](START_HERE.md). [Comparison](docs/CAPTURE-COMPARISON.md)
separates OpenCode's summaries from actual capture evidence. [GAPS.csv](docs/GAPS.csv)
keeps unobserved/trial-gated behavior visible. [Public requirements](docs/public-sources/REQUIREMENTS.md)
fill documented behavior without inventing private implementation or UI evidence.

```sh
python3 scripts/verify_reference.py
python3 scripts/check_contrast.py
npm ci --ignore-scripts
npm run check:schema
```

Open [index.html](index.html) locally for the visual archive. Build instructions
are in [docs/IMPLEMENTATION.md](docs/IMPLEMENTATION.md) and [the architecture build order](docs/architecture/build-order.md).
All 80 feature clone flags remain no until actual implementation and verification.

## Reuse and provenance

Original authored docs/helpers are MIT. Third-party screenshots/trademarks retain
their owners' rights and are reference only. Not affiliated with BambooHR.
See [NOTICE.md](NOTICE.md) and [evidence rules](docs/EVIDENCE.md). The original
public reference is [aiconfirmedd/bamboo](https://github.com/aiconfirmedd/bamboo);
this repository contains the consolidated reference and setup handoff.

[All-screen state coverage](docs/STATE_COVERAGE.csv) · [Source/link index](docs/LINKS.md) · [Validation](docs/VALIDATION.md) · [Adapt for your agency](docs/ADAPT_FOR_YOUR_AGENCY.md)

Byte-identical images are stored once. [Original-name alias map](docs/inventory/deduplication.csv) preserves capture provenance without duplicate files.

## Implementation-ready transfer

[Git handoff](docs/GIT_HANDOFF.md) pins publisher/recipient steps to a commit. [Connections](docs/CONNECTIONS.md) defines recipient-owned service setup; [connection manifest](config/connections.json) and offline checker are executable configuration contracts. [Rebuild runbook](docs/REBUILD_RUNBOOK.md) gives exit gates through staging and operations. Services remain planned until the app and actual integration tests exist.

[Fill out the setup form](setup/form.html), then upload its exported JSON for configuration preparation. See [the submission workflow](setup/README.md).

## Deploy only the setup intake

Follow [the online intake deployment guide](intake/README.md) for the working
Flask/Gunicorn backend, Neon migration, OIDC configuration, private exports and
retention scheduler. This service reuses the annotated form without building the HR
app. Hosting and credentials are not configured automatically.
