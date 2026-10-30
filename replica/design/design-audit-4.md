# Live-tour design audit 4 — 2026-10-30

Scope: all 38 `live-tour-*.png` inspected in ten labelled contact sheets; six key
frames additionally inspected at native 1440×900. 23 ATS, 8 onboarding, 7 employee
record captures; exact filenames below. Audit 3 remains correct for the older
`live-demo-*` gate files, but its absence-of-shell conclusions no longer describe
this new set. All 38 contain application UI; none is demo chrome only. S36 is the
new administrator packet-setup screen, distinct from recipient/preview S19.

## Mapping and visible states

Each row lists the app header/nav, content and actions or inherits the explicitly
named same layout above. Demo hints, pointer outlines and left-rail current steps
are not product selection or validation. No internal validation error is visible.

| Image | S-ID | What is shown / visible states |
| --- | --- | --- |
| live-tour-ats-00000045-0.png | S34 | Public description; organization header, article left/apply-share/metadata right; filled role text, Apply action; no HR nav. |
| live-tour-ats-00000050-0.png | S12 | Horizontal shell, Hiring selected; Hiring heading + Job Openings raised tab (Candidates, Talent Pools siblings); Add Job Opening left, Draft & Open selected right; filled 5-column table, six rows, candidate/new counts, Open statuses. |
| live-tour-ats-00000070-0.png | S13 | Hiring shell; role header, edit/collaborator actions left, lead/status/open age right; overview + share rail; candidate table headers, status filter Still in the Running; 0 Candidates, illustrated empty result. |
| live-tour-ats-00000080-0.png | S13 | Collaborate dialog replaces shell view; title/close, creator row, collaboration-view select unset, Add People contains partial query; Done bottom-left; no validation. |
| live-tour-ats-00000082-0.png | S13 | Same dialog; one selected collaborator chip with remove x; permission select unset; Done. |
| live-tour-ats-00000086-0.png | S13 | Same dialog; two selected chips, notify-by-email unchecked; Share + Cancel footer; demo Share hint is external chrome. |
| live-tour-ats-00000090-0.png | S13 | Role header/overview/share retained; 1 Candidate (1 New), New Candidate link; populated pale-green candidate table row, New status, unrated stars, applied date. |
| live-tour-ats-00000091-0.png | S15 | Hiring shell; green identity band with fallback avatar/applied date; Candidate Info selected; resume viewer/page controls left; rating/actions/status/contact rail right; five grey stars, New status. |
| live-tour-ats-00000093-0.png | S15 | Notes selected; Comments selected beside History (4), All; blank comment input and illustrated empty comments; contact/rating rail retained, no rating. |
| live-tour-ats-00000095-0.png | S15 | Emails selected; New Email top-left; illustrated empty email area; New status, five grey stars; rail retained. |
| live-tour-ats-00000100-0.png | S15 | Emails empty; four gold stars + one grey (4/5 selected); New status; New Email action remains. |
| live-tour-ats-00000110-0.png | S15 | Emails empty, 4/5; searchable status menu open: New, Active Statuses group, Reviewed, Schedule Phone Screen, Phone Screened, Schedule Interview, Interviewed, Put on Hold; Offer Letter Sent muted, Hire action. |
| live-tour-ats-00000292-0.png | S15 | Emails empty, 4/5; Schedule Phone Screen selected; updated actor/time above select; no scheduling calendar shown. |
| live-tour-ats-00000293-0.png | S15 | Send an Email full-scene composer; title/close, No Template selected, empty subject/body, formatting/Attach Files toolbar; placeholder rail right, Send Email + Cancel bottom-left. |
| live-tour-ats-00000297-0.png | S15 | Composer filled via Phone Screen Request template: subject/body populated; placeholder rail retained, Send Email + Cancel footer. Demo hint points to send; no validation. |
| live-tour-ats-00000300-0.png | S15 | Emails (1) selected with one sent message row, recipient/subject/Status On its way; 4/5 and Schedule Phone Screen; optional status-change comment box with Save Comment/No Comment in rail. |
| live-tour-ats-00000305-0.png | S15 | Emails (1) retained; status menu open, Schedule Phone Screen current; options include Reviewing qualifications, Phone Screen Scheduled, Interview Scheduled, Schedule Follow-Up Interview, Create Offer Letter, Hire. |
| live-tour-ats-00000310-0.png | S17 | Hiring shell, breadcrumb/Create Offer heading; candidate + filled email; narrow Offer Details form left, wide rich-text letter right; dates/job/pay unset, weekly selected, placeholders in prose; attached PDF e-sign switch enabled. |
| live-tour-ats-00000390-0.png | S17 | Create Offer filled: expiration/start dates, Senior Recruiter, $120,000 USD/year, weekly/contact; matching merged letter and PDF attachment; lower actions outside capture. |
| live-tour-ats-00000400-0.png | S17 | Standalone offer preview: dark recipient header, Edit Offer + Send Offer Letter upper-right; white letter/document attachment, filled merged values; no global HR nav. |
| live-tour-ats-00000410-0.png | S17 | Candidate shell/identity/rail; Offer selected before Candidate Info, Notes, Emails (1); Revise Offer/View Offer left, Cancel Offer right; Sent completed, Viewed/ Signed grey; Hire Angela action; filled offer details/letter, Offer Sent status. |
| live-tour-ats-00000420-0.png | S17 | Same Offer view; Sent and Viewed green/date-stamped, Signed grey; Emails (2); rating now 3/5. No signature completion evidenced. |
| live-tour-ats-00000430-0.png | S18 | Hire confirmation dialog: success/confetti, Angela got the job; close-opening/remove-public-posting checkbox checked; Add New Employee primary and Don’t Hire Angela secondary; add-employee form absent. |
| live-tour-emprec-00000000-0.png | S08 | People shell selected; circular photo overlaps identity band/vitals rail; Personal selected; Social Links blank, Basic Information mixed filled/blank, masked SSN; Customize Fields right; Request a Change/gear + Previous/Next upper-right. |
| live-tour-emprec-00000010-0.png | S08 | Job selected; Employment Status table empty with update action; Job Information, Compensation, Bonus tables populated; section update links right; vitals/manager/direct reports rail. |
| live-tour-emprec-00000020-0.png | S08 | Update Employment Status dialog, shell hidden; employee strip, effective date filled, employment status/tax type unset, comment blank; Save + Cancel bottom-left, close top-right; no validation. |
| live-tour-emprec-00000023-0.png | S08 | Same dialog; employment-status searchable dropdown open, Full Time highlighted; Contractor, Full or Part Time shifts, Furloughed, Internship, Part Time, Temporary, Terminated, Add Item visible; selection/save not yet shown. |
| live-tour-emprec-00000027-0.png | S08 | Job selected; Employment Status now populated with effective date, Full Time, W2; other filled tables retained; Benefits outlined by demo hint only (not selected). |
| live-tour-emprec-00000040-0.png | S08 | Benefits selected; Benefit Overview empty (no plans), Dependents empty; Add Benefit Group/Add Dependent right; Benefit History Show collapsed; photo/vitals/header retained. Reference-only excluded module. |
| live-tour-emprec-00000050-0.png | S08 | Change Benefit Group dialog; employee strip, group select unset, explanatory text; Save + Cancel bottom-left, close top-right; demo prompt, no validation. Reference only. |
| live-tour-onboard-00000000-0.png | S20 | People profile shell; Onboarding heading, neutral 5-step packet progress; Create New Hire Packet/Skip This for Now; task panel empty with clipboard + Import From Template/Add a Task, gear right. |
| live-tour-onboard-00000003-0.png | S36 | New Hire Packet administrator setup: Home/My Info/People/Hiring/Reports/Files/Payroll nav variant; title + Customize New Hire Packet Fields right; employee/email filled, template unset; choose-template empty prompt. |
| live-tour-onboard-00000007-0.png | S36 | Same packet setup, template dropdown open: HR Sydney Australia, HR Lindon United States, Sales Utah United States, Test Packet; no template selection captured in this frame. |
| live-tour-onboard-00000010-0.png | S36 | Scrolled filled packet editor; hire date/time/location/contact/manager/instructions filled; Introduce to Team pale-green panel, send-email checked, All Employees selected, six question rows with reorder/remove/required controls + Add Question; payroll options unchecked; tasks section begins. |
| live-tour-onboard-00000015-0.png | S19 | Packet preview with dark recipient header, Edit Packet/Send New Hire Packet top-right; When & Where, New Employee Info current, Get Introduced, Tasks to Complete horizontal steps; mixed filled/blank Personal/Address fields, Add Photo placeholder. Preview is not proof of recipient submission. |
| live-tour-onboard-00000060-0.png | S20 | Profile Onboarding filled; packet progress first four checked/date-stamped, final New Hire Tasks Completed grey; View Packet/Resend/Cancel upper-right; grouped unchecked tasks, Add Task/gear; no all-done claim. |
| live-tour-onboard-00000061-0.png | S20 | Scrolled task list; New Hire Paperwork/Manager/IT/Culture Orientation/HR groups; background-check task and New Hire Orientation checked/struck with completion attribution; Office Tour unchecked under demo pointer. |
| live-tour-onboard-00000062-0.png | S20 | Scrolled task list; Office Tour now checked/struck with completion attribution beside New Hire Orientation in pale-green HR group; many other tasks unchecked; trash actions right; packet final step still incomplete. |

