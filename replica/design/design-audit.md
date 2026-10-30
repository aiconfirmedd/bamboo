# Screenshot design audit — 2026-10-30

Scope: all 48 local files visually inspected, including transparency composited on
white for the 16 help icons. Clean-room structural reference only. No source assets,
copy, brand greens or proprietary font files are implementation material.

## How to read the findings

Every row records the actual image, screen mapping, layout/state and correction.
Global shell absent means its position/order cannot be supplied from that image.
Marketing fragments are illustrative compositions, not full viewport captures.
Confidence **high** means directly legible structure/state; **medium** covers pixel
estimates or tentative screen mapping; **guess** marks retained implementation
choices. No photographed/marketing frame dimensions are CSS viewport evidence.

Shared visual measurements (apply to marketing rows unless noted): white panels,
off-white interiors, fine light-grey dividers, generous rounded outer corners;
compact fields with much smaller corners. Green serif headings contrasted with
sans labels/body/data. In mkt-01 at native 1120×910: header panel starts around
(74,134), body at y298, left rail ends x277; field boxes about 147×30, name-title
ink roughly 40px high, section headings roughly 20–24px, labels roughly 11–12px.
Those are raster units, not recovered font sizes. Typical panel insets ~24px,
field gaps ~8–12px; repeated 16–24px vertical spacing. Mkt-13 is enlarged relative
to mkt-01: no universal font scale follows from the files. Marketing frames use
~24–32px corners; the mkt-01 inner form uses ~12px and fields ~6px. Mobile app
interiors have square divided rows, small native type, compact bar titles and
44px-ish logical touch targets (estimate); device frames/promo typography excluded.

Measured flat source colours: mkt-01 profile masthead `#03551c`, surface `#f6f6f4`,
panel `#ffffff`; mkt-06 action fill `#217950`; mkt-13 heading green `#2e7918`;
Android play-03 bar `#527a00`, page `#f4f4f4`, promo backdrop `#80c43b`.
These demonstrate multiple colour roles/platform themes, not one universal green.
Neutral slate accent in tokens is deliberate clean-room substitution. Border and
text values are neutral implementation approximations; fine border pixels and
antialiased text do not establish a unique source hex. Danger/success/warning,
focus, hover, shadow and motion remain accessibility defaults without direct proof.

## Per-image findings

