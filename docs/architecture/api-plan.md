# API plan

Architecture contract; no implemented endpoints. Inventory: **215 unique method/path routes** — 209 assigned to F01–F12, plus 6 infrastructure routes. Deferred provider routes remain plans, not working integrations. Paths below use `/api/v1` unless explicitly absolute. Each table is one recon flow; shared routes are assigned to the flow that owns their data. `{id}` denotes UUID. All content, templates, questions, core values, images and files come from the owner. No reference screenshots, proprietary questions, courses or original application APIs ship.

## Assumptions and common contract

- **A1:** One configured company; no public signup, organization creation or billing. Next.js TypeScript handlers use Auth.js OIDC/database sessions, Neon Postgres/raw SQL, private R2, Resend and Inngest on Vercel. MFA/passkeys/SAML, if needed, are enforced by the owner's identity provider; no local password system.
- **A2:** Employee, Manager, Admin and Custom access levels combine explicit allow grants. Manager means direct reports only in this baseline, not blanket employee access. Non-employee recruiters have explicit opening grants. `Admin` is the immutable access-level kind, granting tenant-wide application operations through `can_access`; it still cannot read raw surveys or bypass review release/preview restrictions. Only an authorized administrator may assign this kind. Other level names confer no power. A Payroll Admin label may be Custom HR-data grants; payroll remains excluded.
- **A3:** Every database query passes server data-layer authorization, tenant predicate and projected field allowlist. Database RLS is tenant defense; browser never connects to Postgres. A granted row does not grant all its fields. For Employee/My Info, grants distinguish self/direct-reports/org/home and read/write/export/manage; field metadata/rules mark approval-required writes. Restricted fields are omitted, not returned null. Requesting restricted fields, filters, sort keys, aggregates, exports or search snippets returns 403; mutations reject the whole request. Secret fields use encrypted storage and explicit named field-read grants before decryption.
- **A4:** Preview is an audited, short-lived server session overlay: real Admin actor retained, effective target user used for every read including reports, files and search. Preview permits GET reads only; exports, signed downloads, tokens, jobs and every mutation are blocked. The exit-preview endpoint alone may mutate the overlay. No impersonated authentication credentials are issued.
- **A5:** Public careers, self-scheduling and workflow intake approval are deliberate design additions/inferences. Calendars and external boards are deferred owner-key integrations; initial scheduling uses portal-managed availability and manual board URLs. No plan opening caps.
- **A6:** Time Off/Benefits/Pay Info tabs never imply those excluded modules. Who's Out consumes owner-maintained availability events only; historical compensation fields remain HR record data. Former employees receive no login by default; a later explicit document grant must not reactivate full access.

Auth shorthand: **Session** = active database session + active company membership; **Self** = Session and own employee; **Scoped** = Session and named resource/action grant; **Admin** = Session and management grant; **Token** = purpose-bound, expiring, hashed bearer invitation scoped to one resource, verified on every request; **Public** = no session, published resources only; **Service** = signed trusted integration request. An authenticated route always evaluates its resource/action/field grants, including Admin routes.

Collection GETs accept bounded `cursor,limit` (default 25, max 100), allowlisted `sort,filter,q` and return `{items,nextCursor}`. Detail GETs return `{data,version}`. Mutations return `{data,version}` or 204; creates return 201. Async work returns 202 `{jobId,statusUrl}`. UTC ISO timestamps and IANA display zones; date-only employment dates use the company zone's effective boundary. Money uses `{amountCents,currency}`. Rich text sanitized server-side. PATCH requires `If-Match` matching SQL `row_version` (returned as `version`); atomically update with `WHERE row_version = expected`, while the SQL trigger increments it. Template/question `version` is a separate immutable content revision; stale updates return 409. Idempotency-Key required for apply, hire, packet send, sign, booking, offer send, points transfer and job creation. Unknown fields rejected. Audit stores real actor/effective actor/action/changed field names, not secrets or survey answers.

Errors: `{error:{code,message,fieldErrors?,requestId}}`; 400 invalid shape, 401 expired session/token, 403 permission, 404 absent/inaccessible record, 409 state/version/race, 413 file size, 422 business constraint, 429 rate limit, 503 provider outage. Public tokens use generic errors to prevent enumeration. Cookie mutations require CSRF/origin checks. No GET has business side effects. POST token exchange consumes URL secrets before further navigation; tokens never enter analytics/referrers/logs. Public and survey responses use no-store. Lists and details share the same permission projections.

## Authorization-to-schema mapping

Capability names in route tables map to explicit `permission_grants.resource` strings (for example `employee.read` or `hiring.hire`), not free-form SQL or role labels. Use `action=read` for data reads, `export` for exports, `manage` for configuration/permission changes, and `write` for business mutations. Examples: `can_access('employee.read','read',employeeId,fieldKey)`; `can_access('hiring.hire','write')`. Route guards fix this mapping in code; callers cannot select it. A POST preview/render operation remains a read operation, but is disabled during user preview. `home` scope is evaluated against resource `home` with widget key as `field_key`; `home.read` routes call that canonical helper. No implicit wildcard resource matching. Module-level permission never bypasses per-field checks.

