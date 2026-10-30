# Recon map: BambooHR (web)

Scope: HR portal slice — Home/Dashboard, People, Hiring/ATS (job intake → pipeline), Onboarding (packets, tasks, e-sign), Performance & Retention (reviews, goals, 1:1s, recognition, eNPS/wellbeing). Payroll, benefits, time & attendance excluded.
For: owner's own agency — internal recruiting/retention portal, rebrandable, own content. Clone target is 1:1 features + layout, then customize.
Date: 2026-10-29
Method: clean-room, public sources only (marketing, pricing, help center, product updates, public API docs, app store listings). No logins, no JS-bundle reads, no traffic capture. Live audits use supplied public simulator and OICR careers PNGs only.

Legend: **(O)** = observed on a public page; **(I)** = inferred. States audited against 48 older images plus 21 live captures (2026-10-30); see design/design-audit.md, design/design-audit-2.md and current design/design-audit-3.md. All 17 current simulator captures retain the personalization gate; the former invitation claim is superseded. No logged-in shell is observed. Blank fields are not empty screens; help-center files are icons, not UI captures.

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
| 15 | supplied live simulator captures | https://advantagedemo.bamboohr.com/ | 17 current PNGs; all personalization gate mismatches, no product destination proof |
| 16 | supplied public careers captures | https://oicr.bamboohr.com/careers | four PNGs; S33–S35, including validation state |
| 14 | marketing screenshots | bamboohr.com media URLs (see `screens/mkt-*.png`) | layout reference, 18 files |

## Core loop

A company runs its whole people lifecycle in one place: it opens a job, tracks and screens candidates, sends an offer, hires, onboards the new hire with e-signed packets and assigned tasks, keeps the employee record current, and measures performance and satisfaction to keep people.

## Screens

