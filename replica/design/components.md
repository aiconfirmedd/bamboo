# Bamboo component specs

Every component from the recon list, plus the primitives they are built from.
Tokens refer to `tokens.json` roles — never raw hex. Observed evidence is enumerated in design-audit.md and design-audit-2.md; design-audit-4.md governs live-tour assets; audit 3 governs the older live-demo gate files. Required states are implementation requirements, not screenshot proof. Keyboard and screen-reader behaviour is part of each spec.

## Primitives

```
Button
  variants  primary (accent bg), secondary (surface bg, border), ghost (transparent), danger (danger bg)
  sizes     sm 32px, md 40px, lg 48px; padding 12/16/24 horizontal
  states    default, hover (accent-hover), active (behaviour unobserved), focus-visible (2px focus-ring, offset 2), disabled (50% opacity, no pointer), loading (spinner replaces icon, label kept for SR)
  tokens    bg accent, text on-accent, radius pill for primary/secondary actions, font sm/600, motion fast
  a11y      real <button>, aria-busy while loading, aria-disabled not just visual
  used on   all screens

IconButton
  variants  ghost, secondary; sizes 32/40 square
  states    as Button; tooltip on hover/focus
  a11y      aria-label required, 44px hit area on touch
  used on   S06, S08, S13, S15, S23

Input / Textarea
  states    default (border-input), hover (border text-muted), focus (2px focus-ring), error (danger border + message), disabled, readonly
  tokens    bg bg, border border-input, radius sm, font sm, padding 8/12
  a11y      <label for> always, aria-describedby for help/error, aria-invalid on error
  used on   S05, S14, S18, S22, S29

Select / Combobox
  states    as Input; open listbox, active option, no-results
  a11y      native <select> where possible; combobox pattern with aria-expanded, arrow keys, Esc
  used on   S06 filters, S14, S22, S26 alignment

Checkbox / Radio / Toggle
  states    default, hover, focus-visible, checked, disabled, indeterminate (checkbox)
  tokens    accent checked fill, 20px box, radius sm
  a11y      real inputs, fieldset+legend for groups, 44px label hit area
  used on   S09, S19, S22, S25

DatePicker
  states    default, open calendar, selected, range, disabled day, error
  a11y      grid keyboard nav, month/year labels, typed input fallback
  used on   S14, S25, S27

FileUpload
  states    idle, drag-over, uploading (progress), done, error (retry), size/type rejected
  a11y      button + hidden input, announce progress, list uploaded files with remove
  used on   S10, S11, S15 (resume), S19, S35; public idle and required-file error observed

Badge / StatusPill
  variants  neutral, accent, success, warning, danger, muted
  tokens    tint bg + matching text role, radius pill, font xs/600
  a11y      text inside, never colour-only
  used on   S12, S13, S20, S23

ProgressBar / Stepper
  states    determinate, indeterminate, complete
  a11y      role=progressbar with valuenow, step list as ordered list with current step
  used on   S19, S20

EmptyState
  parts     icon, title, one-line body, primary action, secondary link
  a11y      heading level 3, action is a real button
  used on   every list screen (S06, S10, S11, S12, S13, S23, S28, S31)

Pagination
  states    first/last disabled, current page, page-size select
  a11y      nav landmark, aria-current=page
  used on   S06, S12, S23

Tooltip
  states    hidden, visible on hover/focus, dismiss on Esc
  a11y      aria-describedby, never the only source of a label
  used on   icon buttons, truncated cells

Toast
  variants  success, error, info; auto-dismiss 5s, pause on hover
  a11y      role=status (polite) / role=alert (assertive for errors), close button
  used on   all mutations

Skeleton
  used on   tables, cards, record pages while loading; respects reduced motion
```

## Composites

