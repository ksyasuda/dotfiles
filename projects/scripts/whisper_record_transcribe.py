#!/usr/bin/env python3
"""Record microphone audio and transcribe it with whisper.cpp or faster-whisper."""

from __future__ import annotations

import argparse
import os
import shutil
import signal
import subprocess
import sys
import tempfile
import time
import traceback
import wave
from pathlib import Path

import numpy as np
import sounddevice as sd

DEFAULT_MODEL = "small"
DEFAULT_DURATION = 8.0
DEFAULT_STATE_DIR = Path.home() / ".cache" / "whisper-record-toggle"
DEFAULT_WHISPERCPP_MODEL_DIR = Path.home() / "models" / "whisper.cpp"
APP_NAME = "Whisper Record"
DEFAULT_TOGGLE_DEBOUNCE = 0.0


def _append_log(state_dir: Path, message: str) -> None:
    state_dir.mkdir(parents=True, exist_ok=True)
    log_file = state_dir / "worker.log"
    timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
    with log_file.open("a", encoding="utf-8") as fh:
        fh.write(f"[{timestamp}] {message}\n")


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


def write_wav(path: Path, audio: np.ndarray, samplerate: int, channels: int) -> None:
    with wave.open(str(path), "wb") as wav_file:
        wav_file.setnchannels(channels)
        wav_file.setsampwidth(2)
        wav_file.setframerate(samplerate)
        wav_file.writeframes(audio.tobytes())


def transcribe(
    backend: str,
    model_name_or_path: str,
    wav_path: Path,
    notifier: Notifier,
    device: str,
    compute_type: str,
    beam_size: int,
) -> str:
    if backend == "whispercpp":
        return transcribe_whispercpp(
            model_name_or_path=model_name_or_path,
            wav_path=wav_path,
            notifier=notifier,
            device=device,
            beam_size=beam_size,
        )
    if backend == "ctranslate2":
        return transcribe_ctranslate2(
            model_name_or_path=model_name_or_path,
            wav_path=wav_path,
            notifier=notifier,
            device=device,
            compute_type=compute_type,
            beam_size=beam_size,
        )
    raise RuntimeError(f"Unsupported backend: {backend}")


def _resolve_whispercpp_model(model_name_or_path: str) -> Path:
    candidate = Path(model_name_or_path).expanduser()
    if candidate.exists():
        return candidate

    name = model_name_or_path.strip()
    search_paths = [
        DEFAULT_WHISPERCPP_MODEL_DIR / name,
        DEFAULT_WHISPERCPP_MODEL_DIR / f"ggml-{name}.bin",
        DEFAULT_WHISPERCPP_MODEL_DIR / f"ggml-{name}.en.bin",
    ]
    for path in search_paths:
        if path.exists():
            return path

    raise RuntimeError(
        "whisper.cpp model not found. Pass --model as a .bin path or place model at "
        f"{DEFAULT_WHISPERCPP_MODEL_DIR}/ggml-<name>.bin (for example ggml-small.bin)."
    )


def transcribe_whispercpp(
    model_name_or_path: str,
    wav_path: Path,
    notifier: Notifier,
    device: str,
    beam_size: int,
) -> str:
    whisper_cli = shutil.which("whisper-cli")
    if not whisper_cli:
        raise RuntimeError("whisper-cli not found in PATH. Install whisper.cpp.")

    model_path = _resolve_whispercpp_model(model_name_or_path)
    output_prefix = wav_path.parent / wav_path.stem
    output_txt = Path(f"{output_prefix}.txt")
    if output_txt.exists():
        output_txt.unlink()

    notifier.send("Transcribing", "Running whisper.cpp...", timeout_ms=1500)
    cmd = [
        whisper_cli,
        "-f",
        str(wav_path),
        "-m",
        str(model_path),
        "-otxt",
        "-of",
        str(output_prefix),
        "-bs",
        str(beam_size),
        "-np",
    ]
    if device == "cpu":
        cmd.append("-ng")

    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        details = (result.stderr or result.stdout or "").strip()
        raise RuntimeError(details or "whisper.cpp failed.")
    if not output_txt.exists():
        details = (result.stderr or result.stdout or "").strip()
        raise RuntimeError(
            "whisper.cpp completed but no transcript file was produced. "
            f"Expected: {output_txt}. {details}"
        )
    return output_txt.read_text(encoding="utf-8").strip()