| Image | Screen | Observation (layout, actions, state) | Correction | Confidence |
| --- | --- | --- | --- | --- |
| mkt-01-hr-data-employee-record.png | S08 (not S06) | Dark masthead with avatar left, serif name/subtitle, request-change and overflow right. Tabs: Personal, Job, Time off, Documents, Timesheets, Performance, Emergency, Training, More. Left vitals rail; right title/Edit fields and white section form, four name columns, sparse later rows. Filled and blank individual fields; selected Personal tab. | Remove directory attribution; specify record layout, serif headings and raised active tab. | high |
| mkt-02-hr-data-reports-analytics.png | S23; S03 placement uncertain | No navigation. Wide stacked turnover bars above two narrower cards: department horizontal bars left, location donut right. Serif titles upper-left, legends near charts. Filled charts. | Record 1+2 chart layout; do not claim complete Insights dashboard. | medium |
| mkt-03-home-central.png | S02 / S31 widget | Cropped composition: left Time off card then My Stuff; right Employee Community / What’s Happening tabs, New Post and feed select left, community link right; divided populated feed below. Request action below balances. | Replace generic equal widget grid with asymmetric crop; distinguish toolbar and list rows. | high |
| mkt-04-hr-data-section.png | S08/S23 fragments | No shell. Narrow contact/person card left; status donut card upper-right and turnover bar card lower-right. White panels, green headings; body/contact lines sans. | Treat as montage; not a measured page grid. | medium |
| mkt-05-hiring-onboarding-section.png | S15 / S18 transition / S20 fragments | Candidate mini-record left with Info, Notes, Emails tabs, contact actions and resume/questions; hired confirmation and Add New Employee above-right; task list below-right, unchecked rows and assignee/date columns. | Add hired confirmation evidence; not a pipeline board. | medium |
| mkt-06-ats-job-posting.png | S14 | Title strip above two columns. Left steps Job Information, Application Details, Job Pipeline, Automated Emails, Job Boards; first four checked, current last hollow. Save and finish-later at rail bottom. Right Job Boards panel, two checked posting tiles. | Correct S13 mapping to S14; add completed/current steps and checked board tiles. | high |
| mkt-07-ats-offer-letters.png | S17 | Document body above review-documents section, pending document row and Add Signature action. Overlapping signature editor lower-right: Draw/Type, drawn signature, Clear, save/apply and cancel. | Add drawn signature and pending document states; no signed receipt is proven. | high |
| mkt-08-ats-funnel-reports.png | S23 | Three KPIs in one horizontal top strip: views, candidates, age. Lower white panel has stage labels left and green horizontal funnel bars right, final stage highlighted. No app nav/export shown. | Specify KPI strip + funnel, not report list/table or builder. | high |
| mkt-09-onboarding-packet.png | S19 / packet setup uncertain | Four floating fragments: welcome/start card upper-left, identity/email upper-right, date/time/location form lower-left, team introduction controls lower-right. Selected audience, enabled toggle, filled and blank fields. | Do not claim a full packet stepper or all-new-hire view; retain welcome/form evidence. | medium |
| mkt-10-onboarding-checklists.png | S20 | One wide white task panel, title left, Add Task and gear right; IT Setup then New Employee Paperwork groups. All visible checkboxes unchecked. Task left, assignee and due date right; thin row dividers. | Replace tile-grid claim; no done/overdue state proven by warm dates alone. | high |
| mkt-11-onboarding-i9.png | S08 / S20; excluded I-9 | Dark profile masthead, avatar/name, horizontal record tabs; left vitals and right Onboarding verification cards. Enlarged lower verification section has unchecked enable option and provider heading. Status chips visible in verification cards. | Record verification-specific layout; keep I-9 out of build scope; decorative checks are not task completion proof. | high |
| mkt-12-perf-360.png | S23 performance report; not S26 | Employee Performance header with filter selects and unchecked direct-reports option. Main avatar scatterplot, value vertical and engagement horizontal; overlapping employee list at right. Filled report. | Remove goal-card evidence and classify scatterplot/list. | high |
| mkt-13-perf-review-cycles.png | S25 | Title strip, narrow left wizard People, Feedback, Assessments, Review & Launch; checks and current Assessments row. Next then finish-later at bottom. Right enabled assessment toggle, date input, end-date text, frequency select. Upcoming-windows card overlaps lower-right. | Add enabled toggle, completed/current/pending steps and populated schedule; no open date picker shown. | high |
| mkt-14-employee-experience-section.png | S23 / S30 fragments | Tall employee summary left; trend lines upper-right, circular score and small trend lower-right. No global nav. Mixed serif labels and sans data. | Classify analytics montage, not proof of survey input screen. | medium |
| mkt-15-community.png | S31 / S02 widget | Full-width toolbar card above a single feed panel. Community then What’s Happening tabs; post/filter controls left, community link right. Thumbnail/title/byline rows, one row with counts, heart and View Post. | Feed rows rather than independent post cards; visible reaction/view controls, no composer-open evidence. | high |
| mkt-16-wellbeing.png | S30 report | Two upper panels: multi-series trend left, month/category summary right. Wide lower numeric heatmap table with row labels and gradient legend. Filled data, no survey/rating controls. | Separate report evidence from survey state; retain numeric heatmap and legend. | high |
| mkt-17-compensation-section.png | Outside scoped slice | Review-cycle title strip, metrics/budget summary with donut, compensation-range rows and avatars below. White rounded panels on branded montage; edit/submit actions near heading. | Record excluded compensation reference; not performance review setup evidence. | high |
| mkt-18-payroll-section.png | Outside scoped slice | Left plan summary above two vertically stacked donuts; tall payroll summary right with pill Start action at top then deadline, employee count, period and pay date. | Record excluded payroll reference; no HR portal navigation evidence. | high |
| ios-01.jpg | S32 Home | Centred Home in olive header; settings left, inbox/count right. Time-off balances, wide request action, approval/request/signature rows with counts, out-today avatars and Calendar. Bottom Home, My Info, People, Files; Home selected. | Specify iOS white tab bar, divided rows and counts, not generic web cards. | high |
| ios-02.jpg | S32 request detail | Back left, centred title, Edit right. Date/type summary, avatar request text, overlap row, comment thread and add-comment placeholder. Approve wide at fixed bottom with separate reject icon. | Add filled approval detail/comment affordance; no approval-result state. | high |
| ios-03.jpg | S32 directory / S06 mobile analogue | Centred People header; employee count/filter left, search right. Single photo/name/subtitle list with alphabetical separators and right-side absence dates on some rows. Bottom Home, My Info, People, Files; People active. | Directory is list on mobile; does not prove web table. | high |
| ios-04.jpg | S32 calendar | Cancel left, Calendar centred. Month/day grid with selected date filled green; month separator and employee absence rows below, avatar/name left dates right. No bottom app tabs in this detail. | Add selected calendar day and populated absence list; not empty or permission state. | high |
| ios-05.jpg | S32 / S05 mobile Time off | My Info header above horizontal subtab row; Time Off selected. Request button and calendar at top, current balance, upcoming entries and history stacked. Bottom four app tabs with My Info active. | Record time-off subtab and populated history; excluded time-off functionality remains reference only. | high |
| ios-06.jpg | S32 excluded Pay Info | My Info header, horizontal subtabs with Pay Info active. Year-to-date amounts beside donut; paystub rows underneath. Bottom Home, My Info, People, Files. | Keep payroll reference outside web slice; no payroll build implied. | high |
| play-01.png | S32 request detail | Back left, Request Details title, edit right in olive bar. Date/type summary, avatar request, overlap indicator, threaded comments, add-comment placeholder. Deny text and green Approve at bottom-right. | Android actions differ from iOS wide approve; filled thread only. | high |
| play-02.png | S32 excluded timesheet | My Info header, subtab row with Timesheet active. Running duration, wide Clock Out button, week/pay-period totals side-by-side, day entries below. Bottom Home, My Info, People, Files in green bar. | Record active clock state as mobile reference, not loading. | high |
| play-03.png | S32 / S05 mobile record | Back/title left, add-person/share right. Tabs Info, Time Off, Emergency, Timesheet, clipped Documents. Centred photo, absence badge, name/title. Contact rows with right phone/message/email actions; add-phone/email links for absent values. | Add absent-field state, photo and contact actions; no screen-level empty state. | high |
| play-04.png | S32 Inbox | Close left, Inbox title. Tabs To Do then Announcements (active); avatar/title/time/preview rows. No bottom app tabs in overlay/detail crop. | Add populated announcement inbox and selected subtab; not S31 composer proof. | high |
| play-05.png | S32 directory / S06 mobile analogue | All Employees count/dropdown left and search right in header. Alphabetical photo/name/subtitle rows, photo fallback visible. Bottom Home, My Info, People, Files, People active. | Record Android filled directory list and fallback avatar, no search-result or filter-open evidence. | high |
| play-06.png | S32 calendar | Back left, employee filter/count title and calendar icon right. Month grid, green selected day, next-month strip and out-today avatar rows. No bottom app tabs visible. | Add selected-date state; no range selection proven. | high |
| play-07.png | S32 excluded Payroll | My Info and subtab row with Payroll active. Year-to-date amounts and donut at top; paystub amounts/date rows beneath. Bottom four tabs, My Info active. | Record payroll only as excluded mobile reference. | high |
| play-08.png | S32 / S19 document analogue | Back and I-9 title in header. Dense document viewer; completion indicator and disabled-looking Previous/Next controls, active Finish. Drawn employee signature panel and Clear Signature action near bottom. | Add filled signature/document form; grey controls only visually inactive, actual disabled semantics unproven. | high |
| hc-1976009-693d972c.png | None; article ID is not screen proof | 512×512 transparent monochrome icon: outline plus on stacked panels. No nav, header, grid, controls, text or product UI state. | Exclude from product-state evidence; do not infer empty/error/permission/loading from this asset. | high |
| hc-1976009-9e14afca.png | None; article ID is not screen proof | 512×512 transparent monochrome icon: white minus in solid black front panel, stacked panels behind. No nav, header, grid, controls, text or product UI state. | Exclude from product-state evidence; do not infer empty/error/permission/loading from this asset. | high |
| hc-587295-693d972c.png | None; article ID is not screen proof | 512×512 transparent monochrome icon: outline plus on stacked panels. No nav, header, grid, controls, text or product UI state. | Exclude from product-state evidence; do not infer empty/error/permission/loading from this asset. | high |
| hc-587295-9e14afca.png | None; article ID is not screen proof | 512×512 transparent monochrome icon: white minus in solid black front panel, stacked panels behind. No nav, header, grid, controls, text or product UI state. | Exclude from product-state evidence; do not infer empty/error/permission/loading from this asset. | high |
| hc-587617-693d972c.png | None; article ID is not screen proof | 512×512 transparent monochrome icon: outline plus on stacked panels. No nav, header, grid, controls, text or product UI state. | Exclude from product-state evidence; do not infer empty/error/permission/loading from this asset. | high |
| hc-587617-9e14afca.png | None; article ID is not screen proof | 512×512 transparent monochrome icon: white minus in solid black front panel, stacked panels behind. No nav, header, grid, controls, text or product UI state. | Exclude from product-state evidence; do not infer empty/error/permission/loading from this asset. | high |
| hc-587751-693d972c.png | None; article ID is not screen proof | 512×512 transparent monochrome icon: outline plus on stacked panels. No nav, header, grid, controls, text or product UI state. | Exclude from product-state evidence; do not infer empty/error/permission/loading from this asset. | high |
| hc-587751-9e14afca.png | None; article ID is not screen proof | 512×512 transparent monochrome icon: white minus in solid black front panel, stacked panels behind. No nav, header, grid, controls, text or product UI state. | Exclude from product-state evidence; do not infer empty/error/permission/loading from this asset. | high |
| hc-588009-693d972c.png | None; article ID is not screen proof | 512×512 transparent monochrome icon: outline plus on stacked panels. No nav, header, grid, controls, text or product UI state. | Exclude from product-state evidence; do not infer empty/error/permission/loading from this asset. | high |
| hc-588009-9e14afca.png | None; article ID is not screen proof | 512×512 transparent monochrome icon: white minus in solid black front panel, stacked panels behind. No nav, header, grid, controls, text or product UI state. | Exclude from product-state evidence; do not infer empty/error/permission/loading from this asset. | high |
| hc-588033-693d972c.png | None; article ID is not screen proof | 512×512 transparent monochrome icon: outline plus on stacked panels. No nav, header, grid, controls, text or product UI state. | Exclude from product-state evidence; do not infer empty/error/permission/loading from this asset. | high |
| hc-588033-9e14afca.png | None; article ID is not screen proof | 512×512 transparent monochrome icon: white minus in solid black front panel, stacked panels behind. No nav, header, grid, controls, text or product UI state. | Exclude from product-state evidence; do not infer empty/error/permission/loading from this asset. | high |
| hc-639584-693d972c.png | None; article ID is not screen proof | 512×512 transparent monochrome icon: outline plus on stacked panels. No nav, header, grid, controls, text or product UI state. | Exclude from product-state evidence; do not infer empty/error/permission/loading from this asset. | high |
| hc-639584-9e14afca.png | None; article ID is not screen proof | 512×512 transparent monochrome icon: white minus in solid black front panel, stacked panels behind. No nav, header, grid, controls, text or product UI state. | Exclude from product-state evidence; do not infer empty/error/permission/loading from this asset. | high |
| hc-640097-693d972c.png | None; article ID is not screen proof | 512×512 transparent monochrome icon: outline plus on stacked panels. No nav, header, grid, controls, text or product UI state. | Exclude from product-state evidence; do not infer empty/error/permission/loading from this asset. | high |
| hc-640097-9e14afca.png | None; article ID is not screen proof | 512×512 transparent monochrome icon: white minus in solid black front panel, stacked panels behind. No nav, header, grid, controls, text or product UI state. | Exclude from product-state evidence; do not infer empty/error/permission/loading from this asset. | high |

