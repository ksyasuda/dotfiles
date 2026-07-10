#!/usr/bin/env python3
"""Run a read-only consultation with the opposite model provider."""

import argparse
import json
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


def detect_caller(env: dict[str, str]) -> str:
    is_codex = bool(env.get("CODEX_THREAD_ID"))
    is_claude = env.get("CLAUDECODE") == "1" or bool(
        env.get("CLAUDE_CODE_ENTRYPOINT")
    )
    if is_codex and is_claude:
        raise ValueError("Ambiguous caller environment")
    if is_codex:
        return "codex"
    if is_claude:
        return "claude"
    raise ValueError("Cannot detect caller; pass --caller claude or --caller codex")


@dataclass(frozen=True)
class Route:
    provider: str
    model: str
    effort: str


def select_route(caller: str, complexity: str, context_heavy: bool = False) -> Route:
    if complexity not in {"quick", "standard", "deep"}:
        raise ValueError(f"Unknown complexity: {complexity}")
    effort = (
        "high"
        if complexity == "deep" or (complexity == "quick" and context_heavy)
        else "medium"
    )
    if caller == "claude":
        model = "gpt-5.6-terra" if complexity == "quick" else "gpt-5.6-sol"
        return Route("codex", model, effort)
    if caller == "codex":
        if complexity == "quick":
            model = "claude-sonnet-5" if context_heavy else "claude-sonnet-4-6"
        else:
            model = "claude-opus-4-8"
        return Route("claude", model, effort)
    raise ValueError(f"Unknown caller: {caller}")


def apply_model_override(route: Route, model: str) -> Route:
    if model not in ALLOWED_MODELS[route.provider]:
        raise ValueError(f"Model {model!r} is not allowed for {route.provider}")
    return Route(route.provider, model, route.effort)


def build_command(
    route: Route,
    repo: Path,
    schema_path: Path,
    output_path: Path | None = None,
) -> list[str]:
    if route.provider == "codex":
        if output_path is None:
            raise ValueError("Codex requires an output path")
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
            "read-only",
            "--ephemeral",
            "--skip-git-repo-check",
            "--output-schema",
            str(schema_path),
            "--output-last-message",
            str(output_path),
            "--json",
            "--cd",
            str(repo),
            "-",
        ]

    schema = json.dumps(json.loads(schema_path.read_text()), separators=(",", ":"))
    return [
        "claude",
        "--print",
        "--safe-mode",
        "--model",
        route.model,
        "--effort",
        route.effort,
        "--permission-mode",
        "plan",
        "--tools",
        "Read,Glob,Grep",
        "--disable-slash-commands",
        "--no-session-persistence",
        "--prompt-suggestions",
        "false",
        "--output-format",
        "json",
        "--json-schema",
        schema,
    ]


def build_peer_prompt(question: str, route: Route) -> str:
    return f"""You are an independent {route.provider} reviewer. Inspect the current repository in read-only mode and give a second opinion on the request below.

Hard constraints:
- Do not modify, create, rename, or delete files.
- Do not implement code or run commands that can change state.
- Do not commit, branch, push, open pull requests, or contact external systems.
- Do not delegate to subagents or invoke Claude, Codex, or peer-consult recursively.
- Base claims on repository evidence. Cite file paths and line numbers when available.
- Call out uncertainty and missing evidence. Do not pretend the caller's proposal is correct.
- Return only the structured decision memo required by the response schema.

Request:
{question.strip()}
"""


MEMO_FIELDS = {
    "verdict",
    "evidence",
    "risks",
    "alternatives",
    "recommendation",
    "confidence",
}


def validate_memo(value: object) -> dict[str, object]:
    if not isinstance(value, dict) or set(value) != MEMO_FIELDS:
        raise ValueError("Invalid decision memo fields")
    if not isinstance(value["verdict"], str) or not value["verdict"].strip():
        raise ValueError("Invalid decision memo verdict")
    if not isinstance(value["recommendation"], str) or not value["recommendation"].strip():
        raise ValueError("Invalid decision memo recommendation")
    for field in ("evidence", "risks", "alternatives"):
        items = value[field]
        if not isinstance(items, list) or any(
            not isinstance(item, str) or not item.strip() for item in items
        ):
            raise ValueError(f"Invalid decision memo {field}")
    if value["confidence"] not in {"low", "medium", "high"}:
        raise ValueError("Invalid decision memo confidence")
    return value