For each read/write query, resolve membership, active access dates, effective preview subject, capability/action, row scope, each field key, then additional resource relationships. Files require owner/shared/grant/audience checks; hiring requires opening lead/collaborator scope; tasks require assignee or lifecycle management; private goals require owner/shared member; 1:1s require participant; assessment drafts require assigned reviewer and released Employee View projects selected answers without peer identities. Exports require both source read and export grants. Approval commits recheck current field/approver grants and expected version. Revoke/termination gates apply to API keys and capabilities too. Sensitive packet values/snapshots use ciphertext companion columns, never plaintext packet JSON.

Preview validation loads `preview_sessions` by opaque token, real actor, target, expiry and ended status; it never accepts a client-supplied effective ID. SQL actor/effective context is set only after this validation. Audit in preview uses a separate real-actor transaction. Internal grants are union-allow/default-deny; Custom levels start empty. The `can_access` helper is a grant predicate, not a substitute for these per-query resource rules.

## F01 — Open a job and collect applicants

| Method path | Does | Auth | Request | Response |
|---|---|---|---|---|
| GET /hiring/settings | Hiring configuration | Scoped hiring.read | — | stages, templates, application questions |
| PATCH /hiring/settings | Configure stages/questions/templates | Admin hiring.configure | ordered stages, question definitions, template IDs | configuration/version |
| GET /job-requisitions | Intake queue | Scoped hiring.intake | status/filter | requisitions |
| POST /job-requisitions | Submit owner-defined intake | Scoped hiring.intake | title, departmentId, locationId, type, description, leadId | pending requisition |
| POST /job-requisitions/{id}/decisions | Approve/reject intake | Scoped hiring.approve | decision, comment | decision and requisition status |
| GET /openings | Opening list/search/counts | Scoped hiring.read | title/dept/location/lead/status | visible openings and stage counts |
| POST /openings | Create draft, optionally approved intake | Scoped hiring.manage | intakeId?, title, departmentId, locationId, type, description, leadId | draft opening |
| GET /openings/{id} | Opening/board/pipeline configuration | Scoped opening.read | — | opening, collaborators, stage counts |
| PATCH /openings/{id} | Edit/publish/close opening | Scoped opening.manage | allowed fields, status | opening/version |
| PUT /openings/{id}/collaborators | Scope lead/collaborators | Scoped opening.manage | userIds and hiring permissions | assignments |
| POST /openings/{id}/board-postings | Record manual external posting | Scoped opening.manage | boardName, publicUrl | posting; no vendor automation |
| DELETE /openings/{id}/board-postings/{postingId} | Remove posting link | Scoped opening.manage | — | 204 |
| GET /careers | Published careers listing | Public | q/location | public opening summaries |
| GET /careers/{slug} | Public opening/application definition | Public | — | published content and public questions |
| POST /careers/{slug}/upload-intents | Stage resume in private quarantine | Public rate-limited | name, MIME, byteSize,sha256 | single-use upload URL,uploadId and restricted upload capability |
| POST /careers/{slug}/upload-completions | Verify uploaded resume and queue scan | Token single-upload capability | uploadId | quarantined scan job |
| GET /careers/{slug}/uploads/{uploadId} | Resume scan status | Token single-upload capability | — | pending/clean/rejected; no object URL |
| POST /careers/{slug}/applications | Apply | Public rate-limited | contact, answers, scanned uploadId, consent | opaque receipt; never candidate record |

## F02 — Screen and hire a candidate

| Method path | Does | Auth | Request | Response |
|---|---|---|---|---|
| GET /openings/{id}/applications | Pipeline cards | Scoped opening.read | stage,q,source,rating | candidates with authorized fields |
| GET /applications/{id} | Candidate profile | Scoped application.read | — | contact, answers, resume metadata, stage |
| PATCH /applications/{id} | Stage/rating/contact change | Scoped application.manage | stageId/rating/contact/reason | application; stage email event |
| POST /applications/{id}/withdrawals | Record withdrawal | Scoped application.manage | reason | withdrawn status |
| GET /applications/{id}/timeline | Notes/emails/interviews | Scoped application.read | kind | authorized timeline |
| POST /applications/{id}/notes | Add note/comment | Scoped application.comment | body, kind=note/comment | note |
| POST /applications/{id}/messages | Send candidate email | Scoped application.message | templateId?, subject, body | queued message |
| GET /applications/{id}/interviews | Interviews/scorecards | Scoped application.read | — | authorized interviews |
| POST /applications/{id}/interviews | Schedule or invite booking | Scoped interview.manage | interviewerIds, availability, duration, buffer, zone | interview/invitation status |
| PATCH /interviews/{id} | Reschedule/cancel | Scoped interview.manage | startAt?, status, reason | interview/version |
| PUT /interviews/{id}/scorecard | Assigned interviewer assessment | Scoped interview.score | rubric answers, recommendation | scorecard/version |
| POST /booking-sessions | Exchange booking token | Token booking | token | restricted HttpOnly booking session |
| GET /booking/slots | Available slots | Token booking session | date range, zone | UTC slots and display zone |
| POST /booking/reservations | Atomically reserve slot | Token booking session | slotId, candidate zone | confirmed interview; 409 if occupied |
| GET /offer-templates | Owner's templates | Scoped offer.read | — | templates |
| POST /offer-templates | Store owner-authored template | Admin hiring.configure | name, content, merge fields | template |
| PATCH /offer-templates/{id} | Version template | Admin hiring.configure | content, name | template/version |
| POST /applications/{id}/offers | Draft additional or first offer | Scoped offer.manage | templateId, merge values, compensation | draft offer |
| POST /offers/{id}/preview | Render safely before send | Scoped offer.manage | — | sanitized document and recipient preview |
| POST /offers/{id}/send | Freeze offer version and invite | Scoped offer.send | recipient, expiry | offer and e-sign request IDs |
| GET /offers/{id} | Offer status/history | Scoped offer.read | — | versioned offer and signature status |
| POST /applications/{id}/hire | Atomic ATS to HR handoff | Scoped hiring.hire + employee.create | hireDate, employee fields, packetTemplateId? | employeeId, packetId?, alreadyProcessed |