## Cross-file contradictions and corrections

1. Recon S06 cited mkt-01 as directory evidence; it is a profile. S13 cited mkt-06
   as pipeline; it is the create-opening wizard, S14. S26 cited mkt-12 as goals;
   it is a performance scatterplot. S03 attribution of mkt-02 remains tentative.
2. Generic top-nav order, active underline, sticky/condensing behaviour and
   admin-only gear placement are not visible. Native bottom order is visible.
   Implementation guide's web nav order remains a requirement, not visual proof.
3. Universal sans misses web serif headings. Added open-system serif heading role.
   Exact family, weight files, line heights and CSS sizes remain unknown; token
   scale retained as implementation defaults, not falsely remeasured facts.
4. Universal medium-radius buttons miss pill save/next/request controls. Card
   radius 16 alone misses small 12px form corners versus larger montage panels;
   md/lg now 12/24 estimates, fields retain 6. Hover translation never observed.
5. Community uses one divided feed, not a card per post; onboarding shows grouped
   unchecked task rows, not a tile grid. Done/overdue styling remains unverified.
6. Empty table/widget/pipeline labels previously marked observed were unsupported.
   Removed observed markers; no empty product screen, permission denial, error or
   loading state appears. Blank fields and add-contact links are narrower evidence.
7. Signature drawing is visible; timestamp/hash receipt is not. Review enabled
   toggle, checked posting tiles, wizard completed/current/pending steps, selected
   date/tab, avatar fallback, populated comment thread and pending document are
   now explicitly distinguished from required future states.
