---
name: delegate
description: Delegate self-contained tasks to Claude or Codex subagents run as fresh CLI processes. Use proactively, without being asked, whenever work can be handed off — parallel research or code searches, bounded implementation chunks, independent reviews, second implementations for comparison. Pick the provider (Claude, Codex, or both) and tier that best fit each task. Not for consultations the user explicitly routed to a specific peer (use peer-consult for that).
---

# Delegate

Hand a self-contained task to a fresh `claude` or `codex` CLI process and get
back a structured report. Each invocation is one subagent; run several in
parallel for independent tasks.

You call the CLIs directly. The command shapes below are the default recipe,
not a fixed harness — adjust flags when the task needs it (extra directories,
different tools, a longer timeout), and say what you changed in your report.

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

Wrap the brief in this scaffold. Keep the constraint block matching the mode
and keep the report sections verbatim — the result-handling steps below assume
them.

```
You are a subagent completing a delegated task inside the current repository.
Work independently; the caller cannot answer questions mid-task. If the task is
ambiguous, choose the safest reasonable interpretation and note the choice in
your report.

<constraints for the chosen mode — see below>
- Do not delegate further or invoke Claude or Codex recursively.

End your reply with a report containing these sections:
- Summary: what you did or found, in a few sentences.
- Details: key evidence, decisions, or findings, with file:line references.
- Files changed: list each changed file, or "none".
- Verification: what you ran and the outcome, or "not verified" and why.
- Open questions: anything unresolved the caller must decide, or "none".

Task:
<self-contained task brief>
```

`read` constraints:

```
Hard constraints:
- You are in read-only mode. Do not modify, create, rename, or delete files.
- Do not commit, branch, push, or contact external systems that change state.
- Base claims on repository evidence. Cite file paths and line numbers.
```

`write` constraints:

```
Hard constraints:
- Work only inside the given repository directory.
- Do not commit, branch, push, or open pull requests unless the task says to.
- Do not delete or rename files the task does not cover; if something looks
  wrong or unexpected, stop and report instead of guessing.
- Verify your work (build, tests, or a targeted check) when feasible.
```

## Run it

Always send the prompt on stdin via a quoted heredoc (`<<'TASK'`) so nothing in
the brief is expanded or re-parsed by the shell. Run the CLI from the target
repo with `cd <repo> && ...`.

Codex, read-only:

```bash
cd /path/to/repo && codex exec \
  --ignore-user-config \
  --model gpt-5.6-sol \
  --config model_reasoning_effort="medium" \
  --config approval_policy="never" \
  --sandbox read-only \
  --ephemeral \
  --skip-git-repo-check \
  --output-last-message /tmp/delegate-codex-1.md \
  --cd /path/to/repo - <<'TASK'
<scaffold + brief>
TASK
cat /tmp/delegate-codex-1.md
```

Codex, write mode: swap `--sandbox read-only` for `--sandbox workspace-write`.

`--output-last-message` writes just the final report; Codex's stdout also
carries its reasoning stream, which is useful when a run fails or you want to
see what it actually did. Add `--add-dir <dir>` for extra writable roots.

Claude, read-only:

```bash
cd /path/to/repo && claude --print \
  --model claude-opus-4-8 \
  --effort medium \
  --disable-slash-commands \
  --no-session-persistence \
  --permission-mode plan \
  --tools Read,Glob,Grep <<'TASK'
<scaffold + brief>
TASK
```

Claude, write mode: replace the last two lines with

```bash
  --permission-mode acceptEdits \
  --tools Read,Glob,Grep,Edit,Write,Bash \
  --allowedTools Edit,Write,Bash
```

Claude prints the final message on stdout. Widen `--tools` when a task
genuinely needs more (for example `WebSearch` for external research, or
`Bash` in read mode for a `git diff` the subagent must see) — that is a
deliberate choice, so note it when you report back.

Give long runs a timeout that fits the task (the Bash tool's `timeout` is in
milliseconds; 1800000 is a reasonable ceiling for a `deep` tier run).

Parallel delegation: launch each invocation as a separate background shell
command, write each Codex report to its own `--output-last-message` path, then
collect the outputs. Never point two `write`-mode subagents at overlapping
files; split by file/directory or run them sequentially.

## Handle the result

- Treat the report as a subagent's claim, not ground truth: spot-check
  load-bearing findings, and for `write` mode review the diff (`git diff`) and
  re-run verification before building on it.
- Relay the outcome to the user in your own words; credit which provider/model
  produced it when it matters.
- On failure, report the provider, model, and exact error. A nonzero exit or
  empty output is a failure even if the CLI printed something — check both.
  Retry once with the same route if transient; escalate tier or switch provider
  only deliberately, and say you did.
