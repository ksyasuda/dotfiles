#!/usr/bin/env python3
"""Record microphone audio and transcribe it with whisper.cpp."""

from __future__ import annotations

import argparse
import os
import re
import shutil
import signal
import subprocess
import sys
import tempfile
import threading
import time
import wave
from pathlib import Path

import numpy as np
import sounddevice as sd

DEFAULT_MODEL = "~/models/whisper.cpp/ggml-small.bin"
DEFAULT_DURATION = 8.0
DEFAULT_STATE_DIR = Path.home() / ".cache" / "whisper-record-toggle"
APP_NAME = "Whisper Record"


class Notifier:
    """Best-effort desktop notifications with optional live updates."""

    def __init__(self) -> None:
        self.enabled = shutil.which("notify-send") is not None
        self.notification_id: str | None = None

    def send(self, title: str, body: str, timeout_ms: int = 1500) -> None:
        if not self.enabled:
            return

        base_cmd = [
            "notify-send",
            "-a",
            APP_NAME,
            "-u",
            "normal",
            "-t",
            str(timeout_ms),
        ]
        if self.notification_id:
            base_cmd.extend(["-r", self.notification_id])

        # Prefer -p so we can reuse the same ID for replacement updates.
        result = subprocess.run(
            [*base_cmd, "-p", title, body], capture_output=True, text=True
        )
        if result.returncode != 0:
            # Fallback for environments where -p is unsupported.
            subprocess.run([*base_cmd, title, body], capture_output=True, text=True)
            return

        notification_id = result.stdout.strip().splitlines()[-1].strip()
        if notification_id.isdigit():
            self.notification_id = notification_id


class Recorder:
    """Stream microphone audio into memory while tracking elapsed time."""

    def __init__(self, samplerate: int, channels: int) -> None:
        self.samplerate = samplerate
        self.channels = channels
        self.frames: list[np.ndarray] = []

    def _callback(self, indata: np.ndarray, _frames: int, _time, status) -> None:
        if status:
            print(f"sounddevice warning: {status}", file=sys.stderr)
        self.frames.append(indata.copy())

    def record(
        self, duration: float | None, notifier: Notifier, interval: float
    ) -> np.ndarray:
        start = time.monotonic()
        last_update = 0.0

        with sd.InputStream(
            samplerate=self.samplerate,
            channels=self.channels,
            dtype="int16",
            callback=self._callback,
        ):
            while True:
                elapsed = time.monotonic() - start
                if elapsed - last_update >= interval:
                    timer = _format_seconds(elapsed)
                    if duration is not None:
                        notifier.send(
                            "Recording", f"{timer} / {_format_seconds(duration)}"
                        )
                    else:
                        notifier.send(
                            "Recording", f"Elapsed: {timer} (press keybind again)"
                        )
                    last_update = elapsed

                if duration is not None and elapsed >= duration:
                    break

                time.sleep(0.05)

        if not self.frames:
            raise RuntimeError(
                "No audio captured. Check your input device and permissions."
            )

        return np.concatenate(self.frames, axis=0)


def _format_seconds(value: float) -> str:
    total = int(value)
    minutes, seconds = divmod(total, 60)
    return f"{minutes:02d}:{seconds:02d}"


def find_whisper_binary(explicit: str | None) -> str:
    if explicit:
        return explicit

    for candidate in ("whisper-cli", "main", "whisper"):
        path = shutil.which(candidate)
        if path:
            return path

    raise RuntimeError(
        "Could not find whisper.cpp binary. Pass --whisper-bin /path/to/whisper-cli"
    )


def write_wav(path: Path, audio: np.ndarray, samplerate: int, channels: int) -> None:
    with wave.open(str(path), "wb") as wav_file:
        wav_file.setnchannels(channels)
        wav_file.setsampwidth(2)
        wav_file.setframerate(samplerate)
        wav_file.writeframes(audio.tobytes())


