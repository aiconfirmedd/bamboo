# Setup intake form

Open [form.html](form.html) locally in Chrome/Edge/Firefox. It has no server or
external scripts. Fill the required organization/contact fields, account/resource
choices and operational preferences. Unknown decisions can stay deferred. No
passwords, API keys, access tokens, full database URLs or employee data belong here.
Use the secret-manager reference field for where credentials will be supplied later.

1. Click **Submit & download setup JSON**. This downloads bamboo-setup-submission.json;
   it does not transmit the form to any server. Save draft/import are available.
2. Upload that completed JSON to the setup operator or this chat, with the repo/version
   being handed over. Keep the response in private intake storage, not public GitHub.
3. Operator validates and prepares the configuration pack:

```sh
python3 scripts/prepare_setup.py /private/path/bamboo-setup-submission.json --check-only
python3 scripts/prepare_setup.py /private/path/bamboo-setup-submission.json --output work/prepared-setup
```

Output directory must be new. Generated files:

- setup-plan.json: normalized company/branding choices, references and unresolved actions.
- .env.setup.example: provided nonsecret inputs mapped to the application contract;
  credential placeholders remain for secure configuration.
- SETUP_NEXT_STEPS.md: operator steps for account provisioning and remaining gates.

The input form definition is embedded once in form.html and is also read by the
Python validator. Unknown keys, missing required fields, invalid selections/types,
embedded credential URLs and common token patterns are rejected. This is not a
complete secret detector; the submitter must keep credentials and HR records out.

The preparation command makes zero network calls, refuses existing output folders,
and keeps every deferred feature off. It does not create provider accounts, spend
money, send email, grant access, deploy an app or verify live connections. The
operator follows docs/CONNECTIONS.md and docs/REBUILD_RUNBOOK.md in the repository
once inputs and secure account access are available. App callbacks/adapters still
need implementation before actual integration verification.

To validate the shipped form itself: `python3 scripts/prepare_setup.py --check-template`.

Every field includes entry instructions and examples. Examples are illustrative,
not configured accounts. Required unresolved decisions offer a defer/operator choice.
For private online intake, follow the proposed [storage backend and implementation
handoff](../docs/SETUP_STORAGE.md). No online endpoint is deployed in this package.
