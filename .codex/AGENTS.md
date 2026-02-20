# AGENTS.MD

Work style: telegraph; noun-phrases ok; drop grammar; min tokens.

## Agent Protocol

- Contact: Kyle Yasuda (@sudacode, <suda@sudacode.com>).
- Workspace: `~/Projects`.
- “MacBook Air” / “Mac Mini” => SSH there; find hosts/IPs via `tailscale status`.
- PRs: use `gh pr view/diff` (no URLs).
- “Make a note” => edit AGENTS.md (shortcut; not a blocker). Ignore `CLAUDE.md`.
- No `./runner`. Guardrails: use `trash` for deletes.
- Need upstream file: stage in `/tmp/`, then cherry-pick; never overwrite tracked.
- Bugs: add regression test when it fits.
- Keep files <~500 LOC; split/refactor as needed.
- Commits: Conventional Commits (`feat|fix|refactor|build|ci|chore|docs|style|perf|test`).
- Subagents: read [Subagent Coordination Protocol](#subagent-coordination-protocol).
- If `Backlog.md` is set up for the project, each task must be associated with a ticket on the backlog. Create a new ticket on the board if it does not already exist
- Editor: `code <path>`.
- CI: `gh run list/view` (rerun/fix til green).
- Prefer end-to-end verify; if blocked, say what’s missing.
- New deps: quick health check (recent releases/commits, adoption).
- Slash cmds: `~/.codex/prompts/`.
- Web: search early; quote exact errors; prefer 2024–2025 sources; fallback Firecrawl (`pnpm mcp:*`) / `mcporter`.
- Style: telegraph. Drop filler/grammar. Min tokens (global AGENTS + replies).

## Important Locations

- Blog repo: `~/projects/sudacode-blog`
- Obsidian Vault: `~/S/obsidian/Vault` (e.g. `mac-studio.md`, `mac-vm.md`)

<CRITICAL_INSTRUCTION>

## Subagent Coordination Protocol (`docs/subagents/`)

Purpose: multi-agent coordination across runs; single-agent continuity during long runs.

Layout:

- `docs/subagents/INDEX.md` (active agents table)
- `docs/subagents/collaboration.md` (shared notes)
- `docs/subagents/agents/<agent_id>.md` (one file per session/instance)
- `docs/subagents/archive/<yyyy-mm>/` (archived histories)

Required behavior (all agents):

1. At run start, read in order:
   - `docs/subagents/INDEX.md`
   - `docs/subagents/collaboration.md`
   - your own file: `docs/subagents/agents/<agent_id>.md`
   - optional/contextual: other agent files relevant to your task/handoff.
2. Session identity:
   - one runtime instance = one agent file (Codex/OpenCode/Claude Code session each gets separate file).
   - never reuse another active session file.
   - if multiple terminals/sessions open at once, expect multiple files.
3. Agent ID rules:
   - if `AGENT_ID` present: use it.
   - default (no env): `agent_id = <runtime>-<task_slug>-<utc_compact>-<rand4>`.
   - `<runtime>`: `codex|opencode|claude-code`.
   - `<task_slug>`: short slug from current task/user ask.
   - `<utc_compact>` example: `20260219T154455Z`.
   - `<rand4>`: 4-char base36 suffix.
   - collision rule: if file exists, regenerate suffix until unique.
4. Alias + mission:
   - if `AGENT_ALIAS` present: use it; else default `<runtime>-<task_slug>`.
   - mission: one line; specific task focus.
5. Before coding:
   - record intent, planned files, assumptions in your own file.
6. During run:
   - update on phase changes (plan -> edit -> test -> handoff),
   - heartbeat at least every `HEARTBEAT_MINUTES` (default 5),
   - update your own row in `INDEX.md` (`status`, `last_update_utc`),
   - append cross-agent notes in `collaboration.md` when needed.
7. Access limits:
   - MAY read other agent files for context/handoff.
   - MAY edit own file.
   - MAY append to `collaboration.md`.
   - MAY edit only own row in `INDEX.md`.
   - MUST NOT edit other agent files.
8. Self-cleanup loop (required):
   - at each heartbeat, verify own file accuracy:
     - status current,
     - planned/touched files current,
     - assumptions still valid,
     - stale notes collapsed into short summary.
   - remove/trim outdated items in own file; keep handoff-ready.
   - evict completed task details older than `72h` from own file.
   - archive evicted content to `docs/subagents/archive/<yyyy-mm>/agents-<agent_id>-<yyyy-mm-dd>.md` (append + timestamped bullets).
9. Collaboration hygiene (required):
   - keep `collaboration.md` structured by dated sections (`## YYYY-MM-DD`).
   - append-only for normal work.
   - periodic cleanup pass (at least daily by any active agent):
     - dedupe repeated notes,
     - mark resolved items,
     - move resolved items older than `7d` and stale bulk context to `docs/subagents/archive/<yyyy-mm>/collaboration-<yyyy-mm-dd>.md`,
     - leave short index/summary in `collaboration.md`.
10. At run end:
   - record files touched, key decisions, assumptions, blockers, next step for handoff.
11. Conflict handling:
   - if another agent touched your target files, add conflict note in `collaboration.md` before continuing.
12. Parallel bookkeeping:
   - do `subagents/*` coordination + backlog ticket association in parallel when independent.
   - do not block one on the other unless dependency exists.
   - before coding: both present (active agent record + linked backlog ticket when `Backlog.md` is configured).
13. Brevity:
   - terse bullets; factual; no long prose.

Suggested env vars (optional):

- `AGENT_ID` (optional override)
- `AGENT_ALIAS` (optional override)
- `HEARTBEAT_MINUTES` (optional, default 5)

## Docs

- Keep notes short; update docs when behavior/API changes (no ship w/o docs).
- Add `read_when` hints on cross-cutting docs.

## PR Feedback

- Active PR: `gh pr view --json number,title,url --jq '"PR #\\(.number): \\(.title)\\n\\(.url)"'`.
- PR comments: `gh pr view …` + `gh api …/comments --paginate`.
- Replies: cite fix + file/line; resolve threads only after fix lands.
- When merging a PR: thank the contributor in `CHANGELOG.md`.

## Flow & Runtime

- Use repo’s package manager/runtime; no swaps w/o approval.
- Use Codex background for long jobs; tmux only for interactive/persistent (debugger/server).

## Build / Test

- Before handoff: run full gate (lint/typecheck/tests/docs).
- CI red: `gh run list/view`, rerun, fix, push, repeat til green.
- Keep it observable (logs, panes, tails, MCP/browser tools).
- Release: read `docs/RELEASING.md` (or find best checklist if missing).

## Git

- Safe by default: `git status/diff/log`. Push only when user asks.
- `git checkout` ok for PR review / explicit request.
- Branch changes require user consent.
- Destructive ops forbidden unless explicit (`reset --hard`, `clean`, `restore`, `rm`, …).
- Don’t delete/rename unexpected stuff; stop + ask.
- No repo-wide S/R scripts; keep edits small/reviewable.
- Avoid manual `git stash`; if Git auto-stashes during pull/rebase, that’s fine (hint, not hard guardrail).
- If user types a command (“pull and push”), that’s consent for that command.
- No amend unless asked.
- Big review: `git --no-pager diff --color=never`.
- Multi-agent: check `git status/diff` before edits; ship small commits.

## Language/Stack Notes

- Swift: use workspace helper/daemon; validate `swift build` + tests; keep concurrency attrs right.
- TypeScript: use repo PM; keep files small; follow existing patterns.

## macOS Permissions / Signing (TCC)

- Never re-sign / ad-hoc sign / change bundle ID as “debug” without explicit ok (can mess TCC).

## Critical Thinking

- Fix root cause (not band-aid).
- Unsure: read more code; if still stuck, ask w/ short options.
- Conflicts: call out; pick safer path.
- Unrecognized changes: assume other agent; keep going; focus your changes. If it causes issues, stop + ask user.
- Leave breadcrumb notes in thread.

## Tools

Read `~/projects/agent-scripts/tools.md` for the full tool catalog if it exists.

### tmux

- Use only when you need persistence/interaction (debugger/server).
- Quick refs: `tmux new -d -s codex-shell`, `tmux attach -t codex-shell`, `tmux list-sessions`, `tmux kill-session -t codex-shell`.

## Frontend Aesthetics

<frontend_aesthetics>
Avoid “AI slop” UI. Be opinionated + distinctive.

Do:

- Typography: pick a real font; avoid Inter/Roboto/Arial/system defaults.
- Theme: commit to a palette; use CSS vars; bold accents > timid gradients.
- Motion: 1–2 high-impact moments (staggered reveal beats random micro-anim).
- Background: add depth (gradients/patterns), not flat default.

Avoid: purple-on-white clichés, generic component grids, predictable layouts.
</frontend_aesthetics>
