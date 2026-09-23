#!/usr/bin/env python3
"""
aibar-popup.py — Tabbed AI usage popup for codexbar + claudebar.
Toggle: clicking when open closes it (uses PID lockfile).

Run with:  GDK_BACKEND=x11 python3 ~/.config/waybar/scripts/aibar-popup.py
Flags:     --claude   open with Claude tab active
"""

import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk, Gdk, GLib

import subprocess
import json
import threading
import sys
import os
import signal
import atexit
import re

# ── Toggle: kill existing instance if running ─────────────────────────────
LOCK = "/tmp/aibar-popup.pid"

def _cleanup():
    try:
        os.remove(LOCK)
    except FileNotFoundError:
        pass

if os.path.exists(LOCK):
    try:
        with open(LOCK) as f:
            pid = int(f.read().strip())
        os.kill(pid, signal.SIGTERM)
        os.remove(LOCK)
        sys.exit(0)          # toggled off an existing popup — done
    except (ProcessLookupError, ValueError, OSError):
        os.remove(LOCK)      # stale lock — clean up and continue opening

with open(LOCK, "w") as f:
    f.write(str(os.getpid()))
atexit.register(_cleanup)

# ── Catppuccin Macchiato ──────────────────────────────────────────────────
CRUST  = "#181926"
MANTLE = "#1e2030"
BASE   = "#24273a"
S0     = "#363a4f"
S1     = "#494d64"
OV0    = "#6e738d"
OV1    = "#8087a2"
SUB1   = "#a5adcb"
TEXT   = "#cad3f5"
GREEN  = "#a6da95"   # Codex / OpenAI
PEACH  = "#f5a97f"   # Claude / Anthropic
RED    = "#ed8796"
YELLOW = "#eed49f"

FONT = "JetBrainsMono Nerd Font"

CSS = f"""
window {{
    background-color: {MANTLE};
    border-radius: 12px;
    border: 1px solid {S1};
}}
.root-box {{
    background-color: {MANTLE};
    border-radius: 12px;
}}

/* ── Tab bar ── */
.tab-bar {{
    background-color: {CRUST};
    border-radius: 12px 12px 0 0;
    padding: 0;
    border-bottom: 1px solid {S0};
    min-height: 36px;
}}
.tab-btn {{
    background-color: transparent;
    border: none;
    border-radius: 0;
    border-bottom: 3px solid transparent;
    color: {OV1};
    padding: 7px 20px 4px 20px;
    font-family: "{FONT}";
    font-size: 13px;
    font-weight: 600;
    margin: 0;
    box-shadow: none;
    letter-spacing: 0.3px;
}}
.tab-btn:hover {{
    color: {TEXT};
    background-color: {S0};
    box-shadow: none;
    border-bottom: 3px solid {S1};
}}
.tab-codex.active {{
    color: {GREEN};
    border-bottom: 3px solid {GREEN};
    background-color: {MANTLE};
}}
.tab-claude.active {{
    color: {PEACH};
    border-bottom: 3px solid {PEACH};
    background-color: {MANTLE};
}}
.close-btn {{
    background-color: transparent;
    border: none;
    color: {OV0};
    font-size: 11px;
    padding: 4px 12px 4px 12px;
    border-radius: 0;
    border-bottom: 3px solid transparent;
    box-shadow: none;
    min-height: 0;
    min-width: 0;
}}
.close-btn:hover {{
    color: {RED};
    background-color: {S0};
    box-shadow: none;
}}

/* ── Status section ── */
.status-section {{
    background-color: {BASE};
    padding: 12px 18px 10px 18px;
    border-bottom: 1px solid {S0};
}}
.status-label {{
    font-family: "{FONT}";
    font-size: 20px;
    font-weight: bold;
}}

/* ── Accent stripe ── */
.accent-codex {{
    background: linear-gradient(to right, {GREEN}, transparent);
    min-height: 3px;
}}
.accent-claude {{
    background: linear-gradient(to right, {PEACH}, transparent);
    min-height: 3px;
}}

/* ── Content ── */
.content-box {{
    background-color: {MANTLE};
    padding: 14px 18px 16px 18px;
}}
.tooltip-label {{
    font-family: "{FONT}";
    font-size: 12.5px;
    color: {TEXT};
}}
.loading-label {{
    color: {OV0};
    font-family: "{FONT}";
    font-size: 12px;
    font-style: italic;
    padding: 32px 18px;
}}
""".encode()


