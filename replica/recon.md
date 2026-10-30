# Recon map: BambooHR (web)

Scope: HR portal slice — Home/Dashboard, People, Hiring/ATS (job intake → pipeline), Onboarding (packets, tasks, e-sign), Performance & Retention (reviews, goals, 1:1s, recognition, eNPS/wellbeing). Payroll, benefits, time & attendance excluded.
For: owner's own agency — internal recruiting/retention portal, rebrandable, own content. Clone target is 1:1 features + layout, then customize.
Date: 2026-10-29
Method: clean-room, public sources only (marketing, pricing, help center, product updates, public API docs, app store listings). No logins, no JS-bundle reads, no traffic capture.

Legend: **(O)** = observed on a public page; **(I)** = inferred. States column: public marketing shows filled states only — empty/error/permission states are unobserved unless noted.

## Sources

| # | source | URL | notes |
| --- | --- | --- | --- |
| 1 | marketing site | https://www.bamboohr.com/ | positioning, module nav, homepage screenshots |
| 2 | platform overview | https://www.bamboohr.com/platform | native module map, Bamboo AI |
| 3 | pricing | https://www.bamboohr.com/pricing | Core $10 / Pro $17 / Elite $25 PEPM; job-opening caps 5/25/50; feature gating |
| 4 | ATS product page | https://www.bamboohr.com/platform/applicant-tracking-system/ | posting, pipeline, offers, reports |
| 5 | Onboarding product page | https://www.bamboohr.com/platform/onboarding/ | packets, e-sign, checklists, progress |
| 6 | Performance product page | https://www.bamboohr.com/platform/performance-management/ | 360 reviews, goals, 1:1s |
| 7 | Employee Experience page | https://www.bamboohr.com/platform/employee-experience/ | eNPS, wellbeing, community |
| 8 | HR Data & Reporting page | https://www.bamboohr.com/platform/hr-data-and-reporting/ | records, directory, reports, AI |
| 9 | help center | https://help.bamboohr.com/s/ | screen names, workflows, settings, roles (article IDs cited per row) |
| 10 | product updates index | https://www.bamboohr.com/product-updates/query-index.json | last 12 months of changes |
| 11 | public API docs | https://documentation.bamboohr.com/ | data model: employees, fields, tables, files, goals, ATS, reports, webhooks |
| 12 | App Store listing | https://apps.apple.com/us/app/bamboohr/id587244049 | mobile screens (screenshots saved), 4.66★ |
| 13 | integrations directory | https://www.bamboohr.com/integrations | 261 partner listings (names only) |
| 14 | marketing screenshots | bamboohr.com media URLs (see `screens/mkt-*.png`) | layout reference, 18 files |

## Core loop

A company runs its whole people lifecycle in one place: it opens a job, tracks and screens candidates, sends an offer, hires, onboards the new hire with e-signed packets and assigned tasks, keeps the employee record current, and measures performance and satisfaction to keep people.

## Screens

