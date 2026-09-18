---
name: cline-free-workers
description: Delegate bounded code review or coding work to promotional free models through Cline CLI. Use when Cline is the requested harness or its current DeepSeek or Muse free routes are useful; keep repository, Git, quota, and final verification under the parent agent's control.
---

# Cline Free Workers

Use Cline as a subordinate worker. The parent agent owns task scope, acceptable disclosure, repository state, verification, and the final conclusion.

## Choose suitable work

Use Cline for a substantial bounded task, not a tiny lookup or formatting request: its harness adds several thousand input tokens to each run. Good tasks include a focused diff review, a self-contained debugging problem, or a selected implementation.

Treat promotional free models as external services. Do not include credentials, secrets, private session exports, or personal data. The parent chooses the files or diff to disclose; do not add repository-wide privacy scans.

Do not make a free worker the sole authority for security or privacy approval, destructive migrations, release readiness, or public claims.

## Select a model and effort

Use an exact model ID and never fall back to a paid model.

- Default: `cline-free/deepseek-v4.1-flash` for coding and code review.
- Fallback: `cline-free/muse-spark-1.3-contributor`. Use its multimodal capability only through a Cline surface that can directly attach the supplied media.
- Experimental second opinion: `z-ai/glm-5.3-flash`, only after the current Cline selector still labels it free. Its ID and CLI metadata do not prove that status.

Do not use Solar Pro or Laguna through this skill. Free promotions rotate, so recheck the selector only when an ID fails or when using GLM; do not spend a request merely to probe quota.

Effort is deterministic:

- `low` for mechanical changes, summaries, and narrow first-pass reviews.
- `default` for ordinary implementation and review.
- `high` for difficult root-cause analysis, concurrency, migrations, cross-component behavior, or a failure-sensitive second review.
- This skill caps delegated effort at `high`; keep more expensive effort in the parent session unless the user explicitly requests a separate experiment.

## Prepare the task

Give the worker one objective, exact relevant material or paths, expected output, allowed files, useful test commands, and a stopping condition.

Review mode has no approved tools. Include the relevant diff or source in the prompt rather than asking Cline to explore the repository. Coding mode may edit and run commands, so use it only in a clean disposable worktree or equivalent scratch checkout already chosen by the parent.

The parent chooses branches and worktrees and owns fetch, pull, commit, push, and publication. The worker must not perform those operations.

## Run

Use the bundled runner:

```sh
<skill-directory>/scripts/run-worker.sh \
  <review|coding> <exact-model-id> <repository-root> \
  <low|default|high> '<task-prompt>'
```

Append a Cline session ID to continue the same run with the same mode, model, and repository root. Do not start a duplicate while a run may still be active.

The runner uses normal Cline authentication and session storage; it does not create an isolated database or configuration. It forces the local session backend, does not connect the session to a Cline hub or publish it, pins the model, bounds retries and runtime, and blocks Git publication and common network shell commands in coding mode.

Review mode explicitly disables auto-approval. Coding mode requires auto-approval to work headlessly and is not a security sandbox: prompts, file tools, browser tools, or inherited integrations can exceed shell-command restrictions. Use OpenCode or a stronger external sandbox when that risk is unacceptable.

## Verify efficiently

Reject canceled, timed-out, quota-limited, or nonzero-cost runs even if they contain partial prose. If the error includes `try again in`, report that reset estimate. Try at most one other currently verified free route; never silently switch to paid usage.

For coding, inspect the full diff and untracked files and run proportionate tests independently. For review, validate only findings the parent intends to report. After two failures on the same issue, stop delegating and finish with the parent agent.
