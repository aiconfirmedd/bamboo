# Upload or hand off this repository

## Use with a coding agent

Upload the ZIP or extract it as a local project. The ZIP contains one consolidated START_HERE.md handoff with linked supporting files. Start with [START_HERE.md](START_HERE.md),
then follow its setup-only takeover steps. Ask the recipient to read the
brief and implementation guide before changing files. Missing observations are
recorded in [docs/GAPS.csv](docs/GAPS.csv); do not ask an agent to invent them.

## Upload to a new GitHub repository

1. Extract the ZIP. Create an empty repository under the intended account.
2. From the extracted directory run:

```sh
git init -b main
git add .
git commit -m "Add Bamboo reference and implementation handoff"
git remote add origin https://github.com/YOUR_ACCOUNT/YOUR_REPOSITORY.git
git push -u origin main
```

Replace the account/repository placeholders. The ZIP intentionally excludes .git,
node_modules, credentials, browser profiles and machine-specific work files. GitHub
Actions validates the reference and schema after upload. No site or backend is
deployed by uploading this specification repository. Choose repository visibility
appropriate to the reference material you intend to share.

## Validate locally

Python 3 is enough for reference integrity/contrast checks:

```sh
python3 scripts/verify_reference.py
python3 scripts/check_contrast.py
```

Node 20+ is required only for the executable in-memory schema checks:

```sh
npm ci --ignore-scripts
npm run check:schema
```

Open index.html for the offline evidence gallery, or run
`python3 -m http.server 8000` and open http://localhost:8000/ .
No credentials or external database needed for these checks.