Candidate-facing offer access/sign/decline uses F03 e-sign sessions. Hiring idempotency uniquely links one application to one employee; retries cannot duplicate employees or packets. Later offer letters preserve prior signed versions. Talent pools/background checks remain deferred, with no pretend partner routes.

## F03 — Onboard a new hire (also Home and People)

| Method path | Does | Auth | Request | Response |
|---|---|---|---|---|
| GET /home | Personal widgets and allowed metrics | Session home.read | — | projected widgets, tasks, announcements, links, celebrations |
| GET /search | Global search/snapshot results | Session search.read | q, type | authorized employee/opening snippets |
| GET /employees | Directory/export source | Scoped employee.read | standard directory filters, teams | projected employees |
| POST /employees | Add employee directly | Scoped employee.create | identity, employment, packetTemplateId? | employee and optional packet |
| GET /employees/{id} | Profile/snapshot | Scoped employee.read | tab, fields | allowed field groups and tab metadata |
| GET /org-chart | Allowed hierarchy | Scoped employee.read | rootId?, depth | projected nodes, no hidden manager PII |
| GET /employee-metadata | Field/tab/table definitions | Scoped employee.read | — | visible definitions, lists, layouts |
| PUT /employee-metadata | Customize fields/tabs/table definitions | Admin employee.configure | definitions and placement | validated metadata/version |
| GET /employees/{id}/table-rows | HR history/dependents/contacts | Scoped employee.read | table, effectiveAt | projected rows |
| POST /employees/{id}/table-rows | Add effective HR row | Scoped employee.write | table, effectiveAt, fields | row |
| PATCH /employees/{id}/table-rows/{rowId} | Correct permitted history | Scoped employee.write | fields, reason | row/version |
| GET /employees/{id}/audit | Record audit trail | Scoped audit.read | time range, cursor | redacted changes and actor |
| GET /packet-templates | Reusable packets | Scoped onboarding.read | — | templates |
| POST /packet-templates | Author packet | Admin onboarding.configure | name, infoFields, documentIds, taskListIds | template |
| PATCH /packet-templates/{id} | Version packet template | Admin onboarding.configure | template fields | versioned template |
| GET /task-list-templates | Task lists | Scoped onboarding.read | kind | templates and task definitions |
| POST /task-list-templates | Author checklist | Admin onboarding.configure | name, kind, tasks with role/dueOffset/order | template |
| PATCH /task-list-templates/{id} | Edit reusable checklist | Admin onboarding.configure | name/tasks | template/version |
| POST /employees/{id}/packets | Send immutable packet snapshot | Scoped onboarding.manage | templateId, dueAt, accessBeforeStart | packet, delivery status |
| GET /packets/{id} | Administrative progress | Scoped onboarding.read | — | field/document/task completion, no bearer tokens |
| POST /packets/{id}/reminders | Queue controlled reminder | Scoped onboarding.manage | — | queued delivery |
| POST /packet-sessions | Exchange invitation | Token packet | token | restricted HttpOnly packet session |
| GET /packet | Recipient packet | Token packet session | — | assigned steps, own answers, task progress |
| PATCH /packet/answers | Save packet's allowed info fields | Token packet session | fields, version | projected answers/progress |
| PATCH /packet/tasks/{taskId} | Complete new-hire assigned task | Token bound packet session | done,version | own task/progress; no staff tasks |
| POST /packet/complete | Validate packet completion | Token packet session | version | completion/access eligibility |
| GET /employees/{id}/tasks | Employee/IT/manager tasks | Scoped task.read | kind,status | assigned tasks/progress |
| POST /employees/{id}/tasks | Customize task instance | Scoped onboarding.manage | title, assigneeId, dueAt, kind | task |
| PATCH /tasks/{id} | Complete/reassign permitted task | Scoped task.complete/manage | done or assigneeId/dueAt | task/version |
| POST /e-sign-requests | Request owner-document signature | Scoped document.sign.request | fileId/version, signer recipients, filing folder | request/status |
| POST /signature-sessions | Exchange signature invitation | Token signature | token | restricted HttpOnly signer session |
| GET /signature | Exact frozen document and consent | Token signature session | — | document preview, digest, consent version |
| POST /signature/decision | Sign or decline current version | Token signature session | decision, consent, signature, documentDigest | final status and receipt |
| GET /e-sign-requests/{id} | Signature evidence/status | Scoped document.sign.read | — | signer states, evidence metadata, signed fileId |
| POST /employees/{id}/rehire | Explicit rehire with packet | Scoped employee.rehire | hireDate, employment fields, packetTemplateId | employment episode and packet |

