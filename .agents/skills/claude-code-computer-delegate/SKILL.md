---
name: claude-code-computer-delegate
description: Compatibility guidance for requests that explicitly invoke the old Claude Code computer-delegate workflow on this Hyprland desktop. For ordinary desktop work, use hyprland-computer-use and the local desktop MCP tools.
---

# Computer delegate compatibility

The current desktop workflow is documented in
[hyprland-computer-use](../hyprland-computer-use/SKILL.md).
Use its `hyprland_desktop` MCP tools directly when available.

The previous machine-specific assumptions are obsolete: `ydotool` is installed,
the host has a user-owned input socket, and image viewing depends on the caller's
actual tools. Do not assume Codex cannot view screenshots or require an unrestricted
agent sandbox for ordinary desktop work.

If the user explicitly requests delegation, use the available delegation workflow
and give the delegate a bounded app/task. Check that it actually has the desktop MCP
tools and image-viewing capability. If it cannot inspect images, have it return the
screenshot to the caller for interpretation. Never claim visual verification from a
command's exit status alone.

This bridge's Codex MCP registration does not automatically configure Claude Code.
Configure the same stdio server separately in any other client that needs it.
