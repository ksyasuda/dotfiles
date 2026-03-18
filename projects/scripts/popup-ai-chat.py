#!/usr/bin/env python3
"""
Popup AI chat assistant using rofi for input and OpenRouter for responses.
"""

import os
import shutil
import subprocess
import sys
from typing import Optional

import requests

API_URL = "https://openrouter.ai/api/v1/chat/completions"
MODEL = os.environ.get("OPENROUTER_MODEL", "openai/gpt-oss-120b:free")
APP_NAME = "Popup AI Chat"
SYSTEM_PROMPT = (
    "You are a helpful AI assistant. Give direct, accurate answers. "
    "Use concise formatting unless the user asks for depth."
)


def load_api_key() -> str:
    """Load OpenRouter API key from env or fallback file."""
    api_key = os.environ.get("OPENROUTER_API_KEY", "").strip()
    if api_key:
        return api_key

    key_file = os.path.expanduser("~/.openrouterapikey")
    if os.path.isfile(key_file):
        with open(key_file, "r", encoding="utf-8") as handle:
            return handle.read().strip()

    return ""


def show_error(message: str) -> None:
    """Display an error message via zenity."""
    subprocess.run(
        ["zenity", "--error", "--title", "Error", "--text", message],
        stderr=subprocess.DEVNULL,
    )


def check_dependencies() -> bool:
    """Validate required desktop tools are available."""
    missing = [cmd for cmd in ("rofi", "zenity") if shutil.which(cmd) is None]
    if not missing:
        return True

    message = f"Missing required command(s): {', '.join(missing)}"
    if shutil.which("zenity") is not None:
        show_error(message)
    else:
        print(f"Error: {message}", file=sys.stderr)
    return False


def get_rofi_input() -> Optional[str]:
    """Ask for user input through rofi."""
    result = subprocess.run(
        ["rofi", "-dmenu", "-i", "-p", "Ask AI"],
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
    )
    if result.returncode != 0:
        return None

    prompt = result.stdout.strip()
    return prompt or None


def show_notification(body: str) -> None:
    """Show processing notification when notify-send exists."""
    if shutil.which("notify-send") is None:
        return

    subprocess.Popen(
        ["notify-send", "-t", "0", "-a", APP_NAME, "Processing...", body],
        stderr=subprocess.DEVNULL,
    )


def close_notification() -> None:
    """Close the processing notification if one was sent."""
    if shutil.which("pkill") is None:
        return

    subprocess.run(
        ["pkill", "-f", "notify-send.*Processing..."],
        stderr=subprocess.DEVNULL,
    )


def make_api_request(api_key: str, messages: list[dict[str, str]]) -> dict:
    """Send chat request to OpenRouter and return JSON payload."""
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}",
        "HTTP-Referer": "https://github.com/sudacode/scripts",
        "X-Title": APP_NAME,
    }
    payload = {
        "model": MODEL,
        "messages": messages,
        "temperature": 0.7,
    }
    response = requests.post(API_URL, headers=headers, json=payload, timeout=90)
    return response.json()


def display_result(content: str) -> None:
    """Display model output in a text window."""
    subprocess.run(
        [
            "zenity",
            "--text-info",
            "--title",
            "AI Response",
            "--width",
            "900",
            "--height",
            "700",
            "--font",
            "monospace 11",
        ],
        input=content,
        text=True,
        stderr=subprocess.DEVNULL,
    )


def ask_follow_up() -> bool:
    """Ask if the user wants to continue the conversation."""
    result = subprocess.run(
        [
            "zenity",
            "--question",
            "--title",
            APP_NAME,
            "--text",
            "Ask a follow-up question?",
            "--ok-label",
            "Ask Follow-up",
            "--cancel-label",
            "Close",
        ],
        stderr=subprocess.DEVNULL,
    )
    return result.returncode == 0


def extract_content(response: dict) -> str:
    """Extract assistant response from OpenRouter payload."""
    if "error" in response:
        message = response["error"].get("message", "Unknown API error")
        raise ValueError(message)

    try:
        content = response["choices"][0]["message"]["content"]
    except (KeyError, IndexError, TypeError) as exc:
        raise ValueError("Failed to parse API response") from exc

    if not content:
        raise ValueError("Empty response from API")

    return content


def main() -> int:
    if not check_dependencies():
        return 1

    api_key = load_api_key()
    if not api_key:
        show_error("OPENROUTER_API_KEY environment variable is not set.")
        return 1

    history: list[dict[str, str]] = [{"role": "system", "content": SYSTEM_PROMPT}]

    while True:
        user_input = get_rofi_input()
        if not user_input:
            return 0

        request_messages = history + [{"role": "user", "content": user_input}]
        show_notification(f"Thinking: {user_input[:60]}...")

        try:
            response = make_api_request(api_key, request_messages)
            content = extract_content(response)
        except requests.RequestException as exc:
            show_error(f"API request failed: {exc}")
            return 1
        except ValueError as exc:
            show_error(str(exc))
            return 1
        except Exception as exc:  # pragma: no cover
            show_error(f"Unexpected error: {exc}")
            return 1
        finally:
            close_notification()

        history.append({"role": "user", "content": user_input})
        history.append({"role": "assistant", "content": content})

        display_result(content)
        if not ask_follow_up():
            return 0


if __name__ == "__main__":
    sys.exit(main())