| ID | screen | route / how to reach | purpose | key components | states seen |
| --- | --- | --- | --- | --- | --- |
| S01 | Login / SSO | /login | sign in | email+password, SAML SSO button, passkey (O: store listing, passkeys update) | filled only |
| S02 | Home (employee) | default after login | personal dashboard | widgets: Welcome, Celebrations, Company Links, Who's Out, My Stuff, What's Happening (O: help 639584) | filled (mkt-03) |
| S03 | Insights Dashboard (admin) | Reports > Insights | 16 metric widgets, role-based visibility (O: product-updates 2025) | widget grid, filters | filled (mkt-02) |
| S04 | Global search + Employee Snapshot | top search, any page | popup record preview without leaving page (O: help 2007786) | search input, modal card | filled only |
| S05 | My Info (self-service) | My Info nav | edit own record per field permission (O: help 587803) | field groups, save bar | filled only |
| S06 | People directory | People tab | searchable/filterable/exportable list; standard filters dept/division/status/title/location/teams (O: 587751, 587753) | table, filter chips, export | filled (mkt-01) |
| S07 | Org chart | from directory/profile | hierarchy view, quick link (O: update Nov 2025) | node tree, zoom | filled only |
| S08 | Employee profile | click person | tabbed record: Personal, Job, Time Off, Documents, Benefits, Pay Info, Performance, Emergency, Notes, Training, Onboarding/Offboarding, More (O: 587295) | tabs, field groups, action menu | filled (mkt-01) |
| S09 | Profile customize | Customize Tabs / Customize Layout | admin reorders fields/tabs (O: 587295) | drag lists, toggles | not observed |
| S10 | Employee documents | profile Documents tab | list/upload docs, per-doc share checkbox, Employee Uploads folder (O: 640097) | file list, upload, share toggle | not observed |
| S11 | Company Files | Files nav | company file categories (O: 587287) | category list, upload | not observed |
| S12 | Job Openings list | Hiring nav | openings with search by title/dept/location/lead, stage counts (O: 875031) | table, search, status pills | filled only |
| S13 | Job opening detail | click opening | Candidates pipeline + Job Boards tabs (O: 1070282) | pipeline columns w/ counts, candidate cards, tabs | filled (mkt-06) |
| S14 | New/Edit job opening | openings list / Settings > Hiring | intake form: title, dept, location, type, description, hiring lead (O: 587638) | sectioned form, selects | not observed |
| S15 | Candidate profile | click candidate | Info / Emails / Notes / Interviews tabs (O: 587645) | tabs, resume viewer, message composer, scorecard | filled only |
| S16 | Interview self-schedule page | candidate email link | slot picker with calendar buffer (O: 1976009) | calendar, slot list, confirm | not observed |
| S17 | Offer letter flow | candidate profile | template select, auto-populate, email preview, e-sign, status (O: 960688) | template picker, preview, e-sign block | filled (mkt-07) |
| S18 | Add Employee | People > Add | form with optional auto-send New Hire Packet (O: 588009) | sectioned form, packet toggle | not observed |
| S19 | New Hire Packet (new-hire view) | email link / profile Onboarding tab | info fields, e-sign docs, tasks, progress (O: 588009) | stepper, e-sign blocks, task list | filled (mkt-09) |
| S20 | Onboarding/Offboarding tab | profile | task lists (IT Setup, Manager) with tiles (O: 587295, task design update) | task tiles, progress, assignees | filled (mkt-10) |
| S21 | Settings hub | gear, bottom-left (admins only) | admin groups: Hiring, Onboarding & Offboarding, Employee Satisfaction, Core Values, API keys, Billing, Access Levels (O: 2086908) | grouped nav | not observed |
| S22 | Access levels editor | Settings > Access Levels | sections See About Themselves / See About Other Employees / See on Home; preview-as-user; custom levels; non-employee users (O: 587374, 925390) | permission matrix, preview mode | not observed |
| S23 | Reports | Reports nav | standard reports (Candidate Sources, Applicant Funnel, Turnover, Goals Status) + custom builder (O: 587875, 691371) | report list, builder, export | filled (mkt-08) |
| S24 | Performance tab | profile | Goals, assessments, peer feedback subtabs (O: 588034) | subtabs, goal cards, feedback list | not observed |
| S25 | Review cycle setup | Performance admin | questions, 360 config, double-blind, segments, duplicate (O: 588033, 1810421) | form, question editor, toggles | filled (mkt-13) |
| S26 | Goals | profile Performance / nav | individual + shared goals, ≤10 milestones, progress, comments, cascading tree (O: 588034, 984999) | goal cards, milestone list, alignment picker | filled (mkt-12) |
| S27 | 1:1s | profile | scheduling, agenda, shared notes (O: 1898823) | scheduler, notes editor | not observed |
| S28 | Recognition feed | Recognition nav | posts, core-value tags, points (O: 2082447) | feed cards, composer, points | filled only |
| S29 | eNPS survey | email/banner link | 0–10 rating + comment, anonymous (O: 2005406) | rating scale, comment box | not observed |
| S30 | Wellbeing survey + report | link / Reports | validated questions, heatmap (O: 1534121, 1536452) | survey, heatmap | filled (mkt-16) |
| S31 | Community feed | Community nav | posts/announcements (Pro/Elite) (O: glossary 2002837) | feed, composer | filled (mkt-15) |
| S32 | Mobile app home | iOS/Android app | directory, time off, who's out, approvals, SSO, theming (O: store listing) | tab bar, cards | filled (screens/ios-*.jpg) |

