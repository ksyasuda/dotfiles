#!/usr/bin/env python3
"""
Japanese Learning Assistant using OpenRouter API
Uses Google Gemini Flash 2.0 for AJATT-aligned Japanese analysis
"""

import os
import subprocess
import sys

import requests

OPENROUTER_API_KEY = os.environ.get("OPENROUTER_API_KEY", "")
# MODEL = os.environ.get("OPENROUTER_MODEL", "google/gemini-2.0-flash-001")
MODEL = os.environ.get("OPENROUTER_MODEL", "openai/gpt-oss-120b:free")
API_URL = "https://openrouter.ai/api/v1/chat/completions"

# Try to load API key from file if not in environment
if not OPENROUTER_API_KEY:
    key_file = os.path.expanduser("~/.openrouterapikey")
    if os.path.isfile(key_file):
        with open(key_file, "r") as f:
            OPENROUTER_API_KEY = f.read().strip()

TRANSLATION_PROMPT = """You are my Japanese-learning assistant. Help me acquire Japanese through deep, AJATT-aligned analysis.

For every input, output exactly using clean plain text formatting:

═══════════════════════════════════════
1. JAPANESE INPUT
═══════════════════════════════════════

Repeat the original text exactly. Correct only critical OCR/punctuation errors.

═══════════════════════════════════════
2. NATURAL ENGLISH TRANSLATION
═══════════════════════════════════════

Accurate and natural. Preserve tone, formality, and nuance. Avoid literalism.

═══════════════════════════════════════
3. BREAKDOWN
═══════════════════════════════════════

For each token, provide a breakdown of the vocabulary, grammar, and nuance.

  ▸ Vocabulary: Part of speech + concise definition
  ▸ Grammar: Particles, conjugations, constructions (contextual usage)
  ▸ Nuance: Implied meaning, connotation, emotional tone, differences from similar expressions

Core Principles:

  • Preserve native phrasing—never oversimplify
  • Highlight subtle grammar, register shifts, and pragmatic implications
  • Encourage pattern recognition; provide contrastive examples (e.g., ～のに vs ～けど)
  • Focus on real Japanese usage

Rules:

  • English explanations only (no romaji)
  • Use the section dividers shown above (═══) for major sections
  • Use ▸ for sub-items and • for bullet points
  • Put Japanese terms in 「brackets」
  • No filler text

Optional Additions (only when valuable):

  • Synonyms, formality/register notes, cultural insights, common mistakes, extra native examples

Goal: Deep comprehension, natural grammar internalization, nuanced vocabulary, progress toward Japanese-only understanding."""

GRAMMAR_PROMPT = """
    You are a Japanese grammar analysis assistant.

    The user will provide Japanese sentences. Your task is to explain the **grammar and structure in English**, prioritizing how the sentence is constructed rather than translating word-for-word.

    Rules:

    * Always show the original Japanese first.
    * Provide a short, natural English gloss only if helpful.
    * Explain grammar patterns, verb forms, particles, and omissions.
    * Emphasize nuance, implication, and speaker intent.
    * Avoid unnecessary vocabulary definitions unless they affect the grammar.
    * Assume the user is actively studying Japanese and wants deep understanding.

    Your explanations should help the user internalize patterns, not memorize translations.

"""


def show_error(message: str) -> None:
    """Display an error dialog using zenity."""
    subprocess.run(
        ["zenity", "--error", "--text", message, "--title", "Error"],
        stderr=subprocess.DEVNULL,
    )


def get_clipboard() -> str:
    """Get clipboard contents using wl-paste or xclip."""
    # Try wl-paste first (Wayland)
    result = subprocess.run(
        ["wl-paste", "--no-newline"],
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
    )
    if result.returncode == 0:
        return result.stdout.strip()

    # Fall back to xclip (X11)
    result = subprocess.run(
        ["xclip", "-selection", "clipboard", "-o"],
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
    )
    if result.returncode == 0:
        return result.stdout.strip()

    return ""


def get_input() -> str | None:
    """Get input from user via zenity entry dialog, pre-populated with clipboard."""
    clipboard = get_clipboard()

    cmd = [
        "zenity",
        "--entry",
        "--title",
        "Japanese Assistant",
        "--text",
        "Enter Japanese text to analyze (press Enter to send):",
        "--width",
        "600",
    ]

    if clipboard:
        cmd.extend(["--entry-text", clipboard])

    result = subprocess.run(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
    )
    if result.returncode != 0:
        return None
    return result.stdout.strip()


def get_mode() -> str | None:
    """Ask user to choose between translation and grammar assistant."""
    result = subprocess.run(
        [
            "zenity",
            "--list",
            "--title",
            "Japanese Assistant",
            "--text",
            "Choose analysis mode:",
            "--column=Mode",
            "Translation (full analysis)",
            "Grammar (structure focus)",
        ],
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
    )
    if result.returncode != 0:
        return None
    return result.stdout.strip()


def show_notification(message: str, body: str) -> subprocess.Popen:
    """Show a notification using notify-send."""
    return subprocess.Popen(
        ["notify-send", "-t", "0", "-a", "Japanese Assistant", message, body],
        stderr=subprocess.DEVNULL,
    )


def close_notification() -> None:
    """Close the processing notification."""
    subprocess.run(
        ["pkill", "-f", "notify-send.*Processing.*Analyzing"],
        stderr=subprocess.DEVNULL,
    )


def display_result(content: str) -> None:
    """Display the result in a zenity text-info dialog."""
    subprocess.run(
        [
            "zenity",
            "--text-info",
            "--title",
            "Japanese Analysis",
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


def make_api_request(user_input: str, system_prompt: str) -> dict:
    """Make the API request to OpenRouter."""
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {OPENROUTER_API_KEY}",
        "HTTP-Referer": "https://github.com/sudacode/scripts",
        "X-Title": "Japanese Learning Assistant",
    }

    payload = {
        "model": MODEL,
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_input},
        ],
        "temperature": 0.7,
    }

    response = requests.post(API_URL, headers=headers, json=payload, timeout=60)
    return response.json()


def main() -> int:
    # Check for API key
    if not OPENROUTER_API_KEY:
        show_error("OPENROUTER_API_KEY environment variable is not set.")
        return 1

    # Ask user for mode
    mode = get_mode()
    if not mode:
        return 0

    # Select appropriate prompt
    if "Grammar" in mode:
        system_prompt = GRAMMAR_PROMPT
    else:
        system_prompt = TRANSLATION_PROMPT

    # Get input from user
    user_input = get_input()
    if not user_input:
        return 0

    # Show loading notification
    show_notification("Processing...", f"Analyzing: {user_input[:50]}...")

    try:
        # Make API request
        response = make_api_request(user_input, system_prompt)

        # Close loading notification
        close_notification()

        # Check for errors in response
        if "error" in response:
            error_msg = response["error"].get("message", "Unknown error")
            show_error(error_msg)
            return 1

        # Extract content from response
        try:
            content = response["choices"][0]["message"]["content"]
        except (KeyError, IndexError):
            show_error("Failed to parse API response")
            return 1

        if not content:
            show_error("Empty response from API")
            return 1

        # Display result
        display_result(content)

    except requests.RequestException as e:
        close_notification()
        show_error(f"API request failed: {e}")
        return 1
    except Exception as e:
        close_notification()
        show_error(f"Error: {e}")
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
