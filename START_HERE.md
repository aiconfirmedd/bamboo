# Start here

**This is a complete reference package, not a running HR application.**
Scope: Home, People, Hiring/ATS, Onboarding, Performance/Retention for an internal
agency portal. Payroll, benefits, attendance, proprietary AI, licensed content,
partner rails and native apps remain outside the implementation slice.

## Take over setup now — stop before the app build

1. Clone `https://github.com/aiconfirmedd/bamboo.git`, then record `git rev-parse HEAD`.
   Install Python 3 and Node 20+ for the local checks. No provider credentials needed.
2. Open `setup/form.html` from the cloned folder in Chrome. GitHub's file viewer
   displays source; download/clone first. Each of the 43 fields has entry guidance.
   Complete required fields; leave optional unknowns blank and defer provider decisions.
3. Click **Submit & download setup JSON**. Privately send the downloaded JSON and
   reference commit to the setup operator. Never commit completed responses or secrets.
4. Operator follows [the intake workflow](setup/README.md):

```sh
python3 scripts/prepare_setup.py /private/path/bamboo-setup-submission.json --check-only
python3 scripts/prepare_setup.py /private/path/bamboo-setup-submission.json --output work/prepared-setup
```

5. Review the generated `SETUP_NEXT_STEPS.md`, `setup-plan.json` and
   `.env.setup.example`. Resolve owners, staging resources, identity, domain,
   budget, retention and recovery decisions using [connections](docs/CONNECTIONS.md)
   and [owner decisions](docs/OWNER_DECISIONS.csv). Transfer credentials through the
   recipient's secret manager; examples/placeholders are not working credentials.
6. If online intake is wanted, hand the implementer [the private backend design](docs/SETUP_STORAGE.md).
   It specifies Neon storage, access boundaries, retention and acceptance checks.
   This is a proposed backend; the current form remains offline.
7. Run `npm ci --ignore-scripts`, `npm run check` and `npm run check:schema`.
   Record results and unresolved decisions against the reference commit.

**Setup handoff complete when:** the response validates, generated inputs have been
reviewed, account/resource owners and secret-transfer arrangements are recorded,
and every unresolved action has an owner or an explicit defer decision. No HR
application, endpoint, database migration or deployment is required at this stage.
Actual live integration verification requires later implementation and authorization.
Do not start the rebuild runbook's application stages merely to complete this handoff.

Read in this order:

First use [Git handoff](docs/GIT_HANDOFF.md), [connections](docs/CONNECTIONS.md) and [rebuild runbook](docs/REBUILD_RUNBOOK.md) to transfer this reference and define the next implementation stage.

1. Read the recipient instructions below.
2. [Capture comparison](docs/CAPTURE-COMPARISON.md): what OpenCode actually captured.
3. [Gap register](docs/GAPS.csv): observed/documented/trial-gated/untested boundaries.
4. [Recon map](replica/recon.md), [80 features](replica/features.csv), [evidence gallery](index.html).
5. [Implementation guide](docs/IMPLEMENTATION.md), [stack](docs/architecture/STACK.md), [schema](docs/architecture/schema.sql), [API plan](docs/architecture/api-plan.md), [build order](docs/architecture/build-order.md).
6. [Components](replica/design/components.md), [tokens](replica/design/tokens.json), [CSS](replica/design/tokens.css), [public-source supplement](docs/public-sources/REQUIREMENTS.md).
7. [Upload and verification](UPLOAD.md), [attribution](NOTICE.md).

All feature clone flags remain no. The 92-table schema and 215 API routes are
independent implementation proposals, not extracted BambooHR internals. Keep the
specification boundary intact until the owner explicitly starts the app build.

## Recipient instructions

You are receiving an independent clean-room HR-portal reference package. Build for
the recipient's own agency and content only when the recipient authorizes implementation.
Do not claim an existing application, live integrations or implemented endpoints.

## Product and scope

Core loop: requisition/intake → approved job → candidate pipeline → owner-authored
offer → hire → employee record → preboarding packet/tasks → reviews/goals/retention.
The proposed requisition approval is a deliberate independent addition, not an
observed BambooHR feature. Scope is five web modules: Home, People, Hiring,
Onboarding, Performance/Retention. Exclude payroll, benefits, attendance, proprietary
AI, licensed benchmarks/content, native apps and partner-dependent rails.

## Authoritative files

- [Recon](replica/recon.md):39 stable screen IDs,12 flows,29 inferred entities.
- [Features](replica/features.csv):80 rows;43 must/18 should/11 could/8 skip.
- [Comparison](docs/CAPTURE-COMPARISON.md), [gaps](docs/GAPS.csv), [evidence](docs/EVIDENCE.md).
- [Public supplement](docs/public-sources/REQUIREMENTS.md) for Snapshot/reviews/offers/survey details.
- [Architecture](docs/architecture/STACK.md), [schema](docs/architecture/schema.sql), [API contracts](docs/architecture/api-plan.md), [build order](docs/architecture/build-order.md).
- [Design tokens](replica/design/tokens.json), [CSS](replica/design/tokens.css), [component requirements](replica/design/components.md), [implementation](docs/IMPLEMENTATION.md).

## How to interpret evidence

Audits1–7 correct earlier filenames and overclaims. Use the current left-sidebar
trial shell for current-theme layout; older horizontal demo and native mobile
shots are separate themes. Help-center icon files are not screens. Filled lists
are not empty states.404 is not403. Buttons/URLs do not prove completed flows.
Read-only template previews withhold actual employee fields/tasks. Survey trial
disablement is a plan gate, not a permission test. Source documentation describes
behavior; it does not prove exact current pixels or backend internals.

## Required independent implementation behavior

- Enforce row/field permissions server-side; share projection across search,
  snapshots, lists, detail, filters, sort and exports. Preview must not confer write access.
- Distinguish draft, preview, save, send and completion. Make external effects
  idempotent; use private object storage, background jobs and owner-controlled providers.
- Preserve blind-review release rules on the server. Copying a cycle creates a
  draft and cannot trigger invitations.
- Separate anonymous survey eligibility and response storage; no user identifiers,
  reusable linkage or identifying telemetry in the response path. Apply aggregation thresholds.
- Implement empty/loading/validation/forbidden/not-found/error/retry states as
  requirements even when the reference lacks a screenshot; label your choices as independent design.
- Use original company identity, copy, sample data, questions, offer text and files.
  Never ship reference screenshots, BambooHR branding or proprietary resources.

## Build sequence and completion gate

Start primitives and current shell, then Home/People/Hiring/packet vertical slice;
then reviews, goals,1:1s/eNPS and reporting. Follow the architecture build order.
Use local synthetic data and stubbed external effects for acceptance tests. Run
reference checks and schema checks before implementation; expand app tests only
when working behavior exists. Set a feature clone=yes only after implementing and
verifying it, never because a spec or screenshot exists.

## Ready-to-use verification

```sh
python3 scripts/verify_reference.py
python3 scripts/check_contrast.py
npm ci --ignore-scripts
npm run check:schema
```

The checker applies schema to in-memory PostgreSQL-compatible PGlite and runs
constraint/RLS checks. It is not a production deployment/security certification.
[UPLOAD.md](UPLOAD.md) explains how to create the GitHub repository.
