# Public-source gap supplement

New requirements use vendor public documentation, not inferred private endpoints.
These sources close behavior/specification gaps; they do not convert unobserved
screens or unexecuted side effects into observed facts. Historical release notes
may differ from the current UI. Source IDs are listed in [sources.csv](sources.csv).

## Snapshot — P01

Search routing depends on profile access. With full access, a search result can
navigate directly to the profile, as browser recon8 observed. Without full access,
it may show Snapshot. Hover-card Snapshot is another documented entry. Build a
read-only projected view respecting row/field permissions. Include basic/job/contact
and reporting information where granted; do not assume custom fields are supported.
No live restricted Snapshot detail was captured.

## Review setup — P02–P06

The cycle list is observed. For an independent implementation, specify audience,
feedback and assessment configuration, questions/ratings, cadence, hire-date
milestones, review/release status and reminders. Duplication must create a draft,
not launch. Double-blind release must be enforced on server reads as well as UI:
when enabled, mutual answers remain hidden until both submit. In this repository,
these are documented requirements; exact editor pixels and saved outcomes remain
unverified.

## Offer templates — P07

Template selection and candidate/role substitution plus electronic acceptance are
publicly documented. Use owner-written legal/employment text and owner-supplied
branding. Define draft/preview/send/sign/decline/expire states and missing-variable
validation in the independent product; those state names are implementation choices,
not claims about BambooHR internals. Do not copy their templates or invent observed
controls. The older tour is visual evidence only for its captured version.

## Survey entry and recipient flow — P08–P09

Web/mobile Home entry is documented. Mobile help describes a recommendation score
and conditional follow-up question plus confirmation. The current trial admin
setup was explicitly disabled for trial accounts. Never treat vendor anonymity
copy as verification of its storage model. Keep response unlinkability, threshold
aggregation, anti-replay and eligibility separation as independent design requirements
in [the API plan](../architecture/api-plan.md).

## Acceptance cases for the recipient

- Full-profile search and restricted Snapshot routes both obey the same field projection.
- A denied API request leaks no hidden fields, including sorting/filtering/export paths.
- Duplicating a cycle cannot trigger notifications or activate it.
- Double-blind questions remain inaccessible server-side until release conditions hold.
- Offer preview shows unresolved variables; send/sign transitions are idempotent.
- Trial gates, permission denial, missing routes and load failures have distinct states.
- Survey eligibility and response records cannot be joined to identify the respondent.

These are acceptance criteria to build/test, not already implemented behavior.
