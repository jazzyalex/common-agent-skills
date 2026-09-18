---
name: opencode-free-workers
description: Delegate bounded coding or read-only review work from a parent agent to free OpenCode models with session sharing disabled and lightweight local verification. Use when saving the parent agent's limits is useful and the task can be checked from a diff, tests, or source evidence; use hardened mode only when strict tool or path containment is required.
---

# OpenCode Free Workers

Use OpenCode as a subordinate worker. The parent agent owns scope, repository state, verification, and the final conclusion.

## Choose suitable work

Good default tasks are focused implementation, test writing, mechanical changes, and first-pass code review. Do not make a free worker the sole authority for security or privacy approval, destructive migrations, release readiness, or public claims.

Treat the selected OpenCode provider as an external service. Never send credentials, secrets, private session exports, or data the user has not authorized for that provider. A private repository is not automatically excluded: delegate when external-provider access is already authorized and the selected files are appropriate. If strict containment is required, read [Hardened mode](references/hardened-mode.md). Otherwise do not load it.

## Select a model

Use an exact model ID. Check `opencode models` only on first use, after an OpenCode upgrade, or when an ID fails.

- Default: `opencode/muse-spark-1.3-contributor-free`.
- Difficult implementation or review: the same Muse model with its `xhigh` variant.
- Small mechanical work: `opencode/ling-3.0-flash-fin-free`.
- Implementation fallback: `opencode/mimo-v2.5-free`.
- Harder or second review: `opencode/nemotron-3-ultra-free`.
- Avoid `opencode/nemotron-3.5-lightning-free` until revalidated.

Availability and behavior drift; do not treat this list as a permanent ranking.

Use Muse `xhigh` for difficult debugging, concurrency, cross-component changes, or a failure-sensitive review. Keep the default variant for ordinary work. Set `OPENCODE_WORKER_VARIANT=xhigh` on the runner invocation; do not assume other models expose the same variant.

## Prepare the task

Give the worker one objective, review or coding mode, relevant paths or diff, expected result, and useful test commands. For coding, name the files it may change and tell it to stop without committing. For review, request prioritized findings with file and line evidence.

The parent agent chooses branches and worktrees and owns fetch, pull, commit, push, and publication. The worker performs none of those operations. No preliminary commit or push is required.

## Run

Use the bundled runner. It uses OpenCode's normal headless execution path, the built-in `plan` or `build` agent, and disables automatic sharing:

```sh
<skill-directory>/scripts/run-worker.sh \
  <review|coding> <exact-model-id> <repository-root> '<task-prompt>'
```

For Muse `xhigh`:

```sh
OPENCODE_WORKER_VARIANT=xhigh \
  <skill-directory>/scripts/run-worker.sh \
  <review|coding> opencode/muse-spark-1.3-contributor-free \
  <repository-root> '<task-prompt>'
```

The free OpenCode provider currently rejects `opencode run --pure` and custom
`OPENCODE_CONFIG_CONTENT` tool/permission maps with a 403 stating that the free
tier must be used from within OpenCode. Do not add either one to this runner.
The built-in `plan` agent remains read-only for review; the parent still owns
scope, disclosure, and independent verification.

The runner intentionally does not pass OpenCode's global `--auto` flag. That
flag approves every permission not explicitly denied and is not a per-path
allowlist. If external material is needed, create a sanitized staging copy
inside the selected repository root, or choose an explicitly bounded root that
contains all authorized inputs. Do not use `OPENCODE_WORKER_AUTO`.

To continue the same worker session, append its session ID. Do not start a duplicate while a run may still be active.

The runner uses the normal OpenCode database; never create an isolated `OPENCODE_DB`. Run OpenCode commands sequentially. If the shared database is locked, wait for the other OpenCode process and retry the same command.

Review mode selects OpenCode's built-in `plan` agent. Coding mode selects the built-in `build` agent; the task prompt supplies the practical file and command boundary. The old inline tool/permission guard cannot be combined with the free provider. If strict technical containment is required, do not delegate that run to free Muse; use a validated compatible provider or hardened environment instead.

Never add `--share`, invoke `/share`, weaken the runner's sharing controls, or use another provider or credential route to bypass a failure.

## Verify efficiently

For coding, inspect the resulting diff and untracked files, then run proportionate tests. For review, verify only findings that the parent intends to report. Reject unsupported claims and scope drift.

Do not routinely export sessions, add response canaries, dump resolved configuration, or repeat the worker's checks. Use `opencode export`, effective-config inspection, and detailed evidence capture only for troubleshooting, benchmarks, model/cost claims, or hardened work.

After two failures on the same issue, stop delegating and finish with the parent agent.
