# Live Chrome browser recon 7 — 2026-10-30

Scope: finish the existing five-module clean-room recon and handoff, not build.
Source: owner's authenticated BambooHR trial with the visible sample-data banner.
Used native Chrome UI through cua_repl. No code/bundle extraction, network replay,
OpenCode-driven browsing, or native binary reverse engineering. The requested
reverse-engineering skill was read; its binary workflow excludes this pure web
recon. Startup POLICY.md and agencyctl.py remain unavailable at the supplied paths.

Original filled Add Employee tab preserved. A separate recon tab was used. No
Save, Send, Invite, Launch, Delete, permission changes, employee creation, signatures,
billing changes, or sample-data clearing. Read-only editors/previews were opened;
Cancel/Done Previewing used. Do not infer persistence from opening an editor.

## Observed additions

| Existing screen | Live observation | Evidence in ../evidence/browser-recon-7/ |
|---|---|---|
| S21 Settings | Current menu provides real routes to Performance, eNPS, Access Levels, Onboarding and Hiring. Lower-left navigation remains current theme. | settings-nav.txt |
| S22 permissions | Employee level > actions menu > Access Level Settings opens /access_levels/employee/edit/640. Name/description; See About Themselves and See on Home; own-information-only notice. Personal tabs and grouped grants, Access Varies, Edit, Edit - Approval Required, No Access; hide-Personal hint when all fields No Access. | employee-level.txt, employee-permissions.png |
| S22 preview | View BambooHR as sample employee opens named preview banner + Done Previewing. Employee nav is Home/My Info/People/Files/Payroll/Recognition; admin Hiring/Reports/Settings absent. Inbox4 vs administrator24. Preview exited and admin list restored. One persona comparison only. | preview-employee.txt/png; access-list.txt/png |
| S25 cycle list | Five Active cycles: Review Cycle, HR Team Semi-Annual, Sales Team Semi-Annual, 60-Day New Hire Review, 90-Day New Hire Reviews. First3 show0 employees, last2 show91. Create/Duplicate/Deactivate/Delete controls, Include Feedback Summaries unchecked. | review-cycles.txt/png |
| S26 admin settings | Goal Users choices None/All Employees/Only Some Employees, All Employees selected. Cascading Goals enabled; Save disabled. This is setup, not a goal-card/detail view. | operator notes; initial live AX observation |
| S29 admin eNPS | Intro video and Let's Get Started lead to setup explicitly Disabled for trial accounts. Intro date, Include Contractors unchecked, sender selector, message, Preview Email; survey send/close timing text, repeat Six months, Preview Survey Email, Save/Cancel. No schedule saved. | enps-intro.txt/png; enps-setup.txt/png |
| S20 task administration | Task groups HR7, Miscellaneous0, IT Setup4, Manager2, New Employee Paperwork9. HR group expands name/assignee/due-date table with before/on/after-hire offsets. This is Settings task administration, not per-employee completion proof. | onboarding-tasks.txt/png; onboarding-expanded.txt/png |
| S20 Add Task | Name, assignee, list(default Miscellaneous), None/On Hire Date/Custom due options, disabled notification timing, description/file chooser, import audience All Employees + Edit; Save Task/Cancel. Cancelled unchanged. | onboarding-task-form.txt/png |
| S36 template administration | Three sample packet templates. California editor: welcome title/message(500char)/video, first-day time/address/contact/instructions, first-day introduction email audience, six questions/required toggles, optional first-day schedule. Tasks added when creating actual packet. | packet-list.txt/png; packet-editor.txt/png |
| S19 template preview | When & Where / New Employee Info / Get Introduced / Tasks to Complete. Employee-info step explicitly cannot accurately preview actual fields; task step explicitly lacks actual tasks at template stage. Intro answers disabled. This is administrator preview, not recipient submission. | packet-preview-welcome.txt/png; packet-preview-info.txt/png; packet-preview-introduced.txt; packet-preview-tasks.txt/png |

## Route/rendering distinction

Initial direct navigation produced blank content for review setup, eNPS and
Onboarding; these are transient observations, not 403/404 evidence. eNPS and
Onboarding recovered through live Settings navigation. Browser console showed
Datadog SDK loaded more than once warnings, not a proven cause. The existing review
editor was attempted directly and through its list link; a changed title/URL while
old content or blank page remained does not prove editor fields. Keep it unverified.
Hiring's rendered Settings menu exposes Candidate Statuses, Candidate Sources,
Email Templates, Interview Templates, Offer Templates, Calendar & Video Access.
Offer-template content and global employee snapshot are still not verified in this
continuation. Earlier 404 captures remain historical evidence, not current route
availability tests.

## Limits and handoff

Read-only recon pass complete with explicit limits. Trial prevents eNPS launch;
recipient survey input/response anonymity, actual email delivery, saved permission
enforcement/403, saved-state persistence, signatures, and post-submit outcomes
remain untested. Preview-as-user and permission editor are now observed, but a
complete permission matrix and multi-role enforcement test are not. No new computed
CSS, responsive, keyboard-focus or assistive-technology validation. Screenshots are
viewport captures; AX snapshots may contain offscreen controls. Sample values are
not evidence of personalization correctness. See START_HERE.md for the
implementation boundary. Final employee-snapshot attempt stopped on a Chrome ScreenCaptureKit capture failure; no snapshot result or field content is claimed. No build, commit or deployment.
