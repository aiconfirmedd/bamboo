# Bamboo component specs

Every component from the recon list, plus the primitives they are built from.
Tokens refer to `tokens.json` roles — never raw hex. Observed evidence is enumerated in design-audit.md and design-audit-2.md; design-audit-4.md governs live-tour assets; audit 3 governs the older live-demo gate files; design-audit-5.md governs public prospect S37/S38. design-audit-6.md governs the current logged-in trial theme (left nav/serif). Historical tour specs below are scoped to audit4 and must not override audit6. Required states are implementation requirements, not screenshot proof. Keyboard and screen-reader behaviour is part of each spec.

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
  web       current: left nav and trial/sample bar (Audit6 specs below); logo/search/inbox/Ask header. Historical audit4 tour: horizontal Home/My Info/People/Hiring/Reports/Files, packet Payroll; search/help/settings/account right. Role visibility unverified
  mobile    bottom order Home, My Info, People, Files; iOS white background with active accent icon/text; Android solid accent with white icons/text
  header    mobile accent bar, centred iOS title / left Android title; back/close at left on detail screens; contextual actions right
  states    active nav/tabs observed; Collapse action visible in current sidebar, collapsed result/drawer/scroll behaviour/role gating unobserved
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

- Typography (marketing and current audit6 trial serif; historical audit4 tour uses sans): record titles and section/chart headings use a bold serif;
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

Historical tour colour roles: internal-nav #e8e8e8, internal-surface #f2f2f2,
internal-completed #e3ebd9, internal-heading #486f00; panels white. Source light
rule #e0e0e0 decorative only. Source gradient endpoints, stars' exact gold, text
antialiasing and source control boundary contrast not recovered. See audit 4 for
measurement provenance; geometry and font defaults elsewhere are not source CSS.


## Audit 5 — public prospect funnel (S37–S38)

Separate from the internal shell, careers intake and simulator gate. Geometry below
is native capture raster at width1440, not recovered CSS or responsive rules.
Use existing neutral accent/text/boundary roles; source green is observational.

ProspectDemoWizard (S37)
  White left pane width560, green promotional right pane; logo above three-node
  stepper and serif question. Step1: six unchecked tiles in three columns/two rows,
  row-major Hiring & Onboarding, HR Data & Reporting, Payroll & Time, Benefits
  Administration, Employee Experience, Performance Management. Each tile has a
  checkbox top-left, illustration and centered label. No required marker visible.
  Step2 replaces tiles with one floating-label Employee Count select, 76-150 shown;
  first node checked, second current, third pending. Options/open select unobserved.
  Full-width pill Next below content (x54–506); not a final submit. No country,
  consent, contact fields or validation messages visible in either step. Bright
  rectangular question outline in step2 is visible but does not establish an error
  or keyboard-focus state. No checked tile state captured.
  tokens: layout demo-pane-width, demo-action-height; accent/on-accent; radius pill.
  a11y requirements: labelled native checkboxes/fieldset, select label, ordered
  steps with aria-current; no invented required rule or error message as evidence.

ProspectSignupForm (S38)
  Centered white card width600 over blurred promotional app image under a white
  logo strip. Not proof of an authenticated dashboard or dismissible modal. No
  close/back action visible. Three-node stepper and green serif heading above.
  Four paired rows, left→right then top→bottom: First Name*, Last Name*; Work
  Email*, Job Title*; Company Name*, Phone Number*; Employee Count*, Country*.
  All eight filled in live-signup.png; count76-150 and United States selected.
  Floating labels interrupt thin field borders. Closed selects have right chevrons;
  options, country search, defaults and country-dependent behaviour unobserved.
  Consent is prose authorizing product/service/event email and phone contact with
  an inline Privacy Policy link; no checkbox or separate opt-in control visible.
  Full-width Create Account below consent; no-credit-card/automatic-trial-end note
  beneath. No password, password confirmation, terms checkbox or error visible.
  tokens: signup-card-width, prospect-input-height, signup-action-height; existing
  bg/text/text-muted/border-input/accent/on-accent/link, serif heading/sans controls.
  a11y requirements: associated labels, required semantics, email/tel autocomplete,
  native selects; error association/preserve values and focus handling if invalid.
  Empty, invalid, focus, disabled and retry states required if implemented, unobserved.

