# HiddenLayer SDK Track (Instruqt Lab)

Instruqt 2.0 lab, ported from the V1 track `jparton-challenge/hiddenlayer-sdk-track` using the code flow.

Teaches the HiddenLayer Python SDK across 7 challenges: scan ML models from local files, folders, HuggingFace, AWS S3, Azure Blob, and remote URLs.

## Structure

```
main.hcl        Lab metadata, settings, chapters/pages
sandbox.hcl     Infra: network, secrets, AWS/Azure accounts, containers, provisioning
tabs.hcl        Terminals, VSCode editor, cloud credentials tab
layouts.hcl     workstation (Ch 1-4,7) and cloud (Ch 5-6) layouts
pages.hcl       One page per challenge, wired to a completion task
tasks.hcl       Completion checks
instructions/   Markdown for each challenge
scripts/exec/   One-time sandbox provisioning (replaces V1 per-challenge setup)
scripts/task/   Task check scripts
```

## Prerequisites (on the connecting team)

- Team secrets `demo_client_id` and `demo_client_secret` (HiddenLayer API credentials).
- AWS and Azure cloud sandbox provisioning enabled (Challenges 5 and 6).

## Local development

```bash
instruqt lab validate    # validate this config
instruqt lab format      # format the HCL
```

Deployment is via the Instruqt labs UI: connect this GitHub repo to your team.

## Notes on the port

- V1 VM `shell-hl` -> `container "shell_hl"` (`python:3.12`); VSCode service tab -> `editor` tab.
- V1 `cloud-client` -> `container "cloud_client"` (`ubuntu:24.04`); AWS/Azure console tabs -> `cloud_credentials` tab.
- Per-challenge setup scripts consolidated into `scripts/exec/provision_*`.
- V1 `` ```run `` blocks are copy-only in V2; each challenge has a completion task instead.
- Challenge 3 scans `/root/models/batch` (the 3 batch models) so the "Files Scanned: 3" result is deterministic.