Packet completion gates access-before-start under configured policy; a token grants only packet fields/tasks/docs, never portal navigation. Task definitions and sent packets are snapshots. Completed signatures freeze document bytes/digest, signer consent, event times and evidence; finalized artifact auto-files once. This is owner-operated simple e-sign with a retained evidence trail, not a claim of certified identity or regulated document compliance.

## F04 — Employee self-service update

| Method path | Does | Auth | Request | Response |
|---|---|---|---|---|
| GET /me | Own profile and grants | Self | fields? | allowed fields, editability, pending changes |
| PATCH /me | Self update or approval request | Self field.write | fields, version | applied fields and pending request IDs |
| PATCH /employees/{id} | Authorized record edit | Scoped employee.write | allowed fields, reason, version | employee/version |
| GET /change-requests | Approval queue | Scoped approval.read | status | authorized requests |
| POST /change-requests/{id}/decisions | Decide self-service request | Scoped approval.decide | approve/reject, reason | applied change or rejection |
| GET /notifications | Notification center | Session own notifications | unread,cursor | notifications |
| PATCH /notifications/{id} | Mark own notification read | Session own notification | readAt | notification |
| GET /one-on-ones | 1:1 list | Scoped participant/manager | employeeId?,window | authorized meetings |
| POST /one-on-ones | Schedule 1:1 | Scoped participant/manager | participants,startAt,endAt,zone,agenda | meeting |
| PATCH /one-on-ones/{id} | Edit agenda/shared notes/status | Scoped participant | agenda, sharedNotes, startAt?,status | meeting/version |
| GET /employees/{id}/notes | Private profile notes | Scoped employee.note.read + note visibility | cursor | authorized notes |
| POST /employees/{id}/notes | Add private profile note | Scoped employee.note.write | body,visibility=author/hr/manager | note |
| PATCH /employees/{id}/notes/{noteId} | Edit authorized note | Scoped author/HR employee.note.write | body,visibility?,version | note/version |
| DELETE /employees/{id}/notes/{noteId} | Archive permitted note | Scoped author/HR employee.note.write | reason | 204; retention audit |
| GET /training-items | Owner training catalog | Scoped training.read | category | items |
| POST /training-items | Create owner training item | Admin training.configure | name,type,category,description,fileId? | item |
| PATCH /training-items/{id} | Edit catalog item | Admin training.configure | allowed catalog fields | item/version |
| GET /employees/{id}/training | Owner-recorded training history | Scoped training.read | category | records |
| POST /employees/{id}/training | Record training | Scoped training.manage | owner item, completedAt, expiresAt?, fileId? | training record |
| PATCH /employees/{id}/training/{recordId} | Correct training record | Scoped training.manage | allowed training fields | record/version |

## F05 — Run a review cycle

| Method path | Does | Auth | Request | Response |
|---|---|---|---|---|
| GET /review-questions | Owner question templates | Scoped review.configure | — | question definitions |
| POST /review-questions | Create question template | Admin review.configure | text,type,options,employeeView | question |
| PATCH /review-questions/{id} | Version question | Admin review.configure | question fields | version |
| GET /review-cycles | Authorized cycles | Scoped review.read | status | cycles |
| POST /review-cycles | Configure cycle/duplicate | Admin review.manage | sourceCycleId?,name,window,segments,questionIds,doubleBlind,reviewer roles | draft snapshot |
| GET /review-cycles/{id} | Cycle configuration/progress | Scoped review.read | — | visible configuration and counts |
| PATCH /review-cycles/{id} | Edit draft cycle | Admin review.manage | configuration | cycle/version |
| POST /review-cycles/{id}/launch | Freeze roster/questions and launch | Admin review.manage | version | cycle, assignments |
| GET /assessments | Own assigned assessments | Scoped review.respond | cycleId,status | assignments |
| GET /assessments/{id} | Assigned draft or released result | Scoped reviewer/released subject | — | allowed questions and answers |
| PATCH /assessments/{id} | Autosave own draft | Scoped assigned reviewer | answers,version | draft/version |
| POST /assessments/{id}/submit | Finalize assessment | Scoped assigned reviewer | version | submitted status |
| POST /review-cycles/{id}/reassignments | Handle departed reviewer | Admin review.manage | assessmentId,newReviewerId,reason | reassignment audit; submitted answers preserved |
| GET /review-cycles/{id}/results | Permission-filtered results | Scoped review.results | subjectId?,segment? | releasable results/completion |
| POST /review-cycles/{id}/releases | Share selected Employee View answers | Admin review.release | subjectIds,questionIds | release records |
| POST /review-cycles/{id}/close | Close collection | Admin review.manage | — | closed cycle |

Double-blind hides counterpart answers until both required submissions or explicit cycle release policy; draft access stays reviewer-only. Peer anonymity hides reviewer identity in response, exports, audit projections and small cohorts. Configuration freezes on launch; question/roster changes require a new cycle. No report can bypass release or anonymity rules.

## F06 — Set and track goals

| Method path | Does | Auth | Request | Response |
|---|---|---|---|---|
| GET /goals | Own/shared permitted goals | Scoped goal.read | ownerId,status,scope | goals |
| POST /goals | Create individual/shared goal | Scoped goal.create | ownerId,title,description,visibility,milestones,parentGoalId? | goal |
| GET /goals/{id} | Goal detail | Scoped goal.read | — | goal, milestones, comments |
| PATCH /goals/{id} | Goal/progress update | Scoped goal.write | title?,progress?,visibility?,milestones?,parentGoalId? | goal/version |
| DELETE /goals/{id} | Archive goal | Scoped goal.write | version | 204; audit retained |
| GET /goal-alignment-options | Visible company/dept parents | Scoped goal.read | scope | permitted parent goals |
| GET /goals/{id}/tree | Cascading goal subtree | Scoped goal.read | depth | authorized nodes only |
| POST /goals/{id}/comments | Comment | Scoped goal.comment | body | comment |

