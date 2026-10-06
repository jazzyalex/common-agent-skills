# Common Agent Skills

Useful agent skills for Codex, Claude, and other compatible agents. Most skills are portable; platform-specific skills state their requirements explicitly.

Each canonical skill lives under `skills/<skill-name>/`. Its `SKILL.md` contains the portable default workflow. Conditional or high-cost procedures belong in linked references and are loaded only when needed. Product-specific optional metadata belongs in clearly scoped locations such as `agents/openai.yaml`; the portable workflow must not depend on that metadata.

## Install

Run:

```sh
./scripts/install.sh
```

The installer links each skill into the local Codex, Claude, and shared agent skill directories. It refuses to overwrite an existing file, directory, or different symlink.

After pulling changes, the linked installations update immediately because the repository copy remains canonical.

## Included skills

- [`luna-max`](skills/luna-max/SKILL.md) requests GPT-5.6 Luna with max reasoning in the current conversation. **Codex Desktop only**: requires the Desktop thread tools.

- `free-model-workers` selects a currently free harness, model, and effort for bounded delegated work.
- `cline-free-workers` runs bounded Cline review or coding workers without isolated session storage.
- `opencode-free-workers` runs bounded OpenCode review or coding workers with session sharing disabled.

## Luna Max (Codex Desktop only)

Save [the skill file](skills/luna-max/SKILL.md) as `~/.codex/skills/luna-max/SKILL.md`, then invoke `$luna-max` in your Codex Desktop conversation. It uses `mcp__codex_app__list_threads` and `mcp__codex_app__send_message_to_thread`; it cannot run in clients without these tools. Installing it into another agent does not make those tools available.

The default is Luna 5.6 with max reasoning. To adapt it to Luna 6.1 or another available model, update the model ID and matching wording throughout the file. Model availability depends on your app and account.

## Contributing

Useful skills, fixes, and clearer instructions are welcome through issues and pull requests. State any required app, tool, or model and include an example of how to invoke the skill.

## Safety

- Do not store credentials, private session exports, customer data, or machine-specific secrets in this repository.
- Review provider-disclosure rules before invoking a skill that sends material to another service.
- This repository is public. Inspect every staged change for private data and machine-specific details before pushing.
