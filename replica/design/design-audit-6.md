# Logged-in trial design audit 6 — 2026-10-30

Label: `bamboo-clone/design-eyes-6`. Scope: all 20 supplied `live-{name}.png`
listed below, visually inspected as labelled sheets and enlarged crops of long
screens. Read alongside audit 4, recon, components and tokens. These are supplied
logged-in free-trial captures with sample data, not the public simulator. Audit 4
remains evidence for its older horizontal/sans tour theme, not the current shell.
No app code, build, network action, submission or commit performed.

## Current shell and content grid

Shell A: a full-width dark trial bar above the application, countdown/signup text
left and eye icon + “Viewing sample data” right. This right-hand sample-data strip
is part of the same top bar, not simulator chrome or an empty-state notice.
At 1200px the bar is y0–48; left global nav starts x0/y48, width224. Header starts
x224/y48, measured 960×75 (ends x1184; do not stretch this measurement to viewport
width or claim responsive behaviour). Organization mark left; Search, inbox badge
24, outlined Ask action right. No horizontal Home→Files nav or top-right settings
gear in this theme. White nav and header, warm light content canvas, rounded white
panels with subtle bottom edges/shadows. Canvas begins around x224/y123; standard
page titles x256/y155 imply 32px content inset. Tables may overflow horizontally;
full-page captures are not proof that every column fits the viewport.

Global nav order top→bottom: Home, My Info, People, Hiring, Reports, Files,
Payroll, Compensation, Time & Attendance, Benefits, Recognition, Ecosystem,
Global Employment. Lower group: Resources, Settings, My Account, Collapse.
Settings is a lower-left nav item; My Account has a silhouette. Active global
items have a pale rounded background, green bold label/icon; local settings/report
menus use filled green selection. Excluded modules are shell reference only.
Nav sticky/fixed behaviour and role-based visibility cannot be inferred from
full-page screenshots or one administrator persona.

Content patterns: dashboard welcome/actions → two unequal introduction cards →
narrow summary/wide activity columns → direct-report grid → three-column widgets;
directory/chart use a single wide workspace; profile uses a dark identity band,
left vitals rail and stacked main panels; wizard uses steps left/form right;
settings and reports use secondary nav left/content right; recognition uses feed
left/suggestions right. Sample chrome is inherited by every Shell A row below.

## Capture mapping and states

Names below are exact `replica/screens/live-{name}.png` basenames. “A” inherits
all shell details above; selected nav, page tabs, content and actions are explicit.
A 404 means the requested screen was not reached, not permission denied.