At most ten milestones enforced in database; progress 0–100; parent graph acyclic with authorized same-company parents. Private goals remain private in totals, alignment options and reports.

## F07 — Measure satisfaction (eNPS and wellbeing)

| Method path | Does | Auth | Request | Response |
|---|---|---|---|---|
| GET /survey-questions | Owner-authored question bank | Admin survey.manage | type | question definitions |
| POST /survey-questions | Add owner question | Admin survey.manage | text,type,options | question; no licensed validation claim |
| GET /survey-runs | Campaign list | Admin survey.manage | type,status | campaigns, aggregate participation |
| POST /survey-runs | Draft anonymous run | Admin survey.manage | type,window,audience,contractorPolicy,questionIds,reminderSchedule | run |
| PATCH /survey-runs/{id} | Edit unlaunched campaign | Admin survey.manage | configuration | draft/version |
| POST /survey-runs/{id}/launch | Freeze audience and invite | Admin survey.manage | version | campaign, audienceCount |
| POST /survey-sessions | Issue blind-signed one-use run credential | Token survey invitation | invitation token, blinded random nonce | signed blinded credential; issuance recorded only |
| GET /survey | Anonymous questionnaire | Token blind-signed run credential | runId | frozen questions/window |
| POST /survey/responses | One atomic anonymous response | Token blind-signed run credential | runId, unblinded signed nonce, score 0–10 or answers, optional comment | generic receipt |
| GET /survey-runs/{id}/report | Aggregate eNPS/heatmap | Scoped survey.results | run ID only; no respondent segmentation | participation %, score/heatmap or suppressed |
| POST /survey-runs/{id}/close | End collection | Admin survey.manage | — | closed status |

**Anonymity contract (assumption):** Blind-sign a cryptographically random run-scoped one-use credential after invitation eligibility validation; employee-linked eligibility records track issuance only, never completion. Use an established audited blind-signature implementation and disable survey launch until independent review proves unlinkability; do not invent cryptography. A separate survey-ingest database role atomically consumes an anonymous nonce in `survey_spent_tokens` and inserts the response; spent nonces have no employee link and responses have no token link. Normal runtime can read thresholded aggregates only. Response rows contain no employee/user/invitation ID, IP, user agent, request ID, exact submission time or identifying segment. No per-user completion endpoint/list/export. Report participation is a whole-campaign count only. Reminders go to the entire audience with “ignore if completed” text, avoiding a named completion ledger. Minimum cohort 5, whole-run reporting only, delayed/coarse participation batches and no respondent filters prevent simple differencing; the wellbeing heatmap compares question dimensions only. Freeze the audience at launch; do not publish live score changes or overlapping subgroup results. Comments displayed only after close, at cohort threshold, with an explicit warning to respondents to omit identifying information. Raw answers excluded from app logs, tracing and analytics. Token-use time is not retained; processing infrastructure must disable body/access logging for this path. This limits direct linkability; an operator controlling live infrastructure can still observe traffic, a documented operational trust boundary. No claim of mathematically guaranteed anonymity.

## F08 — Recognize a peer (and community)

| Method path | Does | Auth | Request | Response |
|---|---|---|---|---|
| GET /core-values | Owner's core values | Session | — | values |
| PUT /core-values | Configure values | Admin recognition.configure | names,descriptions,active flags | values/version |
| GET /recognition | Visible recognition feed | Scoped recognition.read | recipientId?,cursor | posts |
| POST /recognition | Recognize peer and transfer points | Scoped recognition.create | recipientId,body,coreValueId,points | post and own balance |
| GET /recognition/balance | Own point ledger/balance | Self | — | allocation,available,received |
| PUT /recognition/allocations | Configure group budgets | Admin recognition.configure | period,groupIds,points | allocation policy/version |
| DELETE /recognition/{id} | Moderate post/reverse once | Scoped recognition.moderate | reason | 204; void post once and append immutable audit reversal |
| GET /community/posts | Audience-filtered community | Scoped community.read | cursor | posts/comments |
| POST /community/posts | Publish owner community content | Scoped community.publish | title?,body,audience | post |
| PATCH /community/posts/{id} | Edit own/moderated content | Scoped author/moderator | body,audience? | post/version |
| DELETE /community/posts/{id} | Remove content | Scoped author/moderator | reason? | 204 |
| POST /community/posts/{id}/comments | Discuss | Scoped community.comment | body | comment |

Points are integer internal recognition units, not money; lock `recognition_allocations` before issuing/voiding a post. Received and available balances derive from non-voided posts. Resolve group budgets to non-overlapping per-employee allocation snapshots; audit the group selector and period, and never reduce a budget below spent points. No separate mutable balance or ledger is required. Gift cards and Slack rewards integrations require later owner contracts and remain deferred.

## F09 — Offboard

