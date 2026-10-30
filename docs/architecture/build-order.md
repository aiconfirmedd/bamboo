# Build order

Architecture only. Apply the complete schema to a fresh development database at milestone 0; table lists identify each step’s functional scope, not an alternate migration order. Each milestone ends with a usable, independently verifiable flow, including empty/loading/validation/error/permission-denied states. `api-plan.md` defines concrete endpoints; entity names below map to `schema.sql`. Do not flip `features.csv` clone flags until implemented and verified. No UI or scaffold belongs in this architecture stage.

## 0. Prove the trust boundary

**Screens:** S01, minimal S21/S22. **Tables:** `organizations`, `app_users`, `auth_identities`, `auth_sessions`, `auth_challenges`, `access_levels`, `user_access_levels`, `permission_grants`, `preview_sessions`, `profile_tabs`, `employee_fields`, `audit_events`, `idempotency_keys`, `outbox_events`. **Routes:** F10 authentication/session, access-level read/assignment, preview start/end; shared authorization/error contract.

**Verify:** owner provisions an invitation; Employee, Manager, Admin, Custom, and non-employee recruiter log in with explicit differing scopes. Direct unauthorized endpoint calls fail. Same-org FKs and RLS reject tenant mismatch. Field reads and writes deny independently. Preview returns target-visible fields, preserves real actor audit, and rejects every write/side effect. Revoked sessions fail immediately. Production database runtime role cannot bypass RLS. Seed only synthetic fixtures.

## 1. Thin vertical slice — Home → People → hiring → new-hire packet

**Screens:** S02, S05/S06/S08, S12–S15, S18–S20, minimal S10/S21. **Tables:** `employees`, `org_units`, `employee_teams`, `employee_field_values`, `employee_table_rows`, `company_links`, `announcements`, `home_widgets`, `job_requisitions`, `job_openings`, `job_collaborators`, `candidate_statuses`, `applications`, `application_events`, `candidate_notes`, `file_categories`, `files`, `file_grants`, `esign_requests`, `esign_signers`, `packet_templates`, `packet_template_fields`, `packet_template_documents`, `packet_template_lists`, `packets`, `packet_signatures`, `task_lists`, `task_templates`, `lifecycle_runs`, `tasks`, `capabilities`, `notifications`, `approval_rules`, `approval_requests`, `message_templates`, `jobs`. **Routes:** F01 intake/create opening/publish public application; F02 candidate read/stage/hire; F03 add employee/create/send/open/complete packet and tasks; F04 employee read/update; F12 private document read/upload.

Build one route through the agency lifecycle: owner adds branding and one employee; manager approves one job intake; applicant applies with resume; scoped hiring lead advances candidate and hires; one transaction creates employee and one packet; new hire completes one info field and task using a scoped pre-start link; manager completes assigned task; Home reflects pending/completed work and People shows the new employee. Begin with a packet without e-sign, then immediately add one consent/signature receipt and auto-filed immutable document to complete F03 before declaring this slice done. Reuse the private file path for resumes and packet documents.

**Verify:** run this entire loop with synthetic data; refresh pages and confirm persistence. Retry hire/send/sign operations and assert one employee/packet/receipt. Withdrawn applicants cannot be hired without an explicit valid transition. New-hire capability cannot browse People or another packet. Hidden profile fields never appear in Home/search/network responses. Manager and recruiter cannot see unrelated applications. Failed email leaves recoverable pending delivery; failed object upload leaves no visible completed file. Sign the pinned document version; changing template content does not change an issued packet or signed hash.

## 2. Performance and satisfaction core

**Screens:** S24–S26, S29, relevant S23 reports and S02 reminders. **Tables:** `questions`, `review_cycles`, `review_cycle_questions`, `assessments`, `goals`, `goal_members`, `goal_milestones`, `goal_comments`, `survey_runs`, `survey_questions`, `survey_eligibility`, `survey_spent_tokens`, `survey_responses`, `survey_aggregates`, `reports`, `report_runs`. **Routes:** F05 setup/duplicate/launch/autosave/submit/release, F06 goals/milestones/progress/comments, F07 launch/submit/reminders/aggregate results, F11 standard review/goals/eNPS reports.