TrialPreparationTracker (S38 variant)
  Same page/card location replaces form with preparation heading and short wait
  text. Vertical three-item tracker: Creating your account active, Generating demo
  data pending, Adding the final touches pending. Later frame: Account created
  checked, Generating demo data active, final touches still pending. Top stepper
  first node complete, second current, third pending. No submit/retry action visible.
  This is partial progress, not a final ready-account confirmation. A marketing
  trust line below is not a status message. No determinate percentage observed.
  a11y requirements: aria-busy during preparation, polite live text for changed
  milestones, ordered steps; check + status text prevents colour-only completion.

ProspectMarketingShell (S38)
  Below hero: feature accordion with Integrations & Compatibility expanded, other
  categories collapsed, integration image; trial checklist laptop image; dark green
  CTA band and legal footer. Accordion interaction and CTA destination unproven.
  Images of app/checklist are promotional, not additional observed product screens.
  Use original assets/copy. No mobile layout or sticky/fixed behaviour established.


## Audit 6 — current logged-in trial components (overrides generic/current-web claims)

Source: all20 supplied captures; exact S-ID/state ledger and measurement caveats in
[design-audit-6.md](design-audit-6.md). Audit4 section is historical tour evidence:
its horizontal nav, sans headings, circular photo, gradient and compact rectangular
controls do not specify this current theme. Public careers/prospect/mobile remain
separately scoped. Blank, loading, error, focus and disabled behaviours below are
requirements unless explicitly called observed.

TrialShell / TrialSampleBanner (S02/S04/S06–08/S11–14/S18/S21–23/S28/S39)
  parts     full-width dark countdown/signup bar; right eye + Viewing sample data;
            white left global nav and header logo/search/inbox24/Ask. Nav order:
            Home, My Info, People, Hiring, Reports, Files, Payroll, Compensation,
            Time & Attendance, Benefits, Recognition, Ecosystem, Global Employment;
            lower Resources, Settings, My Account, Collapse. Excluded modules reference only.
  states    active pale rounded nav row/green label; Settings lower-left, not header gear.
            Sample strip is trial product chrome, not simulator guidance. Orgchart404
            is shell-less; other three404 captures retain shell. No role-switch proof.
  tokens    trial-sidebar-width224, trial-banner-height48, trial-header-height75,
            trial-page-inset32; bg/trial-surface/trial-banner/on-trial-banner.
            Inter body15/400; serif trial-page42/700, trial-title34/700, section24/600.
            Source Fields is provenance only; use font.trial-heading serif fallback.
  a11y      nav landmark/current page/skip link; label sample-data state in text;
            do not make clearing sample data an unconfirmed implicit navigation effect.
            Fixed/sticky chrome and responsive collapse are unproved.

TrialButton / TrialField / TrialTabs / TrialPanel
  observed  filled/outlined pill actions, rounded white cards, small-radius form
            controls; tabs underlined for directory/chart/hiring/recognition, raised
            Job tab on profile. Generic or historical-tour dimensions are not universal.
            Blank/filled fields, closed selects, mixed checkboxes and selected tiles.
  tokens    accent/on-accent for white-label actions; trial-button14/600 measured;
            search selector187×35/padding8 (enclosing pill distinct). Border-input
            retained for3:1 boundaries; radius/shadow defaults remain estimates.
            Offscreen first-button42×32/radius100 is not a page action measurement.
  a11y      labelled native controls, required markers/semantics, focus-ring and
            aria-selected/current; observed green outline does not prove keyboard focus.

