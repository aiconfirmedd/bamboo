# Git-based reference handoff

Goal: transfer a reproducible specification and evidence baseline to the next builder.
One consolidated START_HERE.md is the entry. No duplicate handoff archives are required.
The Git commit being transferred is authoritative. Use a full commit SHA to pin the
reference; a downloaded ZIP is a convenience copy. The canonical repository is
https://github.com/aiconfirmedd/bamboo.

## Publisher procedure

1. Extract the package. Run reference/contrast/connection-contract/schema checks below.
2. Choose repository owner and visibility appropriate to reference material. Preserve
   MIT license for original docs/helpers and NOTICE for third-party reference images.
   Open-source helpers/specifications do not make vendor screenshots open-source assets.
3. Commit the validated files in the intended repository. For an existing checkout,
   review git status/diff first; preserve unrelated edits. For a new directory follow
   [UPLOAD.md](../UPLOAD.md). This procedure does not automatically push or deploy.
4. Create a release reference and push only after the publisher has selected the target:

```sh
git status --short
git diff --check
git add .
git commit -m "Prepare validated Bamboo implementation handoff"
git tag reference-v1.1.0
git push origin HEAD
git push origin reference-v1.1.0
git rev-parse HEAD
```

Use another unused tag if that one already exists. Record the full commit SHA in
an issue/release with scope, gap dispositions, passed check results, account owners
and the owner decisions still open. Never put secrets or login exports in that issue.

## Recipient acceptance procedure

```sh
git clone YOUR_GITHUB_REPO_URL bamboo
cd bamboo
git checkout TRANSFERRED_COMMIT_SHA
git rev-parse HEAD
python3 scripts/verify_reference.py
python3 scripts/check_connections.py
python3 scripts/check_contrast.py
npm ci --ignore-scripts
npm run check:schema
```

Replace TRANSFERRED_COMMIT_SHA with the publisher’s actual full commit SHA.
Compare the SHA with the publisher's record. Confirm START_HERE.md, config/connections.json,
OWNER_DECISIONS.csv and the current gap/state registers exist. Confirm this remains
reference-only and all feature clone flags are no. Read START_HERE.md, CONNECTIONS.md,
REBUILD_RUNBOOK.md and the acceptance cases. Accept/defer each gap explicitly; do not
silently reclassify missing evidence as proven UI behavior.

## Ongoing recon-to-build workflow

- Keep a protected reference tag. Create an implementation branch/worktree from its
  content; mark app implementation as a new authorized stage. Lock the actual stack
  versions then. Reference CI is not an application build pipeline.
- For a new observation, record source/date/environment/permissions and a unique
  evidence ID. Hash new assets; run catalog and duplicate checks. Use public sources
  and authorized permitted material; current account-terms boundary is in the source register.
- Change recon/component/API assumptions through a reviewed commit linked to its
  evidence/decision. Do not commit copied vendor JS, private APIs, browser profiles,
  tokens, production records or reference screenshots as app assets.
- Open one issue per rebuild milestone with feature rows, dependencies, acceptance
  evidence and owner. A PR must identify implemented vs deferred behavior and passing tests.
- Regenerate catalogs with python3 scripts/build_catalog.py after modifying reference
  files, then run checks. The immutable reference release remains reproducible; new
  reference changes get a new tag. Keep one current release ZIP.

## Sign-off record (put in the GitHub release/issue)

Record: repository URL; tag; full commit SHA; checker results; scope/exclusions;
remaining evidence gaps accepted/deferred; chosen IdP/providers; resource/account
owners; environment/domain names; credentials transferred via secret manager;
retention/backup decisions; first approved build milestone. Status advances through
reference accepted → app implemented → staging integrations verified → operationally
accepted. Receiving a ZIP or filling env variables does not skip these stages.

## Submitted setup inputs

Recipient completes [the offline form](../setup/form.html) and privately uploads its exported JSON. Operator runs scripts/prepare_setup.py to validate it and generate a local configuration/next-step pack. Follow [the intake workflow](../setup/README.md); never commit real submitted responses or credentials. This changes setup inputs, not live verification status.