# ── Helpers ───────────────────────────────────────────────────────────────

def strip_box(text: str) -> str:
    """Remove box-drawing decoration (╭─│╰) from Pango-markup tooltip strings."""
    cleaned = []
    for line in text.split("\n"):
        if re.search(r"[╭╰╮]", line):
            continue
        if re.search(r"foreground='#5c6370'>[─]", line):
            continue
        line = re.sub(r"<span foreground='#61afef'>│</span>\s*", "", line)
        line = re.sub(r"\s*<span foreground='#61afef'>│</span>", "", line)
        if line.strip():
            cleaned.append(line)
    return "\n".join(cleaned)


# ── Data fetching ─────────────────────────────────────────────────────────

def fetch_data(cmd: list[str]) -> dict:
    try:
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=20)
        return json.loads(r.stdout.strip())
    except Exception as e:
        return {
            "text": "⚠ error",
            "tooltip": f'<span foreground="{RED}">Error: {e}</span>',
            "class": "",
        }


# ── Content page ─────────────────────────────────────────────────────────

class ContentPage(Gtk.Box):
    def __init__(self, service: str):
        super().__init__(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        self.service = service

        # Gradient accent stripe
        accent = Gtk.Box()
        accent.set_size_request(-1, 3)
        accent.get_style_context().add_class(
            "accent-codex" if service == "codex" else "accent-claude"
        )
        self.pack_start(accent, False, False, 0)

        # Status section (bar text — large)
        self.status_section = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=0)
        self.status_section.get_style_context().add_class("status-section")
        self.status_lbl = Gtk.Label(label="—")
        self.status_lbl.get_style_context().add_class("status-label")
        self.status_lbl.set_halign(Gtk.Align.START)
        self.status_section.pack_start(self.status_lbl, True, True, 0)
        self.pack_start(self.status_section, False, False, 0)

        # Tooltip / main content
        self.content_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        self.content_box.get_style_context().add_class("content-box")
        self.pack_start(self.content_box, True, True, 0)

        self.loading = Gtk.Label(label="fetching…")
        self.loading.get_style_context().add_class("loading-label")
        self.loading.set_halign(Gtk.Align.CENTER)
        self.content_box.pack_start(self.loading, True, True, 0)

        cmd = ["codexbar"] if service == "codex" else ["claudebar"]
        threading.Thread(target=self._fetch, args=(cmd,), daemon=True).start()

    def _fetch(self, cmd):
        data = fetch_data(cmd)
        GLib.idle_add(self._populate, data)

    def _populate(self, data):
        color = GREEN if self.service == "codex" else PEACH
        text  = data.get("text", "")
        tip   = strip_box(data.get("tooltip", "No data"))

        # Update status bar
        self.status_lbl.set_markup(
            f'<span foreground="{color}" font="{FONT} 20" weight="bold">{text}</span>'
        )

        # Replace loading with tooltip content
        self.content_box.remove(self.loading)
        lbl = Gtk.Label()
        try:
            lbl.set_markup(tip)
        except Exception:
            lbl.set_text(tip)
        lbl.get_style_context().add_class("tooltip-label")
        lbl.set_halign(Gtk.Align.START)
        lbl.set_valign(Gtk.Align.START)
        lbl.set_selectable(True)
        lbl.set_line_wrap(False)
        self.content_box.pack_start(lbl, True, True, 0)
        self.content_box.show_all()
        return False


# ── Main window ──────────────────────────────────────────────────────────