```
GlobalNav / MobileTabBar
  web       horizontal logo + Home, My Info, People, Hiring, Reports, Files; packet editor adds Payroll; search/inbox/help/settings/account right. Hiring/People active observed; role visibility unverified (audit 4)
  mobile    bottom order Home, My Info, People, Files; iOS white background with active accent icon/text; Android solid accent with white icons/text
  header    mobile accent bar, centred iOS title / left Android title; back/close at left on detail screens; contextual actions right
  states    active tab observed; drawer, condensed-on-scroll and role gating unobserved
  a11y      nav landmark, aria-current=page, labelled icons, skip link
  used on   S08, S12, S13, S15, S17, S20, S36, S32 mobile

WidgetCard
  variants  welcome, celebrations, company-links, whos-out, my-stuff, whats-happening, insights-metric
  states    empty (required, unobserved), filled (observed), loading, error, admin-configured hidden
  tokens    bg surface-raised, border border, radius lg, shadow card, padding 16
  a11y      h2 per widget, admin edit affordance labelled "Configure <widget>"
  used on   S02, S03

DataTable
  states    empty and filled (observed S13), filled S12 and mixed empty/filled S08 section tables; selected status filter observed; sorted/selected rows/loading/permission-masked cells required, unobserved
  tokens    row height, border-b border, header font xs/600 text-muted, hover surface
  a11y      <table> with caption, th scope, sort buttons with aria-sort, row action menu
  used on   S06, S12, S23

FilterChipRow
  states    default, applied (accent-tint), removable, overflow "+N more"
  a11y      group label, chips are buttons with aria-pressed
  used on   S06, S12

TabbedRecordPage
  states    default tab, deep-linked tab, overflow "More" menu, permission-hidden tabs
  a11y      tablist/tab/tabpanel, arrow-key nav, aria-selected
  used on   S08, S15

PipelineBoard
  states    empty column (required), filled column (required; audit 4 shows a candidate table, no Kanban screenshot), drag-over, collapsed column, stage count
  tokens    column bg surface, card bg bg + shadow card, radius md
  a11y      columns as lists with headings; drag has keyboard alternative (move-to menu)
  used on   S13

TaskList / TaskTile
  states    todo, done (strikethrough + check), overdue (warning), assigned-to-me, assigned-to-other
  tokens    flat grouped list, internal-task-row-height; checked + strike + attribution observed, HR completion tint internal-completed; unchecked rows and neutral completed background-check row observed; overdue styling unproven
  a11y      checkbox per task, assignee in text, progress announced
  used on   S19, S20

ESignBlock
  states    unsigned, signing, signature drawn (observed), signed receipt with hash + timestamp (required, unobserved), declined, expired
  tokens    border dashed border-input, radius md, signed = success-tint + lock icon
  a11y      sign action is a button, receipt text readable, document link opens new tab
  used on   S17, S19

Modal / Dialog
  states    open, loading, confirm, destructive
  tokens    overlay rgba(16,24,40,.4), panel bg bg, radius lg, shadow pop, max-w 480
  a11y      focus trap, Esc, aria-modal, labelled by title, return focus on close
  used on   S04, S17, deletes

SectionedForm
  states    default, dirty, validation error per field, submit loading, success
  tokens    section heading lg/600, field gap 16, section gap 32
  a11y      fieldset+legend per section, linked error summary required for implementation; source careers form shows inline errors only
  used on   S14, S18, S22

EmailTemplateEditor
  states    default, merge-tag insert, preview, dirty
  a11y      textarea + tag buttons, preview in dialog
  used on   hiring settings, S17

RatingScale (eNPS 0–10, Likert)
  states    unselected, hover, selected, submitted
  tokens    pill buttons 40px, selected = accent bg on-accent
  a11y      radiogroup, arrow keys, scale ends labelled
  used on   S29, S30

FeedPostCard
  states    default, with points, with core-value tag, edited, deleted placeholder
  a11y      article landmark, author + time readable, actions labelled
  used on   S28, S31

OrgChartNode
  states    collapsed, expanded, current employee, vacant
  a11y      tree pattern, expand buttons labelled
  used on   S07

Avatar / PhotoUpload
  states    initials fallback, photo, uploading, error
  a11y      alt = person name, upload button labelled
  used on   S06, S08

Heatmap
  states    empty, populated, cell focus
  a11y      table fallback with values, legend
  used on   S30

GoalCard / MilestoneList
  states    in-progress, done, aligned (parent link), private, overdue
  a11y      progress text, milestone checkboxes, alignment link labelled
  used on   S26
```

## Rules