| ID | screen | route / how to reach | purpose | key components | states seen |
| --- | --- | --- | --- | --- | --- |
| S01 | Login / SSO | /login | sign in | email+password, SAML SSO button, passkey (O: store listing, passkeys update) | not visually observed |
| S02 | Home (employee) | default after login | personal dashboard | widgets: Welcome, Celebrations, Company Links, Who's Out, My Stuff, What's Happening (O: help 639584) | filled balances/summary + selected community tab and populated feed (mkt-03); full shell unobserved; current live-demo-dashboard retains simulator gate (audit 3); no added dashboard proof |
| S03 | Insights Dashboard (admin) | Reports > Insights | 16 metric widgets, role-based visibility (O: product-updates 2025) | widget grid, filters | populated chart montage (mkt-02); Insights page placement unproven |
| S04 | Global search + Employee Snapshot | top search, any page | popup record preview without leaving page (O: help 2007786) | search input, modal card | not visually observed |
| S05 | My Info (self-service) | My Info nav | edit own record per field permission (O: help 587803) | field groups, save bar | mobile populated contact record + absent contact fields/add links (play-03); web edit/save unobserved |
| S06 | People directory | People tab | searchable/filterable/exportable list; standard filters dept/division/status/title/location/teams (O: 587751, 587753) | table, filter chips, export | mobile filled alphabetical list, avatar fallback, active People tab (ios-03, play-05); web directory unobserved |
| S07 | Org chart | from directory/profile | hierarchy view, quick link (O: update Nov 2025) | node tree, zoom | not visually observed |
| S08 | Employee profile | click person | tabbed record: Personal, Job, Time Off, Documents, Benefits, Pay Info, Performance, Emergency, Notes, Training, Onboarding/Offboarding, More (O: 587295) | tabs, field groups, action menu | Personal selected, filled and blank fields, photo, request-change/edit actions (mkt-01); Onboarding verification fragment (mkt-11); live emp-record/status retain simulator gate |
| S09 | Profile customize | Customize Tabs / Customize Layout | admin reorders fields/tabs (O: 587295) | drag lists, toggles | not observed |
| S10 | Employee documents | profile Documents tab | list/upload docs, per-doc share checkbox, Employee Uploads folder (O: 640097) | file list, upload, share toggle | not observed; live emp-documents retains simulator gate |
| S11 | Company Files | Files nav | company file categories (O: 587287) | category list, upload | not observed |
| S12 | Job Openings list | Hiring nav | openings with search by title/dept/location/lead, stage counts (O: 875031) | table, search, status pills | not visually observed; internal list unproven; public list is S33 |
| S13 | Job opening detail | click opening | Candidates pipeline + Job Boards tabs (O: 1070282) | pipeline columns w/ counts, candidate cards, tabs | not visually observed; mkt-06 is S14, not a candidate pipeline; live ATS captures retain gate; public detail is S34 |
| S14 | New/Edit job opening | openings list / Settings > Hiring | intake form: title, dept, location, type, description, hiring lead (O: 587638) | sectioned form, selects | Job Boards current, prior steps complete, two board tiles checked, save/finish-later actions (mkt-06); live ats-add-job retains gate |
| S15 | Candidate profile | click candidate | Info / Emails / Notes / Interviews tabs (O: 587645) | tabs, resume viewer, message composer, scorecard | populated candidate fragment, Info selected (mkt-05); full screen unobserved; live ats-candidate retains gate; public application is S35 |
| S16 | Interview self-schedule page | candidate email link | slot picker with calendar buffer (O: 1976009) | calendar, slot list, confirm | not observed |
| S17 | Offer letter flow | candidate profile | template select, auto-populate, email preview, e-sign, status (O: 960688) | template picker, preview, e-sign block | pending document + signature drawing editor with drawn mark (mkt-07); final receipt unobserved |
| S18 | Add Employee | People > Add | form with optional auto-send New Hire Packet (O: 588009) | sectioned form, packet toggle | hired confirmation + add-employee action only (mkt-05); add form unobserved |
| S19 | New Hire Packet (new-hire view) | email link / profile Onboarding tab | info fields, e-sign docs, tasks, progress (O: 588009) | stepper, e-sign blocks, task list | welcome/start and packet/setup form fragments with filled/blank fields and enabled introduction toggle (mkt-09; actor uncertain); mobile drawn I-9 signature (play-08); live onb-packet retains gate; packet builder unproven |
| S20 | Onboarding/Offboarding tab | profile | task lists (IT Setup, Manager) with tiles (O: 587295, task design update) | task tiles, progress, assignees | grouped unchecked tasks, assignee/due dates, Add Task/gear (mkt-10, mkt-05); no completed/overdue proof; live onb-tasks retains gate |
| S21 | Settings hub | gear, bottom-left (admins only) | admin groups: Hiring, Onboarding & Offboarding, Employee Satisfaction, Core Values, API keys, Billing, Access Levels (O: 2086908) | grouped nav | not observed |
| S22 | Access levels editor | Settings > Access Levels | sections See About Themselves / See About Other Employees / See on Home; preview-as-user; custom levels; non-employee users (O: 587374, 925390) | permission matrix, preview mode | not observed |
| S23 | Reports | Reports nav | standard reports (Candidate Sources, Applicant Funnel, Turnover, Goals Status) + custom builder (O: 587875, 691371) | report list, builder, export | populated bar/donut charts (mkt-02), KPI/funnel (mkt-08), performance scatterplot (mkt-12); builder/list/export unobserved; live reports/rep-* and sat-report retain gate; no report list/builder proof |
| S24 | Performance tab | profile | Goals, assessments, peer feedback subtabs (O: 588034) | subtabs, goal cards, feedback list | not observed; live perf retains gate |
| S25 | Review cycle setup | Performance admin | questions, 360 config, double-blind, segments, duplicate (O: 588033, 1810421) | form, question editor, toggles | Assessments selected, prior steps checked, pending review step, enabled toggle, filled dates/frequency and upcoming windows (mkt-13) |
| S26 | Goals | profile Performance / nav | individual + shared goals, ≤10 milestones, progress, comments, cascading tree (O: 588034, 984999) | goal cards, milestone list, alignment picker | not visually observed; mkt-12 is performance scatterplot, not goals |
| S27 | 1:1s | profile | scheduling, agenda, shared notes (O: 1898823) | scheduler, notes editor | not observed |
| S28 | Recognition feed | Recognition nav | posts, core-value tags, points (O: 2082447) | feed cards, composer, points | not visually observed |
| S29 | eNPS survey | email/banner link | 0–10 rating + comment, anonymous (O: 2005406) | rating scale, comment box | not observed; current live-demo-sat-enps shows personalization gate, not invitation or rating/comment controls (audit 3) |
| S30 | Wellbeing survey + report | link / Reports | validated questions, heatmap (O: 1534121, 1536452) | survey, heatmap | populated trend/category summary and numeric heatmap (mkt-16); survey input unobserved |
| S31 | Community feed | Community nav | posts/announcements (Pro/Elite) (O: glossary 2002837) | feed, composer | community tab selected, populated divided feed, toolbar, reaction/view controls (mkt-15, mkt-03); composer unobserved |
| S32 | Mobile app home | iOS/Android app | directory, time off, who's out, approvals, SSO, theming (O: store listing) | tab bar, cards | filled Home/counts, directory/fallback, request/comment thread, selected calendar day, active tabs, inbox, running timer, payroll and drawn document signature (ios-01..06, play-01..08); excluded modules remain reference only |
| S33 | Public careers openings | public /careers | candidate discovers jobs; S12-adjacent | branded surface, divided three-column job rows, social links, footer | filled three-opening list; no empty/filter/selected state (live-careers-list) |
| S34 | Public job description | public /careers/464 (observed link) | candidate reads role; S13-adjacent, not internal detail | article, back link, apply/share rail, metadata | populated description, sidebar and links (live-careers-detail); no offer/candidate profile |
| S35 | Public application | apply action on S34; exact URL unproven | candidate intake, upstream of S15; not S17 offer | identity fields, file choosers, screening radios/text, footer actions | blank inputs/unselected radios/no-file; required text/group/resume errors and inline pink messages (live-careers-apply, live-careers-apply-validation); no summary or successful submit |

