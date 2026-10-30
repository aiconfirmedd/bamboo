# Adapt for your agency

This repository is specifications and evidence. Example config/data are contracts,
not a working configuration loader or database import. After implementation starts:

1. Replace [brand example](../config/brand.example.json) with original company identity, logo and palette.
2. Replace [synthetic seed example](../data/seed.example.json) with authorized original content; map it to the proposed schema.
3. Prune/reprioritize [features](../replica/features.csv) for the recipient's clientele. Keep out-of-scope and skipped partner rails explicit.
4. Follow [build order](architecture/build-order.md). Wire owner's OIDC, Postgres, private R2, mail and jobs only when those flows exist. [Environment example](../.env.example) contains placeholders.
5. Write original offer/onboarding/legal copy, survey questions, core values and resources. Never ship reference images or substitute proprietary content.
6. Implement/test role projection, review release, anonymous response boundaries and external-effect idempotency against local synthetic data before sending any real communication.
7. Re-run contrast after palette changes. Set clone=yes only after behavior works and is verified.

Agency-specific extensions include requisition approval, client attribution and
recruiter collaboration. The intake approval is an independent product addition;
client staffing/payroll/benefits features are not silently added to this scope.
