---
name: claude-code-computer-delegate
description: "Route Claude Code computer-use, browser-use, GUI automation, and workstation interaction tasks to Codex subagents only. Use when Claude Code needs another agent to inspect or operate a desktop app, browser, local UI, terminal-driven workflow, or repo task involving computer control. Always use GPT-5.6 Codex models only: gpt-5.6-terra for narrow/simple work and gpt-5.6-sol for complex/high-risk work. Never use gpt-5.6-luna, Luna aliases, Claude models, or non-GPT-5.6 Codex models."
---

# Claude Code Computer Delegate

## Overview

Delegate computer-use work from Claude Code to Codex subagents. Route every task to `gpt-5.6-terra` or `gpt-5.6-sol`; reject Luna and every other model.

## Hard Rules

- Use provider `codex` only.
- Use only `gpt-5.6-terra` or `gpt-5.6-sol`.
- Never use `gpt-5.6-luna`, `luna`, aliases, "latest", fallback models, Claude models, or pre-5.6 Codex models.
- If a requested model violates these rules, stop and report the conflict. Do not silently substitute.
- Do not delegate recursively. The Codex subagent must complete the task itself and report back.
- Prefer read-only delegation for inspection, diagnosis, screenshots, or review. Use write mode only for explicit implementation or file edits.

## Route Selection

Choose the smallest adequate route:

| Complexity | Use | Model | Effort |
|---|---|---|---|
| Narrow | Single screen, one command, simple browser/GUI check, small file inspection, bounded terminal task | `gpt-5.6-terra` | medium |
| Narrow but context-heavy | Same scope, but with long logs, many screenshots, or nuanced UI state | `gpt-5.6-terra` | high |
| Standard | Multi-step computer workflow, multi-file repo task, ordinary debugging, meaningful trade-offs | `gpt-5.6-sol` | medium |
| Deep | Architecture, security, concurrency, risky edits, broad ambiguity, high-impact user/system state | `gpt-5.6-sol` | high |

Default to `gpt-5.6-sol` when failure could change user data, spend money, publish, delete, overwrite, or affect credentials. Default to `gpt-5.6-terra` when the task is reversible, local, and easy to verify.

## Preferred Invocation

When the local `delegate` broker is available, use it because it enforces the approved Codex model set and safe execution modes:

```bash
python3 /Users/sudacode/.agents/skills/delegate/scripts/delegate.py \
  --provider codex \
  --tier quick \
  --mode read \
  --repo "$PWD" <<'TASK'
<self-contained computer-use task>
TASK
```

Map tiers as follows:

- `quick` -> `gpt-5.6-terra`, medium
- `quick-context` -> `gpt-5.6-terra`, high
- `standard` -> `gpt-5.6-sol`, medium
- `deep` -> `gpt-5.6-sol`, high

Use `--mode write` only when the user explicitly wants implementation or edits.

## Direct Codex Fallback

If the broker is unavailable, call Codex directly with an approved model:

```bash
codex exec \
  --ignore-user-config \
  --model gpt-5.6-terra \
  --config 'model_reasoning_effort="medium"' \
  --config 'approval_policy="never"' \
  --sandbox read-only \
  --ephemeral \
  --skip-git-repo-check \
  --cd "$PWD" \
  -
```

For write tasks, use `--sandbox workspace-write`; never grant broader access unless the user explicitly approves that exact operation.

## Task Brief

Write a complete brief; the Codex subagent starts with no conversation context. Include:

- Goal and definition of done.
- Exact app, browser tab, local URL, file path, command, or screen state involved.
- Constraints: forbidden actions, allowed edits, credentials/payment/publishing restrictions.
- Verification expected: screenshot, command output, tests, or concise report.
- Reporting format: summary, actions taken, evidence, files changed, verification, open questions.

Pass raw evidence such as errors, logs, screenshots paths, or diffs. Do not tell Codex the answer to find.

## Safety Checks

- Before launching: state selected model, tier, mode, and why.
- After completion: inspect the report and verify load-bearing claims before acting on them.
- For write mode: review `git diff` and run targeted tests/checks before reporting success.
- On failure: report selected model, exact command path used, and the error. Retry once only for transient failures, with the same allowed model family.