| Name / size | S-ID | Shell, content, selected state and visible actions |
| --- | --- | --- |
| home / 1200×4223 | S02 | A, Home current. Filled greeting/fallback avatar, New dropdown + Edit. Tour and Invite Team panels with Start Tour/Add Team Members. Narrow My Time/Time Off/My Stuff beside filled activity list. Direct Reports selected beside Headcount/Turnover; populated photo grid. Lower three-column Celebrations, Cascading Goals, Who’s Out, Company Links, Recognition, Onboarding, welcome, time-off chart, holidays, training, location donut, pay-raise count and request cards. Section-level absence (“no one scheduled”, no overdue group) coexists with filled dashboard; not a blank dashboard. Payroll/time/benefit tiles reference only. |
| people / 1200×1132 | S07 | A, People current, **Org Chart selected**, List/Directory siblings. Org Chart (90), New Employee, quick directory link. Jump-to-employee input blank, depth 1, collapse/filter/export and zoom controls. Three connected visible person cards: executive above HR administrator and finance executive, photos/fallback and subordinate counts. No node expansion/zoom/export outcome proved. Filename is not a list. |
| people-empty / 1200×5457 | S06 | A, People current, **List selected**, Directory/Org Chart siblings. New Employee/quick access, filters All Employees + Showing Active, count91. Filled alphabetical employee table with photo, employee#, Last Name/First Name, title, location, employment status; photos and silhouette fallbacks. Footer 1–50 of91, page1 selected, page2/Next. URL query `search=zzzzzz` did not yield a visible empty result. No no-results message. |
| profile / 1200×3084 | S08 | A, People current. Solid dark-green band, large rounded-square silhouette, white serif identity/title; 6 of91 + Previous/Next, Request a Change + overflow. Personal→**Job selected**→Time Off→Documents→More. Vitals, out-until notice, manager/direct reports left; Job heading/Customize Layout right. Hire date filled, ethnicity unset, EEO category filled; four veteran checkboxes mixed checked/unchecked. Employment Status, Job Information, Compensation histories populated; Potential Bonus percentage10 and amount blank; Bonus section empty, Commission and Equity populated, Add Entry actions. No save or edit result. |
| hiring / 1200×1299 | S12 | A, Hiring current. **Job Openings selected**, Candidates/Talent Pools siblings; View Careers Website/Get Embed Code. New Job Opening, blank Search openings, Draft & Open filter, download-like action. Six populated rows: candidate counts/new counts, title/location, lead, created date, five Open/one Draft; summary 5 of50 openings open. Source table exceeds viewport bounds. |
| hiring-job / 1200×1132 | S13 | A, no clearly highlighted global item in this capture. Breadcrumb includes Previous: Videographer; actual title IT Security Engineer. Lead/status/Open37 Days right. **Candidates selected**, Job Description/Job Boards siblings; chart/collaboration/share/settings icon controls. 4 Candidates (0 New), Still in the Running, action menus/New Candidate. Four filled rows, unchecked boxes, mixed status, 3–5 gold stars, applied-date sort arrow and last-email/Received/Reply Now states. No Kanban. |
| hiring-add / 1200×1847 | S14 | A, no clear global selection. Create Job Opening/back/Cancel; step rail **Job Information current**, Application Details/Job Pipeline/Automated Emails pending. Next Step, Save & Finish Later and Cancel. Right white form: Posting Title blank required, Draft selected, Hiring Lead/Department/Employment Type/Minimum Experience unset, compensation placeholder, unselected On Site/Hybrid/Remote tiles, blank description rich text toolbar, blank internal code. Four steps visible; do not invent a fifth Job Boards step from older marketing. |
| new-employee / 1200×4005 | S18 | A dimmed behind **Heads Up modal**. New Employee/Customize Add Employee Form, send-new-hire-packet unchecked. Modal warns new data is lost when trial demo data is cleared; close, I’ll Hold Off, Add Anyway. Underlying blank/mixed-default Personal, Address (United States), Compensation, Contact, Job, Employment Status, Job Information panels; eligibility integration/Install reference and self-service Allow Access vs **No Access selected**. Cancel/Save bar visible at viewport boundary in stitched capture; fixed behaviour unproved. No actual employee created. |
| reports / 1200×1660 | S23 list | A, Reports current. Reports/New Report; secondary **Recent selected**, Dashboards, Standard Reports, Benchmarks, Custom Reports, Signed Documents. Favorites tiles Headcount/Employee Turnover/Additions & Terminations/Time Off Used. Filled Recent table grouped Today/Last30 days with title/last-viewed/owner. Not an insights chart dashboard; export unproved. |
| report-builder / 1200×1680 | S23 builder | A, no clear global selection. New Report, empty report name with green outline (focus-like appearance, keyboard focus not proved). Choose Fields: blank search; collapsed Personal/Job/Time Off/Benefits/Training/Assets/Notes/Emergency groups left; Selected Fields contains Last name, First name. Lower Filter Results section partly crossed by action bar; Sort Results default name A to Z; Group by None. Cancel/Save visible. No executed report, chosen filter, dataset picker, saved report or export evidenced. |
| settings / 1200×1899 | S21 | A, Settings current. Two-column workspace: long category menu **Account selected**; white Account panel with Account Info, trial-end notice, My Subscription, add-ons/job-posting/file-storage allowances, available upgrades, data-center location. Manage Subscription/Learn More links. Settings categories include Access Levels/Employee Fields/Approvals/Apps and module groups; no changed subscription or billing action evidenced. |
| access-levels / 1200×2193 | S22 list | A, Settings current; settings secondary **Access Levels selected**. Purple dismissible former-employee feature notice + setup action. Inner Levels rail **All (91) selected**, Full Admin(1), employee regional levels, manager levels with zero counts; add dropdown. Right All(91), blank search and filled Name/Level/Last Login table, Name ascending, footer1–25 of91. Right columns clipped/overflowing. This is a level/user listing, **not a permission matrix/editor or preview-as-user**. |
| files / 1200×1337 | S11 | A, Files current. Files/Upload File; folder rail All Files, **Signature Templates selected**, four named folder categories/counts. Filled nine-row file list, unchecked select-all/row checkboxes, Name A–Z sort, icon actions, PDF icons, filename/add attribution/size; footer1–9 of9/page1. No upload or signature sent. |
| announcements / 1200×1132 | **S39** | A, no clear global selection. Back, Announcements, New Announcement. White table with Title/Author/Status/Date, six filled rows: published and draft, author cells mixed blank/filled. Distinct administrative listing, not S31 community feed; composer/publication not captured. |
| recognition / 1200×7469 | S28 | A, Recognition current. My Points100/Redeem Points and Points to Give50/Give Recognition. **All selected**, Received/Given inactive; Division/Department/Location filters unset. Long populated feed: sender→one/multiple recipients, date,10-point badge, serif message, core-value tags, reaction pills/counts, avatar stack/View Comments, Comment; some posts include images. Right Recognition Suggestions with editable-looking message boxes, AI suggestion label,10 points/Edit/Send/dismiss, Thought-Starters. No composer opened, sent recognition, redeemed points or comment expansion proved. |
| orgchart / 1200×1132 | S07 attempted; 404 | **No global shell visible**. Warm canvas, red Page Not Found (404 error) strip, white illustrated error panel and Go Home. Metrics have only a zero-size button. Successful chart is instead live-people. |
| performance / 1440×900 | S24 attempted; 404 | A at wider capture, no clear global selection. Red404 strip/illustrated panel/Go Home. No Performance controls, review cycle or goals evidenced by this file. |
| onboarding / 1440×900 | S20 attempted; 404 | A at wider capture, no clear global selection. Same404 state; no tasks/packet UI in this file. Older audit4 S20 evidence remains valid separately. |
| satisfaction / 1440×900 | S29-related attempted destination; 404 | A at wider capture, no clear global selection. Same404 state; not an eNPS recipient scale, admin setup or results. Destination purpose inferred from filename only; URL absent from metrics. |
| snapshot / 1440×4080 | S04 search state over S02 | A, Home current; search contains `a`, results dropdown anchored beneath top search overlays dashboard. Employees group five named photo/fallback results, first grey-highlighted; Job Openings group four entries with Open/On Hold/Filled and age; Reports group one result. No selected employee snapshot card, detailed popup, no-results search or result-navigation outcome. |

