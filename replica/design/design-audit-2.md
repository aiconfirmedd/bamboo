# Live screenshot design audit 2 — 2026-10-30

Scope: all **21** `live-*.png` files (17 demo + 4 careers), visually inspected as
images; request said 20. Read after design-audit.md (48 older images). No browsing,
source code, private API or login used. Native pixel sampling used only for flat
colours/geometry. Screenshots remain reference assets; no branding/copy shipped.

## Critical result and mapping convention

**16 of 17 simulator filenames mismatch their visible content.** They all retain
Get Started > Personalize: name/company prefilled, email blank, email hint open,
Log In action. This is a simulator gate, **no product S-ID**, and is not S01:
there is no password/SSO authentication UI. Requested S-ID below describes only
filename intent. Different presenter video frames do not imply product navigation.
The seventeenth shows an introductory survey email, S29-adjacent, not survey input.
No logged-in application shell has become proven by these captures.

## Findings (one row per image)

| Image | Actual S-ID / observation | Correction | Confidence |
| --- | --- | --- | --- |
| live-demo-ats-add-job.png | No product S-ID: personalization gate; filled name/company, blank email, hint; filename implies S14 (job intake). | Flag mismatch; do not promote job intake or app-shell states to observed. | high actual content; intended mapping tentative |
| live-demo-ats-candidate.png | No product S-ID: personalization gate; filled name/company, blank email, hint; filename implies S15 (candidate profile). | Flag mismatch; do not promote candidate profile or app-shell states to observed. | high actual content; intended mapping tentative |
| live-demo-ats-careers-site.png | No product S-ID: personalization gate; filled name/company, blank email, hint; filename implies S33 (public careers list). | Flag mismatch; do not promote public careers list or app-shell states to observed. | high actual content; intended mapping tentative |
| live-demo-ats-collaborators.png | No product S-ID: personalization gate; filled name/company, blank email, hint; filename implies S13-adjacent (hiring collaborators). | Flag mismatch; do not promote hiring collaborators or app-shell states to observed. | high actual content; intended mapping tentative |
| live-demo-dashboard.png | No product S-ID: personalization gate; filled name/company, blank email, hint; filename implies S02 (dashboard). | Flag mismatch; do not promote dashboard or app-shell states to observed. | high actual content; intended mapping tentative |
| live-demo-emp-documents.png | No product S-ID: personalization gate; filled name/company, blank email, hint; filename implies S10 (employee documents). | Flag mismatch; do not promote employee documents or app-shell states to observed. | high actual content; intended mapping tentative |
| live-demo-emp-record.png | No product S-ID: personalization gate; filled name/company, blank email, hint; filename implies S08 (employee record). | Flag mismatch; do not promote employee record or app-shell states to observed. | high actual content; intended mapping tentative |
| live-demo-emp-status.png | No product S-ID: personalization gate; filled name/company, blank email, hint; filename implies S08 Job tab (employment status). | Flag mismatch; do not promote employment status or app-shell states to observed. | high actual content; intended mapping tentative |
| live-demo-onb-packet.png | No product S-ID: personalization gate; filled name/company, blank email, hint; filename implies S19 / packet builder (onboarding packet). | Flag mismatch; do not promote onboarding packet or app-shell states to observed. | high actual content; intended mapping tentative |
| live-demo-onb-tasks.png | No product S-ID: personalization gate; filled name/company, blank email, hint; filename implies S20 (onboarding tasks). | Flag mismatch; do not promote onboarding tasks or app-shell states to observed. | high actual content; intended mapping tentative |
| live-demo-perf.png | No product S-ID: personalization gate; filled name/company, blank email, hint; filename implies S24 (performance). | Flag mismatch; do not promote performance or app-shell states to observed. | high actual content; intended mapping tentative |
| live-demo-rep-audit.png | No product S-ID: personalization gate; filled name/company, blank email, hint; filename implies S23 (audit report). | Flag mismatch; do not promote audit report or app-shell states to observed. | high actual content; intended mapping tentative |
| live-demo-rep-custom.png | No product S-ID: personalization gate; filled name/company, blank email, hint; filename implies S23 (custom report builder). | Flag mismatch; do not promote custom report builder or app-shell states to observed. | high actual content; intended mapping tentative |
| live-demo-rep-turnover.png | No product S-ID: personalization gate; filled name/company, blank email, hint; filename implies S23 (turnover report). | Flag mismatch; do not promote turnover report or app-shell states to observed. | high actual content; intended mapping tentative |
| live-demo-reports.png | No product S-ID: personalization gate; filled name/company, blank email, hint; filename implies S23 (reports). | Flag mismatch; do not promote reports or app-shell states to observed. | high actual content; intended mapping tentative |
| live-demo-sat-report.png | No product S-ID: personalization gate; filled name/company, blank email, hint; filename implies S23 eNPS report (satisfaction report). | Flag mismatch; do not promote satisfaction report or app-shell states to observed. | high actual content; intended mapping tentative |
| live-demo-sat-enps.png | S29-adjacent invitation email in simulated mailbox, Inbox selected; survey chapter expanded/current. No scale/comment controls. | Record invitation only; eNPS form/admin/report remain unproven. | high |
| live-careers-list.png | S33: filled three-row public opening list; three metadata columns, serif heading, social links upper-right, footer below large blank surface. | Add candidate shell/list; blank lower page is whitespace, not empty-result state. | high |
| live-careers-detail.png | S34: populated long article, back link, right apply/share card then ruled job metadata. | Add job-detail/rail; distinct from internal S13 and S15. | high |
| live-careers-apply.png | S35: blank identity and questions; paired name inputs, idle optional/required uploads, unselected radios, bottom cancel/submit. | Add initial form, no-file state and separate footer action bar; not S17 offer/signing. | high |
| live-careers-apply-validation.png | S35 validation: required field/group/file errors together; red labels/icons/borders, pink inline messages, optional upload neutral. | Add inline validation; top summary not visible, retain as accessibility requirement only. | high |