| Method path | Does | Auth | Request | Response |
|---|---|---|---|---|
| POST /employees/{id}/offboardings | Schedule separation/checklist | Scoped employee.terminate | effectiveAt,type,reason,rehireEligible,regrettable,taskListIds | offboarding/tasks |
| GET /employees/{id}/offboardings | Separation and checklist | Scoped employee.read sensitive separation grants | — | projected offboarding state |
| PATCH /offboardings/{id} | Correct/cancel before effective time | Scoped employee.terminate | effectiveAt?,status?,reason | version; replacement job scheduled |
| POST /offboardings/{id}/finalize | Complete remaining administrative checklist | Scoped onboarding.manage | version | completion; cannot delay access cutoff |

F03 task routes serve offboarding checklists. Effective separation invalidates active sessions, invitations and API keys belonging to the departing user at the authorization boundary as well as the worker; terminated records are read-only except explicit correction/rehire capabilities. Retention/deletion is owner policy, not immediate cascade deletion. Former pay-document self-service is deferred because payroll is out of scope.

## F10 — Configure permissions (and platform settings/auth)

| Method path | Does | Auth | Request | Response |
|---|---|---|---|---|
| GET /api/auth/signin | Begin configured OIDC | Public | safe same-origin returnTo | Auth.js redirect |
| GET /api/auth/callback/{provider} | OIDC code/state/PKCE callback | OIDC protocol | code,state | session cookie and safe redirect |
| POST /api/auth/signout | Revoke own session | Session | CSRF token | cleared cookie |
| GET /session | Current real/effective identity | Session | — | user,employeeId?,capabilities,preview state |
| GET /settings | Visible settings navigation | Session settings.read | — | allowed sections |
| GET /company | Branding and company settings | Session | — | authorized name/logo/theme/timezone |
| PATCH /company | Owner rebrand/configure | Admin company.manage | name,logoFileId,theme,timezone,accessPolicy | company/version |
| GET /organization-units | Directory filter configuration | Session employee.read | kind | departments/divisions/locations/teams |
| PUT /organization-units | Manage owner organization structure | Admin employee.configure | units,parentIds,team memberships | validated units/version |
| GET /retention-policies | Retention and hold configuration | Admin retention.manage | — | policies and active holds |
| PUT /retention-policies | Set policy, place/release hold | Admin retention.manage | policies,resource holds,reason | audited configuration |
| GET /users | Employee/non-employee users | Admin access.manage | status,q | users and assigned levels |
| POST /users | Invite employee or scoped recruiter | Admin access.manage | email,employeeId?,levelIds | pending user/invitation |
| PATCH /users/{id} | Disable/invite/update linkage | Admin access.manage | active?,employeeId?,reason | user/version; sessions revoked if disabled |
| GET /access-levels | Levels and explicit grants | Admin access.manage | — | Employee/Manager/Admin/Custom levels |
| POST /access-levels | Create custom level | Admin access.manage | name,grants,self/other/home scope,field grants | level |
| PATCH /access-levels/{id} | Modify configurable grants | Admin access.manage | grants,name?,version | level/version |
| PUT /users/{id}/access-levels | Assign multiple levels | Admin access.manage | levelIds,scope | assignments; reject privilege escalation |
| POST /preview-sessions | Start read-only preview | Admin access.preview | targetUserId,reason | effective identity,expiry; audited |
| DELETE /preview-sessions/current | Exit preview | Real Admin actor | — | restored real identity |
| GET /home-layout | Read effective widget configuration | Session home.read | — | visible ordered widgets |
| PUT /home-layout | Enable/rearrange widgets | Admin home.configure | ordered widget config and audience | layout/version |
| POST /announcements | Publish owner announcement | Scoped home.publish | title,body,audience,startAt,expireAt | announcement |
| PATCH /announcements/{id} | Edit/end announcement | Scoped home.publish | content/window/audience | announcement/version |
| POST /company-links | Add company link | Admin home.configure | label,url,icon,audience | link |
| PATCH /company-links/{id} | Change company link | Admin home.configure | link fields | link/version |
| DELETE /company-links/{id} | Remove company link | Admin home.configure | — | 204 |
| GET /availability-events | Who's Out visibility | Scoped home.availability | bounded window | allowed absence summaries; no medical reasons |
| POST /availability-events | Owner-maintained absence display | Scoped home.availability.manage | employeeId,startAt,endAt,label,audience | display event; no PTO accounting |
| GET /workflow-rules | Approval/stage automation rules | Admin workflow.manage | — | owner-defined limited rules |
| POST /workflow-rules | Configure allowlisted rule | Admin workflow.manage | trigger,conditions,approved action,approver scope | rule |
| PATCH /workflow-rules/{id} | Enable/version rule | Admin workflow.manage | enabled,conditions?,action? | rule/version |
| GET /api-keys | Key metadata only | Admin integration.manage | — | label,scope,lastUsedAt,expiresAt |
| POST /api-keys | Create scoped owner integration key | Admin integration.manage | label,scopes,expiresAt | one-time key and metadata |
| DELETE /api-keys/{id} | Revoke key | Admin integration.manage | — | 204 |
| GET /webhooks | Outbound subscription metadata | Admin integration.manage | — | subscriptions; secret omitted |
| POST /webhooks | Register owned HTTPS endpoint | Admin integration.manage | URL,events,monitorFieldIds | subscription and one-time signing secret |
| PATCH /webhooks/{id} | Change/disable subscription | Admin integration.manage | URL?,events?,monitorFieldIds?,enabled? | subscription/version |
| DELETE /webhooks/{id} | Disable delivery | Admin integration.manage | — | 204 |
| GET /webhooks/{id}/deliveries | Delivery outcomes | Admin integration.manage | status | redacted attempts |
| POST /webhooks/{id}/deliveries/{deliveryId}/retry | Explicit replay, same event ID | Admin integration.manage | — | queued delivery |

