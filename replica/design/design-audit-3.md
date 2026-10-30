# Live screenshot design audit 3 — 2026-10-30

Scope: visually inspected all 17 live-demo PNGs in labelled contact sheets and
all four live-careers PNGs; native demo inspection confirms field content. Pixel
hashes compare decoded RGB images, not filenames or PNG metadata. Careers flat
colours independently re-sampled at native resolution. Docs/tokens only.

## Evidence conflict

The supplied request says the gate passed and files were recaptured. **The files
currently on disk still show the personalization gate in all 17 demo images.**
There is no mailbox in current `live-demo-sat-enps.png`; audit 2's S29-adjacent
invitation claim no longer describes this asset. This audit supersedes audit 2
where current pixels disagree; historical marketing evidence is unchanged.
No new internal product S-ID is justified. Do not infer the destination from a
chapter, filename or click attempt. File replacement outside this workspace may
explain the discrepancy, but is not established here.

## Mapping (all demo images 1440×900)

| Image | Actual screen/state | Filename matches? |
| --- | --- | --- |
| live-demo-ats-add-job.png | gate/previous screen: Get Started > Personalize; email blank; email hint open | No — S14 job intake absent |
| live-demo-ats-candidate.png | gate/previous screen: Get Started > Personalize; email blank; email hint open | No — S15 candidate absent |
| live-demo-ats-careers-site.png | gate/previous screen: Get Started > Personalize; email blank; email hint open | No — S33 careers absent |
| live-demo-ats-collaborators.png | gate/previous screen: Get Started > Personalize; email blank; email hint open | No — S13-adjacent collaborators absent |
| live-demo-dashboard.png | gate/previous screen: Get Started > Personalize; email blank; email hint open | No — S02 dashboard absent |
| live-demo-emp-documents.png | gate/previous screen: Get Started > Personalize; email blank; email hint open | No — S10 documents absent |
| live-demo-emp-record.png | gate/previous screen: Get Started > Personalize; email blank; email hint open | No — S08 record absent |
| live-demo-emp-status.png | gate/previous screen: Get Started > Personalize; email blank; email hint open | No — S08 Job/status absent |
| live-demo-onb-packet.png | gate/previous screen: Get Started > Personalize; email blank; email hint open | No — S19-adjacent packet builder absent |
| live-demo-onb-tasks.png | gate/previous screen: Get Started > Personalize; email blank; email hint open | No — S20 tasks absent |
| live-demo-perf.png | gate/previous screen: Get Started > Personalize; email contains `na@`; no validation message | No — S24 performance absent |
| live-demo-rep-audit.png | gate/previous screen: Get Started > Personalize; email blank; email hint open | No — S23 audit report absent |
| live-demo-rep-custom.png | gate/previous screen: Get Started > Personalize; email blank; email hint open | No — S23 custom builder absent |
| live-demo-rep-turnover.png | gate/previous screen: Get Started > Personalize; email blank; email hint open | No — S23 turnover absent |
| live-demo-reports.png | gate/previous screen: Get Started > Personalize; email blank; email hint open | No — S23 reports absent |
| live-demo-sat-enps.png | gate/previous screen: Get Started > Personalize; email blank; email hint open | No — S29 survey absent |
| live-demo-sat-report.png | gate/previous screen: Get Started > Personalize; email blank; email hint open | No — S23 satisfaction report absent |

## Identical-image groups

All 17 share the same gate layout. Presenter frames, Auto mode and field content
must not be mistaken for different application screens. Exact decoded-pixel groups:

- `efb62d6533bb8514f29b7c1b2c0ff29fb274a025bb870b69fcfccb8f2e1d1dd7`: `live-demo-ats-collaborators.png`, `live-demo-emp-status.png`.
- `072d0c4f0a9a1ec2961f2372b8109edf4483e71538f002b7be702bf77a2f1f7d`: `live-demo-emp-documents.png`, `live-demo-rep-audit.png`, `live-demo-rep-custom.png`, `live-demo-rep-turnover.png`.

The other 11 captures are exact-image singletons, not 11 product screens. All
except `perf` have blank email; `perf` contains `na@`. `sat-report` shows Auto mode
on; this is a simulator state, not survey/report completion. No visible gate error
is proven by incomplete email text or the grey instructional hint.

## Shell and states actually established

**Simulator only:** top bar ~49px high; left instruction rail x8–298 (~290px);
scene begins x298, with black letterboxing. Gate panel x579–1159/y345–638
(~580×293), rectangular small-radius panel, sans heading/labels, compact fields
and green Log In. Name/company filled; email blank or partially filled; grey hint
open. Get Started selected, Personalize expanded/current. Visible top chapter
sequence: Get Started, Dashboard, ATS, Onboarding, Employee Records, Mobile
Application, Reporting & Analytics (clipped). Employee Satisfaction and Add-ons
are reported by the request but not legible in these captures. No completed
product step or HR navigation is proven. These dimensions/colours are excluded
from product tokens.