def transcribe(whisper_bin: str, model: str, wav_path: Path, notifier: Notifier) -> str:
    with tempfile.TemporaryDirectory(prefix="whisper-out-") as out_dir:
        out_base = Path(out_dir) / "transcript"
        cmd = [
            whisper_bin,
            "-m",
            model,
            "-f",
            str(wav_path),
            "-otxt",
            "-of",
            str(out_base),
            "-nt",
        ]
        process = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1,
        )
        output_lines: list[str] = []
        progress: dict[str, int | None] = {"pct": None}

        def _reader() -> None:
            assert process.stdout is not None
            for line in process.stdout:
                output_lines.append(line)
                match = re.search(r"(?<!\d)(\d{1,3})%", line)
                if match:
                    progress["pct"] = min(100, int(match.group(1)))

        reader = threading.Thread(target=_reader, daemon=True)
        reader.start()

        spinner = "|/-\\"
        frame = 0
        while process.poll() is None:
            pct = progress["pct"]
            status = (
                f"Transcribing... {pct}%"
                if pct is not None
                else f"Transcribing... {spinner[frame % len(spinner)]}"
            )
            notifier.send("Transcribing", status, timeout_ms=1200)
            print(f"\r{status}", end="", file=sys.stderr, flush=True)
            frame += 1
            time.sleep(0.35)

        reader.join(timeout=1.0)
        print("\r" + (" " * 48) + "\r", end="", file=sys.stderr, flush=True)
        result_stdout = "".join(output_lines).strip()

        if process.returncode != 0:
            stderr = result_stdout
            raise RuntimeError(f"whisper.cpp failed: {stderr}")

        txt_file = out_base.with_suffix(".txt")
        if txt_file.exists():
            return txt_file.read_text(encoding="utf-8").strip()

        fallback = result_stdout
        if fallback:
            return fallback

    raise RuntimeError("Transcription finished but no output text was produced.")


def _type_with_tool(text: str) -> None:
    if shutil.which("wtype"):
        subprocess.run(["wtype", text], check=True)
        return
    if shutil.which("ydotool"):
        subprocess.run(["ydotool", "type", "--", text], check=True)
        return
    if shutil.which("xdotool"):
        subprocess.run(["xdotool", "type", "--clearmodifiers", "--", text], check=True)
        return
    raise RuntimeError("No typing tool found. Install one of: wtype, ydotool, xdotool.")


def _emit_text(text: str, args: argparse.Namespace, notifier: Notifier) -> int:
    if args.output == "print":
        print(text)
        notifier.send("Done", "Transcription printed to terminal", timeout_ms=1500)
        return 0

    try:
        _type_with_tool(text)
    except Exception as exc:
        print(f"Failed to simulate typing: {exc}", file=sys.stderr)
        notifier.send("Typing error", str(exc), timeout_ms=2500)
        return 1

    notifier.send("Done", "Transcription typed into active window", timeout_ms=1500)
    return 0


def _read_pid(pid_file: Path) -> int | None:
    if not pid_file.exists():
        return None
    try:
        return int(pid_file.read_text(encoding="utf-8").strip())
    except ValueError:
        return None


def _is_alive(pid: int | None) -> bool:
    if pid is None:
        return False
    try:
        os.kill(pid, 0)
    except ProcessLookupError:
        return False
    except PermissionError:
        return True
    return True


def _run_transcription_job(args: argparse.Namespace, duration: float | None) -> str:
    notifier = Notifier()
    model_path = Path(args.model).expanduser()
    if not model_path.exists():
        raise RuntimeError(f"Model file not found: {model_path}")

    whisper_bin = find_whisper_binary(args.whisper_bin)

    notifier.send("Recording", "Starting...", timeout_ms=1200)
    recorder = Recorder(samplerate=args.samplerate, channels=args.channels)

    try:
        audio = recorder.record(
            duration=duration,
            notifier=notifier,
            interval=max(args.notify_interval, 0.2),
        )
    except KeyboardInterrupt:
        if not recorder.frames:
            notifier.send("Recording", "Cancelled", timeout_ms=1000)
            return ""
        audio = np.concatenate(recorder.frames, axis=0)
    except Exception as exc:
        raise RuntimeError(f"Recording failed: {exc}") from exc

    with tempfile.TemporaryDirectory(prefix="whisper-audio-") as tmp_dir:
        wav_path = Path(tmp_dir) / "input.wav"
        write_wav(wav_path, audio, args.samplerate, args.channels)
        notifier.send("Transcribing", "Running whisper.cpp...", timeout_ms=1500)
        text = transcribe(whisper_bin, str(model_path), wav_path, notifier)

    return text.strip()


def run_once(args: argparse.Namespace) -> int:
    duration = None if args.duration <= 0 else args.duration
    try:
        text = _run_transcription_job(args, duration=duration)
    except Exception as exc:
        print(str(exc), file=sys.stderr)
        Notifier().send("Transcription error", str(exc), timeout_ms=3000)
        return 1

    if not text:
        print("(No speech detected)")
        Notifier().send("Done", "No speech detected", timeout_ms=1500)
        return 0

    return _emit_text(text, args, Notifier())


def run_worker(args: argparse.Namespace) -> int:
    state_dir = Path(args.state_dir)
    state_dir.mkdir(parents=True, exist_ok=True)
    pid_file = state_dir / "recording.pid"
    transcript_file = state_dir / "transcript.txt"
    error_file = state_dir / "error.txt"

    pid_file.write_text(str(os.getpid()), encoding="utf-8")
    if transcript_file.exists():
        transcript_file.unlink()
    if error_file.exists():
        error_file.unlink()

    try:
        text = _run_transcription_job(args, duration=None)
        transcript_file.write_text(text, encoding="utf-8")
    except Exception as exc:
        error_file.write_text(str(exc), encoding="utf-8")
        return 1
    finally:
        if pid_file.exists():
            pid_file.unlink()

    return 0


