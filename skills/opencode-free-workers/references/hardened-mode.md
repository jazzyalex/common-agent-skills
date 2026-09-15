# Hardened mode

Read this reference only when the user requests strict containment, repository configuration is untrusted, or an authorized external-provider task still needs enforceable path and command limits. Hardened mode reduces risk but adds setup and verification cost. It does not make secrets suitable for delegation.

## Establish the boundary

Inventory the current worktree and preserve existing changes. State exact readable and editable paths, exact shell commands, forbidden directories, expected outputs, and stopping conditions. Prefer a sanitized staging copy if the provider should see only a small subset of otherwise authorized material.

Build a task-specific `OPENCODE_CONFIG_CONTENT` from the normal runner guard with these tighter rules:

- Keep `"share":"disabled"`, `"lsp":false`, and `"formatter":false`.
- Start the agent's `tools` map with `"*":false`; enable only required built-in tools.
- Treat OpenCode's `edit` and `write` tools as one write capability; enabling edit may resolve write as enabled, so constrain and verify their shared edit permission.
- Deny all permissions first, then allow exact read, edit, and shell patterns.
- Keep common secret files denied, including `.env`, `.env.*`, `*.pem`, and `*.key`.
- Enumerate inherited MCP server names without displaying credentials and set each server to `enabled:false`.
- Reject inherited instructions or agent overrides that conflict with the task or disclose inappropriate material.

Do not rely on prompts alone for a confidentiality boundary. Assess allowlisted shell commands for indirect network access, dependency installation, generated-file writes, Git mutations, and child processes.

## Check once before the run

Use the exact guarded environment, repository, and agent intended for execution:

```sh
OPENCODE_AUTO_SHARE=false \
OPENCODE_CONFIG_CONTENT='<exact-task-guard>' \
  opencode debug config --pure

OPENCODE_AUTO_SHARE=false \
OPENCODE_CONFIG_CONTENT='<exact-task-guard>' \
  opencode debug agent <plan-or-build> --pure
```

Require sharing, LSP, formatters, and MCP servers to resolve disabled. Confirm the effective tool and permission rules implement the declared boundary. Managed configuration can override inline configuration; refuse the run if the effective result differs or is ambiguous. Repeat these checks only after the guard or OpenCode configuration changes.

OpenCode may append access to `~/.local/share/opencode/tool-output/*`. That directory is shared across OpenCode tasks and can contain output from another repository or session. A sanitized repository copy does not isolate it. If this exception is unacceptable, do not delegate the task.

## Run and verify

Run `opencode run --pure --format json` with `OPENCODE_AUTO_SHARE=false`, the verified task guard, exact agent, model, and repository root. Reuse the same session and guard for corrections.

After coding, inspect the full diff and untracked files, require changes to stay within the authorized paths, and run the named checks independently. After review, validate every finding that will be reported. Export the session only when its recorded identity or full transcript is part of the required evidence.
