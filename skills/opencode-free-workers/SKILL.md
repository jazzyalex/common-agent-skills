---
name: opencode-free-workers
description: Delegate bounded coding or read-only review work from a parent agent session to free OpenCode models with sharing disabled, restricted tools, and independent local verification. Use when preserving the parent agent's limits matters and the task can be packaged with exact scope and deterministic checks; do not use for OpenCode storage benchmarks.
---

# OpenCode Free Workers

Use OpenCode as a subordinate worker. The parent agent retains ownership of scope, repository state, verification, and the final conclusion.

## Decide whether to delegate

Delegate only when the task is bounded, the supplied material is safe for the selected provider, and the result can be checked from a diff, tests, or cited evidence. Do not delegate private session history, credentials, secrets, customer data, unsanitized artifacts, or inputs whose provider data terms are unacceptable.

Do not use a free worker as the sole authority for architecture, security or privacy approval, destructive migrations, release readiness, evidence qualification, or public claims. It may produce a first pass or independent review; the parent agent must adjudicate it.

Free endpoints and model IDs change. Before the first submission in a task, run `opencode --version` and `opencode models`, then select an exact currently listed ID. Never rely on OpenCode's default model.

## Never share worker sessions

OpenCode sharing uploads the conversation and creates a public link. This skill never shares or auto-shares a session. Do not pass `--share` or invoke `/share`.

Every preflight, initial run, and continuation must set `OPENCODE_AUTO_SHARE=false` and include `"share":"disabled"` in the inline `OPENCODE_CONFIG_CONTENT` guard. Run `opencode debug config --pure` with the exact environment from the target repository and require the effective value to be `share: disabled`. Refuse the submission if a managed configuration overrides it or the value cannot be verified. Do not change the repository's or user's persistent OpenCode configuration. If the user asks to share an OpenCode worker session, stop using this skill rather than weakening this invariant.

## Route the work

Starting policy, based on a bounded local September 2026 bake-off:

- Prefer `opencode/muse-spark-1.3-contributor-free` for ordinary coding and review.
- Use `opencode/ling-3.0-flash-fin-free` for small mechanical tasks with narrow path and command limits; expect more exploratory tool use.
- Use `opencode/mimo-v2.5-free` as a secondary implementation worker.
- Use `opencode/nemotron-3-ultra-free` for harder analysis or a second review when latency is acceptable.
- Do not select `opencode/nemotron-3.5-lightning-free` until it is revalidated; it failed the controlled tool-use and canary workload.
- Prefer Muse 1.3 over Muse 1.2 unless version comparison is the task.

Treat this as routing evidence, not a permanent ranking. Re-run a small synthetic calibration after a material OpenCode or model change.

## Prepare the packet

Inventory the target repository and current worktree first. Preserve pre-existing changes. The parent agent owns all repository-topology and remote-Git decisions: selecting or creating branches and worktrees, switching checkouts, fetching, pulling, committing, and pushing. The worker must perform none of those operations, and delegation does not require a preliminary commit or push. Give the worker:

- one objective and whether the mode is review or coding;
- the repository root and exact allowed paths;
- forbidden paths, repositories, network access, and mutations;
- the relevant source or diff rather than unrelated context;
- exact acceptance commands and expected outcomes;
- a unique final response canary;
- required reporting: files changed, findings or implementation summary, commands and results, uncertainty, session ID, model ID, and failures.

For read-only review, explicitly forbid edits, formatting, dependency changes, commits, pushes, and publication. Ask for prioritized findings with exact file and line evidence, concrete failure modes, and smallest fixes. Use the `plan` agent with only read, grep, and glob enabled; deny edit, shell, web, subagent, and external-directory access. The `plan` label alone is not a read-only boundary.

For coding, state the approved design and file boundary. Require the worker to inspect before editing, make the smallest change, run the named checks, and stop without committing or publishing. Use the `build` agent with an inline permission configuration generated for that task: deny all tools first, enable only the necessary built-in tools, allow edits only to the declared paths, and allow only the exact inspection and test commands. Deny web, subagent, external-directory, commit, push, and publication paths. OpenCode shell commands run with host authority, so assess each allowlisted command for indirect network or mutation before submission. Do not pass `--auto`.

If the repository contains material that the provider must not receive, do not point OpenCode at it. Use a user-authorized sanitized staging copy containing only the allowed inputs, or keep the task with the parent agent. Prompt-only path restrictions are not a confidentiality boundary.

## Run with a guarded effective configuration

Use the normal OpenCode session database. This skill does not create or select an isolated `OPENCODE_DB`. Run OpenCode preflights, worker invocations, exports, and continuations sequentially because concurrent processes can contend on the shared database. If a command reports `database is locked`, let the competing OpenCode process finish and retry the same command; do not work around contention with another database.

Review template:

```sh
OPENCODE_AUTO_SHARE=false \
OPENCODE_CONFIG_CONTENT='{"share":"disabled","lsp":false,"formatter":false,"agent":{"plan":{"tools":{"*":false,"read":true,"grep":true,"glob":true},"permission":{"read":{"*":"allow","*.env":"deny","*.env.*":"deny","*.pem":"deny","*.key":"deny"},"edit":"deny","bash":"deny","webfetch":"deny","websearch":"deny","task":"deny","external_directory":"deny"}}}}' \
  opencode run --pure --format json \
  --agent plan \
  --model <exact-free-model-id> \
  --dir <absolute-repository-root> \
  '<bounded-review-prompt>'
```

Coding template:

```sh
OPENCODE_AUTO_SHARE=false \
OPENCODE_CONFIG_CONTENT='<task-specific-json-with-share-lsp-and-formatter-disabled-and-deny-first-build-permissions>' \
  opencode run --pure --format json \
  --agent build \
  --model <exact-free-model-id> \
  --dir <absolute-repository-root> \
  '<bounded-coding-prompt>'
```

Build the task-specific JSON in this shape, adding only the exact allowed files and commands after the deny rules:

```json
{
  "share": "disabled",
  "lsp": false,
  "formatter": false,
  "agent": {
    "build": {
      "tools": {
        "*": false,
        "read": true,
        "grep": true,
        "glob": true,
        "edit": true,
        "bash": true
      },
      "permission": {
        "read": {
          "*": "allow",
          "*.env": "deny",
          "*.env.*": "deny",
          "*.pem": "deny",
          "*.key": "deny"
        },
        "edit": {
          "*": "deny",
          "<allowed-file>": "allow"
        },
        "bash": {
          "*": "deny",
          "<exact-allowed-command>": "allow"
        },
        "webfetch": "deny",
        "websearch": "deny",
        "task": "deny",
        "external_directory": "deny"
      }
    }
  }
}
```

Before submitting, use the same two environment values and the same agent as the intended run:

```sh
OPENCODE_AUTO_SHARE=false \
OPENCODE_CONFIG_CONTENT='<the-exact-inline-guard>' \
  opencode debug config --pure

OPENCODE_AUTO_SHARE=false \
OPENCODE_CONFIG_CONTENT='<the-exact-inline-guard>' \
  opencode debug agent <plan-or-build> --pure
```

Inspect both resolved outputs. Require sharing, LSP, and formatters to be disabled and the runtime agent's tools and permissions to match the guard. LSP servers and formatters can start subprocesses without using the `bash` tool, so never omit these top-level disables; the parent agent runs any needed formatting or language checks independently. List configured MCP server names without exposing their credentials; add an `enabled:false` inline override for every inherited MCP server, then re-run both checks and require all MCP servers to be disabled. The deny-first `tools` map is an additional guard against MCP tool use, not a substitute for preventing the servers from starting. Review inherited instruction paths and agent overrides; if they contradict the packet or cannot be safely disclosed to the provider, do not submit.

OpenCode may append a runtime `external_directory` allow for its managed `~/.local/share/opencode/tool-output/*` path even when the inline agent configuration denies external directories. Treat that exact path as a disclosed OpenCode runtime exception because it is shared across OpenCode tasks and may contain tool output from another repository or session. Permission rules are ordered, so inherited allow entries may still appear earlier in the dump; require the later catch-all deny to make their effective access denied, with only the exact tool-output exception allowed afterward. A sanitized repository copy does not isolate this shared path. If the effective result is ambiguous, or the disclosure boundary cannot permit the exception, keep the task with the parent agent.

`OPENCODE_CONFIG_CONTENT` normally has higher precedence than project and user configuration, but managed configuration may override it. If the effective configuration differs from the guard, refuse the run rather than editing persistent configuration.

Use `--session <session-id>` with the same model, agent, repository root, and guarded environment when the task requires a correction or continuation. Do not start a duplicate while a submitted run may still be active.

`--pure` disables external plugins; it does not by itself disable MCP, sharing, LSP, formatters, inherited instructions, or host network access through an allowed shell command. Provider terms still apply. Do not use an alternate browser, provider, model, repository, or credential route to work around a failure.

## Verify independently

After the worker finishes, the parent agent must:

1. Confirm the JSON stream's session ID and inspect that session with `opencode export <session-id>`; require the recorded model to match the requested model and note reported cost without assuming that `$0` guarantees permanent free availability.
2. For coding, inspect the full diff and untracked files, verify only authorized paths changed, and run proportionate tests independently.
3. For review, validate each claimed finding against the current checkout; omit unsupported findings and separate defects from hypotheses.
4. Check the final canary and report missing canaries, tool errors, scope drift, or unexpected filesystem access.
5. Preserve the worker's failure as evidence. Authentication, runtime, capture, or model failure is not proof about code quality.

Stop delegating and return the task to the parent agent when the worker fails twice on the same issue, violates scope, cannot produce reproducible evidence, or reaches a decision reserved for the parent. A successful worker run is not permission to commit, push, publish, or broaden the task.