## Computed measurements and tokens

`/tmp/live-metrics.json` contains 16 entries (home through orgchart); no entries
for performance/onboarding/satisfaction/snapshot. All 16 URLs and every raw selector
measurement are preserved under `_measurements.trial.screens` in tokens.json so
transient `/tmp` evidence is not lost. These are supplied DOM rectangles/computed
styles, distinct from audit4 raster estimates and from screenshot pixel colors.

| Role / observation | Measured value | Token treatment |
| --- | --- | --- |
| header | x224 y48 w960 h75 | trial-header-height75, sidebar-width224, banner-height48; not legacy internal-header60 |
| nav | x0 y48 w224 h1084; padding top16/17.8653/21.125/21.1707, x12, bottom24 | stable x/bottom padding tokens; no fixed nav-height or fractional animated top-padding token |
| search input | x806 y68 w187 h35, padding8, radius0, transparent | trial-search width187/height35/padding8; zero input radius is selector box, not the enclosing visible pill |
| ordinary inherited text | Inter,sans-serif 15px/400, #48413f | font.sans Inter first; trial-body15/400; text role updated, source raster text#3f3937 recorded separately |
| page h1 | Fields,serif42px/700, #287411; h52 rectangle | trial-page42/700, trial-heading; heading serif fallback, no licensed Fields file; **line-height unmeasured** |
| page/profile title | Fields,serif34px/700; profile white | trial-title34/700; on-accent on trial-identity |
| promo / section h2 | 32px/600 green;24px/600 #38312f | trial-promo/trial-section and trial-heading-secondary |
| first button | x958,y−38 or−56,w42,h32,radius100,padding0 12; transparent, white14px/600 | trial-button14/600 only; offscreen element is not primary-button geometry/fill evidence |
| main | either document-size1200-wide box at0,0 or x1082,y65,w102,h40 | rejected as content container measurement; use screenshot grid and validated header/nav anchors |
| table | 15px/400 Inter, transparent/radius0 | per-screen rectangles below; no row-height inferred from total table height |
| orgchart button | x0 y0 w0 h0,bg#2e2e2e,radius50% | zero-size match excluded from usable design tokens |