## Shell, geometry, hierarchy and colour

Simulator at 1440×900: top chrome ~49px, left instructional rail x8..298 (~290px),
black letterboxing around content. Top chapters Get Started, Dashboard, ATS,
Onboarding, Employee Records, Mobile Application, Reporting & Analytics and
Employee Satisfaction (some clipped by horizontal position), plus Auto mode and
view/reset controls. Left chapter heading, expanded current hint panel, presenter
video and font-size choices. These are demo tools, not application navigation.
Gate white panel ~x579..1159/y345..638 on grey scene; email hint sits to its right.
Mailbox example has its own mail folders and top search; neither is HR navigation.
No employee/manager/admin comparison, permission gating, settings entry or global
app header/order can be recovered. Current/expanded simulator steps are visible;
completed product wizard steps are not in these new captures.

Careers list at 1200×1132: outer surface x32..1168/y32..1100, white card
x64..1136/y172..652, ~16px radius and subtle offset shadow. Header logo top-left,
social links top-right; card heading x84/y193, rule y254, then row separators y381
and y508 (~127px rows). Three columns begin ~x100/444/768: job/department,
work-mode/location, department/employment-type. No table heading, board, filter,
search, pagination or row selection shown. Footer legal links left, attribution
right; large remaining area is intentional document whitespace.

Detail/apply at 1440px wide: surface inset ~32, main panel x78..970 (~892), rail
x1002..1362 (~360), gap32, both start y172; main content inset20. Back link then
serif title, subtitle and rule. Right card has pill action, divider, job-link field,
three sharing buttons. Metadata below sits directly on warm surface with rules.
Main description is long prose with bold sans subheads/lists; footer follows it.
Form has paired first/last names, narrower separate email/phone, section dividers,
stacked file controls and radio/text questions. Input height ~40 raster px, radius
~6; form/radio vertical rhythm ~16–32. Main white panel radius ~16. Footer is dark,
brand left, cancel and white submit pill right. Sticky/fixed positioning is not
established by a full-page PNG. No data table or candidate pipeline is visible.
These coordinates are raster measures (medium confidence), not source CSS/zoom.

Flat sampled colours: warm surface `#f3f2ef`, white panels, divider `#bfbab7`,
text `#3f3937`, muted `#6c6765`, source heading/action `#1e6e46`, blue link
`#0e46cb`, dark action footer `#312b29`, error tint `#fde7e9`, bright error label
`#d91425`, darker error-message ink `#a40b17`. Flat-region confidence high;
font identity, CSS sizes/weights and shadow parameters remain unproven. Serif
headings + sans body confirmed; no justification for changing default font families.

## States and corrections across the system

- Filled: public three-job list, job detail/metadata and email invitation; gate
  name/company. Blank: public inputs/radios and no-file uploads; gate email.
- Error: public required text, radio groups and resume; icon/text plus colour;
  pink group messages span the content, short field messages hug text. Native form
  height rises 2628→3408 with errors. No top summary, success or recovery shown.
- Selected/current: mailbox Inbox, simulator chapter/expanded rail; not employee
  app selection. No public row/radio selection. Completed steps remain only older
  marketing S14/S25 evidence; none new. No whole-screen empty product state.
- Components now scope careers separately: shell, divided job row, detail rail,
  application, file chooser, inline errors and required-but-unobserved summary.
- Tokens retain neutral accent roles; sampled source green is optional likeness.
  Surface/text/divider/error/footer/link roles corrected from careers samples.
  Generic admin dimensions and marketing radii retained; added explicit careers
  raster dimensions and panel radius. `border-input` darkened to #838b95 because
  the old accessible border fell below 3:1 against the newly measured surface.
  Danger uses darker observed message ink, not bright source label red.
- Recon adds S33–S35 (validation is a state of S35). Public candidate pages relate
  to S12/S13 openings and applicant intake, not internal candidate S15 or offer S17.
  Simulator gate is recorded as non-product evidence rather than inventing S36.

## Remaining unproven

Logged-in settings (S21), access-level editor/preview (S22), full review-cycle setup
(S25; only earlier marketing fragment), eNPS administration and result report,
and packet builder (earlier packet fragments cannot establish builder actor/layout).
Also global app shell/order/role visibility; desktop directory/openings tables,
candidate pipeline/drag, menus, goals, org chart, permission-denied/loading/empty,
completed/overdue tasks, successful application, file selection/progress/rejection,
validation recovery, keyboard/focus/hover, mobile careers layout, responsive
breakpoints and persistence. S29 invitation does not prove anonymous storage.
No admin component dimensions were inferred from demo chrome or careers pages.

## Verification

`python3 /Users/aiconfirmed/.config/opencode/skills/replica-design/contrast.py replica/design/tokens.json`:
34 declared pairs, 0 failing AA after border correction. Optional likeness palette
also checked after merging over color roles. CSS regenerated values and aliases
checked against JSON. Contrast is for declared implementation pairs, not proof
that source pixels or unbuilt screens pass accessibility checks.
Docs/tokens only; no build, commit, network research or source assets added.
Startup POLICY.md and agencyctl.py unavailable at user-supplied absolute paths.