## Flows

```
F01 Open a job and collect applicants
    S21 hiring settings -> S14 create opening -> S12 list -> S13 boards tab -> post to boards -> candidate applies (public form)
    happy path clicks: ~8
    edge: job-opening cap hit (5/25/50 by plan), no hiring lead assigned, board post fails

F02 Screen and hire a candidate
    S13 -> S15 review (resume, Q&A, notes) -> S16 self-schedule -> S15 interview + scorecard -> S17 offer -> e-sign -> status hired -> triggers F03
    happy path clicks: ~12
    edge: candidate withdraws, slot taken, offer declined, additional offer letter after signature (O: update)

F03 Onboard a new hire
    S18 Add Employee (auto-send packet) -> S19 new hire completes info + e-signs + tasks -> S20 manager/IT tasks -> docs auto-file to S10 -> record live on S08
    happy path clicks: ~10 (new hire side) + ~6 (admin side)
    edge: packet not completed before start date, access-before-hire-date rule (O: 712129), rehire (O: Sep 2026)

F04 Employee self-service update
    S05 edit field -> save -> audit trail on S08
    happy path clicks: ~4
    edge: field not granted, manager approval workflow

F05 Run a review cycle
    S25 create cycle (questions, segments, double-blind) -> launch -> S24 self/peer/manager assessments (autosave) -> reminders -> S23 results -> Employee View share
    happy path clicks: ~9 (admin) + per-reviewer
    edge: reviewer leaves, cycle duplicated, anonymity toggle

F06 Set and track goals
    S26 create goal + milestones -> align to dept/company -> progress updates -> S23 Goals Status report
    happy path clicks: ~6
    edge: >10 milestones, private vs shared visibility

F07 Measure satisfaction (eNPS)
    S29 launch company-wide -> auto-reminders -> anonymous responses -> S23 report (participation %, score)
    happy path clicks: ~4
    edge: contractors included/excluded, admin sees % complete only

F08 Recognize a peer
    S28 post with core value + points -> feed -> points balance
    happy path clicks: ~4
    edge: point allocation by group (O: Oct 2026)

F09 Offboard
    S20 offboarding task list -> tasks -> termination date on S08 Job tab -> access revoked on effective date -> record read-only
    happy path clicks: ~7
    edge: former-employee self-service for pay docs (O: 2026-02)

F10 Configure permissions
    S22 edit/create access level -> preview-as-user -> assign user (multiple levels allowed)
    happy path clicks: ~8
    edge: non-employee user (external recruiter), custom field-level grants

F11 Build a custom report
    S23 builder -> pick dataset/fields -> filters -> run -> export
    happy path clicks: ~7
    edge: dataset field limits, scheduled delivery (I)

F12 Manage company files
    S11 upload -> categorize -> visibility
    happy path clicks: ~4
    edge: employee-uploaded docs land in Employee Uploads folder (O: 640097)
```

## Components

