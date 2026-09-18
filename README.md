# Common Agent Skills

Vendor-neutral agent skills shared across Codex, Claude, and other compatible agents.

Each canonical skill lives under `skills/<skill-name>/`. Its `SKILL.md` contains the portable default workflow. Conditional or high-cost procedures belong in linked references and are loaded only when needed. Product-specific optional metadata belongs in clearly scoped locations such as `agents/openai.yaml`; the portable workflow must not depend on that metadata.

## Install

Run:

```sh
./scripts/install.sh
```

The installer links each skill into the local Codex, Claude, and shared agent skill directories. It refuses to overwrite an existing file, directory, or different symlink.

After pulling changes, the linked installations update immediately because the repository copy remains canonical.

## Included skills

- `free-model-workers` selects a currently free harness, model, and effort for bounded delegated work.
- `cline-free-workers` runs bounded Cline review or coding workers without isolated session storage.
- `opencode-free-workers` runs bounded OpenCode review or coding workers with session sharing disabled.

## Safety

- Do not store credentials, private session exports, customer data, or machine-specific secrets in this repository.
- Review provider-disclosure rules before invoking a skill that sends material to another service.
- This repository is public. Inspect every staged change for private data and machine-specific details before pushing.