## Shell, geometry and colour extraction

All dimensions below are **capture raster pixels**, not recovered CSS. Scene zoom,
letterboxing and scrolling vary between steps; do not normalize them against the
1440px browser width. Shared coordinate anchor: ats-00000050, emprec-00000000 and
ats-00000310 render the app x298–1440 (1142 wide). First has app y136–811; latter
two start y49 and extend below viewport. The same header measures 60px in these
anchors. A 60px raster measurement is defensible; source CSS/DPR is unknown.

- Demo chrome: top y0–49, instruction/video/zoom rail x8–298, dark letterbox
  outside the app; chapter rail and Auto toggle are excluded. Grey callouts and
  bright outlines attached to actions are tour guidance, not app focus/errors.
- Product global header: organization logo left (~x327–488); horizontal nav
  Home → My Info → People → Hiring → Reports → Files. Packet editor adds Payroll
  after Files. Search pill right, followed by inbox/tray, help ?, settings gear,
  green account/brand control. Selected Hiring or People has pale background and
  darker green bold text; thin lime rule under header. No product left global
  sidebar. A top-right gear is observed; the previous bottom-left claim is wrong
  for this shell. Admin-only visibility is **not established**: one scripted persona,
  no role switching. Payroll/nav/tab differences cannot prove permission rules.