def parse_claude_output(output: str) -> object:
    try:
        envelope = json.loads(output)
    except json.JSONDecodeError as error:
        raise ValueError("Claude returned malformed JSON") from error
    if isinstance(envelope, dict) and "structured_output" in envelope:
        return envelope["structured_output"]
    if isinstance(envelope, dict) and isinstance(envelope.get("result"), str):
        try:
            return json.loads(envelope["result"])
        except json.JSONDecodeError as error:
            raise ValueError("Claude result did not contain structured JSON") from error
    return envelope


def _bullets(items: object) -> str:
    values = items if isinstance(items, list) else []
    return "\n".join(f"- {item}" for item in values) or "- None identified."


def render_memo(memo: dict[str, object], route: Route) -> str:
    provider = route.provider.capitalize()
    return f"""## Peer consultation

{provider} · {route.model} · {route.effort}

### Verdict

{memo['verdict']}

### Evidence

{_bullets(memo['evidence'])}

### Risks

{_bullets(memo['risks'])}

### Alternatives

{_bullets(memo['alternatives'])}

### Recommendation

{memo['recommendation']}

### Confidence

{memo['confidence']}
"""


def run_consultation(
    route: Route,
    repo: Path,
    prompt: str,
    schema_path: Path,
    *,
    timeout: int = 600,
    env: dict[str, str] | None = None,
) -> dict[str, object]:
    process_env = dict(os.environ if env is None else env)
    if shutil.which(route.provider, path=process_env.get("PATH")) is None:
        raise RuntimeError(f"Required CLI is not installed: {route.provider}")

    with tempfile.TemporaryDirectory(prefix="peer-consult-") as temp_dir:
        output_path = (
            Path(temp_dir) / "memo.json" if route.provider == "codex" else None
        )
        command = build_command(route, repo, schema_path, output_path)
        try:
            result = subprocess.run(
                command,
                cwd=repo,
                env=process_env,
                input=prompt,
                text=True,
                capture_output=True,
                timeout=timeout,
                check=False,
            )
        except subprocess.TimeoutExpired as error:
            raise RuntimeError(f"{route.provider} consultation timed out") from error
        if result.returncode != 0:
            detail = (result.stderr or result.stdout).strip() or "no error output"
            raise RuntimeError(
                f"{route.provider} consultation failed ({result.returncode}): {detail}"
            )
        if route.provider == "codex":
            if output_path is None or not output_path.is_file():
                raise RuntimeError("Codex did not produce a decision memo")
            try:
                value = json.loads(output_path.read_text())
            except json.JSONDecodeError as error:
                raise RuntimeError("Codex returned malformed JSON") from error
        else:
            value = parse_claude_output(result.stdout)
        return validate_memo(value)


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Get a read-only second opinion from the opposite model provider."
    )
    parser.add_argument("--caller", choices=("claude", "codex"))
    parser.add_argument(
        "--complexity",
        choices=("quick", "standard", "deep"),
        default="standard",
    )
    parser.add_argument("--context-heavy", action="store_true")
    parser.add_argument("--model", help="Approved target-model override")
    parser.add_argument("--repo", type=Path, default=Path.cwd())
    parser.add_argument("--timeout", type=int, default=600)
    parser.add_argument("--dry-run", action="store_true")
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    try:
        question = sys.stdin.read().strip()
        if not question:
            raise ValueError("Consultation request must be provided on stdin")
        repo = args.repo.expanduser().resolve()
        if not repo.is_dir():
            raise ValueError(f"Repository directory does not exist: {repo}")
        caller = args.caller or detect_caller(dict(os.environ))
        route = select_route(caller, args.complexity, args.context_heavy)
        if args.model:
            route = apply_model_override(route, args.model)
        prompt = build_peer_prompt(question, route)
        schema_path = Path(__file__).with_name("memo.schema.json")
        output_path = (
            Path(tempfile.gettempdir()) / "peer-consult-dry-run-output.json"
            if route.provider == "codex"
            else None
        )
        command = build_command(route, repo, schema_path, output_path)
        if args.dry_run:
            print(
                json.dumps(
                    {
                        "provider": route.provider,
                        "model": route.model,
                        "effort": route.effort,
                        "command": command,
                        "prompt": prompt,
                    },
                    indent=2,
                )
            )
            return 0
        memo = run_consultation(
            route,
            repo,
            prompt,
            schema_path,
            timeout=args.timeout,
        )
        print(render_memo(memo, route), end="")
        return 0
    except (OSError, RuntimeError, ValueError) as error:
        print(f"peer-consult: error: {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