Prevent last active administrator removal, self-grant escalation and cross-company links; permissions changes revoke cached grants immediately. The application supports invitation-based access only; OIDC success without an active invitation/membership is denied. Workflow rules are an allowlisted condition/action model, not arbitrary executable expressions. New hires cannot read announcements older than their configured visibility start.

## F11 — Build a custom report

| Method path | Does | Auth | Request | Response |
|---|---|---|---|---|
| GET /report-datasets | Allowed dataset/field catalog | Scoped report.read | — | fields,types,operators,limits |
| GET /reports | Standard/custom definitions | Scoped report.read | kind | definitions |
| POST /reports | Save custom report | Scoped report.create | dataset,fields,typed filters,sort | definition |
| GET /reports/{id} | Read authorized definition | Scoped report.read | — | allowed definition/version |
| PATCH /reports/{id} | Edit own/shared definition | Scoped report.manage | fields,filters,sort | definition/version |
| DELETE /reports/{id} | Archive custom definition | Scoped report.manage | — | 204 |
| POST /reports/{id}/runs | Run with current grants | Scoped report.run | bounded parameters | immediate projected rows or jobId |
| GET /report-runs/{id} | Read own authorized result | Scoped report.run | cursor | projected rows, totals, expiry |
| POST /report-runs/{id}/exports | Request safe CSV export | Scoped report.export | format=csv | export jobId |
| GET /exports/{id} | Status/download authorization | Scoped original requester | — | status or short-lived download URL |
| POST /reports/{id}/schedules | Schedule delivery (inferred) | Scoped report.schedule | zone,cron,recipientUserIds | schedule |
| PATCH /report-schedules/{id} | Change/disable delivery | Scoped report.schedule | enabled,cron?,recipientUserIds? | schedule/version |
| GET /insights | Visible admin metric widgets | Scoped insights.read | bounded period,approved filters | authorized own-company metrics |

Allowlisted datasets: directory/employment, hiring funnel/sources, onboarding tasks, goals status, released performance and turnover. No arbitrary SQL/joins or raw anonymous survey dataset. Dataset catalogs advertise indexed, allowlisted filter/sort keys. New custom fields can be selected for display but need a reviewed index migration before becoming filter/sort keys; unbounded scans are rejected. Validate all selected/filter/group/sort fields against grants; evaluate joined resources and aggregation inference risks. Recheck grants at execution and download, discard stale results after grant change. Export formula-leading cells escaped; downloads expire. Scheduled reports run separately with each recipient's current permissions and deliver authenticated links, never attachments. Standard report definitions do not grant data access. Retain own-company metrics only; no benchmark datasets.

## F12 — Manage company and employee files

| Method path | Does | Auth | Request | Response |
|---|---|---|---|---|
| GET /file-categories | Visible categories/folders | Scoped file.read | employeeId? | categories |
| POST /file-categories | Add owner category/folder | Admin file.configure | name,scope,parentId?,employeeUpload flag | category |
| PATCH /file-categories/{id} | Rename/restrict category | Admin file.configure | name?,visibility? | category/version |
| GET /files | Visible company/employee documents | Scoped file.read | categoryId,employeeId,q | metadata only |
| POST /files/upload-intents | Authorize private quarantine upload | Scoped file.create | employeeId?,categoryId,name,MIME,byteSize,digest | single-use upload URL,uploadId |
| POST /files/upload-completions | Validate storage object and queue scan | Scoped upload owner | uploadId | quarantined file and scan status |
| PATCH /files/{id} | Category/share/metadata change | Scoped file.manage | categoryId?,shared?,audience? | file/version |
| POST /files/{id}/download-tickets | Authorize exact object read | Scoped file.read | purpose=view/download | short-lived single-object URL |
| DELETE /files/{id} | Soft-delete permitted file | Scoped file.delete | reason | 204; retention/legal-hold enforced |

Employee self-uploads always land in Employee Uploads; user-supplied employee/category IDs cannot widen access. Per-document sharing is an additional grant, never a bypass for field or employment access. Default maximum 20 MiB, PDF/JPEG/PNG/DOCX only (assumption, owner configurable later); sniff bytes and scan before reads or e-sign. Disallow HTML/SVG/scripts, inline active content and MIME spoofing; use attachment disposition where appropriate. Replacements create new object versions; signed versions cannot be overwritten. R2 keys are opaque, buckets private, URLs excluded from logs. Downloads are blocked in preview. GET /files uses metadata authorization and cannot expose an unscanned payload.

## Integration ingress and background execution

These infrastructure routes use absolute paths and are outside the F01–F12 product tables.

