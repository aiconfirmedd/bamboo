# Comparison and portability audit8 — 2026-10-30

Compared 221 messages from OpenCode's original Bamboo session, persisted captures,
audits1–7 and GitHub main. Exact baseline tree/counts in
[CAPTURE-COMPARISON.md](../../docs/CAPTURE-COMPARISON.md).

## New observation and sources

Global search query Aaron returned a sample employee. Selecting it navigated to
the full Job profile; see browser-recon-8/search-result-profile.txt/png. This is
not a captured Snapshot. Public source P01 explains the full-access routing and
hover-card alternative. Added P02–P09 behavioral requirements for reviews/offers
and surveys without claiming newly observed editors or backend behavior.

Account capture stopped after the public terms check (P10). No account mutation,
source-code extraction, private endpoint capture, or gated help bypass in this audit.
Newly requested gap filling thereafter uses already collected evidence and public
documentation. Public help articles588033/960688/2007786 could not be read with
the web tool (CSS-error/access failure); those links remain classified as gated or
unreadable, not treated as absent features.

## Recovered artifacts and checks

Original /tmp/live-metrics.json, live-spec.json and nav.json now in the portable
archive. Metrics remain16 selector/viewport-specific entries; main selector may
hit nested markup, so use audit6's interpretation. Original schema check script
used an absolute machine path and external npm setup. It now resolves schema
relative to this repo and pins PGlite 0.5.13. Running it freshly applied all 92 tables
and passed 33 checks on in-memory PostgreSQL-compatible engine 18.6.

Added offline catalogs, hashes, local-link/anchor checks, portable contrast check,
GitHub Actions, owner-content examples, recipient/upload guides and a consolidated recipient handoff. A functioning application is intentionally absent. All 80 clone flags
stay no. Gap dispositions distinguish observed, documented, partial, trial-gated,
not-tested and excluded; remaining observation gaps are not silently closed.