Table rectangles x/y/w/h (CSS px): people-empty276/397/984/4932;
profile532/1177/600/156; hiring276/381/944/814;
hiring-job276/459/894/605; reports570/535/615/265;
access-levels812/638/665/1443; files592/364/535/820;
announcements276/274/975/476. These are element bounds, not universal grid widths;
several extend beyond1200, consistent with clipping/overflow in supplied imagery.

Raster flat colors: canvas#f5f5f2; white panels; identity/action green#246912;
banner#3f3937; warm table/subpanel#f3f2ef. Computed title#287411/text#48413f differ
from dominant raster source title/action#246912/text#3f3937. Preserve provenance;
do not claim exact pixel/CSS equivalence or invent an explanation for the mismatch.
New trial color roles stay scoped; neutral slate accent and optional careers-green
override retained. Historical internal-* roles still represent the older tour.
Source faint borders remain decorative; accessible border-input retained.

CSS regenerated from JSON with existing compatibility aliases and @theme mappings,
including new trial roles. No line-height invented from bounding-box height; new
trial type entries deliberately omit line. Generic spacing/radii/shadows/motion
and breakpoints remain defaults where computed evidence is absent.

Validation: `python3 .../replica-design/contrast.py replica/design/tokens.json`
passed **62 pairs, 0 failing AA** (normal text4.5:1, UI3:1). Trial heading/canvas
5.35:1, input boundary/canvas3.47:1, white/identity6.76:1. This checks declared role
pairs, not every source pixel, source opacity state or rendered interaction.

## Corrections applied

- recon: authenticated supplied evidence added; current shell supersedes generic
  no-shell claims, not historical audits. S02/S04/S06/S07/S08/S11–14/S18/S21–24/
  S28/S29/S31 states clarified; S39 announcement administration added. S23 builder
  remains a variant of existing screen ID rather than unnecessary new ID.
- components: current left shell/trial chrome, serif heading scope, square avatar,
  pill actions/card grids, search results versus snapshot, filled tables, list
  versus permission editor, warning modal, four-step job wizard, new employee form,
  report field chooser, signature-template list, recognition and404 specified.
- tokens: measured roles and scoped geometry/type added; computed source font
  retained as provenance, open/system fallback used. Historical tour raster
  dimensions retained without applying them to the new trial shell.

## Unproven / limits

- **Permission-denied:** none captured.404 does not establish403, plan restriction,
  inaccessible module, wrong role or missing feature. No permission-masked comparison.
- **Preview-as-user:** no preview control, switched identity, grant editor/matrix,
  saved access level or effective field permissions captured. All91 is a listing.
- **Real versus sample data:** sample strip visible; no clearing, real-only record,
  persistence or migration comparison. Mixed personal-looking values do not prove
  real production data. Modal explicitly warns of data loss on sample-data clearing;
  this audit does not execute it.
- **Post-submit flows:** no create/save result for job, employee, report, file,
  announcement, recognition, subscription or access level. Buttons do not prove
  delivery, permissions, success, validation, redirect or recovery. Older tour
  offer/email/packet transitions remain separately scoped to audit4.
- **Empty search:** no authenticated no-results screen; `people-empty` is populated,
  snapshot query`a` has results. Empty Bonus panel or no-overdue message is not an
  empty directory. Search result employee snapshot itself remains unobserved.
- Performance/onboarding/satisfaction screenshots add only404 states; review setup,
  eNPS admin/recipient input and current-theme onboarding remain unproved. Org chart
  itself is proved by `people`, not the direct orgchart URL.
- No hover, keyboard focus/operation, modal focus trap, loading, disabled control
  semantics, drag/drop, responsive breakpoints, fixed chrome or interaction timing
  validated. Green outline and first highlighted search row do not prove keyboard focus.
- Startup policy path and original agencyctl path missing. Catalog policy copy read;
  catalog status command failed while attempting to initialize state outside writable
  roots (`PermissionError: Operation not permitted`). No recorded active next action
  recovered; no external state created. Work confined to requested docs/tokens.

Final consistency checks:20 capture rows;39 unique recon S-IDs;16 metric entries
match supplied JSON exactly; canonical JSON/CSS values match and all prior CSS
aliases resolve. Default and merged optional careers palettes each pass62 pairs,
zero AA failures. `git diff --check` passes. Five requested docs/token files changed;
20 supplied untracked PNGs retained untouched. No build or commit.