def transcribe_ctranslate2(
    model_name_or_path: str,
    wav_path: Path,
    notifier: Notifier,
    device: str,
    compute_type: str,
    beam_size: int,
) -> str:
    whisper_cli = shutil.which("whisper-ctranslate2")
    if not whisper_cli:
        raise RuntimeError(
            "whisper-ctranslate2 not found in PATH. Install with: pip install faster-whisper"
        )

    if model_name_or_path.endswith(".bin"):
        raise RuntimeError(
            "faster-whisper/ctranslate2 does not use ggml .bin models. "
            "Use a model name like 'small' or a CTranslate2 model directory."
        )

    notifier.send("Transcribing", "Running whisper-ctranslate2...", timeout_ms=1500)
    output_dir = wav_path.parent
    output_txt = output_dir / f"{wav_path.stem}.txt"
    if output_txt.exists():
        output_txt.unlink()

    cmd = [
        whisper_cli,
        str(wav_path),
        "--output_dir",
        str(output_dir),
        "--output_format",
        "txt",
        "--device",
        device,
        "--compute_type",
        compute_type,
        "--beam_size",
        str(beam_size),
        "--verbose",
        "False",
    ]
    model_dir_candidate = Path(model_name_or_path).expanduser()
    if model_dir_candidate.exists() and model_dir_candidate.is_dir():
        cmd.extend(["--model_directory", str(model_dir_candidate)])
    elif "/" in model_name_or_path or model_name_or_path.startswith("."):
        cmd.extend(["--model_directory", model_name_or_path])
    else:
        cmd.extend(["--model", model_name_or_path])

    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        details = (result.stderr or result.stdout or "").strip()
        raise RuntimeError(details or "whisper-ctranslate2 failed.")
    if not output_txt.exists():
        details = (result.stderr or result.stdout or "").strip()
        raise RuntimeError(
            "whisper-ctranslate2 completed but no transcript file was produced. "
            f"Expected: {output_txt}. {details}"
        )
    return output_txt.read_text(encoding="utf-8").strip()


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


def _read_and_clear_error(error_file: Path) -> str | None:
    if not error_file.exists():
        return None
    message = error_file.read_text(encoding="utf-8").strip()
    error_file.unlink()
    return message or "Worker failed."


