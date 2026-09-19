---
name: claude-code-computer-delegate
description: "Delegate desktop GUI and workstation control to a Codex subagent that acts as remote hands while Claude Code reads the screenshots. Use when a task needs to see or operate the local desktop: take a screenshot, check what is currently on screen, inspect or drive a native or Electron app window, read window/workspace/monitor state, launch a desktop program, or run a live-session workflow that a sandboxed shell cannot reach. Not for web pages (use the Chrome DevTools or Playwright MCP tools) and not for ordinary repo edits (use the delegate skill). Codex only: gpt-5.6-terra for narrow work, gpt-5.6-sol for complex or risky work; never gpt-5.6-luna, Luna aliases, or Claude models."
---

# Claude Code Computer Delegate

## The one thing to understand first

**Codex is the hands. Claude Code is the eyes.**

Verified on this machine: a `codex exec` subagent *cannot view image files*. Asked to
screenshot the desktop and describe it, it replies `CANNOT VIEW IMAGES`. So never ask
Codex "what does the screen look like" or "check whether the dialog appeared". It is
blind.

The working division of labor:

| Step | Who | How |
|---|---|---|
| Capture screen, drive windows, launch apps, run live-session commands | Codex subagent | `grim`, `hyprctl`, `wtype` |
| Interpret pixels: layout, colors, error text, "did it work" | Claude Code (you) | `Read` the PNG path Codex reports |
| Decide the next action | Claude Code (you) | Send a follow-up brief |

Codex reasons only over **text**: `hyprctl -j clients` JSON, command output, exit codes,
log files. Have it report those. Have it report *screenshot paths*, never screenshot
*descriptions*.

## Use this skill when

- "What's on my screen right now", "take a screenshot", "look at my desktop"
- Inspecting or operating a native/Electron/GTK/Qt app window
- Reading window, workspace, or monitor layout state
- Launching or focusing a desktop program
- A command that must touch the live graphical session

## Do NOT use this skill when

- **Web page or web app work.** You have `chrome-devtools` and `playwright` MCP tools
  in-process. They give you the DOM, console, network, and snapshots you can actually
  see. Delegating browser work to a blind subagent is strictly worse. Use the MCP tools.
- **Plain repo work** (reading code, edits, reviews) with no GUI involved. Use the
  `delegate` skill instead.
- The task is a single command you can just run in Bash yourself. Do that.

## Hard model policy

- Provider `codex` only. Model must be `gpt-5.6-terra` or `gpt-5.6-sol`.
- Never `gpt-5.6-luna`, `luna`, aliases, `latest`, fallbacks, Claude models, or pre-5.6
  Codex models.
- If the user names a model outside this set, stop and report the conflict. Do not
  silently substitute.
- The subagent must not delegate further.

| Complexity | Model | Effort |
|---|---|---|
| Single screenshot, one command, bounded lookup | `gpt-5.6-terra` | medium |
| Same scope, long logs or fiddly state | `gpt-5.6-terra` | high |
| Multi-step GUI workflow, ordinary debugging | `gpt-5.6-sol` | medium |
| Risky, ambiguous, or touching credentials/money/user data | `gpt-5.6-sol` | high |

Default to `sol` when a mistake could change user data, spend money, publish, delete, or
overwrite. Default to `terra` when the action is reversible and easy to verify.

## Sandbox: the part that used to silently fail

GUI access requires `--sandbox danger-full-access`. This is not optional and there is no
narrower mode that works.

Measured on this box (Wayland, Hyprland 0.56.2):

| Sandbox | `grim` screenshot | `hyprctl` |
|---|---|---|
| `read-only` | fails, `failed to create display` | fails, `Couldn't set socket timeout` |
| `workspace-write` | fails, `failed to create display` | fails |
| `workspace-write --add-dir /run/user/1000` | still fails | still fails |
| `danger-full-access` | works | works |

The sandbox passes `WAYLAND_DISPLAY` and `XDG_RUNTIME_DIR` through as environment
variables but blocks the compositor sockets themselves, so the failure looks like a
missing display rather than a permission error. `--add-dir` does not fix it.