| component | variants | states | used on |
| --- | --- | --- | --- |
| Top nav | employee, manager, admin (items appear by role) | default, active, collapsed | all screens |
| Settings gear entry | admin only | default | all screens |
| Widget card | 6+ widget types, admin-configurable | empty, filled, rearranged | S02, S03 |
| Data table | directory, openings, reports | empty, filtered, sorted, exported | S06, S12, S23 |
| Filter chip row | standard filters | default, applied, cleared | S06, S12 |
| Tabbed record page | profile, candidate | default tab, deep-linked tab | S08, S15 |
| Pipeline board | column list w/ stage counts, drag | empty column, filled, drag-over | S13 |
| Task list / task tile | IT Setup, Manager, per-employee | todo, done, overdue | S19, S20 |
| E-sign block | sign here, date, initials | unsigned, signed, declined | S17, S19 |
| Status pill | candidate stage, task, employment | color-coded states | S12, S13, S20 |
| Modal | snapshot, email preview, confirm | open, loading | S04, S17 |
| Sectioned form | job intake, add employee, access level | default, validation error, dirty | S14, S18, S22 |
| Email template editor | stage emails, offers | default, merge-tag insert | S17, hiring settings |
| Rating scale | eNPS 0–10, survey Likert | unselected, selected | S29, S30 |
| Feed post card | recognition, community | default, with points, with tags | S28, S31 |
| Org chart node | person node, expand | collapsed, expanded | S07 |
| Avatar + photo upload | initials fallback, photo | default, uploaded | S06, S08 |
| Toast / alert | success, error, info | auto-dismiss | all |
| Heatmap | wellbeing report | empty, populated | S30 |
| Goal card + milestone list | private, shared, cascading | in-progress, done, aligned | S26 |

## Inferred data model

```
Employee      id, firstName, lastName, workEmail, phone, dateOfBirth, ssn, jobTitle,
              department, division, location, supervisorId, employmentStatus, hireDate,
              terminationDate(+type/reason/rehire/regrettable), payRate, payType, photo
              evidence: API standard-field list, S08, S06
              confidence: high
EmployeeField name, type (text/select/date/currency/...), listValues, tabPlacement, custom?
              evidence: /meta/fields, /hris/custom-fields, S09
              confidence: high
TableRow      employeeId, table (jobInfo|compensation|employmentStatus|dependents|contacts|
              emergencyContacts|bonus|commission), date, fields
              evidence: /docs/table-name-fields, S08
              confidence: high
User          id, employeeId?, accessLevels[], nonEmployee?, ssoSubject
              evidence: 587374, 1976637
              confidence: high
AccessLevel   name, grants{seeSelf, seeOther, seeHome, perField}, custom?
              evidence: 587374, 925390
              confidence: high
File          id, category, employeeId?, name, shared, signed?, folder
              evidence: /files, 640097, 587287
              confidence: high
ESignRequest  documentId, signers[], status, signedFileId
              evidence: 1492921, feature flag E_SIGNATURES
              confidence: medium (no public API)
JobOpening    id, title, department, location, employmentType, description, hiringLeadId,
              status(open|closed|filled), boardPostings[]
              evidence: /applicant_tracking/jobs, /job_opening, S13, S14
              confidence: high
Application   id, jobOpeningId, name, email, phone, resumeFileId, answers(json), statusId,
              source, rating, appliedAt
              evidence: /applicant_tracking/application, S15
              confidence: high
CandidateStatus id, label, order
              evidence: custom statuses (video), S13
              confidence: high
CandidateNote applicationId, authorId, body, kind(email|note|comment), createdAt
              evidence: /applications/{id}/comments, S15
              confidence: high
Interview     applicationId, templateId, scheduledAt, buffer, interviewerIds[], scorecard
              evidence: 1976009, press release (scorecards)
              confidence: medium-high
OfferLetter   applicationId, templateId, fields(json), eSignRequestId, status
              evidence: 960688
              confidence: high
PacketTemplate name, infoFields[], eSignDocIds[], taskListIds[]
              evidence: 588009, 1376515
              confidence: high
Packet        employeeId, templateId, progress, dueAt
              evidence: 588009, 712129
              confidence: high
TaskList      name, kind(onboarding|offboarding|it|manager), tasks[]
              evidence: 587617, 1467415
              confidence: high
Task          title, assigneeRole, dueOffset, done, order
              evidence: 587617, 587627
              confidence: high
ReviewCycle   name, type(self|manager|peer|360|skip), questionIds[], segments(dept/location/title),
              window, doubleBlind, status
              evidence: 588033, 1810421
              confidence: high
Assessment    cycleId, subjectId, reviewerId, role, answers, draft, submittedAt
              evidence: 588033, autosave update
              confidence: high
Goal          ownerId, title, description, milestones(≤10){title,status}, progress,
              visibility(private|shared), parentGoalId, comments[]
              evidence: /performance/.../goals, 984999
              confidence: high
OneOnOne      managerId, employeeId, scheduledAt, agenda, notes
              evidence: 1898823
              confidence: medium
RecognitionPost authorId, recipientId, message, coreValueId, points, createdAt
              evidence: 2082447
              confidence: high
SurveyRun     type(enps|wellbeing), audience, window, questionIds[], anonymous=true, reminders
              evidence: 2005406 (embedded IDs deleted), 1534121
              confidence: medium (no public API)
SurveyResponse runId, score(0–10)/answers, no employee link
              evidence: 2005406
              confidence: medium
Announcement  title, body, audience, startOn, expireOn
              evidence: What's Happening widget, 2001089
              confidence: medium
CompanyLink   label, url, icon, audience
              evidence: 639584
              confidence: high
Report        kind(standard|custom), dataset, fields[], filters[]
              evidence: /custom-reports, /datasets, S23
              confidence: high
Webhook       event(employee.created|updated|deleted|...), monitorFields[], target
              evidence: /webhooks, event-based-webhooks doc
              confidence: high
TrainingItem  type, category, employeeRecord
              evidence: /training/*
              confidence: medium
```

