# AGENTS.MD

## Agent Protocol

- PRs: use `gh pr view/diff` (no URLs).
- Need upstream file: stage in `/tmp/`, then cherry-pick; never overwrite tracked.
- Commits: Conventional Commits (`feat|fix|refactor|build|ci|chore|docs|style|perf|test`).
- Prefer end-to-end verify; if blocked, say what’s missing.
- Do not use em-dashes

## Coding Preferences - general

- Keep things simple. Channel "yagni" energy unless told otherwise
- Typesafety is useful, take full advantage of it
- Don't be scared to propose bold ideas if they can meaningfully benefit our
  work
- Be careful with destructive actions that are not explicitly requested by the
  user
- Tests are good! Endless smoke tests, "regression tests" for feature deletions
  and things like that are not good. Tests should be focused and not slop
- Comments are a great way to clarify functionality and how code is used, but
  don't comment on every line. Feel free to describe (concisely) how functions
  are used above function definitions, classes, etc
- Keep comments up to date. When making changes, it's important to keep things in
  sync

## Coding Preferences (Typescript focused)

- `any` is the enemy. Inferred types are our friend. Our system should adapt to
  changes, instead of requiring changes everywhere
- If TS code looks like it was written by a Python dev, then it's bad TS code
- Avoid one-line functions that are just casting wrappers

## Questions are read-only

- A question is a request for an answer, not for changes. If the message opens
  with something along the lines of "how hard would it be", "what would it look
  like if we did X", "what are your thoughts", "why does", "should we", "is it
  possible", or otherwise asks rather than instructs - answer it and do not edit
  files
- If the answer is obvious and the change is trivial, still answer it first and
  offer to make the change after. Ask before making it

## Docs

- Keep notes short; update docs when behavior/API changes

## Build / Test

- Release: read `docs/RELEASING.md` (or find best checklist if missing).
- Do not write plans into `docs/plans`

## Git

- Safe by default: `git status/diff/log`. Push only when user asks.
- Branch changes require user consent.
- Destructive ops forbidden unless explicit (`reset --hard`, `clean`, `restore`, `rm`, …).
- Don’t delete/rename unexpected stuff; stop + ask.
- No repo-wide S/R scripts; keep edits small/reviewable.
- Avoid manual `git stash`; if Git auto-stashes during pull/rebase, that’s fine (hint, not hard guardrail).
- If user types a command (“pull and push”), that’s consent for that command.
- No amend unless asked.
- Big review: `git --no-pager diff --color=never`.
- Multi-agent: check `git status/diff` before edits.

## Language/Stack Notes

- Swift: use workspace helper/daemon; validate `swift build` + tests; keep concurrency attrs right.
- TypeScript: use repo PM; keep files small; follow existing patterns.

## Critical Thinking

- Fix root cause (not band-aid).
- Unsure: read more code; if still stuck, ask w/ short options.
- Conflicts: call out; pick safer path.
- Unrecognized changes: assume other agent; keep going; focus your changes. If it causes issues, stop + ask user.
- Leave breadcrumb notes in thread.

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