def start_background(args: argparse.Namespace) -> int:
    state_dir = Path(args.state_dir)
    state_dir.mkdir(parents=True, exist_ok=True)
    pid_file = state_dir / "recording.pid"
    pid = _read_pid(pid_file)

    if _is_alive(pid):
        print("Recording is already running.")
        return 0

    cmd = [
        sys.executable,
        str(Path(__file__).resolve()),
        "--mode",
        "once",
        "--worker",
        "--model",
        args.model,
        "--samplerate",
        str(args.samplerate),
        "--channels",
        str(args.channels),
        "--notify-interval",
        str(args.notify_interval),
        "--state-dir",
        str(state_dir),
    ]
    if args.whisper_bin:
        cmd.extend(["--whisper-bin", args.whisper_bin])

    subprocess.Popen(
        cmd,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        start_new_session=True,
    )
    Notifier().send(
        "Recording", "Started (press keybind again to stop)", timeout_ms=1200
    )
    print("Recording started.")
    return 0


def stop_background(args: argparse.Namespace) -> int:
    state_dir = Path(args.state_dir)
    pid_file = state_dir / "recording.pid"
    transcript_file = state_dir / "transcript.txt"
    error_file = state_dir / "error.txt"
    pid = _read_pid(pid_file)

    if not _is_alive(pid):
        if pid_file.exists():
            pid_file.unlink()
        print("No active recording.")
        return 1

    assert pid is not None
    os.kill(pid, signal.SIGINT)
    Notifier().send("Recording", "Stopping...", timeout_ms=1200)

    deadline = time.monotonic() + max(args.stop_timeout, 1.0)
    while _is_alive(pid) and time.monotonic() < deadline:
        time.sleep(0.1)

    if _is_alive(pid):
        print("Timed out waiting for transcription to finish.", file=sys.stderr)
        return 1

    if error_file.exists():
        message = error_file.read_text(encoding="utf-8").strip()
        error_file.unlink()
        print(message or "Worker failed.", file=sys.stderr)
        return 1

    text = ""
    if transcript_file.exists():
        text = transcript_file.read_text(encoding="utf-8").strip()
        transcript_file.unlink()

    if not text:
        print("(No speech detected)")
        Notifier().send("Done", "No speech detected", timeout_ms=1500)
        return 0

    return _emit_text(text, args, Notifier())


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Record from microphone and transcribe with whisper.cpp"
    )
    parser.add_argument(
        "--mode",
        choices=("once", "start", "stop", "toggle"),
        default="once",
        help="once: record/transcribe immediately, start/stop: background toggle pieces, toggle: start if idle else stop",
    )
    parser.add_argument(
        "--worker",
        action="store_true",
        help=argparse.SUPPRESS,
    )
    parser.add_argument(
        "--model", default=DEFAULT_MODEL, help="Path to whisper.cpp model"
    )
    parser.add_argument(
        "--whisper-bin",
        default=None,
        help="Path to whisper.cpp binary (default: auto-detect whisper-cli/main)",
    )
    parser.add_argument(
        "--duration",
        type=float,
        default=DEFAULT_DURATION,
        help="Recording length in seconds for --mode once (default: 8). Use 0 for manual stop.",
    )
    parser.add_argument(
        "--samplerate",
        type=int,
        default=16000,
        help="Input sample rate (default: 16000)",
    )
    parser.add_argument(
        "--channels", type=int, default=1, help="Input channels (default: 1)"
    )
    parser.add_argument(
        "--notify-interval",
        type=float,
        default=1.0,
        help="Seconds between notification timer updates (default: 1.0)",
    )
    parser.add_argument(
        "--output",
        choices=("print", "type"),
        default="print",
        help="How to emit transcript text: print to terminal or type into active window",
    )
    parser.add_argument(
        "--state-dir",
        default=str(DEFAULT_STATE_DIR),
        help="Directory to store toggle state files",
    )
    parser.add_argument(
        "--stop-timeout",
        type=float,
        default=90.0,
        help="Max seconds to wait for background transcription to finish on stop",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    if args.worker:
        return run_worker(args)

    if args.mode == "once":
        return run_once(args)

    if args.mode == "start":
        return start_background(args)

    if args.mode == "stop":
        return stop_background(args)

    state_dir = Path(args.state_dir)
    pid = _read_pid(state_dir / "recording.pid")
    if _is_alive(pid):
        return stop_background(args)
    return start_background(args)


if __name__ == "__main__":
    raise SystemExit(main())