## Flows

```
F01 Open a job and collect applicants
    S21 hiring settings -> S14 create opening -> S12 list -> S13 boards tab -> post to boards -> S33 public list -> S34 description -> S35 public application (blank/validation observed; submission unproven)
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
| Global nav | live demo rail is simulator chrome, web role variants unverified; mobile bottom Home/My Info/People/Files | mobile active observed; web/collapsed unobserved; current demo selected/expanded/Auto mode are simulator-only | all screens |
| Settings gear entry | admin only | default | all screens |
| Widget card | 6+ widget types, admin-configurable | filled observed; empty/rearranged required, unobserved | S02, S03 |
| Data table | directory, openings, reports | required: empty, filtered, sorted, exported; internal live table unobserved | S06, S12, S23 |
| Filter chip row | standard filters | default, applied, cleared | S06, S12 |
| Tabbed record page | profile, candidate | default tab, deep-linked tab | S08, S15 |
| Pipeline board | column list w/ stage counts, drag | required: empty column, filled, drag-over; live pipeline unobserved | S13 |
| Task list / task tile | IT Setup, Manager, per-employee | unchecked observed (marketing); done/overdue required, unobserved | S19, S20 |
| E-sign block | sign here, date, initials | unsigned, signed, declined | S17, S19 |
| Status pill | candidate stage, task, employment | color-coded states | S12, S13, S20 |
| Modal | snapshot, email preview, confirm | open, loading | S04, S17 |
| Sectioned form | job intake, add employee, access level | default, validation error, dirty | S14, S18, S22 |
| Email template editor | stage emails, offers | default, merge-tag insert | S17, hiring settings |
| Rating scale | eNPS 0–10, survey Likert | survey input unobserved; unselected/selected required | S29, S30 |
| Feed post card | recognition, community | default, with points, with tags | S28, S31 |
| Org chart node | person node, expand | collapsed, expanded | S07 |
| Avatar + photo upload | initials fallback, photo | default, uploaded | S06, S08 |
| Toast / alert | success, error, info | auto-dismiss | all |
| Public careers | job row, description, apply form, file chooser, inline errors | filled list/detail, blank and validation observed; summary/success unproven | S33–S35 |
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

- Audit 3: current demo assets are all gate/previous screen despite reported recapture. Admin settings, access levels, full review setup, packet builder and eNPS form remain unproven. No new S-ID; current public product evidence is S33–S35 only.

- Public application validation errors are now observed (S35); whole-screen empty, permission-denied and loading states remain unobserved. Blank fields, unchecked tasks, selected controls and drawn signatures have older evidence; see design/design-audit.md and design/design-audit-3.md. Help-center files show only repeated plus/minus icons.
- Demo videos (Wistia embeds) not watched.
- Play screenshots play-01..08 and iOS ios-01..06 are saved and visually audited; these native themes do not establish responsive web behaviour.
- Original has **no formal requisition-approval workflow** (I) — the clone should add intake → approval as a deliberate improvement.
- Interview scorecards evidenced by press release only (no help article).
- No public API for surveys, reviews, e-sign, announcements — those models are inferred from help articles and UI.

## Size

Screens 35, flows 12, entities 27. Hard parts: field-level permission engine with preview-as-user, e-signature + auto-filing, candidate self-scheduling with calendar sync, automated stage emails/workflows, anonymous survey integrity, document management with audit trail, report builder + datasets. Size: **L** for the full slice. Recommended: M-sized vertical slice first (Home + People + Hiring pipeline + packet onboarding), then reviews/eNPS, then the rest.