**Verify:** launch a segmented self/manager/peer cycle; reload an autosaved draft; double-blind responses remain hidden until authorized release; Employee View shows selected answers only. Remove a reviewer and reassign without exposing drafts. Reject milestone eleven and cyclic alignment, including concurrent inserts. Submit one eNPS credential twice and persist one response; administrator sees only cohort-safe aggregates/participation percentage, never respondent identity joins or per-person completion. Issue blind-signed run credentials through an audited library, with issuance records revealing eligibility only. Remind all eligible employees because per-person completion is deliberately unavailable. Raw answers require a separate database role; never carry answers or response timestamps into operational logs. Use an external anonymous survey service if an audited credential implementation is unavailable. Test small-run suppression and rejection of every respondent subgroup filter.

## 3. Complete hiring and onboarding depth

**Screens:** S13 Job Boards, S15 Emails/Interviews, S16/S17, expanded S19/S20. **Tables:** `message_templates`, `candidate_notes`, `stage_automations`, `inbox_events`, `interview_templates`, `interview_invitations`, `interview_availability`, `interviews`, `interview_attendees`, `calendar_connections`, `offer_letters`, `esign_requests`, `esign_signers`, `board_postings`; extend packet/task tables from milestone 1. **Routes:** remaining F01 boards/manual links; F02 messaging/scheduling/scorecard/offer/sign/decline; F03 packet templates/access-before-start/progress/welcome/rehire.

**Verify:** two bookings racing for one interviewer slot yield one winner; test DST boundaries and buffer overlap. Email preview uses allowlisted merge fields and cannot leak compensation/private notes. Offer acceptance is version-bound; additional offers retain prior signed artifacts. Expired/revoked public links fail. Packet copied from template stays stable after template edits. Rehire creates a new employment episode/packet while preserving prior history. External posting failure stays visible and retryable. Calendar synchronization remains blocked behind owner-selected provider credentials; manual scheduling still works.

## 4. Complete People, Home, and offboarding

**Screens:** S03/S04/S07/S09–S11/S18/S20 and full S05/S08. **Tables:** `profile_tabs`, `employee_fields`, `employee_table_rows`, `employee_notes`, `org_units`, `employee_teams`, `training_items`, `training_records`, `availability_events`, `home_widgets`, `legal_holds`, `retention_policies`; extend `employees`, `files`, `file_grants`, `lifecycle_runs`, `tasks`, `approval_rules`, `approval_requests`. **Routes:** F03 history/customization plus remaining F04 self-edit/approval; F09 offboarding/effective-date access revocation; F12 categories/share/files; shared directory/search/snapshot/org-chart/Home/insights.

**Verify:** filters, org chart, snapshot, export, and widgets respect the same row/field scopes. Reject supervisor cycles. Approval-required self edits remain pending until an authorized approval. Private documents cannot be downloaded by guessing object paths. Effective termination revokes sessions/capabilities even if the scheduled job is delayed, using per-request employment checks; an overdue job is repairable. Terminated records are read-only except explicit authorized lifecycle corrections. Former-employee document access, if enabled, exposes only specifically granted documents. Unavailable excluded-module tabs contain no invented payroll/PTO functions.

## 5. Retention depth

**Screens:** S27/S28/S30/S31, S21 Core Values. **Tables:** `one_on_ones`, `core_values`, `recognition_allocations`, `recognition_posts`, `community_posts`, `audit_events`; reuse survey tables for owner-authored wellbeing questions. **Routes:** F08 recognition/core-values/points, F04 one-on-ones adjunct, F07 wellbeing adjunct, shared community endpoints.

**Verify:** only participants see 1:1 notes; reject unsupported private-note inputs; the notes field is explicitly shared with both participants. Concurrent recognition awards cannot overspend allocation; replay cannot award twice. Wellbeing reports obey the same cohort suppression as eNPS and use owner-supplied question content. Community audience restrictions apply to notifications and search. Gift-card redemption stays unavailable until the owner selects/funds an integration; points alone do not imply monetary fulfillment.