TrialDashboard (S02)
  observed  greeting/fallback + New/Edit; tour and invite cards; narrow summaries /
            wide activity list; Direct Reports current photo grid; lower three-column
            widget cards including goals, out, links, recognition, onboarding, charts,
            training/holidays/counts. Filled and section-level no-scheduled/no-overdue states.
  tokens    surface-raised, trial-surface, text, trial-heading; trial body/title roles.
  a11y      headings per widget, lists/table alternatives for charts; no data solely
            in color. Widget rearrangement/edit/persistence and New menu unproved.

DirectoryTable / OrgChartWorkspace (S06/S07)
  observed  List selected in people-empty:91 employees, Active/All Employees filters,
            filled photo/number/name/title/location/status rows, page1/1–50 of91.
            No empty result despite URL query. people: Org Chart current (90), executive
            and two subordinate nodes, links/counts, depth1/jump/zoom/export controls.
  states    photos/fallbacks, local tab selected, unselected row controls; node
            expansion/export/search-no-results/filter changes not demonstrated.
  a11y      real table with scoped headings/sort labels and pagination; chart tree
            with labelled expand/zoom, keyboard alternative and accessible hierarchy.
            A visible control alone does not establish keyboard/drag behaviour.

TrialRecord / JobSectionTables (S08)
  observed  solid dark identity band, large rounded-square fallback, white serif name;
            Request a Change/overflow/pager; Personal→Job(current)→Time Off→Documents→More.
            Vitals/manager/direct reports left; main stacked white Job sections.
            Mixed fields/veteran checks; populated historical employment/job/pay,
            Commission/Equity rows, Potential Bonus10%/blank amount, Bonus section empty.
            Customize Layout/Add Entry visible; no field-save or Documents content.
  tokens    trial-identity/on-accent, trial-title, trial-surface/text/border-input.
  a11y      labelled tabs/fields/check groups; histories as tables, caption per section;
            empty Bonus text if implemented, not an empty-record illustration.

TrialHiringList / CandidateTable / JobWizard (S12/S13/S14)
  observed  Job Openings current, search blank, Draft & Open; six filled openings,
            five Open/one Draft, counts/new counts. Candidate detail Candidates current,
            four filled rows, Still in the Running, unchecked selections, varied stars/
            status/last-email Received and Reply Now; applied sort arrow. No board.
            Wizard four steps: Job Information current; Application Details, Job Pipeline,
            Automated Emails pending. Blank title/lead/type, Draft default, unset selects,
            unselected location tiles, blank rich description/internal code; Next Step,
            Save & Finish Later/Cancel. Job Boards fifth step belongs to older evidence.
  a11y      table selection/sort labels, numeric star alternatives, step list/current,
            required fields/fieldset location choices, editor toolbar names; retain input
            on validation. Post-next/post-save and validation states remain unproved.

NewEmployeeForm / SampleDataWarning (S18)
  observed  actual sectioned Personal/Address/Compensation/Contact/Job/Employment Status/
            Job Information form, country United States, packet unchecked, No Access
            selected beside Allow Access. Integration install is excluded reference.
            Heads Up modal overlays/dims form: sample-data-clearing loss warning;
            close, Hold Off and Add Anyway. Cancel/Save behind modal. Stitched full-page
            crop does not prove footer position. This is not permission-denied.
  tokens    bg/trial-surface/text/trial-heading/accent/on-accent, shadow pop as default;
            source backdrop opacity and dialog CSS dimensions not measured.
  a11y      alertdialog, named title/description, focus containment/return and labelled
            close; safe cancel path and explicit proceed. Do not discard validation or
            warn only after saving. No click outcome, saved employee or persistence proof.

ReportsLibrary / ReportFieldChooser (S23 variants)
  observed  Recent selected in secondary nav; Favorites tiles + grouped filled report
            table. New Report empty name/search; Browse Fields collapsed categories and
            Selected Fields Last name/First name. Lower filter section, name A–Z sorting,
            Group by None; Cancel/Save bar. No dataset picker/result/export shown.
  tokens    trial-surface/surface-raised/text/link/trial heading/type, border-input.
  a11y      labelled report name/search, expand buttons with expanded state, keyboard
            field-add/remove/reorder alternatives if implemented; labels for sort/filter.
            Saved, run, exported, dirty/error/loading and expanded group states unproved.

