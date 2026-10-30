# Architecture stack

Status: architecture only; clean-room implementation plan. Source of feature/flow truth: `replica/recon.md`, `replica/features.csv`, and `docs/workflow.md`. User-requested `docs/architecture/` paths override the skill's default output paths. No original source, private endpoints, shipped screenshots, proprietary content, or licensed datasets.

## Managed choices

| Layer | Choice | Rationale |
| --- | --- | --- |
| Web | Next.js App Router + TypeScript | One application for responsive internal screens, public application/packet links, and server endpoints. |
| Styling | Tailwind with tokens supplied by `/replica-design` | Rebrand through owner logo, colors, typography, and content without rewriting components. |
| Database | Managed Neon Postgres | One relational source of truth with transactions, constraints, backups, and connection pooling. |
| Data access | Parameterized SQL through the Postgres driver; versioned SQL migrations | Preserve explicit SQL/RLS guarantees without an additional ORM model. |
| Authentication | Auth.js OIDC with database sessions; owner-managed identity provider | Delegate MFA, SAML federation, passkeys, and account recovery to the managed IdP. |
| Authorization | Server data-layer authorization on every query, plus database tenant RLS | Resolve Employee/Manager/Admin/Custom grants and field masks centrally; RLS limits accidental cross-organization access. |
| Files | Private Cloudflare R2 objects with short-lived signed URLs | Keep document bytes out of Postgres and require permission checks before upload/download. |
| Email | Resend with owner-verified domain | Managed delivery, templates, webhook status, and suppression handling. |
| Background work | Inngest | Durable reminders, scheduled revocation, provider retries, and document workflows without a worker fleet. |
| Hosting | Vercel | Managed Next.js deployment, environment secrets, HTTPS, and preview environments. |
| Search | Postgres full-text search and indexed normalized filters | Directory, applicants, and permitted report fields fit one database; permission filtering precedes pagination/counts. |
| Observability | Vercel runtime logs + provider delivery/job dashboards + database audit events | Separate operational failure diagnostics from restricted business audit history. |