- Openings page: heading strip y197–303 (~106 high), title x372/y231, raised tabs
  below. Main x372–1366 (~994 wide), 74px side insets. Toolbar y321–345, table
  header y356–389 (~33), rows ~55–57 high. Columns: Candidates, Job Opening,
  Hiring Lead, Created On, Status; title/location and date/relative age stack.
  Thin horizontal separators, no card per row, no Kanban board. Table toolbar
  action left, selected status filter/export-like icon right; no search box in
  this particular table toolbar (global search exists).
- Job detail: role title/location + Edit/Collaborators left, lead/status/age right;
  overview below with get-job-link/social card right; candidate count/New Candidate
  left and status filter right above table. Candidate Info, Status, Rating,
  Applied, Last Email columns. Illustrated empty filtered-result at step70;
  filled pale-green New row at90. Green row tint alone does not establish checkbox
  selection: the row checkbox is unchecked. Pipeline board remains unobserved.
- Candidate: green gradient identity band ~145 high (y109–254), breadcrumb,
  fallback avatar, sans name/applied date. Candidate Info → Notes → Emails; Offer
  prepended after sending. White raised active tab. Main x372–1118 (~746), pale
  contact rail x1144–1440 (~296), ~26 gap. Rating/action/status card x1157–1366
  (~209), overlaps band and rail; contact fields below divided by rules. Star
  states 0/5, 4/5 and later 3/5; grey is unrated, gold selected. Resume is embedded
  document with page controls, not a generic card grid. Notes/Emails have actual
  empty illustrations/messages and relevant input/New Email action.