- Focus ring: 2px `focus-ring`, offset 2, on every interactive element.
- Minimum touch target 44×44 on mobile.
- Colour is never the only signal (pills carry text, errors carry icons + text).
- Reduced motion: transitions collapse to 0.01ms.
- Every list screen ships an empty state with a real next action.

## Visual audit corrections (2026-10-30)

`design-audit.md` is the evidence ledger. Marketing green backgrounds, offset lime
frames, arrows, stars, phone hardware and promotional headlines are presentation,
not application components. Never ship source assets/copy/branding. Sizes in this older marketing section are implementation estimates unless explicitly called raster coordinates; later live careers measurements are scoped separately.

- Typography (historical marketing only; internal live tour uses sans): record titles and section/chart headings use a bold serif;
  controls, labels and body use sans. Use `font.heading` for that job; never infer
  the proprietary face from a raster. Mobile uses sans throughout the app.
- Buttons: observed web save/next actions are full-width pills at the bottom of a
  wizard rail; secondary finish-later immediately below. Profile request/overflow
  and edit actions sit top-right. Fields have small rounded corners, white fill,
  thin grey borders; labels above. Selected tab is a raised light rectangle,
  not a global 2px underline rule.
- Record header (mkt-01): dark branded masthead; large overlapping square avatar
  left, serif name and subtitle, right-side actions. Below, tabs in order Personal,
  Job, Time off, Documents, Timesheets, Performance, Emergency, Training, More.
  Left vitals/manager rail; right section title + Edit fields above white form.
  Four name fields across, later rows 1–3 fields; not a directory table.
- Wizard (mkt-06,13): standalone title strip above a narrow left step rail and
  wider right form. Completed check circles, current light row, incomplete hollow
  circle; all three observed. Job steps: Job Information, Application Details,
  Job Pipeline, Automated Emails, Job Boards. Review steps: People, Feedback,
  Assessments, Review & Launch. Checked job-board tiles and enabled review toggle
  observed; no dropdown-open or validation state shown.
- Home/community (mkt-03,15): compact summary cards left, wide tabbed community
  list right. Toolbar separate from divided feed rows; thumbnail, title, byline,
  metadata, reaction/view controls. Not independent large cards for each post.
- Tasks (mkt-10): single white list panel; heading left, Add Task and gear right;
  category labels then unchecked rows; assignee and due date right. Audit 4 adds checked/struck rows and green HR completion block; overdue and tile grid remain unobserved.
- Signature (mkt-07): document review plus Add Signature editor with Draw/Type,
  drawn mark, clear/cancel and save/apply control. No visible receipt/hash/expiry.
- Analytics (mkt-02,08,12,16): bar/donut panels; KPI strip and horizontal funnel;
  performance value-versus-engagement scatterplot with avatars and employee list;
  wellbeing trend chart, category summary and numeric heatmap respectively.
  Heatmap needs legible numbers and legend, not colour alone. No goal/milestone
  UI is evidenced by mkt-12.
- Mobile: single-column divided lists, compact headers and bottom tabs, not web
  card grids. Directory photo and initials/silhouette fallbacks, selected calendar
  date, request comment thread with fixed bottom approval actions, unread inbox
  tab, and filled signature form are observed. Empty contact slots in play-03
  are field-level absence with add links, not an empty-screen state.

Geometry policy: `space` remains the proposed 4px rhythm; field radius ~6 raster
pixels in mkt-01; its inner form corners ~12px. Large composite panels elsewhere
have ~24–32 raster-pixel corners. `md=12`, `lg=24` are estimates for separate panel
sizes, not evidence of one CSS scale. Generic header 56, row 44, sidebar widths, type sizes,
shadows, breakpoint values and motion are defaults awaiting a live app check.

## Live careers corrections (2026-10-30)

These scoped specs override generic geometry for S33–S35 only. The 17 simulator
captures do not establish the logged-in app shell: all 17 show the personalization gate. Audit 2's invitation observation is superseded by current pixels. Never use its dark left rail, top chapters, hints,
video, font zoom or Auto mode as application nav or permission evidence.
Historical absence claim superseded for live-tour assets by audit 4: horizontal header/nav and tables observed; role visibility and Kanban board remain unproven.
For these older files no live completed/current product wizard steps are shown; prior marketing evidence
for S14/S25 remains valid. Simulator current/expanded steps belong to demo chrome.

