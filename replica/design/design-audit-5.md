# Design audit 5 — public prospect funnel

Date: 2026-10-30. Label: bamboo-clone/design-eyes-5.
Scope: six supplied PNGs, visually inspected including native signup form crop;
recon.md, components.md, tokens.json and audit 4 read. Docs and tokens only.
These are prospect acquisition surfaces, outside the authenticated application.
No live requests, submissions, account creation or sales messages performed.

## Screen/state mapping

Two new screens: **S37 Demo Request** and **S38 Trial Signup / Create Account**.
Their steps are variants, not six screens. Neither is the simulator gate, S01
login or candidate application S35. Exact source routes are absent from pixels;
no navigation from demo to signup is established. Filenames are not state proof.

| Capture in replica/screens/ | Screen/state actually visible | Validation / confirmation evidence |
| --- | --- | --- |
| live-demo-request.png | S37 step1, three-node stepper first current; six unchecked category tiles, Next below | No error, required marker or final confirmation |
| live-demo-request-validation.png | S37 step2, first node checked/second current; Employee Count select filled 76-150; Next | No validation message. Thin bright rectangle around question is not proof of validation or focus |
| live-demo-request-filled.png | S37 same step2, count76-150 | Decoded pixels identical to preceding file; no additional state |
| live-signup.png | S38 filled eight-field form, first step current, Create Account | Not empty. No error; all fields have required asterisks |
| live-signup-validation.png | S38 preparation, first top node checked/second current; Creating your account active, demo-data and final-touches steps pending | Loading/progress rather than validation; no error or completed account yet |
| live-signup-filled.png | S38 later preparation; Account created checked, Generating demo data active, final touches pending | UI reports account-created milestone; not fully completed provisioning or trial-ready confirmation |

Six files, five distinct decoded RGB images. Duplicate demo step2 SHA-256 prefix:
`6f0b6cb1fb2d2a41`. Demo captures1440×900; signup captures1440×3176.

## Layout and fields

**S37:** split page, white x0–560 left pane and green promotional x560–1440
right pane. Logo, three-node horizontal stepper, stage label, serif question,
then fields/tiles. Six tiles, three columns and two rows: Hiring & Onboarding,
HR Data & Reporting, Payroll & Time; Benefits Administration, Employee Experience,
Performance Management. Each has unchecked top-left square, green illustration,
centered label. No selected tile is captured. Right pane contains product montage,
integration/customer proof, testimonial, ratings and customer-logo strip; those
are promotional assets, not product components or evidence for excluded modules.

Step2 replaces tiles with one Employee Count select showing76-150, floating label
and right chevron. Required asterisk, country select, contact fields and consent
are absent from the captured steps. Dropdown options and mandatory-category rules
are unproven. Next is a full-width pill under the current controls: x54–506,
y575–619 in step1; y349–393 in step2, approximately44px high. It advances a wizard;
no final demo-request submit action is shown. No back action visible.

**S38:** white logo strip above a blurred promotional dashboard hero; centered
white card x420–1020 (600 wide), top about166, small rounded corners, three-node
stepper and green serif heading. Form uses sans labels/control text. Four rows,
left-to-right then top-to-bottom:

1. First Name*, Last Name*.
2. Work Email*, Job Title*.
3. Company Name*, Phone Number*.
4. Employee Count*, Country*.

All eight values populated. Count76-150, country United States; no claim that either
is a default. Floating labels interrupt thin grey borders. Fields about44px high;
select chevrons right. No open country list, search, locale options, phone-country
coupling, password or password confirmation. Personal values are not copied into
reusable fixtures/docs. Small source grey labels/borders are not accessible role
measurements to adopt automatically.

Below fields: consent prose authorizes marketing product/service/event contact by
email and phone and links Privacy Policy. No consent checkbox or separate toggle
visible; acceptance enforcement and legal sufficiency are not established. Full-
width Create Account pill below prose, about56px high; trial/no-card note beneath.
No close/back control, inline error, validation summary or disabled submit visible.
Do not infer a dismissible modal/focus trap solely from the centered card.

Preparation replaces this form in the same hero area. Vertical tracker uses icons,
connectors and explicit status text; later frame adds check + Account created while
Generating demo data is active. Adding the final touches remains pending. No
percentage, retry, final redirect or ready-account CTA shown. Marketing trust text
below is not an account status. Remaining page: feature accordion (integrations
expanded), integration image, trial-checklist laptop image, green trial CTA band,
legal footer. App imagery does not establish logged-in Home or a working checklist.

Dimensions are native raster, not recovered CSS. Signup preview rendered smaller
in the viewer; measurements use native1440px width. Responsive, sticky/fixed,
hover, keyboard, focus, motion and exact font identity remain unproven.

## Corrections

- recon.md: add S37/S38 with variants; identify public prospect boundary, unreliable
  suffixes, partial preparation and exact route gaps. Update screen total to38;
  keep12 core-product flows. Internal loading remains unobserved; prospect loading
  is now observed. No additional inferred entity/API or core HR feature.
- components.md: add demo wizard/tiles/count select, paired required signup fields,
  country selector, consent prose/privacy link, submit placement, preparation
  tracker and prospect marketing shell. Separate observed states from accessibility
  requirements; no invented empty-submit errors or final confirmation.
- tokens.json: add scoped measured demo-pane-width560, demo-action-height44,
  signup-card-width600, prospect-input-height44, signup-action-height56. These
  differ from internal dialog450/control26 and careers input40; preserve those
  older scopes. Regenerate canonical CSS declarations, retain compatibility aliases
  and Tailwind mapping. No new colour roles or palette changes: source demo action
  flat sample #296e17 is observational branding, not a replacement for neutral accent
  or the separately scoped careers optional green. No font/radius/gradient endpoint
  invented from antialiasing or promotional art.

## What the funnel still does not prove

- Demo final contact fields, final submit, validation, success/thank-you page,
  booking calendar or confirmation email. No sales handoff, lead delivery, routing,
  representative assignment or response time observed.
- Signup empty/error states, server validation, country choices, consent mechanics,
  duplicate-email/error recovery, verification email or authentication credentials.
- Signup does show post-submit preparation and an **Account created** milestone.
  It does not prove durable backend creation, completed demo-data generation/final
  touches, tenant provisioning, invitation delivery, authenticated access, final
  trial-ready confirmation or destination. Those require further evidence.
- Screenshots establish visible statuses only; no network/backend semantics, actual
  progress timing, accessibility behaviour or responsive implementation verified.

## Verification

Shared policy and agencyctl missing at supplied absolute paths; no replacement
policy inferred. Existing temporary `/tmp/contrast.py` inspected before use; its
WCAG luminance self-checks cover black/white and the 4.5 boundary. It checks declared
text pairs at4.5:1 and UI pairs at3:1, for default and merged optional palettes.
Results: **50 pairs each, 0 failing AA**, minimum3.089:1 (UI pair). This validates
specified token combinations, not the raster artwork or a built application.
Canonical token declarations regenerated from JSON; CSS references and recon IDs
checked. `git diff --check` passed. No build, runtime check or commit.
