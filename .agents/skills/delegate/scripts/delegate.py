#!/usr/bin/env python3
"""Delegate a self-contained task to a Claude or Codex subagent."""

import argparse
import os
import shutil
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path


ALLOWED_MODELS = {
    "codex": frozenset({"gpt-5.6-terra", "gpt-5.6-sol"}),
    "claude": frozenset(
        {"claude-sonnet-4-6", "claude-sonnet-5", "claude-opus-4-8"}
    ),
}

# tier -> provider -> (model, effort)
ROUTES = {
    "quick": {
        "codex": ("gpt-5.6-terra", "medium"),
        "claude": ("claude-sonnet-4-6", "medium"),
    },
    "quick-context": {
        "codex": ("gpt-5.6-terra", "high"),
        "claude": ("claude-sonnet-5", "high"),
    },
    "standard": {
        "codex": ("gpt-5.6-sol", "medium"),
        "claude": ("claude-opus-4-8", "medium"),
    },
    "deep": {
        "codex": ("gpt-5.6-sol", "high"),
        "claude": ("claude-opus-4-8", "high"),
    },
}

READ_ONLY_RULES = """\
Hard constraints:
- You are in read-only mode. Do not modify, create, rename, or delete files.
- Do not commit, branch, push, or contact external systems that change state.
- Base claims on repository evidence. Cite file paths and line numbers."""

WRITE_RULES = """\
Hard constraints:
- Work only inside the given repository directory.
- Do not commit, branch, push, or open pull requests unless the task says to.
- Do not delete or rename files the task does not cover; if something looks
  wrong or unexpected, stop and report instead of guessing.
- Verify your work (build, tests, or a targeted check) when feasible."""

REPORT_FORMAT = """\
End your reply with a report containing these sections:
- Summary: what you did or found, in a few sentences.
- Details: key evidence, decisions, or findings, with file:line references.
- Files changed: list each changed file, or "none".
- Verification: what you ran and the outcome, or "not verified" and why.
- Open questions: anything unresolved the caller must decide, or "none"."""


@dataclass(frozen=True)
class Route:
    provider: str
    model: str
    effort: str


def select_route(provider: str, tier: str) -> Route:
    if tier not in ROUTES:
        raise ValueError(f"Unknown tier: {tier}")
    if provider not in ("claude", "codex"):
        raise ValueError(f"Unknown provider: {provider}")
    model, effort = ROUTES[tier][provider]
    return Route(provider, model, effort)


def apply_model_override(route: Route, model: str) -> Route:
    if model not in ALLOWED_MODELS[route.provider]:
        raise ValueError(f"Model {model!r} is not allowed for {route.provider}")
    return Route(route.provider, model, route.effort)


def build_command(
    route: Route,
    repo: Path,
    mode: str,
    output_path: Path | None = None,
) -> list[str]:
    if route.provider == "codex":
        if output_path is None:
            raise ValueError("Codex requires an output path")
        sandbox = "read-only" if mode == "read" else "workspace-write"
        return [
            "codex",
            "exec",
            "--ignore-user-config",
            "--model",
            route.model,
            "--config",
            f'model_reasoning_effort="{route.effort}"',
            "--config",
            'approval_policy="never"',
            "--sandbox",
            sandbox,
            "--ephemeral",
            "--skip-git-repo-check",
            "--output-last-message",
            str(output_path),
            "--cd",
            str(repo),
            "-",
        ]

    command = [
        "claude",
        "--print",
        "--model",
        route.model,
        "--effort",
        route.effort,
        "--disable-slash-commands",
        "--no-session-persistence",
    ]
    if mode == "read":
        command += [
            "--permission-mode",
            "plan",
            "--tools",
            "Read,Glob,Grep",
        ]
    else:
        command += [
            "--permission-mode",
            "acceptEdits",
            "--tools",
            "Read,Glob,Grep,Edit,Write,Bash",
            "--allowedTools",
            "Edit,Write,Bash",
        ]
    return command


def build_prompt(task: str, route: Route, mode: str) -> str:
    rules = READ_ONLY_RULES if mode == "read" else WRITE_RULES
    return f"""You are a {route.provider} subagent completing a delegated task \
inside the current repository. Work independently; the caller cannot answer \
questions mid-task. If the task is ambiguous, choose the safest reasonable \
interpretation and note the choice in your report.

{rules}
- Do not delegate further or invoke Claude or Codex recursively.

{REPORT_FORMAT}

Task:
{task.strip()}
"""


def run_delegation(
    route: Route,
    repo: Path,
    prompt: str,
    mode: str,
    *,
    timeout: int = 1800,
) -> str:
    if shutil.which(route.provider) is None:
        raise RuntimeError(f"Required CLI is not installed: {route.provider}")

    with tempfile.TemporaryDirectory(prefix="delegate-") as temp_dir:
        output_path = (
            Path(temp_dir) / "report.md" if route.provider == "codex" else None
        )
        command = build_command(route, repo, mode, output_path)
        try:
            result = subprocess.run(
                command,
                cwd=repo,
                input=prompt,
                text=True,
                capture_output=True,
                timeout=timeout,
                check=False,
            )
        except subprocess.TimeoutExpired as error:
            raise RuntimeError(
                f"{route.provider} delegation timed out after {timeout}s"
            ) from error
        if result.returncode != 0:
            detail = (result.stderr or result.stdout).strip() or "no error output"
            raise RuntimeError(
                f"{route.provider} delegation failed ({result.returncode}): {detail}"
            )
        if route.provider == "codex":
            if output_path is None or not output_path.is_file():
                raise RuntimeError("Codex did not produce a report")
            report = output_path.read_text().strip()
        else:
            report = result.stdout.strip()
        if not report:
            raise RuntimeError(f"{route.provider} returned an empty report")
        return report


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Delegate a self-contained task to a Claude or Codex subagent."
    )
    parser.add_argument("--provider", choices=("claude", "codex"), required=True)
    parser.add_argument(
        "--tier",
        choices=("quick", "quick-context", "standard", "deep"),
        default="standard",
    )
    parser.add_argument("--mode", choices=("read", "write"), default="read")
    parser.add_argument("--model", help="Approved model override")
    parser.add_argument("--repo", type=Path, default=Path.cwd())
    parser.add_argument("--timeout", type=int, default=1800)
    parser.add_argument("--dry-run", action="store_true")
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    try:
        task = sys.stdin.read().strip()
        if not task:
            raise ValueError("Task must be provided on stdin")
        repo = args.repo.expanduser().resolve()
        if not repo.is_dir():
            raise ValueError(f"Repository directory does not exist: {repo}")
        route = select_route(args.provider, args.tier)
        if args.model:
            route = apply_model_override(route, args.model)
        prompt = build_prompt(task, route, args.mode)
        if args.dry_run:
            output_path = (
                Path(tempfile.gettempdir()) / "delegate-dry-run-report.md"
                if route.provider == "codex"
                else None
            )
            command = build_command(route, repo, args.mode, output_path)
            print(f"provider: {route.provider}")
            print(f"model: {route.model}")
            print(f"effort: {route.effort}")
            print(f"mode: {args.mode}")
            print(f"command: {' '.join(command)}")
            print(f"prompt:\n{prompt}")
            return 0
        report = run_delegation(
            route,
            repo,
            prompt,
            args.mode,
            timeout=args.timeout,
        )
        print(f"[{route.provider} · {route.model} · {route.effort} · {args.mode}]")
        print(report)
        return 0
    except (OSError, RuntimeError, ValueError) as error:
        print(f"delegate: error: {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