PublicCareersShell (S33–S35)
  White outer canvas; warm surface container inset ~32 raster px, small rounded
  outer corners. Organization mark upper-left. List has three social links top-right;
  detail/apply has privacy link upper-right. No employee/admin nav or login shown.
  List at 1200px: white panel x64..1136, y172..652, ~16px corners, subtle bottom shadow;
  inset 20px, title serif ~24px, body sans ~14–16px. Footer near page bottom.
  Detail/apply at 1440px: main x78..970 (~892), rail x1002..1362 (~360), gap 32;
  panels begin y172. Main inset ~20, outer inset 32, inner inset ~46 from surface.
  Careers inner-inset token 32 is the list layout; detail/apply differ as above.
  White panels use radius-careers-panel; generic lg=24 remains a marketing/default role.
  Title uses heading family, copy/labels sans; exact family/weights unproven.
  Surface #f3f2ef, panel white, text #3f3937, muted #6c6765, divider #bfbab7;
  source heading/action #1e6e46, links #0e46cb. Neutral accent remains default.

JobListRow (S33; observed filled, three rows)
  One divided list, no board, table header, search, stage counts or status pills.
  Three columns: linked title + department; work mode icon/text + location;
  department icon/text + employment type. Native raster rows ~127px high.
  Separators inset 20px; row content inset another ~16px. No selected/empty state seen.
  a11y: list semantics, descriptive title links; icons decorative with adjacent text.

JobDetail (S34)
  Main white article: back-to-openings link, serif title, metadata line, divider,
  long sectioned prose and bullet lists. Rail white card: full-width pill primary
  apply action, divider, job-link field, three outlined social icon pills.
  Below card on surface: location, department, employment type, compensation,
  each separated by rules. No candidate profile, internal pipeline or offer UI.
  Footer legal links left, platform attribution right. Sticky rail unproven.
  a11y: article headings and lists, labelled sharing actions and link field.

