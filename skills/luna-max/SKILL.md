---
name: luna-max
description: Switch the current Codex conversation to GPT-5.6 Luna with max reasoning by sending an internal message when the user explicitly asks for Luna Max.
---

# Luna Max

Use this skill only when the user explicitly asks to change the current Codex conversation to “Luna Max,” “GPT-5.6 Luna max,” or an equivalent model-and-effort setting.

1. Call `mcp__codex_app__list_threads` and identify the active Codex thread for the current task. Prefer the entry whose title or summary matches the request and whose `cwd` matches the current workspace. Do not target a ChatGPT conversation or another unrelated active thread. If the target is not unique, ask the user which thread to change.
2. Call `mcp__codex_app__send_message_to_thread` with the selected thread’s `threadId` and `hostId`, using:
   - `model`: `gpt-5.6-luna`
   - `thinking`: `max`
   - `prompt`: `Switch this conversation to GPT-5.6 Luna with max reasoning effort and continue handling the user's request.`
3. Report that the internal message was accepted, including the target thread only if useful. Do not claim more than the tool result confirms.

This skill changes the Codex conversation model for the requested turn. It does not edit repository files, API configuration, provider settings, or unrelated threads.