| Method path | Does | Auth | Request | Response |
|---|---|---|---|---|
| POST /api/integrations/resend/events | Delivery/bounce and configured inbound reply events | Service verified Resend signature and replay window | event ID, delivery event | 204 after durable inbox insert |
| POST /api/integrations/calendar/events | Optional owner's calendar changes | Service provider signature | provider event ID/version | 204 durable inbox; enabled only with configured integration |
| GET /api/inngest | Inngest function registration | Inngest SDK authenticated registration | protocol | registered function metadata |
| POST /api/inngest | Execute/retry jobs | Service Inngest signature | signed function event/step | SDK protocol result |
| PUT /api/inngest | Inngest synchronization | Service Inngest signature | SDK protocol | SDK protocol result |
| GET /api/v1/jobs/{id} | Authorized job status | Session original requester/resource grant | — | status, safe errors; no raw payload |

No Stripe/payroll/background-check ingress. Candidate replies require an owner-configured verified inbound Resend domain: verify provider event, fetch body through official owner-key API, bind opaque reply alias to one application/thread, quarantine unmatched senders, scan attachments and sanitize text. Never trust an email From header to grant portal access. Outbound messages/timeline ship first; verified inbound replies complete messaging in milestone 3. Calendar route is a specified deferred integration, not a promise of working sync in the first slice.

| Job | Trigger/schedule (UTC unless noted) | Contract |
|---|---|---|
| Domain outbox dispatcher | Event-driven; recovery every minute | Persist events with business transaction; dedupe by event ID; never lose hire/packet/stage changes on provider failure. |
| Email send + status | Outbox event, exponential backoff, max 8 attempts/24h | Unique recipient/template/business-event key; Resend idempotency where available; dead-letter with operator retry. Suppress hard bounces; owner's verified sending domain/SPF/DKIM/DMARC. |
| Stage automation | Candidate stage event | Run frozen rule version once per stage transition; email only after committed change; manual resend is distinct audited action. |
| Packet/task/review reminders | Hourly; due-date evaluation in company/recipient zone | Respect run window, quiet hours, recipient active status and daily dedupe; no reminders after completion. |
| Survey invitations/reminders | Launch event; daily 14:00 UTC scheduler evaluates run-local schedule | Entire-audience reminders, no named completion state; logs contain run/count only. |
| Access activation/revocation | Effective employment boundary; sweep every minute | Enforce effective state on each request even if sweep delayed; revoke sessions/invitations/keys and log safe outcome. |
| File validation/scan | Upload completion event | Verify actual object size/type/digest, malware scan in isolated worker; quarantine on outage; publish only clean objects. |
| Signature finalization | Final signer committed | Lock request; deterministic final artifact/evidence; store immutable object then atomically auto-file; retry without duplicate files. |
| Calendar sync | Optional verified event; recovery every 15 minutes | Provider event ID/version dedupe; portal resource locks remain booking authority; warn operator on conflict. |
| Report run/export | User event | Bound runtime/row count; project granted fields; revalidate grants before publishing result; audit request without sensitive payload. |
| Report schedules | Every 5 minutes | Recipient-specific current authorization; authenticated expiring links; prevent duplicate scheduled occurrence through unique key. |
| Outbound webhooks | Committed employee created/updated/archived event | HTTPS POST with eventId/type/occurredAt/version, minimal granted field delta; HMAC timestamp/body; no SSN, compensation, surveys, bearer secrets or signed URLs by default. |
| Webhook retries | Backoff 1m,5m,30m,2h,12h,24h; then dead-letter | Same stable event ID, signed fresh attempt; receiver dedupes. Reject private/link-local/loopback destinations, DNS rebinding and redirects; validate endpoint at registration and delivery. |
| Cleanup/retention | Daily 03:00 UTC | Remove abandoned quarantine uploads after 24h, expired export objects after 24h, expired token/session rows; preserve legal holds and owner-configured HR retention. Deletion requests require scoped Admin review and redaction audit. |

## Failure and verification boundaries

- Time zones/DST: UTC intervals; explicit IANA zone; reject nonexistent local times and require offset choice for ambiguous times. Interview buffers participate in database exclusion/unique reservation checks. Date-effective HR events use the company zone.
- Races: lock balance, booking, offer, hire and signature state; transaction checks reject stale workflow transitions. Idempotency keys bind actor/resource/body digest and never turn different requests into accidental successes.
- Rate limits: per-session and public-IP/token budgets; resume uploads separate from application submission. Bound query complexity, search length, file sizes and report rows. Return Retry-After; do not log public tokens or survey network identifiers.
- Search/realtime/offline: Postgres indexed search with permission-first projection. No external search index, realtime server or offline sensitive-data cache initially. Poll job/notification status; write failures keep explicit retry state.
- Tenancy: one configured org; derive org from membership/config, never trust request org IDs. Same-org composite references and RLS block accidental cross-tenant relationships if a second organization is ever introduced.
- Deletion: soft-archive employment/files by default, policy-driven purge with legal-hold check. Candidate consent/retention and employee erasure requests receive owner review; anonymize only where history must remain. R2 objects, exports, sessions and provider copies must follow the same retention request.
- Delivery providers: official APIs and owner keys only. Durable outbox/inbox, stable event IDs, bounded retries and inspectable dead letters. Provider outage cannot roll back committed employee data or silently mark messages delivered.
- Verify each route's anonymous/employee/manager/custom/admin/preview matrix; object and field denial, list/detail/export consistency, session revocation, stale writes, duplicate events, race conflicts and no secret logging. Test anonymous survey schemas, report suppression and non-identifying reminder behavior separately. No routes are implemented or integration-tested by this architecture stage; SQL validation evidence is recorded in build-order.md.
