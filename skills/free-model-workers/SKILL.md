---
name: free-model-workers
description: Route bounded coding and review work from a parent agent to a currently free OpenCode or Cline model. Use when saving the parent model's limits matters and the user has not already chosen the harness; do not use it as an authority for high-risk conclusions.
---

# Free Model Workers

Choose the harness, model, and effort before delegating. The worker never chooses its own route. The parent remains responsible for scope, Git state, verification, and the final answer.

## Decide whether to delegate

Delegate a task only when it is bounded, substantial enough to justify harness overhead, and independently checkable from source evidence, a diff, or tests. Keep the work in the parent session when preparing and verifying the packet would cost as much as doing it directly.

Do not send credentials, secrets, private session exports, or personal data. The parent decides which material is appropriate for the selected external provider; do not perform broad precautionary scans.

## Choose the harness

Honor an explicit user choice among the allowed free routes first. Otherwise use this order:

| Task | Harness | Reason |
| --- | --- | --- |
| Bounded review or debugging from a supplied packet | Cline | DeepSeek V4.1 Flash is the strongest currently tested default and needs no repository tools. |
| Image, video, or document reasoning | Cline with Muse, only when the current surface can directly attach that media | Avoid pretending a text-only runner supplied the attachment. |
| Repo-aware coding, test writing, or mechanical edits | OpenCode | Its worker runner provides narrower repository tool controls; Muse `xhigh` is available for hard work. |
| Independent second review | The harness/model family that did not produce the change | Reduces correlated blind spots. |

If the preferred CLI is unavailable or its free quota is exhausted, use one verified free fallback suitable for the same task. If that fails, stop delegation. Never switch providers, credentials, or paid models merely to finish the run.

Before using a harness, read its installed provider skill:

- `cline-free-workers` for Cline.
- `opencode-free-workers` for OpenCode.

## Choose the model

- Cline review or difficult bounded reasoning: `cline-free/deepseek-v4.1-flash`.
- Multimodal work or shared fallback: Muse Spark 1.3 on the chosen harness.
- Difficult repo-aware coding or review: OpenCode Muse Spark 1.3 with `OPENCODE_WORKER_VARIANT=xhigh`.
- Small mechanical OpenCode work: use the lightweight model selected by `opencode-free-workers`.
- Hard independent review: use the stronger review model selected by `opencode-free-workers` when Cline produced the first result.
- GLM through Cline is experimental and must still be visibly labeled free at selection time.

Never choose Solar Pro or Laguna. Treat Muse promotions and all other free catalogs as temporary; exact provider skills own their current IDs.

## Choose effort

Apply this mapping when the chosen harness exposes an effort control. Otherwise keep its provider default and use the provider skill's model tier for task complexity.

- `low`: mechanical edits, summaries, classification, and narrow first-pass review.
- Provider default: normal implementation, tests, and ordinary review.
- `high`: difficult bounded work through Cline, or another harness where `high` is the strongest suitable verified setting.
- OpenCode Muse `xhigh`: difficult debugging, concurrency, migrations, behavior spanning several components, or a failure-sensitive second review.

Task length alone does not justify higher effort. Prefer one coherent packet over many tiny worker calls.

## Hand off and verify

Give the selected worker one objective, only the necessary context, exact output expectations, allowed files for coding, useful test commands, and a stopping condition. The parent chooses branches and worktrees and owns all fetch, pull, commit, push, and publication decisions.

Use at most one fallback run. Verify the resulting diff, tests, or reportable findings independently and reject scope drift, unsupported claims, canceled runs, and any run that is no longer free.
