# Evidence and provenance

- [Screens and assets](inventory/assets.csv): every image, source category and hash.
- [All files](inventory/files.json): SHA-256 inventory for this distributable.
- [Stable screen IDs](inventory/screens.csv):39 original screen IDs.
- [Source routes](inventory/routes.csv): observed browser URLs, provenance and auth requirement; not clone API routes.
- [Public source register](public-sources/sources.csv): exact URLs and supported claims.
- [Comparison](CAPTURE-COMPARISON.md) and [gap register](GAPS.csv).
- [Original CSS metrics](../replica/evidence/opencode-original/live-metrics.json), [capture spec](../replica/evidence/opencode-original/live-spec.json), [navigation](../replica/evidence/opencode-original/nav.json).
- [Browser7 evidence](../replica/evidence/browser-recon-7/manifest.json).

Evidence hierarchy: observed pixels/AX > source documentation for documented behavior
> inferred data model/independent implementation requirements. Marketing, simulator,
trial admin and mobile sources are different environments. A URL, title, label or
button does not establish successful page load, persistence, delivery or enforcement.

Help-center hc-* images were judged to be icons by earlier audits; they remain
provenance artifacts, not valid full-screen references. Transient blank captures
remain labelled as attempts. Never render these images as application UI.

Original customer trial material is a reference archive, not a redistributable
application asset library. Package includes no login/session cookies, browser profile,
API keys, model credentials, raw OpenCode transcript, or vendor HTML/JS bundles.

The current [state coverage](STATE_COVERAGE.csv), [link index](LINKS.md) and [audit8](../replica/design/design-audit-8.md) complement the original capture evidence.

## Deduplication

Byte-identical images were consolidated after the capture comparison. Historical audit filenames/counts describe the original acquisition, not the number of unique stored images. Use [deduplication.csv](inventory/deduplication.csv) to map removed names to identical canonical files. No distinct image content was discarded. START_HERE.md is the single recipient handoff; overlapping summaries/full-text copies were consolidated.
