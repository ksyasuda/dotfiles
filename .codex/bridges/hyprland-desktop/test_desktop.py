"""Exercise the real MCP transport against an isolated Tk test window on the live desktop."""

import asyncio
import base64
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).parent


def native_fixture(path: Path) -> None:
    import gi
    gi.require_version("Gtk", "4.0")
    from gi.repository import GLib, Gtk

    app = Gtk.Application(application_id="local.hyprland.bridge.test")
    def activate(application):
        window = Gtk.ApplicationWindow(application=application, title="Hyprland bridge verification")
        window.set_default_size(600, 360)
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=20)
        for edge in ("top", "bottom", "start", "end"):
            getattr(box, f"set_margin_{edge}")(30)
        window.set_child(box)
        box.append(Gtk.Label(label="Temporary native Wayland bridge test"))
        entry = Gtk.Entry()
        box.append(entry)
        button = Gtk.Button(label="Test click")
        box.append(button)
        canvas = Gtk.DrawingArea()
        canvas.set_content_height(100)
        box.append(canvas)
        counters = {"clicks": 0, "wheels": 0, "drags": 0}
        def increment(name):
            counters[name] += 1
        button.connect("clicked", lambda _: increment("clicks"))
        wheel = Gtk.EventControllerScroll.new(Gtk.EventControllerScrollFlags.VERTICAL)
        wheel.connect("scroll", lambda *_: increment("wheels") or True)
        canvas.add_controller(wheel)
        gesture = Gtk.GestureDrag.new()
        gesture.connect("drag-update", lambda *_: increment("drags"))
        canvas.add_controller(gesture)
        def record():
            data = {"text": entry.get_text(), **counters}
            for name, widget in (("entry", entry), ("button", button), ("canvas", canvas)):
                valid, bounds = widget.compute_bounds(window)
                if not valid:
                    return True
                data[name] = [round(bounds.get_x() + bounds.get_width()/2),
                              round(bounds.get_y() + bounds.get_height()/2)]
            path.write_text(json.dumps(data))
            return True
        GLib.timeout_add(50, record)
        window.present()
    app.connect("activate", activate)
    app.run([])


