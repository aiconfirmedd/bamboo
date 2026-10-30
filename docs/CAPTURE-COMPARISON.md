# OpenCode / Codex / GitHub comparison

Date: October 30, 2026. Baseline: local OpenCode session `bamboo-clone recon`
(221 messages read), its persisted files, audits1–6, and public GitHub main tree
`991e918fe6ff88a6cf4da352668be0494b6d7810`. Session transcripts and tool logs are not
included because they contain unrelated context and account details.

## Quantitative baseline before this assembly

- Public GitHub main: 157 files.
- Local reference before new assembly: 197 files.
- 40 local-only files and 5 differing tracked files; primarily the browser7 continuation.
- Architecture:92 tables and 215 authored routes, all design contracts rather than
  extracted vendor internals. No application implementation exists.

## Claims corrected by the actual audits

| OpenCode summary claim | What the evidence supports | Resolution |
|---|---|---|
| Help-center captures were real UI states | Audits identified repeated icon artifacts | Keep files for provenance; exclude them as screen-layout proof |
| Simulator attempts captured internal screens | Earlier personalization gates obscured content | Use audit4's actual live-tour captures; historical gate captures stay labelled |
| people-empty was a true empty result | Audit6 shows91 employees, not no-results | No-results remains unobserved; no filename-based state inference |
| performance/onboarding/satisfaction were captured | Audit6 shows404 attempts | Browser7 adds valid Settings paths and task/packet/eNPS configuration; profile Performance and full review editor remain separate |
| live-snapshot was a Snapshot popup | It was search dropdown evidence, not detail | Browser8 search clicked through to profile; public P01 explains access-dependent routing |
| All admin gaps except preview were closed | Permission editor, review editor, offers and eNPS were not all proved | Browser7 proves employee grant editor/preview and trial-gated eNPS; public supplement covers documented behavior |
| CSS metrics were supplied | /tmp/live-metrics.json was not in the repo | Recovered original16-entry file, source route spec and nav list into repository |
|33 schema checks passed | Executable checker was outside the repo and used an absolute path | Recovered portable checker, pinned dependency/lockfile and GitHub CI |

## Evidence layers

1. Public marketing/store/demo references: layout and product claims only.
2. Audits1–6: visual corrections and original trial metrics.
3. Browser7: live user-account UI observations with explicit no-save boundary.
4. Browser8: search-to-profile result and public source clarification.
5. Authored design: data model/API plan/acceptance cases. Never label these recovered source code.

See [GAPS.csv](GAPS.csv) for each remaining limitation and its disposition.