8. Branded green token family conflicted with clean-room neutral-placeholder rule.
   Replaced accent roles with slate; source colour observations retained above.
   Surface white/off-white split is supported; no claim that status palette was
   sampled. Added pairs for tinted badges and secondary surfaces, not just white.
9. `tokens.css` regenerated for every token leaf including weights, heading family,
   geometry and breakpoints. Removed self-referential Tailwind aliases; unique
   underlying custom properties feed theme aliases.
10. Recon's claim that Play screenshots were not saved is obsolete. Sixteen help
    files are reusable icon assets, not help-center screen captures or state proof.

## Remaining unproven / implementation choices

- Full web shell, global nav placement/order and responsive breakpoints; sidebar,
  header, table row and max-content dimensions; real desktop directory/pipeline.
- Empty screens, errors, permission denial/masking, loading, hover, keyboard focus,
  drag/drop, toast, open menus/calendars, submitted/declined/expired signatures,
  completed/overdue tasks, goals, org chart, eNPS survey, access matrix and 1:1s.
- Exact CSS sizes, font family/weights, spacing system, box-shadow and transitions;
  screenshots are rescaled marketing montages and older native platform themes.
- Actual disabled semantics of grey I-9 navigation, anonymous-survey behaviour,
  role gating and any interaction or persistence. Static images prove appearance.

## Validation

`python3 /Users/aiconfirmed/.config/opencode/skills/replica-design/contrast.py replica/design/tokens.json`:
**30 pairs, 0 failing AA**. Minimum text ratio 4.64:1 (warning on warning tint);
minimum UI ratio 3.06:1 (input border on surface). This validates listed token
pairs, not source screenshots or unbuilt pages. Token/CSS parity checked separately.
No UI/scaffold, network research, commit, copied assets or product copy added.