ApplyForm (S35)
  Retains detail title/back link and metadata rail; rail primary becomes outlined
  return-to-description pill. First/last name paired; email and phone separate rows,
  narrower phone. Labels above; required asterisk. Controls ~40 raster px high,
  ~6px corners, white fill. Sections divided horizontally: identity, attachments,
  screening/consent. Questions stack with vertical radio groups or short inputs;
  no select-open, checked option, entered answer or successful submission observed.
  Full-width dark footer (#312b29): attribution left, cancel + white submit pill
  right. It is at document bottom; fixed/sticky behaviour unproven.
  a11y: labels, fieldset/legend, native radios, required semantics; preserve input
  after validation. Employer questions/copy are reference only, write original copy.

PublicFileUpload (S35)
  Cover letter optional, resume required; two stacked rows. Outlined pill chooser
  with upload icon, adjacent document icon + empty filename status. Observed idle
  and required-resume error only. No dropzone, progress, chosen filename or remove
  action proven. Those generic FileUpload states remain requirements if implemented.
  a11y: labelled file input, required state and error association; announce filename.

ValidationSummary / InlineValidation (S35 validation variant)
  Observed: all required blank fields/groups flagged together. Red icon + label,
  red input border; pale pink error blocks below fields. Radio-group errors span
  main content width, text-input messages fit content. Required resume gets its own
  error; optional cover letter remains neutral. Form grows 2628→3408 raster px.
  No top-level error summary is visible. Add a linked summary as an accessibility
  requirement, explicitly unobserved. Use danger text on danger-tint; source bright
  red #d91425 is observational, darker #a40b17 token preserves AA normal text.
  a11y: aria-invalid, aria-describedby, focus summary after failed submit; error
  icon/text prevents colour-only signaling. Successful correction/focus unproven.

Token scope: added careers layout roles are native raster measurements, not universal
CSS dimensions. Generic header/row/sidebar defaults remain separate from audit 4 internal raster tokens.
Border-input retains accessible #7c848e rather than copying faint source borders.
No source shadows, proprietary fonts, role gating or responsive behaviour recovered.

## Audit 3 overrides — older live-demo assets (2026-10-30)

All 17 older live-demo captures show Get Started > Personalize, including sat-enps. No
invitation or internal shell is evidenced by those older files; audit 4 adds shell evidence from 38 live-tour files. Gate email `na@` in perf is
partial input, not a product validation state; Auto mode on in sat-report is
simulator state. Current/expanded simulator chapters are not product steppers.
See design-audit-3.md for every filename and exact duplicate group.

PublicShareRail (S34–S35, observed)
  Main/rail gap32, rail360 at 1440px; panel padding20 and radius16 raster px.
  Filled apply pill switches to outlined description-return pill on S35.
  Link field with displayed URL; readonly/editable behaviour unproven.
  Three outlined social icon pills, not square global IconButtons; accessible
  names required. Metadata is below card on surface with decorative dividers.

Public form states override generic Checkbox/Radio/Toggle dimensions: unselected
round radios only; 20px checkbox geometry is an implementation default. Input,
radio and FileUpload use also includes S35. No checked public answer or filled
application is observed. Inline validation is observed; summary is required only.
Panel padding20 and detail inset46 are native raster measures scoped to careers;
list inner inset32 remains separate. Source divider is decorative; border-input
is the accessible control boundary. Public type sizes are approximate raster
estimates, not measured font CSS. No new internal component dimensions inferred.


## Audit 4 — live internal application overrides

These supersede historical/generic specs where contradicted. All dimensions are
raster measurements at the anchor scale documented in design-audit-4.md. Required
interaction/accessibility behaviours above are not claimed observed. Source-green
UI is optional likeness; use accessible semantic tokens for implementation.

InternalShell / RecordHeader (S08, S12, S13, S15, S17, S20, S36)
  60px header, logo left, horizontal nav then right search/inbox/help/gear/account.
  Nav order Home/My Info/People/Hiring/Reports/Files; packet editor adds Payroll.
  Active item has pale background + bold coloured text, thin lime header rule.
  Header position/order observed; admin-only gating unproven. No left global nav.
  Serif heading default is NOT applied internally: page/name/section titles sans.
  Green gradient identity band ~145px, white raised small-radius active tab.
  Employee circular ~147px photo overlaps band and 178px vitals/manager rail;
  main ~793px with gap24. Request a Change/gear and record pager upper-right.
  Candidate fallback round icon smaller; main746, right contact rail296, gap26;
  overlapping rating/status card209. Exact source gradient/fonts unproven.
  Employee tabs vary: emprec Personal/Job/Time Off/Benefits/Training/Documents/
  Notes/Performance/More; onboarding variant adds Assets/Emergency. Do not freeze
  marketing tab order or infer hidden tabs from permissions.

InternalButton / InternalField / InternalTab
  Controls rectangular ~0–3px radius, compact ~24–26px capture height; search pill.
  Filled green Save/Send; outlined green contextual actions; Cancel blue text.
  40px pill controls and radius24 cards are generic/public defaults, not internal
  likeness. Do not reduce required accessible hit areas to match raster height.
  White fields, thin grey border, label above, compact date icon/select arrow;
  field widths vary, not equal columns everywhere. Blank/filled, checked/unchecked,
  select closed/open observed; no internal validation/disabled behaviour proven.
  Demo hint outlines are excluded from app focus state. Source faint borders are
  decorative; accessible border-input remains implementation boundary role.

OpeningTable / CandidateTable (S12/S13)
  Openings heading/tabs strip above white content. Add Job Opening left;
  Draft & Open filter plus small export-like action right. Header33, rows~56.
  Columns Candidates/Job Opening/Hiring Lead/Created On/Status, divided rows.
  Detail has overview + share rail, edit/collaborators left and lead/status right.
  Candidate toolbar count/New Candidate left, Still in the Running filter right;
  columns Candidate Info/Status/Rating/Applied/Last Email. 0-result illustration
  and one New filled row observed. Pale row tint is not checkbox selection.
  PipelineBoard remains a separate required, unobserved layout.

CollaboratorDialog (S13)
  Title/close; creator row; collaboration-view select; Add People text area with
  query then one/two removable collaborator chips; Notify people via email unchecked.
  Done transitions to Share/Cancel state. Footer action left under green rule.
  No permission denial or saved-share result captured. Dialog often450px wide;
  source backdrop opacity/focus trap unproven, implement accessible dialog pattern.

StarRating / CandidateStatusMenu (S15)
  Five-star 0/5, 4/5, later3/5 observed; gold filled/grey unfilled. Expose numeric
  label and keyboard-operable radio choices; colour alone insufficient.
  Status select/searchable open list, group labels, lifecycle options, Create
  Offer Letter/Hire actions. New and Schedule Phone Screen selected, Offer Sent
  after sending. Exact option set differs by step; no universal enum inferred.
  Optional comment box with Save Comment/No Comment observed after status change.

CandidateNotes / EmailComposer (S15)
  Candidate Info/Notes/Emails raised active tabs; Notes has Comments/History/All
  subnav, empty input and illustrated empty comments. Emails empty illustration
  plus New Email; filled state Emails(1), then(2), sent row with delivery text.
  Composer replaces shell: title/close, template dropdown, Attach Files/formatting,
  subject/body, placeholder list/filter right; Send Email/Cancel bottom-left.
  No Template blank and Phone Screen Request filled states observed; do not treat
  email templates as evidence for offer template administration.

OfferEditor / OfferPreview / OfferTracker (S17)
  Candidate/email header; ~222px details form left, letter editor right, gap~17.
  Blank dates/job/pay + highlighted merge placeholders; then populated details/
  merged prose. PDF tile includes e-sign switch enabled. Preview dark header with
  recipient/avatar, Edit Offer/Send Offer Letter upper-right and paper body.
  Tracker tab Offer prepends Candidate Info/Notes/Emails; Revise/View left,
  Cancel Offer right, Hire action beside Sent/Viewed/Signed connected steps.
  Sent then Viewed complete/date-stamped, Signed pending. No signed receipt.
  Offer-template picker/library remains unobserved. Hire confirmation S18 has
  checked close-opening control and Add New Employee/Don’t Hire actions; no form.

PacketBuilder (S36; administrator setup, distinct from S19 recipient/preview)
  New Hire Packet heading, Customize Fields right; employee/email, template
  unset + empty prompt then dropdown open; filled arrival/contact/instructions.
  Checked introduction email option, audience select, question rows with handles,
  required/remove controls, Add Question; unchecked payroll reference options.
  Source captures do not prove drag/drop, custom-field editor or payroll behaviour.
  Preview S19 uses dark recipient header, Edit/Send upper-right; When & Where /
  New Employee Info(current) / Get Introduced / Tasks to Complete steps; mixed
  filled/blank information and Add Photo placeholder. Sending action observed,
  recipient submission and delivery unproven.

PacketProgress / OnboardingTaskList (S20)
  Initial five neutral circles, Create New Hire Packet/Skip; task panel empty
  clipboard + Import From Template/Add a Task. Filled progress first4 checked
  and dated; final New Hire Tasks Completed pending. View Packet/Resend/Cancel
  above progress right. Grouped checkbox list, Add Task/gear upper-right, rows~36.
  New Hire Paperwork/Manager/IT/Culture Orientation/HR groups; checked/strike/
  completion attribution and trash action; HR completed block pale green, completed
  background-check row neutral. Office Tour unchecked→checked in steps61→62.
  No overdue state or fully completed packet; do not infer all-done from tour rail.

RecordSectionTable / EmploymentStatusDialog (S08)
  Job: Employment Status empty→filled Full Time/W2; Job Information/Compensation/
  Bonus populated, update links right. Dialog employee strip, effective date,
  status/tax selects, comment, Save/Cancel; searchable status open with Full Time
  highlight. Benefits empty plans/dependents + add links; change-group dialog
  unset select. Benefits reference only, excluded from build scope.
  Personal mixed filled/blank and masked fields; Documents still unobserved.

Internal colour roles: internal-nav #e8e8e8, internal-surface #f2f2f2,
internal-completed #e3ebd9, internal-heading #486f00; panels white. Source light
rule #e0e0e0 decorative only. Source gradient endpoints, stars' exact gold, text
antialiasing and source control boundary contrast not recovered. See audit 4 for
measurement provenance; geometry and font defaults elsewhere are not source CSS.