**Product UI is public careers only**, separate from the employee/admin shell:

| Capture | Actual screen | Filename matches? | States |
| --- | --- | --- | --- |
| live-careers-list.png | S33 public openings | Yes | three filled rows; no selected row/filter/empty result |
| live-careers-detail.png | S34 public description | Yes | populated article, apply/share rail, metadata |
| live-careers-apply.png | S35 public application | Yes | blank fields, unselected radios, idle/no-file uploads |
| live-careers-apply-validation.png | S35 validation | Yes | simultaneous required input/group/resume errors; optional upload neutral |

List: organization mark upper-left, social actions upper-right. Warm container
inset32; white panel x64–1136/y172–652 at 1200px width. Panel padding20;
three columns begin x100/444/768; row separators y254/381/508 (~127px rhythm).
No HR nav, global search, internal table toolbar or login. Legal links and
attribution below the large blank area; that space is not an empty-result state.

Detail/application at native 1440px: main x78–970 (892px), sidebar x1002–1362
(360px), gap32; top y172. Surface inset32; main offset from surface46; panel
padding20. Back link, serif role title, muted subtitle, divider; bold sans article
subheadings and sans body/controls. Approximate raster title24px/body14–16px;
font identity, precise line-height and weight remain unmeasured. Panel radius~16,
input radius~6, inputs~40 high; spacing ~16–32 between field/groups/sections.
Name fields paired; other fields narrower and stacked. No universal admin grid
or type scale can be inferred from public careers.

Right card: full-width filled pill Apply on detail, outlined return-to-description
pill on application, divider, job-link field and three social icon pills. Metadata
below the card sits on the warm surface separated by rules. Application document
footer is dark with brand left, cancel and white submit pill right. Sticky/fixed
behaviour cannot be established by a full-page capture.

Selected/current/completed: no public row/radio selection or product stepper here.
Earlier marketing S14/S25 checks/current rows remain historical evidence only.
Filled list/article are observed; fully entered application, chosen file, success,
loading, denied and whole-screen empty states are not. Validation has red labels,
icons and borders, pale pink inline messages; radio messages span the form width,
short text messages hug content. Resume error leaves optional cover letter neutral.
No top error summary/recovery observed. Height changes 2628→3408 raster px.

## Colour measurements and corrections

Native flat-region sampling reconfirms surface #f3f2ef, panel #ffffff, divider
#bfbab7, body #3f3937, muted #6c6765, careers heading/action #1e6e46, link #0e46cb,
footer #312b29, error tint #fde7e9, bright error label/border #d91425 and error
message #a40b17. Keep source sampling distinct from implementation roles: slate
accent remains the white-label default; source green is optional likeness only.
Border-input #838b95 and danger #a40b17 remain accessible implementation choices.
The faint divider is decorative, not an accessible input boundary.

- components.md: remove stale invitation claim; gate/partial-email/Auto mode states
  scoped to simulator; careers social pills, readonly-looking link field and
  application states clarified. Link editability cannot be established visually.
- tokens.json: retain revalidated colours; add scoped measured careers padding20
  and detail inset46. Generic admin geometry/type/fonts/shadows/motion remain
  defaults, not recovered source CSS. Regenerate tokens.css from token values.
- recon.md: current assets all gate; remove invitation observation; retain S33–S35
  and historical evidence. No new screen ID needed. State observations separated
  from required implementation states.

## Remaining unproven

- Admin settings S21: hub, grouped navigation, permissions and dimensions.
- Access levels S22: matrix, editor, preview-as-user and visibility rules.
- Review setup S25: full live flow; only older marketing fragment is observed.
- Packet builder: actor, editor, steps and launch; older fragments do not prove it.
- eNPS form S29: 0–10 choice, comments, submission/anonymity behaviour; current
  capture does not even show an invitation. Administration/results also unproven.
- Internal app shell/order/header/grid, employee documents, status edit, custom
  report builder, audit/turnover reports and candidate collaboration/pipeline.
- Whole-screen empty/loading/denied, focus/hover/keyboard, validation recovery,
  upload progress/rejection, successful application, role/responsive behaviour.

## Verification

Shared POLICY.md and agencyctl.py absent at supplied absolute paths; no recorded
next action could be read. Existing unrelated edits preserved. No build or commit.
Contrast and JSON/CSS consistency results recorded after generation below.

`contrast.py`: 34 declared pairs, 0 failing AA, both default and merged optional
likeness palettes. JSON parsed; generated CSS values, unique token declarations,
compatibility references and all 17 mapping rows checked. Contrast applies to
declared implementation pairs, not source pixels or unbuilt application screens.
