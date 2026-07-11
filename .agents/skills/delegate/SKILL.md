---
name: delegate
description: Delegate self-contained tasks to Claude or Codex subagents run as fresh CLI processes. Use proactively, without being asked, whenever work can be handed off — parallel research or code searches, bounded implementation chunks, independent reviews, second implementations for comparison. Pick the provider (Claude, Codex, or both) and tier that best fit each task. Not for consultations the user explicitly routed to a specific peer (use peer-consult for that).
---

# Delegate

Hand a self-contained task to a fresh Claude or Codex subagent and get back a
structured report. Each invocation is one subagent; run several in parallel for
independent tasks.

## When to delegate

- Research or code searches whose details you don't need in your own context.
- Bounded implementation chunks that can be specified up front and verified.
- Independent review passes over a diff, file, or subsystem.
- Getting two independent takes by sending the same task to both providers.

Do not delegate work that needs mid-task input from you or the user, or tasks
so small that writing the brief costs more than doing the work.

## Route the task

Classify the smallest adequate tier:

| Tier | Signals | Codex | Claude |
|---|---|---|---|
| `quick` | Narrow, bounded, one component | `gpt-5.6-terra`, medium | `claude-sonnet-4-6`, medium |
| `quick-context` | Still bounded; more context or nuance | `gpt-5.6-terra`, high | `claude-sonnet-5`, high |
| `standard` | Multi-file feature, ordinary design/debugging, meaningful trade-offs | `gpt-5.6-sol`, medium | `claude-opus-4-8`, medium |
| `deep` | Architecture, concurrency, security, broad ambiguity, high-impact choice | `gpt-5.6-sol`, high | `claude-opus-4-8`, high |

Pick the provider by judgment:

- Either provider handles general coding, research, and review well; when the
  task has no special pull, prefer the provider you are NOT running as, so the
  subagent brings an independent perspective.
- Use **both** (two invocations, same task) when you want independent
  perspectives on a risky or ambiguous problem, or when splitting parallel
  work across providers to avoid rate-limit contention.
- Honor an explicit user model preference only if it is in the allowed list:
  Codex `gpt-5.6-terra`/`gpt-5.6-sol`; Claude
  `claude-sonnet-4-6`/`claude-sonnet-5`/`claude-opus-4-8`. Never silently
  substitute another model.

Pick the mode:

- `read` (default): research, searches, reviews, second opinions. Subagent
  cannot modify files.
- `write`: implementation and refactors. Subagent may edit files and run
  commands inside the repo; it will not commit or push unless the task says to.

## Write the brief

The subagent starts with zero context. Write a self-contained task containing:

- The goal and definition of done.
- Relevant paths, symbols, error messages, or raw diff/plan text.
- Constraints (style, APIs to use or avoid, files off-limits).
- For `write` mode: how to verify (build/test commands).

Pass raw evidence; do not tell the subagent the answer you expect.

## Run it

Resolve `<skill-dir>` to the directory containing this `SKILL.md`. Send the
task on stdin; do not interpolate it into the shell command.

```bash
python3 <skill-dir>/scripts/delegate.py \
  --provider codex \
  --tier standard \
  --mode read \
  --repo "$PWD" <<'TASK'
<self-contained task brief>
TASK
```

Flags:

- `--provider claude|codex` (required)
- `--tier quick|quick-context|standard|deep` (default `standard`)
- `--mode read|write` (default `read`)
- `--model <approved-model>` for an explicit allowed override
- `--repo <dir>` (default cwd)
- `--timeout <seconds>` (default 1800)
- `--dry-run` to inspect routing and command construction without running

Parallel delegation: launch each invocation as a separate background shell
command, then collect the outputs. Never point two `write`-mode subagents at
overlapping files; split by file/directory or run them sequentially.

## Handle the result

The report ends with Summary / Details / Files changed / Verification / Open
questions sections. Then:

- Treat it as a subagent's claim, not ground truth: spot-check load-bearing
  findings, and for `write` mode review the diff (`git diff`) and re-run
  verification before building on it.
- Relay the outcome to the user in your own words; credit which provider/model
  produced it when it matters.
- On failure, report the provider, model, and exact error. Retry once with the
  same route if transient; escalate tier or switch provider only deliberately,
  and say you did.