- Employee: same band with circular photo x386–533 (~147 diameter) overlapping
  lower edge; sans name, request-change + gear and previous/next upper-right.
  emprec tabs Personal → Job → Time Off → Benefits → Training → Documents → Notes
  → Performance → More. Onboard profile variant includes Assets/Emergency and
  different tab order: record order is not universal. Rail x371–549 (~178);
  main x573–1366 (~793), gap24. Vitals, manager/direct reports in pale rail;
  Social Links/Basic Information groups in main, mixed field widths and 4-name
  field row. Job/Benefits use compact section tables and right-aligned update/add
  links. Employment Status, benefit plans and dependents show section-level empty
  text; this is not a wholly empty profile.
- Packet/task page: profile grid retained. Five connected progress circles with
  text/date; first four complete, final neutral in step60. Grouped flat checkbox
  rows, ~36px at step62, compact grey category labels. Completion uses checked
  green box + struck label + attribution; HR completion block #e3ebd9. Background
  check completed row is neutral, so do not tint every completed row. Add Task and
  gear top-right, trash controls right of completed rows. Tasks remaining are
  unchecked; no overdue styling observed.
- Packet administrator editor: title/employee/email/template top, select-empty
  prompt until template choice; filled arrival grid and instructions, optional
  introduction panel with checked send toggle, audience and six reorderable-looking
  question rows. Handles are observed; actual drag behaviour is not. Payroll
  unchecked options are reference only. Separate preview has dark header, step
  rail and mixed blank/filled recipient fields. Preview Send is a visible action,
  not proof of email delivery or completed recipient form.
- Email composer: full-scene editor, narrow placeholder rail right, toolbar,
  template select and subject/body; bottom-left Send/Cancel. Empty and template-
  populated states, then sent entry observed. No send-failure or validation proof.
- Offer editor: filled email header then narrow details column x372–594 (~222),
  rich-text letter x611 onward (~17 gap). Dates/selects/pay/contact fields drive
  displayed placeholders/merged text. Attached file tile/e-sign switch below.
  Preview switches to dark header, Edit/Send upper-right and paper letter. Offer
  tracking shows Sent then Viewed completed, Signed pending; no signature receipt.
- Dialogs: isolated white small-radius panels on light scene, usually ~450px
  wide; title above panel/close upper-right, employee/creator strip, stacked fields,
  thin green footer rule and Save/Done/Share + Cancel bottom-left. Captures do not
  prove a dark translucent overlay or a universal max-width480. Do not copy the
  demo canvas as a modal backdrop. Hire confirmation adds success/confetti and a
  checked close-opening control; add form still absent.
- Typography: internal identity/page headings are **sans**, unlike serif headings
  in newer public careers/marketing. Candidate name ~26, section title ~20, body
  and controls ~11–13 raster high; text-size estimates are not exact font metrics.
  Lato appears in rich-text toolbar; this does not prove global font identity.
  Keep configurable fallback families; serif heading role scoped to careers/
  marketing. Internal controls ~24–26 high, square/small radius ~0–3, active tabs
  ~3; search is pill. Do not apply pill40 buttons or radius24 cards universally.
  Content gaps ~16/24, section spacing ~24–32; no single source spacing scale proven.