Because `danger-full-access` removes the sandbox entirely, keep the blast radius in the
brief instead: name the exact commands allowed, and forbid everything else.

## Run it

```bash
cd "$PWD" && timeout 900 codex exec \
  --ignore-user-config \
  --model gpt-5.6-terra \
  --config model_reasoning_effort="medium" \
  --config approval_policy="never" \
  --sandbox danger-full-access \
  --ephemeral \
  --skip-git-repo-check \
  --output-last-message /tmp/codex-gui-1.md \
  --cd "$PWD" - <<'TASK'
<brief from the template below>
TASK
cat /tmp/codex-gui-1.md
```

Notes that matter:

- Always feed the brief on stdin via a **quoted** heredoc (`<<'TASK'`) so the shell does
  not expand anything in it. The trailing `-` is what tells Codex to read stdin.
- `--output-last-message` gives you the clean report; stdout also carries the reasoning
  stream, which is what you want when a run fails.
- Give screenshots a path you can reach afterward. Prefer your scratchpad directory.
- A nonzero exit or empty report file is a failure even if stdout printed something.
  Check both.

## Brief template

Codex starts with zero context.

```
You are a subagent with direct access to the live graphical session.

Environment: Wayland + Hyprland. Available: grim (screenshot), slurp (region),
wtype (typing), hyprctl (window control and JSON introspection), xdotool
(XWayland windows only), playwright, google-chrome-stable, firefox.

You CANNOT view images. Never describe the contents of a screenshot. Capture it,
report the absolute path, and let the caller look at it.

Hard constraints:
- Run only these commands: <explicit list>
- Do not close, move, or resize the user's existing windows unless told to.
- Do not type into or click on windows the task does not name.
- Do not delegate further or invoke Codex/Claude recursively.

Report, in these sections:
- Summary: what you did.
- Screenshots: absolute path of each, and what each was meant to capture.
- Structural state: relevant `hyprctl -j clients` output or command stdout, verbatim.
- Commands run: each with its exit code.
- Open questions: anything you could not determine without vision.

Task:
<self-contained task>
```

Pass raw evidence. Do not tell Codex the answer you expect it to find.

## Desktop cookbook (verified available here)

Prefer structured text over pixels wherever possible, since that is the part Codex can
reason about.

```bash
grim /path/shot.png                  # whole screen
grim -g "$(slurp)" /path/region.png  # region (interactive, needs a human)
hyprctl -j clients                   # every window: class, title, at[x,y], size[w,h], workspace
hyprctl -j activewindow              # focused window
hyprctl -j monitors                  # geometry and scale
hyprctl notify -1 3000 "rgb(44ccff)" "message"
wtype 'text to type'                 # types into the focused window
```

`hyprctl -j clients` is the highest-value call: it returns exact window rectangles, so
Codex can position and identify windows without seeing anything.

## Known limits, state honestly

- **No synthetic mouse clicks.** `ydotool` is not installed and the user is not in the
  `input` group, so `/dev/uinput` is not writable. There is no working click injection.
  If a task needs a click, say so and ask the user, rather than having Codex flail.
- **Hyprland 0.56 changed the dispatch API** to a Lua form (`hl.dsp.window.close()`).
  Old `hyprctl dispatch <name>` strings error out. Verify a dispatcher before relying on
  it.
- `xdotool` only reaches XWayland clients, not native Wayland ones.
- **Screenshots are downscaled when you Read them.** A 3440x1440 capture is shown to you
  at 2000x837. If you derive coordinates from the image, multiply by the stated factor
  before handing them to anything.

## After the run

- Read the screenshot yourself before believing any claim about UI state.
- Treat the report as a claim. Spot-check load-bearing parts against the raw output.
- On failure, report the model, the exact command, and the error. Retry once only for
  transient faults, on the same model family. If the error is `failed to create display`,
  the sandbox flag was wrong, not the task.