class AIBarPopup(Gtk.Window):
    def __init__(self, default_tab: int = 0):
        super().__init__(type=Gtk.WindowType.TOPLEVEL)
        self.set_title("aibar")
        self.set_decorated(False)
        self.set_resizable(False)
        self.set_keep_above(True)
        self.set_type_hint(Gdk.WindowTypeHint.DIALOG)
        self.active_tab = default_tab

        provider = Gtk.CssProvider()
        provider.load_from_data(CSS)
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(),
            provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION,
        )

        self.connect("key-press-event", self._on_key)

        root = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        root.get_style_context().add_class("root-box")
        self.add(root)

        # ── Tab bar ──────────────────────────────────────────────────────
        tab_bar = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=0)
        tab_bar.get_style_context().add_class("tab-bar")

        self.btn_codex = Gtk.Button(label=" Codex")
        self.btn_codex.get_style_context().add_class("tab-btn")
        self.btn_codex.get_style_context().add_class("tab-codex")
        self.btn_codex.connect("clicked", lambda *_: self._set_tab(0))

        self.btn_claude = Gtk.Button(label=" Claude")
        self.btn_claude.get_style_context().add_class("tab-btn")
        self.btn_claude.get_style_context().add_class("tab-claude")
        self.btn_claude.connect("clicked", lambda *_: self._set_tab(1))

        spacer = Gtk.Box()
        spacer.set_hexpand(True)

        close_btn = Gtk.Button(label="✕")
        close_btn.get_style_context().add_class("close-btn")
        close_btn.connect("clicked", lambda *_: self._quit())

        tab_bar.pack_start(self.btn_codex, False, False, 0)
        tab_bar.pack_start(self.btn_claude, False, False, 0)
        tab_bar.pack_start(spacer, True, True, 0)
        tab_bar.pack_start(close_btn, False, False, 0)
        root.pack_start(tab_bar, False, False, 0)

        # ── Stack ─────────────────────────────────────────────────────────
        self.stack = Gtk.Stack()
        self.stack.set_transition_type(Gtk.StackTransitionType.SLIDE_LEFT_RIGHT)
        self.stack.set_transition_duration(130)
        # Fixed size: 360px wide fits the codexbar/claudebar cards (~280px) with padding.
        # Height 410 accommodates the tallest page (Claude has 4 sections); scrolled below.
        self.stack.set_size_request(360, 410)

        self.page_codex  = ContentPage("codex")
        self.page_claude = ContentPage("claude")
        self.stack.add_named(self.page_codex,  "codex")
        self.stack.add_named(self.page_claude, "claude")
        root.pack_start(self.stack, True, True, 0)

        self._set_tab(default_tab, animate=False)
        self.show_all()
        self._position()

    def _set_tab(self, idx: int, animate: bool = True):
        self.active_tab = idx
        if not animate:
            self.stack.set_transition_type(Gtk.StackTransitionType.NONE)
        self.stack.set_visible_child_name("codex" if idx == 0 else "claude")
        if not animate:
            self.stack.set_transition_type(Gtk.StackTransitionType.SLIDE_LEFT_RIGHT)

        cc = self.btn_codex.get_style_context()
        ca = self.btn_claude.get_style_context()
        if idx == 0:
            cc.add_class("active");    ca.remove_class("active")
        else:
            cc.remove_class("active"); ca.add_class("active")

    def _position(self):
        self.realize()
        w, _h = self.get_size()
        display  = Gdk.Display.get_default()
        n        = display.get_n_monitors()
        monitor  = display.get_monitor(n - 1)
        geo      = monitor.get_geometry()
        x = geo.x + geo.width - w - 14
        y = geo.y + 48
        self.move(x, y)

    def _on_key(self, _w, event):
        if event.keyval == Gdk.KEY_Escape:
            self._quit()

    def _quit(self):
        _cleanup()
        Gtk.main_quit()


# ── Entry point ──────────────────────────────────────────────────────────

def main():
    default = 1 if "--claude" in sys.argv else 0
    win = AIBarPopup(default)
    win.connect("destroy", lambda *_: (_cleanup(), Gtk.main_quit()))
    Gtk.main()


if __name__ == "__main__":
    main()