- Flat RGB counts on native crops: header/table header #e8e8e8; record rail,
  dialog canvas/task framing #f2f2f2; panel #ffffff; section icon/title #486f00;
  completed HR block #e3ebd9. Rule has a #e0e0e0 core plus resampling shades.
  Identity band is a horizontal olive/lime gradient, not a solid dark masthead;
  exact endpoints and source gradient CSS are unproven. Bright source greens,
  grey links/text and faint borders are not automatically accessible roles.
  Preserve careers warm #f3f2ef and #1e6e46 separately from this older internal
  theme. Gold stars and green checks also have shape/text state signals.

## Corrections made

- components.md: replace no-shell and no-pipeline-evidence conflations with observed
  horizontal shell and table; correct sans internal headings, circular profile
  photo, rectangular controls, record tab variants; add collaboration dialog,
  searchable status menu, star rating, composer/placeholder rail, offer editor/
  preview/tracker, administrator packet builder and task completion states.
- recon.md: update S08/S12/S13/S15/S17/S18/S19/S20/S34 states and gear placement;
  add S36 administrator packet setup. Benefits captures remain S08 reference-only,
  preserving the excluded scope. No newly inferred ATS/job-create screen.
- tokens.json: add scoped internal surfaces/geometry/radii, sampled source notes,
  accessible internal title/completion roles; preserve neutral white-label default
  and optional careers-green palette. Generic dimensions stay explicit defaults;
  new `internal-*` measurements avoid redefining public-careers/mobile geometry.
  Regenerate CSS including compatibility aliases. No brand assets copied.

## Remaining unproven

- Admin settings hub: groups, pages, dimensions, settings behaviour (gear visible only).
- Access levels: permission matrix, preview-as-user, all role-specific visibility.
- Review-cycle setup: no new live evidence; prior marketing fragment only.
- eNPS admin: survey setup, anonymity controls, audience, launch/results; recipient
  rating/comment form also absent from this tour set.
- Report builder: dataset/fields/filters/export; reports nav label is not a builder.
- Org chart: nodes, layout, expansion, zoom and permissions.
- Snapshot popup: search results/employee preview; header search alone is insufficient.
- Offer templates: library, picker/admin editor; merged Create Offer letter is
  observed, reusable offer-template management is not. Email template selection
  is observed separately.
- Announcements: composer, audience, publication; no new live evidence.
- Permission-denied: no blocked screen/action or masked-per-role comparison.
- Employee Documents: not captured despite visible tab/left demo chapter.
- New/edit job wizard, interview calendar, Add Employee form, signature completion,
  errors/recovery, loading, hover/focus/keyboard, responsive breakpoints, delivery
  behaviour, draggable rows and source CSS/font identity remain unproven.

## Verification

Policy and agency status tool absent at supplied absolute paths. 38 filename rows
match 38 input files, with 38 distinct decoded image hashes. `contrast.py` absent
from workspace and installed skill trees; temporary `/tmp/contrast.py` implements
WCAG relative luminance with 4.5:1 text and 3:1 UI thresholds, validates both default
and merged optional palettes. Results appended below after execution. Only docs,
JSON and generated CSS changed; no build or commit.

Final checks: default **50 pairs, 0 failing AA**; optional merged careers-green
palette **50 pairs, 0 failing AA**. Minimum ratio 3.089:1 is a UI boundary pair;
normal text pairs meet 4.5:1. Initial border-input #838b95 failed on internal-nav
and internal-completed (~2.81:1); corrected to #7c848e globally and regenerated CSS.
All canonical JSON values match CSS; compatibility references resolve, no duplicate
root declarations or duplicate contrast pairs. 38 mapping rows/38 distinct decoded
hashes and 36 unique recon IDs verified. `git diff --check` passed. No app build,
source-CSS extraction or runtime accessibility check performed; AA claim covers
only declared token combinations, not screenshots or an implemented product.
