# Implementation guide for the recipient

You are holding a clean-room reference for **Bamboo**, an HR portal covering
intake, onboarding, recruiting, and retention. Nothing here is built yet — the
recon, the architecture, and the design system are documented. This guide is how you
turn them into your own working product: its **likeness**, your **content**,
and your **clientele**.

Read `docs/workflow.md` first. This guide assumes you follow it.

## 1. Implement the likeness

Likeness is layout and behaviour, not pixels and not their brand.

Visual evidence and its limits: see `replica/design/design-audit.md`. Full web
navigation, pipeline, goals and packet stepper remain requirements without screenshot
proof; mobile and marketing crops do not establish their complete web layout.

**Keep (product requirements; observation status is in the audit):**

- The nav order and role-based visibility: Home, My Info, Recognition, People,
  Files, Community, Reports, Settings, My Account.
- The Home widget grid (Welcome, Celebrations, Company Links, Who's Out, My
  Stuff, What's Happening) and admin-configured widgets.
- The record pattern: tabbed profile (Personal, Job, Documents, Performance,
  Notes, Training, Onboarding/Offboarding), candidate profile (Info, Emails,
  Notes, Interviews).
- The pipeline board with stage columns and counts, the packet stepper, task
  tiles, e-sign blocks, the review-cycle builder, the eNPS scale.
- The permission model: Employee / Manager / Admin / Custom, per-field grants,
  preview-as-user.
- The spacing rhythm, type scale, and component states in
  `replica/design/components.md`.

**Change (this is your brand):**

- Name, logo, favicon, accent colour, font. Swap values in
  `replica/design/tokens.json`, regenerate `tokens.css`, re-run
  `python3 contrast.py replica/design/tokens.json` until zero AA failures.
  The default accent is a neutral slate (clean-room placeholder); for the
  closest likeness copy the `theme-likeness` block over the matching colour
  roles — those are the measured source greens, contrast-checked.
- All copy. Every label, empty state, email template, and survey question is
  written fresh — do not copy BambooHR's wording.
- Icons: use Lucide or Phosphor. Illustrations: commission or make your own.

**Method:** build the primitives first (Button, Input, Select, Checkbox,
Dialog, Toast, EmptyState) in isolation on a `/design` route, screenshot them,
then assemble screens from them. Open `replica/screens/` beside the build and
match structure — column order, tab order, where actions sit — not pixels.
Where the recon lists an edge case under a flow, that is a requirement.

**Do not ship** anything from `replica/screens/`. They are reference captures.

## 2. Load your content

The installation starts empty. Seed in this order so foreign keys and
permissions exist before records do:

1. **Organization + branding** — name, logo, accent, email sender domain.
2. **Access levels** — the four base levels, then custom levels for your
   recruiters; assign the owner as Admin.
3. **Org units** — departments, divisions, locations, teams.
4. **Fields and tabs** — standard fields stay; add custom fields for what your
   agency actually tracks; hide the rest.
5. **Templates** — New Hire Packet templates (info fields, documents, task
   lists), stage emails, offer letters, review questions, eNPS/wellbeing
   questions, core values.
6. **Policies and company files** — handbook, I-9 pack if US, benefits docs.
7. **People** — employees, then open jobs, then candidates.

**Content rules:**

- Write your own empty-state copy: what the screen is for, one next action.
- Review questions: 6–10 per cycle, behaviour-anchored, no BambooHR wording.
- Packet tasks: split by role (new hire / manager / IT), due offsets in days.
- eNPS stays one question + optional comment; anonymity is structural (no
  employee link on responses), not a setting.
- Keep the requisition intake → approval flow — it is a deliberate improvement
  over the original, which has none.

## 3. Aim it at your clientele

The recon was scoped for an agency. Pick your model and adapt:

**A. Internal agency (your own staff).** Use as-is. Retention features
(reviews, goals, recognition, eNPS) carry the value; recruiting fills your own
roles. Light adaptation: rename "Hiring" to your language, set review cadence
to your size.

**B. Staffing / recruiting agency (placing people at client companies).** Add:

- `client` on job openings and placements; client-facing job intake form.
- Placement records: start date, end date, bill rate, client contact.
- Candidate-facing pages branded to the agency, not the end client.
- Retention check-ins scheduled against placement anniversaries (reuse 1:1s
  and survey runs; do not build a second module).
- Reports: time-to-fill, placement retention at 30/60/90 days, client
  concentration.

**C. Recruiting-as-a-service for one vertical.** Keep B, plus a vertical
vocabulary pass over labels and templates, and a public careers page per
client. The ATS pipeline is the product; onboarding shrinks to pre-start
compliance for placed staff.

Whatever the model: keep the permission model honest — external recruiters get
non-employee accounts scoped to their openings only.

## 4. Build and verify

1. Follow `docs/architecture/build-order.md` in order. Milestone 0 (trust
   boundary) is not optional.
2. Apply `docs/architecture/schema.sql` to a fresh database; keep RLS on.
3. Implement routes from `docs/architecture/api-plan.md` flow by flow.
4. Flip `clone` to `yes` in `replica/features.csv` only when a feature is
   built **and** verified against its flow and edge cases.
5. Gate every palette change on `contrast.py`; gate every screen on its empty,
   error, and permission-denied states.
6. Run `/replica-diff` for the parity score before calling it done.

## 5. Legal notes

- Clean-room: public sources and your own account only; no source code, no
  private APIs, no network capture.
- Screenshots © BambooHR LLC, reference only.
- BambooHR's name and logo are theirs; "Bamboo" here is your white label.
- The feature matrix and this guide are MIT — fork freely.
