# How this reference is meant to be used

This repo is the **recon stage** of a clean-room app rebuild. It captures what
BambooHR's HR portal does and how a user moves through it, so a clone can be
built with the same features and layout, then rebranded and filled with your
own content.

## The pack, in order

| step | skill | produces |
| --- | --- | --- |
| 1. recon | `replica-recon` | `replica/recon.md`, `replica/features.csv`, `replica/screens/` — **done, this repo** |
| 2. architect | `replica-architect` | stack, `schema.sql` with indexes + access rules, route list by flow, vertical-slice build order |
| 3. design | `replica-design` | design tokens, component specs, WCAG contrast checks |
| 4. build | `replica-build` | the app, screen by screen, states included |
| 5. diff | `replica-diff` | parity score from the feature matrix + layout diff |
| 6. test | `replica-test` | test plan, e2e tests, bug reports |
| 7. brand | `replica-brand` | name, palette, logo brief, leftover sweep |
| 8. launch | `replica-launch` | landing page, pricing, store listing |
| 9. deploy | `replica-deploy` | preflight gate, production, DNS, monitoring |

## Ground rules (clean-room)

- Public sources and your own account only. No logins that are not yours, no
  paywall tricks.
- Reading, not scraping. No crawlers, no bulk downloads, no loops.
- No source code, no private APIs. Public API docs are fine.
- Screenshots are reference. They live in `replica/screens/`, are used to
  compare layouts, and never ship in the clone.

## Adapting it for yourself

1. Fork the repo.
2. Edit the scope block at the top of `replica/recon.md` (what you keep, what
   you drop). The scope is a decision, not a default.
3. Edit `replica/features.csv`: change priorities (`must`/`should`/`could`/
   `skip`), add rows for your own features, delete rows you do not want.
4. Keep the `clone` column at `no` — it flips to `yes` only when a feature is
   actually built and verified.
5. Run step 2 onward. Do not start building before the schema and the
   vertical slice are planned.

## Rules of thumb

- The feature matrix is the build checklist and the diff score. Keep it honest.
- One flow at a time, happy path first, then the edge cases listed in
  `recon.md`.
- Empty, error, and permission states are part of the screen, not polish.
- Anything in "Out of scope" stays out unless you consciously add it.