SettingsAccount / AccessLevelListing (S21/S22)
  observed  Settings lower nav active. Long settings menu Account or Access Levels current;
            account/trial/subscription/allowance/upgrades cards. Access page adds purple
            dismissible former-employee notice/setup action, Levels rail All91 selected,
            admin/regional employee/manager counts, add dropdown and search; filled users
            Name/Level/Last Login, name ascending,1–25 of91, right overflow/clipping.
  a11y      distinct navigation labels for global/settings/levels, accessible horizontal
            overflow and table headers; notice dismiss has name. Purple is observational,
            not a new semantic success/error role. Editor matrix, changed grants and
            Preview-as-user are unproved; listing must not be described as editor proof.

SignatureTemplateFiles (S11)
  observed  Signature Templates current beside All Files/folders/counts; nine PDF rows,
            unchecked selection/select-all, Name A–Z, attribution/size, page1/1–9 of9;
            Upload File and icon actions. No picker/upload/download/sign outcome.
  a11y      checkbox labels include filename; file type and size in text, named icon
            actions, selection count and pagination; no checkbox implied checked by tint.

AnnouncementAdministration (S39; separate from S31 feed)
  observed  Back/New Announcement above six-row Title/Author/Status/Date table;
            draft/published, author blank/filled. No composer/audience/publish outcome.
  tokens    trial heading/body, bg/trial-surface/text/link.
  a11y      table caption/scoped headers, meaningful title links/status text; composer
            validation/focus/loading/publish feedback required only if implemented.

RecognitionWorkspace (S28)
  observed  All current (Received/Given inactive), My Points100/Points to Give50,
            Redeem/Give Recognition, unset Division/Department/Location filters;
            filled feed sender→recipients/date/10-point badge/serif message/core-value
            tags, reaction counts/avatar stacks/comments/images. Suggestions rail has
            AI-labelled message boxes, Edit/Send/dismiss and Thought-Starters.
  a11y      article headings/named recipients, point/status text, image alternatives,
            labelled reaction/count and comment actions; distinguish AI suggestion.
            Composer, sending, redemption, comments expanded and reaction changes unproved.

GlobalSearchResults (S04 over S02)
  observed  query a, dropdown Employees (five results, first grey-highlighted),
            Job Openings (four/status+age), Reports (one); photo/fallback. Anchored to
            header search over dashboard, not a modal employee snapshot card.
  a11y      combobox/listbox/group semantics with labelled options and active descendant,
            arrow/Enter/Esc support, results announcement; keyboard operation unverified.
            Employee detail preview, zero results and navigation result unproved.

RouteNotFound (S07/S20/S24/S29 attempted destinations)
  observed  red Page Not Found404 strip, neutral illustration/panel, Go Home;
            orgchart shell-less, others with trial shell. No permission-denied state.
  tokens    danger/on-accent for alert, bg/trial-surface/text for panel; original art.
  a11y      error heading + alert text and real home link; do not conflate404 with403
            or claim entitlement/role denial. Recovery navigation untested.

## Audit 7 current-trial component evidence

See design-audit-7.md. Current permission editor: grouped Personal-field grants with mixed Access Varies, Edit, Edit - Approval Required, No Access; Self/Home sections and all-No-Access hides-tab hint. Named preview banner/Done Previewing and reduced employee navigation are observed. No field enforcement claim.

Current task administration: collapsible groups with counts; Name/Assigned To/Due Date; Add Task modal with assignee/list/relative date/description/file/import audience. Cancel leaves draft unsaved. Packet template editor covers welcome/video, arrival/contact, introduction questions/required toggles and first-day schedule. Preview has four steps but explicitly withholds actual employee fields/tasks; retain placeholder semantics rather than inventing fields.

eNPS setup has explicit trial-disabled copy, intro email controls, survey timing/cadence and preview controls. Treat trial gate separately from role denial or route errors. Goals settings are observed; goal cards and complete review editor remain separate unverified variants.
