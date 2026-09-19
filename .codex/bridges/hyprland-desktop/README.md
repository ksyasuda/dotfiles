# Hyprland desktop bridge

Local stdio MCP server for Hyprland 0.56+, using `grim`, `hyprctl`, `ydotool`,
`wtype`, and `xdotool`. Registered as `hyprland_desktop` in the Linux Codex config.
The shared skill is `~/.agents/skills/hyprland-computer-use/SKILL.md`.

The server starts on demand as the logged-in user. It has no network listener,
shell-command tool, or arbitrary file-write tool. It inherits the graphical session
environment through the MCP config. The agent's normal sandbox remains enabled.
Focus checks and coordinate validation reduce misdirected input but do not isolate
apps or prevent desktop-wide keyboard shortcuts. Use one desktop task at a time.

The existing user `ydotool.service` owns a mode-0600 socket at
`$XDG_RUNTIME_DIR/.ydotool_socket`. This machine already grants the active user access
to `/dev/uinput` through its installed Steam input udev rule. No new root service,
input-group membership, or system-wide permission rule was added.

## Maintenance

Inspect input service state with `systemctl --user status ydotool.service`.
If input stops after system package changes, check `/dev/uinput` and its ACL before
changing permissions. Stop input injection with `systemctl --user stop ydotool.service`;
other programs using that shared service will also lose synthetic mouse input.
To disable this MCP bridge, set `enabled = false` in its Codex config section and
restart the client.

Dependencies are pinned in `requirements.lock`. Recreate the environment with:

```sh
cd ~/.codex/bridges/hyprland-desktop
uv venv .venv --python 3.13
uv pip sync --python .venv/bin/python requirements.lock
```

## Verification

These commands briefly operate a temporary test window on the live desktop.
Keep local mouse and keyboard input idle during the run.

```sh
.venv/bin/python test_desktop.py
.venv/bin/python test_desktop.py --native
```

The first tests XWayland with Tk; the second tests native Wayland with GTK 4.
They exercise the MCP handshake and tool calls, Unicode text, selection shortcuts,
clicks, wheel input, dragging, PNG capture, input validation, and the focus guard.
The latest screenshot is `/tmp/hyprland-desktop-verified.png`.
Test fixtures require the system Python Tk and PyGObject/GTK packages.
