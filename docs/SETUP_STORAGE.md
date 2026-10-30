# Private setup intake backend

The standalone backend is implemented in [intake](../intake/README.md). Follow that
single deployment guide for database migration, verified organization login,
hosting secrets, scheduled deletion and acceptance tests. It requires no HR rebuild.

It uses Neon PostgreSQL for validated responses and a dedicated Flask/Gunicorn
container for online intake. The canonical [offline form](../setup/form.html) is
served with online submission added at runtime; no duplicate form specification.
[Neon security](https://neon.com/security) documents encryption at rest and transit.
The application also requires certificate-verified TLS, restricted runtime credentials,
server-side authorization, forced database RLS, CSRF checks and private exports.

No R2 bucket or file-scanning service is needed: only small structured JSON responses
are accepted. Secrets remain in the recipient's secret manager. GitHub stores source,
templates and tests, never actual responses, runtime environment files or credentials.

The implementation is included, but no live deployment or provider account is
configured by this repository. Owner approval of access, region, retention, recovery
and hosting costs remains part of deployment. The future HR application's proposed
Next.js/Vercel stack and feature flags remain independent of the intake service.
