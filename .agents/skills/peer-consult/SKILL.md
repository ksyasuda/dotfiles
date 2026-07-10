---
name: peer-consult
description: Request an independent, read-only repository review or second opinion from the opposite model provider, using Claude from Codex or Codex from Claude. Use only when the user explicitly asks to consult, ask, review with, or get an opinion from Claude or Codex about an issue, feature, design, plan, diagnosis, or decision. Never invoke proactively. Never use for implementation or file changes.
---

# Peer Consult

Get one independent opinion from the opposite provider. Preserve the repository unchanged and return a standardized decision memo.

## Preconditions

- Require an explicit user request for cross-provider consultation. A normal request for review, planning, or advice is insufficient unless it names Claude, Codex, a peer model, or a second opinion.
- Run Claude only when the active agent is Codex. Run Codex only when the active agent is Claude.
- Do not use this skill from any other caller.
- Do not edit files, implement the recommendation, or perform follow-on changes unless the user separately requests them after seeing the memo.

## Route the request

Classify the smallest adequate tier:

| Tier | Signals | Codex peer | Claude peer |
|---|---|---|---|
| Quick | Narrow, bounded, one component | `gpt-5.6-terra`, medium | `claude-sonnet-4-6`, medium |
| Quick, context-heavy | Still bounded; more context or nuance | `gpt-5.6-terra`, high | `claude-sonnet-5`, high |
| Standard | Multi-file feature, ordinary design/debugging, meaningful trade-offs | `gpt-5.6-sol`, medium | `claude-opus-4-8`, medium |
| Deep | Architecture, concurrency, security, broad ambiguity, high-impact choice | `gpt-5.6-sol`, high | `claude-opus-4-8`, high |

Honor an explicit model override only when it is allowed for the target provider:

- Codex: `gpt-5.6-terra`, `gpt-5.6-sol`
- Claude: `claude-sonnet-4-6`, `claude-sonnet-5`, `claude-opus-4-8`

Reject GPT-5.6 Luna, pre-5.6 Codex models, Claude Haiku, every other Claude model, aliases, and cross-provider model names. Never silently fall back.

## Prepare independent context

Write a self-contained request containing:

- The question or decision to assess.
- Relevant constraints and success criteria.
- Relevant paths, symbols, errors, or raw plan text.
- Specific uncertainties the peer should resolve.

Pass raw evidence. Avoid telling the peer the expected answer or presenting the active agent's conclusion as fact. Let the peer inspect the current repository independently.

## Run the broker

Resolve `<skill-dir>` to the directory containing this `SKILL.md`. Send the request on stdin; do not interpolate it into a shell command.

From Codex:

```bash
python3 <skill-dir>/scripts/peer_consult.py \
  --caller codex \
  --complexity standard \
  --repo "$PWD" <<'PEER_REQUEST'
<self-contained consultation request>
PEER_REQUEST
```

From Claude:

```bash
python3 <skill-dir>/scripts/peer_consult.py \
  --caller claude \
  --complexity standard \
  --repo "$PWD" <<'PEER_REQUEST'
<self-contained consultation request>
PEER_REQUEST
```

Adjust only these routing flags when needed:

- `--complexity quick|standard|deep`
- `--context-heavy` for the context-heavy quick tier
- `--model <approved-model>` for an explicit allowed override
- `--timeout <seconds>` when the default 600 seconds is unsuitable
- `--dry-run` to inspect routing and command construction without calling a provider

The broker enforces pinned models, opposite-provider routing, nonpersistent execution, tool restrictions, structured output, and read-only repository access.

## Return the result

Return the broker's memo without changing its meaning. Keep its sections:

- Verdict
- Evidence
- Risks
- Alternatives
- Recommendation
- Confidence

Identify it as the peer provider's opinion. If useful, add a short, separately labeled synthesis explaining how the feedback affects the active discussion. Do not implement anything.

On failure, report the selected provider, model, and exact failure. Do not retry with another model unless the user explicitly requests it.
