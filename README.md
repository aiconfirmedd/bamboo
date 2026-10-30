# Bamboo

**AI Confirmed white-label HR portal** — clean-room rebuild reference of
BambooHR's intake, onboarding, recruiting, and retention flows. Captured so the
product can be rebuilt 1:1 on features and layout, then rebranded and filled
with your own content.

> Not affiliated with BambooHR. Screenshots are reference captures of public
> pages. Everything here was gathered from public sources only: marketing
> pages, pricing, help center, product updates, public API docs, and app store
> listings. No logins, no source code, no network capture.

## What's inside

| path | what it is |
| --- | --- |
| `replica/recon.md` | the recon map: sources, 32 screens, 12 user flows, components, inferred data model, out-of-scope list, size estimate |
| `replica/features.csv` | the feature matrix: 80 rows, priority-tagged (43 must / 18 should / 11 could / 8 skip) — this is the build checklist and the parity score |
| `replica/screens/` | 24 layout reference screenshots (18 web, 6 iOS). Reference only — never shipped |
| `docs/workflow.md` | the 9-step rebuild workflow and the clean-room ground rules |

Scope of the recon: **Home/Dashboard, People, Hiring/ATS (job intake →
pipeline), Onboarding (packets, tasks, e-sign), Performance & Retention
(reviews, goals, 1:1s, recognition, eNPS/wellbeing)**. Payroll, benefits, and
time & attendance are deliberately excluded.

## Status

- [x] Recon (this repo)
- [ ] Architecture — stack, schema, API plan
- [ ] Design system
- [ ] Build
- [ ] Parity diff, tests, rebrand, launch

## How to use it

1. Read `replica/recon.md` end to end. The flows are the spec; the edge cases
   listed under each flow are requirements, not trivia.
2. Treat `replica/features.csv` as the checklist. The `clone` column stays `no`
   until a feature is built **and** verified.
3. Open `replica/screens/` next to your build and match layout, not pixels.
4. Follow `docs/workflow.md` for the remaining steps (architect → design →
   build → diff → test → brand → launch → deploy).

### Make it yours

Fork it, then:

- rewrite the scope block at the top of `replica/recon.md`;
- re-prioritize and prune `features.csv` — add your own rows;
- keep the "Out of scope" list honest, or consciously move items out of it.

## Known gaps

- Empty, error, and permission states are unobserved — public marketing only
  shows filled states. A logged-in pass on your own account closes this.
- BambooHR has no formal requisition-approval flow; the clone should add
  intake → approval as a deliberate improvement.
- Google Play screenshots were not captured (iOS set is included instead).

## License

MIT for the recon text, matrix, and docs. Screenshots © BambooHR LLC, included
for reference only. See `LICENSE`.

---

Built by [AI Confirmed](https://github.com/aiconfirmedd).