Relationships: Company 1-n User; User 1-1 Employee (optional); Employee 1-n TableRow, File, Goal, Assessment; JobOpening 1-n Application; Application 1-n CandidateNote, Interview, OfferLetter; PacketTemplate 1-n Packet; ReviewCycle 1-n Assessment; SurveyRun 1-n anonymous SurveyResponse.

## Feature matrix

See `features.csv`. Must: 43, should: 18, could: 11, skip: 8 (80 rows).

## Out of scope (cannot or should not be cloned)

- **Bamboo AI™ / AI Connectors** — their proprietary model layer; replace with own AI in phase 2.
- **HR Benchmarks** — licensed industry datasets (Mercer-class); clone can only show own-company numbers.
- **Job-board partnerships** (Indeed, ZipRecruiter, SEEK, LinkedIn ads) — commercial deals + APIs; clone posts via own careers page, manual links, or board APIs if obtained.
- **Background-check partners** (Checkr, TazWorks, Verified First, ...) — partner APIs; integrate later if wanted.
- **I-9 / E-Verify automation** — US-regulated; original uses Mitratech.
- **On-demand pay** (Clair), **employment verification** (The Work Number) — partner rails.
- **Compliance content** (VirgilHR, EasyLlama courses) — licensed libraries.
- **EOR / global employment** (Remote, Deel, ...) — partner services.
- **Community network effects** — the feed is cloneable, the network is not.
- **Native mobile apps** — phase 2; responsive web first.
- **Payroll, benefits admin, time & attendance** — excluded slice modules.
- **Integration marketplace (261 partners)** — not part of the rebuildable product.

## Gaps / follow-ups

- Empty, error, permission-denied, and loading states are unobserved — public marketing only shows filled states. A logged-in pass on the owner's own account (owner drives login) would fix this.
- Demo videos (Wistia embeds) not watched.
- Google Play screenshot hashes truncated in recon output — Play screenshots not saved; iOS set saved instead.
- Original has **no formal requisition-approval workflow** (I) — the clone should add intake → approval as a deliberate improvement.
- Interview scorecards evidenced by press release only (no help article).
- No public API for surveys, reviews, e-sign, announcements — those models are inferred from help articles and UI.

## Size

Screens 32, flows 12, entities 27. Hard parts: field-level permission engine with preview-as-user, e-signature + auto-filing, candidate self-scheduling with calendar sync, automated stage emails/workflows, anonymous survey integrity, document management with audit trail, report builder + datasets. Size: **L** for the full slice. Recommended: M-sized vertical slice first (Home + People + Hiring pipeline + packet onboarding), then reviews/eNPS, then the rest.