## 6. Reporting, integrations, and configuration completion

**Screens:** S21/S22/S23, remaining S03 metric widgets. **Tables:** `reports`, `report_runs`, `report_schedules`, `report_schedule_recipients`, `jobs`, `api_keys`, `webhooks`, `webhook_deliveries`, `inbox_events`, `outbox_events`, `approval_rules`, `approval_requests`, `stage_automations`. **Routes:** remaining F10 configuration/custom access/multiple assignments; F11 report builder/run/export/schedule; shared API credential management, inbound verified provider events, outbound webhooks, workflow rules.

**Verify:** each F01–F12 route has at least one success case and one direct-call denial case. Reports cannot select unauthorized fields or infer hidden data through filters/counts; queued reports recheck access at execution/download. Invalid SQL-like filters are rejected by the allowlist. Webhook retries preserve event IDs, use signatures, prevent SSRF/private-network targets, and stop after bounded attempts. Revoked API keys fail; secrets never reappear in list responses. Scheduled email delivers a permission-checked expiring report link, not a stale sensitive attachment. Permission changes invalidate relevant cached responses and in-flight export downloads.

## 7. Readiness gate and handoff

**Screens:** all in-scope S01–S31; S32 represented by responsive browser coverage only. **Tables/routes:** complete schema and F01–F12 inventory, no new platform.

**Verify:** reconcile every must row in `features.csv`; explicitly accept/defer each should/could. Exercise provider failure/retry, access revocation, restore, purge/legal hold, key rotation, audit redaction, upload malware quarantine, accessibility, mobile layout, and public endpoint abuse limits. Measure directory/report pagination with realistic synthetic agency volume. Review signed-document receipt scope and survey anonymity boundary with the owner before operational use. Verify no original assets or content ship. No native app, regulated HR/payroll rails, AI, licensed benchmarks, or marketplace integration is implied by completion.

Next stage: `/replica-design` for tokens, screen/component specifications, and WCAG checks; then `/replica-build` starting at milestone 0. Entrepreneur-stage recommendations enter only after explicit scope review; they do not silently enlarge this plan.

## Architecture verification evidence — 2026-10-30

`schema.sql` applied unchanged to isolated PGlite PostgreSQL 18.6 with `btree_gist`. **92 tables; 33 assertions passed.** Checks covered base columns, forced RLS on every table, indexed foreign keys, non-superuser runtime roles, singleton tenancy, FK rejection, field grants/default denial/multiple levels, direct-report scope, read-only preview, row-version increment, raw-survey denial, immutable audit privileges, hierarchy cycles, eleven-milestone rejection, buffer-aware booking overlap/cancellation, points-budget rejection/reversal, survey nonce replay, score bounds and coarse timestamps. Schema includes repeatable metadata assertions before commit. The check used synthetic records in an in-memory database; nothing was applied to Neon or production.

A future implementer can apply the baseline using `psql "$DATABASE_MIGRATION_URL" -v ON_ERROR_STOP=1 -f docs/architecture/schema.sql` **against a fresh disposable development database only**; it is a one-time baseline, not an idempotent production upgrade. `CREATE ROLE` and `btree_gist` need migration-owner privileges. Keep runtime login membership restricted to its named role.

Not verified here: native Neon behavior, parallel transactions, provider credentials/webhooks, cryptographic unlinkability, browser/UI states, app query authorization, real e-sign receipt generation, production backups or deletion. PGlite is a PostgreSQL execution check, not evidence that these planned services exist. Milestone acceptance tests above remain required during implementation.

## Recipient transfer gate

Use [Git handoff](../GIT_HANDOFF.md), [connections](../CONNECTIONS.md) and [rebuild runbook](../REBUILD_RUNBOOK.md). Service credentials and callbacks remain planned. The Auth.js adapter/custom auth schema mapping, scanner, signing assurance and anonymous-survey implementation are explicit owner decisions, not preconnected services.