def fixture(path: Path) -> None:
    import tkinter as tk

    app = tk.Tk(className="HyprlandBridgeTest")
    app.title("Hyprland bridge verification")
    app.geometry("600x360")
    tk.Label(app, text="Temporary desktop bridge test", font=("DejaVu Sans", 18)).pack(pady=20)
    entry = tk.Entry(app, font=("DejaVu Sans", 16))
    entry.pack(padx=30, fill="x")
    clicks = 0
    wheels = 0
    drags = 0
    events = []
    def pointer_event(event):
        events.append([str(event.type), str(event.widget), event.x, event.y])
    app.bind_all("<ButtonPress-1>", pointer_event, add=True)
    app.bind_all("<ButtonRelease-1>", pointer_event, add=True)

    def clicked() -> None:
        nonlocal clicks
        clicks += 1

    def wheel(_event: object) -> None:
        nonlocal wheels
        wheels += 1

    def dragged(_event: object) -> None:
        nonlocal drags
        drags += 1

    button = tk.Button(app, text="Test click", command=clicked)
    button.pack(pady=20)
    canvas = tk.Canvas(app, background="#bdd7ce", height=100)
    canvas.pack(padx=30, fill="x")
    canvas.bind("<Button-4>", wheel)
    canvas.bind("<Button-5>", wheel)
    canvas.bind("<B1-Motion>", dragged)

    def record() -> None:
        data = {"text": entry.get(), "clicks": clicks, "wheels": wheels, "drags": drags,
                "events": events[-8:]}
        for name, widget in (("entry", entry), ("button", button), ("canvas", canvas)):
            data[name] = [widget.winfo_x() + widget.winfo_width() // 2,
                          widget.winfo_y() + widget.winfo_height() // 2]
        path.write_text(json.dumps(data))
        app.after(50, record)

    app.after(100, record)
    app.mainloop()


async def verify() -> None:
    from mcp import ClientSession, StdioServerParameters
    from mcp.client.stdio import stdio_client

    original = json.loads(subprocess.check_output(["hyprctl", "-j", "activewindow"]))
    cursor = json.loads(subprocess.check_output(["hyprctl", "-j", "cursorpos"]))
    with tempfile.TemporaryDirectory(prefix="hyprland-bridge-test-") as directory:
        state_path = Path(directory) / "state.json"
        mode = "--native-fixture" if "--native" in sys.argv else "--fixture"
        gui = subprocess.Popen(["/usr/bin/python", str(__file__), mode, str(state_path)],
                               env={**os.environ, "GDK_BACKEND": "wayland"})
        try:
            params = StdioServerParameters(command=str(ROOT / ".venv/bin/python"),
                                           args=[str(ROOT / "server.py")], env={
                                               key: os.environ[key] for key in (
                                                   "XDG_RUNTIME_DIR", "WAYLAND_DISPLAY",
                                                   "HYPRLAND_INSTANCE_SIGNATURE", "YDOTOOL_SOCKET",
                                                   "DISPLAY", "XAUTHORITY",
                                               ) if key in os.environ
                                           })
            async with stdio_client(params) as (reader, writer):
                async with ClientSession(reader, writer) as session:
                    await session.initialize()
                    catalog = await session.list_tools()
                    print("MCP tools:", ", ".join(t.name for t in catalog.tools))

                    async def call(name: str, **args: object):
                        result = await session.call_tool(name, args)
                        if result.isError:
                            print("Active at failure:", subprocess.check_output(["hyprctl", "-j", "activewindow"]).decode())
                            raise RuntimeError(f"{name}: {result.content}")
                        return result

                    address = None
                    for _ in range(50):
                        state = await call("desktop_state")
                        data = json.loads(state.content[0].text)
                        address = next((w["address"] for w in data["windows"]
                                        if w["title"] == "Hyprland bridge verification"), None)
                        if address and state_path.exists():
                            break
                        await asyncio.sleep(0.1)
                    assert address, "Test window did not appear"
                    await call("focus_window", address=address)
                    await asyncio.sleep(0.5)
                    initial = await call("screenshot", address=address)
                    initial_image = next(c for c in initial.content if c.type == "image")
                    Path("/tmp/hyprland-desktop-initial.png").write_bytes(base64.b64decode(initial_image.data))

                    def state():
                        return json.loads(state_path.read_text())

                    async def pointer(name: str, widget: str, **args: object):
                        x, y = state()[widget]
                        return await call(name, address=address, x=x, y=y, **args)

                    await pointer("click", "entry")
                    await call("type_text", address=address, text="Hello Wayland 日本語")
                    await asyncio.sleep(0.25)
                    assert state()["text"] == "Hello Wayland 日本語", state()
                    await call("press_key", address=address, key="Home")
                    await call("press_key", address=address, key="End", modifiers=["shift"])
                    await call("type_text", address=address, text="Bridge verified ✓")
                    await pointer("click", "button")
                    await asyncio.sleep(0.25)
                    print("After button:", state())
                    await pointer("scroll", "canvas", direction="down", steps=2)
                    x, y = state()["canvas"]
                    await call("drag", address=address, start_x=x-50, start_y=y, end_x=x+50, end_y=y)
                    await asyncio.sleep(0.3)
                    observed = state()
                    assert observed["text"] == "Bridge verified ✓", observed
                    assert observed["clicks"] == 1, observed
                    assert observed["wheels"] >= 1, observed
                    assert observed["drags"] >= 1, observed
                    shot = await call("screenshot", address=address)
                    image = next(c for c in shot.content if c.type == "image")
                    Path("/tmp/hyprland-desktop-verified.png").write_bytes(base64.b64decode(image.data))
                    for name, args in (
                        ("click", {"address": address, "x": 32768, "y": 0}),
                        ("focus_window", {"address": '0x1\");os.execute("false")--'}),
                        ("press_key", {"address": address, "key": "--help"}),
                    ):
                        rejected = await session.call_tool(name, args)
                        assert rejected.isError, f"Invalid {name} was accepted"
                    if original.get("address"):
                        await call("focus_window", address=original["address"])
                        rejected = await session.call_tool("type_text", {"address": address, "text": "wrong focus"})
                        assert rejected.isError, "Input after focus change was accepted"
                    print("PASS: focus, Unicode, shortcut, click, wheel, drag, screenshot, invalid input, focus guard")
                    print("Observed:", observed)
        finally:
            gui.terminate()
            gui.wait(timeout=5)
            x, y = round(cursor["x"]), round(cursor["y"])
            subprocess.run(["hyprctl", "eval", f"hl.dispatch(hl.dsp.cursor.move({{x={x},y={y}}}))"],
                           check=False, capture_output=True)


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--native-fixture":
        native_fixture(Path(sys.argv[2]))
    elif len(sys.argv) > 1 and sys.argv[1] == "--fixture":
        fixture(Path(sys.argv[2]))
    else:
        asyncio.run(verify())