def _run_transcription_job(args: argparse.Namespace, duration: float | None) -> str:
    notifier = Notifier()
    model_name_or_path = args.model
    if (
        "/" in model_name_or_path
        or model_name_or_path.startswith(".")
        or model_name_or_path.startswith("~")
    ):
        model_path = Path(model_name_or_path).expanduser()
        if not model_path.exists():
            raise RuntimeError(f"Model path not found: {model_path}")
        model_name_or_path = str(model_path)

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
        notifier.send(
            "Transcribing",
            f"Running backend: {args.backend}",
            timeout_ms=1500,
        )
        text = transcribe(
            backend=args.backend,
            model_name_or_path=model_name_or_path,
            wav_path=wav_path,
            notifier=notifier,
            device=args.device,
            compute_type=args.compute_type,
            beam_size=args.beam_size,
        )

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
    _append_log(
        state_dir,
        f"worker start model={args.model} device={args.device} compute_type={args.compute_type}",
    )

    try:
        text = _run_transcription_job(args, duration=None)
        transcript_file.write_text(text, encoding="utf-8")
        _append_log(state_dir, f"worker complete transcript_chars={len(text)}")
    except Exception as exc:
        details = "".join(
            traceback.format_exception(type(exc), exc, exc.__traceback__)
        ).strip()
        error_file.write_text(str(exc), encoding="utf-8")
        _append_log(state_dir, f"worker error: {details}")
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
        "--backend",
        args.backend,
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
        "--device",
        args.device,
        "--compute-type",
        args.compute_type,
        "--beam-size",
        str(args.beam_size),
    ]

    log_path = state_dir / "worker.log"
    with log_path.open("a", encoding="utf-8") as log_fh:
        subprocess.Popen(
            cmd,
            stdout=log_fh,
            stderr=log_fh,
            start_new_session=True,
        )
    _append_log(state_dir, "start requested")
    # If worker fails immediately (common with model/device config issues),
    # surface that early instead of only showing "No active recording" later.
    time.sleep(0.15)
    worker_error = _read_and_clear_error(state_dir / "error.txt")
    if worker_error:
        print(worker_error, file=sys.stderr)
        Notifier().send("Transcription error", worker_error, timeout_ms=3000)
        return 1

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
        worker_error = _read_and_clear_error(error_file)
        if worker_error:
            print(worker_error, file=sys.stderr)
            Notifier().send("Transcription error", worker_error, timeout_ms=3000)
            return 1
        if pid_file.exists():
            pid_file.unlink()
        print(f"No active recording. Check log: {state_dir / 'worker.log'}")
        return 1

    assert pid is not None
    os.kill(pid, signal.SIGINT)
    Notifier().send("Recording", "Stopping...", timeout_ms=1200)

    deadline = time.monotonic() + max(args.stop_timeout, 1.0)
    while _is_alive(pid) and time.monotonic() < deadline:
        time.sleep(0.1)

    if _is_alive(pid):
        print("Timed out waiting for transcription to finish.", file=sys.stderr)
        _append_log(state_dir, "stop timeout waiting for worker exit")
        return 1

    worker_error = _read_and_clear_error(error_file)
    if worker_error:
        print(worker_error, file=sys.stderr)
        Notifier().send("Transcription error", worker_error, timeout_ms=3000)
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
        description="Record from microphone and transcribe with whisper.cpp or faster-whisper"
    )
    parser.add_argument(
        "--mode",
        choices=("once", "start", "stop", "toggle"),
        default="once",
        help="once: record/transcribe immediately, start/stop: background toggle pieces, toggle: start if idle else stop",
    )
    parser.add_argument("--start", action="store_true", help=argparse.SUPPRESS)
    parser.add_argument("--stop", action="store_true", help=argparse.SUPPRESS)
    parser.add_argument("--toggle", action="store_true", help=argparse.SUPPRESS)
    parser.add_argument(
        "--worker",
        action="store_true",
        help=argparse.SUPPRESS,
    )
    parser.add_argument(
        "--backend",
        choices=("whispercpp", "ctranslate2"),
        default="whispercpp",
        help="Transcription backend (default: whispercpp)",
    )
    parser.add_argument(
        "--model",
        default=DEFAULT_MODEL,
        help="Model name or path. For whispercpp: ggml .bin path/name. For ctranslate2: model name or model directory.",
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
        "--device",
        default="auto",
        help="Inference device for faster-whisper (auto, cpu, cuda)",
    )
    parser.add_argument(
        "--compute-type",
        default="auto",
        help="faster-whisper compute type (auto, default, float16, int8, int8_float16, ...)",
    )
    parser.add_argument(
        "--beam-size",
        type=int,
        default=5,
        help="Beam size for decoding (default: 5)",
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
    parser.add_argument(
        "--toggle-debounce",
        type=float,
        default=DEFAULT_TOGGLE_DEBOUNCE,
        help="Ignore repeated toggle triggers within this many seconds (default: 0.0, disabled)",
    )
    args = parser.parse_args()
    legacy_modes = [
        mode
        for flag, mode in (
            (args.start, "start"),
            (args.stop, "stop"),
            (args.toggle, "toggle"),
        )
        if flag
    ]
    if len(legacy_modes) > 1:
        parser.error("Use only one of --start, --stop, or --toggle.")
    if legacy_modes:
        args.mode = legacy_modes[0]
    return args


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
    state_dir.mkdir(parents=True, exist_ok=True)
    debounce_file = state_dir / "last-toggle.txt"
    now = time.monotonic()
    if args.toggle_debounce > 0 and debounce_file.exists():
        try:
            last = float(debounce_file.read_text(encoding="utf-8").strip())
        except ValueError:
            last = 0.0
        if now - last < args.toggle_debounce:
            _append_log(
                state_dir,
                f"toggle ignored by debounce: delta={now - last:.3f}s < {args.toggle_debounce:.3f}s",
            )
            return 0

    debounce_file.write_text(f"{now:.6f}", encoding="utf-8")
    pid = _read_pid(state_dir / "recording.pid")
    if _is_alive(pid):
        return stop_background(args)
    return start_background(args)


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        state_dir = DEFAULT_STATE_DIR
        try:
            argv = sys.argv[1:]
            if "--state-dir" in argv:
                idx = argv.index("--state-dir")
                if idx + 1 < len(argv):
                    state_dir = Path(argv[idx + 1]).expanduser()
        except Exception:
            pass
        _append_log(
            state_dir,
            "fatal exception: "
            + "".join(traceback.format_exception(type(exc), exc, exc.__traceback__)).strip(),
        )
        raise