Use supported versions when implementation begins; lock dependencies then. Auth integration follows [Auth.js Next.js reference](https://authjs.dev/reference/nextjs); retry policy follows [Inngest retry documentation](https://www.inngest.com/docs/durable-execution/guides-and-advanced/error-handling/retries). Provider selection does not assert current plan prices or quotas.

## Assumptions and product decisions

- **A1 — single tenant:** exactly one organization per deployment. Keep `org_id` on owned records and enforce same-organization FKs; no tenant signup, switcher, subscription, or tier caps.
- **A2 — owner content:** empty installation; the owner supplies branding, employees, questions, templates, policy documents, core values, and lawful retention settings. No copied BambooHR templates or courses.
- **A3 — sign-in:** invitation-only internal accounts. Non-employee recruiters receive scoped accounts. Candidates and pre-start hires receive expiring, purpose-bound capabilities rather than internal sessions. S01's password/SAML/passkey parity is provided upstream; no local password store.
- **A4 — intake:** requisition approval is an explicit clone improvement inferred from the recon gap; it is not claimed original behavior. A small explicit approval state machine suffices before a general workflow builder.
- **A5 — e-sign:** first version records typed intent, consent text/version, document hash/version, signer identity verification, and immutable receipt; higher-assurance or regulated signatures require an independently selected provider before use. No I-9/E-Verify automation.
- **A6 — excluded modules:** Time Off/Benefits/Pay Info tabs expose permitted record fields or an unavailable state, not payroll, benefits administration, or time tracking. Who's Out uses owner-maintained absence visibility records, not an accrual engine.
- **A7 — integrations:** own careers page and manual external posting URLs first. Calendar synchronization, commercial board posting, gift-card fulfillment, background checks, and research-validated wellbeing question libraries need the owner's integrations/content; no invented vendor compatibility.
- **A8 — anonymity:** surveys promise anonymity within an explicit operational boundary, not protection against a database administrator with infrastructure control. Use audited blind-signed run credentials: store employee eligibility/issuance separately from unlinked answers, never per-employee completion. Remind all eligible employees. Restrict raw responses to a separate database role; prohibit identity/timestamp correlation in exports/logs and suppress cohorts below five. This cryptographic design is an assumption requiring an audited library; use an external anonymous survey service if unavailable, never invent a protocol.

## Access boundary

Internal requests resolve the real actor from a database session, then load organization membership, active employment/access dates, access-level union, scoped grants, and field grants. Default deny. Manager scope is direct reports only, never all employees. Admin is an application role, never database superuser. A Custom level can add only explicit actions, datasets, row scopes, home widgets, and fields. Reject unauthorized input keys rather than silently persisting hidden fields. Project authorized response fields before serializing; apply the same policy to search, exports, job payloads, notifications, documents, and metrics.

Preview-as-user is an audited, expiring, **read-only** effective-subject context. Only authorized administrators can start it. Resolve target permissions exactly as for that target, retain the real actor for audit, and reject mutations, exports, capability issuance, and external side effects while previewing. Never issue a target session or let a client choose arbitrary SQL identity settings. Jobs carry original authority/purpose and recheck permission at execution; external capabilities can touch only their bound resource/action.

## What not to use

| Exclusion | Reason |
| --- | --- |
| Microservices, Kubernetes, separate backend, event bus | One team and one portal need transactions and simpler operations. |
| Second database, Redis, Elasticsearch, vector database | No demonstrated need beyond indexed Postgres and durable jobs. |
| Prisma/Drizzle plus raw-SQL duplicate schemas | One explicit schema avoids two sources of truth. |
| Supabase alongside Neon/Auth.js/R2 | Duplicates selected database, auth, and storage responsibilities. |
| Native apps, offline editing, realtime collaboration | Responsive web and refresh/polling satisfy first release; privacy and merge complexity add no core-loop value. |
| Stripe, SaaS tiers, opening caps | Single-tenant owner portal has no billing or commercial packaging. |
| Custom password/MFA/SAML infrastructure | Managed owner IdP already handles identity security and recovery. |
| Proprietary AI, licensed benchmarks/compliance libraries, original private APIs | Outside clean-room scope and owner-provided content. |
| General workflow language or unbounded SQL report builder | Explicit transitions and allowlisted report datasets cover the flows safely. |

## Parts that bite

| Concern | Decision / verification boundary |
| --- | --- |
| Time zones / DST | Store instants as `timestamptz`; retain IANA timezone for schedules. Date-only hire/termination inputs map to explicit organization-local midnight, converted to UTC. Birth dates are UTC-midnight calendar-date carriers and never timezone-shifted. Reject ambiguous/nonexistent scheduling times unless a specific offset is selected; test both DST transitions. |
| Idempotency | Unique operation keys for hiring handoff, packet send, signing finalization, points awards, email dispatch, and provider events. Transactional outbox after commit; jobs retry by durable key and record attempts. A retry never creates a second employee or receipt. |
| Race conditions | Lock/check transition versions for candidate stages, hire, offer, packet, and permission edits. Database constraints arbitrate booking overlaps, one spent anonymous survey credential, milestone cap, points allocation, and duplicate hire. |
| Rate limits | Public application/token endpoints use bounded per-IP and per-capability limits; background providers use explicit concurrency, retry/backoff, and dead-letter/manual recovery. Never retry validation failures indefinitely. |
| File limits | Assumed first-release maximum: 20 MiB per file; allowlisted PDF/JPEG/PNG/DOCX and resume formats with MIME/content validation. Quarantine pending malware inspection; no public object access or active inline HTML. Validate actual bytes, not browser metadata. |
| Search | Query only permitted rows and fields; do not index SSNs, compensation, private notes, or anonymous answers into a global search document. Stable cursor pagination; scoped counts and export limits. |
| Realtime | Refresh after writes and bounded polling for task/status updates; no websocket service in the first release. |
| Offline | Read/write requires network; show unsaved state and retry with an idempotency key. Do not cache sensitive HR payloads in service workers or local storage. |
| Email deliverability | Verify SPF/DKIM/DMARC, use owner sender domain, track bounces/complaints, suppress undeliverable recipients, and expose resend/recovery. Provider accepted is not delivered. |
| Tenancy | Singleton organization, same-org FKs, transaction-local trusted context, runtime non-owner database role, and RLS. Never expose Neon credentials or privileged data roles to the client. |
| Deletion / retention | Archive employment without destructive cascades; owner retention policy governs candidate/document/HR deletion. Legal holds suspend purge. Purge object versions, capability secrets, exports, queued jobs, and provider copies where supported; document backup expiration and immutable audit minimization. |
| Sensitive fields | Encrypt sensitive values with managed deployment keys and separate field-level access; no plaintext SSN/pay data in logs, traces, templates, or broad employee JSON. Key rotation and backups must be exercised before production. |
| Anonymous results | Minimum report cohort assumed five completed responses; suppress smaller runs, prohibit respondent segmentation/filter cohorts and row exports, and do not expose completion identities to admins. Free text can self-identify; explain this before submission. |

## Recon entity coverage

The recon text lists **29 named model entities**; the earlier closing-summary count of27 was corrected during handoff preparation. All map to SQL; support tables normalize memberships, signers, task snapshots, survey credentials and delivery state. Total: **92 tables**, each with UUID PK, timestamps and an organization owner (the singleton organization owns itself). `schema.sql` is the canonical definition.

| Recon entity | SQL tables |
| --- | --- |
| Company (relationship root) / Employee / EmployeeField / TableRow | `organizations`, `employees`, `employee_fields`, `employee_field_values`, `employee_table_rows`, `profile_tabs`, `org_units`, `employee_teams` |
| User / AccessLevel | `app_users`, `auth_identities`, `auth_sessions`, `auth_challenges`, `access_levels`, `user_access_levels`, `permission_grants`, `preview_sessions` |
| File / ESignRequest | `files`, `file_categories`, `file_grants`, `esign_requests`, `esign_signers` |
| JobOpening / Application / CandidateStatus / CandidateNote | `job_openings`, `job_requisitions`, `job_collaborators`, `board_postings`, `applications`, `candidate_statuses`, `candidate_notes`, `application_events` |
| Interview / OfferLetter | `interviews`, `interview_templates`, `interview_attendees`, `interview_invitations`, `interview_availability`, `calendar_connections`, `offer_letters`, `message_templates` |
| PacketTemplate / Packet / TaskList / Task | `packet_templates`, `packet_template_fields`, `packet_template_documents`, `packet_template_lists`, `packets`, `packet_signatures`, `task_lists`, `task_templates`, `tasks`, `lifecycle_runs`, `capabilities` |
| ReviewCycle / Assessment / Goal / OneOnOne | `review_cycles`, `review_cycle_questions`, `questions`, `assessments`, `goals`, `goal_members`, `goal_milestones`, `goal_comments`, `one_on_ones` |
| RecognitionPost | `recognition_posts`, `recognition_allocations`, `core_values` |
| SurveyRun / SurveyResponse | `survey_runs`, `survey_questions`, `survey_eligibility`, `survey_spent_tokens`, `survey_responses`, `survey_aggregates` |
| Announcement / CompanyLink | `announcements`, `company_links`, `home_widgets`, `availability_events`, `community_posts`, `notifications` |
| Report / Webhook / TrainingItem | `reports`, `report_runs`, `report_schedules`, `report_schedule_recipients`, `webhooks`, `webhook_deliveries`, `training_items`, `training_records` |
| Supporting authorization/operations | `employee_notes`, `api_keys`, `stage_automations`, `approval_rules`, `approval_requests`, `audit_events`, `idempotency_keys`, `outbox_events`, `inbox_events`, `jobs`, `retention_policies`, `legal_holds` |

Every FK has an explicit delete action and an index; tenant-owned relationships use `(org_id,id)` composite keys. RLS enforces the tenant and preview-write fence; **field-level, relationship, lifecycle and disclosure authorization remains mandatory in the server query layer**, including JSON keys and aggregates. The API contract defines those checks rather than pretending row policies hide columns.
