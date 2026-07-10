import importlib.util
import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).parents[1] / "scripts" / "peer_consult.py"


def load_broker():
    if not SCRIPT.exists():
        raise AssertionError("peer_consult.py is missing")
    spec = importlib.util.spec_from_file_location("peer_consult", SCRIPT)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class RoutingTests(unittest.TestCase):
    def test_routes_approved_models_and_effort(self):
        broker = load_broker()

        cases = {
            ("claude", "quick", False): ("codex", "gpt-5.6-terra", "medium"),
            ("claude", "quick", True): ("codex", "gpt-5.6-terra", "high"),
            ("claude", "standard", False): ("codex", "gpt-5.6-sol", "medium"),
            ("claude", "deep", False): ("codex", "gpt-5.6-sol", "high"),
            ("codex", "quick", False): ("claude", "claude-sonnet-4-6", "medium"),
            ("codex", "quick", True): ("claude", "claude-sonnet-5", "high"),
            ("codex", "standard", False): ("claude", "claude-opus-4-8", "medium"),
            ("codex", "deep", False): ("claude", "claude-opus-4-8", "high"),
        }

        for inputs, expected in cases.items():
            with self.subTest(inputs=inputs):
                route = broker.select_route(*inputs)
                self.assertEqual(
                    (route.provider, route.model, route.effort),
                    expected,
                )

    def test_rejects_unknown_complexity(self):
        broker = load_broker()

        with self.assertRaisesRegex(ValueError, "Unknown complexity"):
            broker.select_route("codex", "extreme")

    def test_accepts_only_target_provider_model_overrides(self):
        broker = load_broker()
        self.assertTrue(
            hasattr(broker, "apply_model_override"),
            "model override validation is missing",
        )
        codex_route = broker.apply_model_override(
            broker.select_route("claude", "quick"),
            "gpt-5.6-sol",
        )
        claude_route = broker.apply_model_override(
            broker.select_route("codex", "quick"),
            "claude-opus-4-8",
        )

        self.assertEqual(codex_route.model, "gpt-5.6-sol")
        self.assertEqual(claude_route.model, "claude-opus-4-8")

    def test_rejects_disallowed_or_wrong_provider_model_overrides(self):
        broker = load_broker()
        self.assertTrue(
            hasattr(broker, "apply_model_override"),
            "model override validation is missing",
        )
        route = broker.select_route("claude", "quick")

        for model in (
            "gpt-5.6-luna",
            "gpt-5.5",
            "claude-sonnet-5",
            "claude-haiku-4-5",
        ):
            with self.subTest(model=model):
                with self.assertRaisesRegex(ValueError, "not allowed"):
                    broker.apply_model_override(route, model)


class CallerDetectionTests(unittest.TestCase):
    def test_detects_codex_and_claude_environments(self):
        broker = load_broker()
        self.assertTrue(hasattr(broker, "detect_caller"), "caller detection is missing")

        self.assertEqual(broker.detect_caller({"CODEX_THREAD_ID": "abc"}), "codex")
        self.assertEqual(broker.detect_caller({"CLAUDECODE": "1"}), "claude")
        self.assertEqual(
            broker.detect_caller({"CLAUDE_CODE_ENTRYPOINT": "cli"}),
            "claude",
        )

    def test_rejects_missing_or_ambiguous_caller(self):
        broker = load_broker()
        self.assertTrue(hasattr(broker, "detect_caller"), "caller detection is missing")

        with self.assertRaisesRegex(ValueError, "Cannot detect"):
            broker.detect_caller({})
        with self.assertRaisesRegex(ValueError, "Ambiguous"):
            broker.detect_caller({"CODEX_THREAD_ID": "abc", "CLAUDECODE": "1"})


class CommandTests(unittest.TestCase):
    def setUp(self):
        self.broker = load_broker()
        self.repo = Path("/tmp/example-repo")
        self.schema = Path(__file__).parents[1] / "scripts" / "memo.schema.json"

    def test_builds_read_only_ephemeral_codex_command(self):
        self.assertTrue(hasattr(self.broker, "build_command"), "command builder is missing")
        route = self.broker.select_route("claude", "standard")
        command = self.broker.build_command(
            route,
            self.repo,
            self.schema,
            Path("/tmp/peer-output.json"),
        )

        self.assertEqual(command[:2], ["codex", "exec"])
        self.assertIn("gpt-5.6-sol", command)
        self.assertIn('model_reasoning_effort="medium"', command)
        self.assertIn('approval_policy="never"', command)
        self.assertIn("read-only", command)
        self.assertIn("--ephemeral", command)
        self.assertIn("--ignore-user-config", command)
        self.assertIn("--json", command)
        self.assertIn(str(self.schema), command)
        self.assertIn("/tmp/peer-output.json", command)
        self.assertEqual(command[-1], "-")
        self.assertFalse(any("dangerously" in arg for arg in command))

    def test_builds_safe_nonpersistent_claude_command(self):
        self.assertTrue(hasattr(self.broker, "build_command"), "command builder is missing")
        route = self.broker.select_route("codex", "deep")
        command = self.broker.build_command(route, self.repo, self.schema)

        self.assertEqual(command[0], "claude")
        self.assertIn("--print", command)
        self.assertIn("claude-opus-4-8", command)
        self.assertIn("high", command)
        self.assertIn("--safe-mode", command)
        self.assertIn("--permission-mode", command)
        self.assertIn("plan", command)
        self.assertIn("--no-session-persistence", command)
        self.assertIn("Read,Glob,Grep", command)
        self.assertNotIn("Bash", command)
        schema_arg = command[command.index("--json-schema") + 1]
        self.assertEqual(json.loads(schema_arg)["additionalProperties"], False)

    def test_peer_prompt_forbids_changes_and_requires_evidence(self):
        self.assertTrue(hasattr(self.broker, "build_peer_prompt"), "peer prompt builder is missing")
        route = self.broker.select_route("codex", "standard")
        prompt = self.broker.build_peer_prompt("Should we split this service?", route)

        for phrase in (
            "read-only",
            "Do not modify",
            "Do not implement",
            "Do not delegate",
            "repository evidence",
            "Should we split this service?",
        ):
            with self.subTest(phrase=phrase):
                self.assertIn(phrase, prompt)


class MemoTests(unittest.TestCase):
    def setUp(self):
        self.broker = load_broker()
        self.memo = {
            "verdict": "Split only after measuring coupling.",
            "evidence": ["src/service.py:42 owns both workflows."],
            "risks": ["A premature split adds coordination overhead."],
            "alternatives": ["Extract an internal module first."],
            "recommendation": "Instrument boundaries, then reassess.",
            "confidence": "medium",
        }

    def test_validates_and_renders_standardized_memo(self):
        self.assertTrue(hasattr(self.broker, "validate_memo"), "memo validation is missing")
        self.assertTrue(hasattr(self.broker, "render_memo"), "memo rendering is missing")
        route = self.broker.select_route("codex", "standard")

        validated = self.broker.validate_memo(self.memo)
        rendered = self.broker.render_memo(validated, route)

        for heading in (
            "## Peer consultation",
            "### Verdict",
            "### Evidence",
            "### Risks",
            "### Alternatives",
            "### Recommendation",
            "### Confidence",
        ):
            with self.subTest(heading=heading):
                self.assertIn(heading, rendered)
        self.assertIn("Claude · claude-opus-4-8 · medium", rendered)

    def test_rejects_malformed_memo(self):
        self.assertTrue(hasattr(self.broker, "validate_memo"), "memo validation is missing")

        malformed = dict(self.memo, confidence="certain", surprise="extra")
        with self.assertRaisesRegex(ValueError, "memo"):
            self.broker.validate_memo(malformed)

    def test_extracts_claude_structured_output(self):
        self.assertTrue(
            hasattr(self.broker, "parse_claude_output"),
            "Claude output parser is missing",
        )
        envelope = json.dumps({"type": "result", "structured_output": self.memo})

        self.assertEqual(self.broker.parse_claude_output(envelope), self.memo)


class CliTests(unittest.TestCase):
    def test_dry_run_prints_route_command_and_prompt_without_provider_call(self):
        broker = load_broker()
        self.assertTrue(hasattr(broker, "main"), "CLI entrypoint is missing")
        with tempfile.TemporaryDirectory() as repo:
            result = subprocess.run(
                [
                    sys.executable,
                    str(SCRIPT),
                    "--caller",
                    "codex",
                    "--complexity",
                    "standard",
                    "--repo",
                    repo,
                    "--dry-run",
                ],
                input="Should we split this service?",
                text=True,
                capture_output=True,
                check=False,
            )

        self.assertEqual(result.returncode, 0, result.stderr)
        payload = json.loads(result.stdout)
        self.assertEqual(payload["provider"], "claude")
        self.assertEqual(payload["model"], "claude-opus-4-8")
        self.assertEqual(payload["effort"], "medium")
        self.assertIn("--safe-mode", payload["command"])
        self.assertIn("Should we split this service?", payload["prompt"])

    def test_cli_rejects_luna_override_before_execution(self):
        broker = load_broker()
        self.assertTrue(hasattr(broker, "main"), "CLI entrypoint is missing")
        result = subprocess.run(
            [
                sys.executable,
                str(SCRIPT),
                "--caller",
                "claude",
                "--complexity",
                "quick",
                "--model",
                "gpt-5.6-luna",
                "--dry-run",
            ],
            input="Review this choice.",
            text=True,
            capture_output=True,
            check=False,
        )

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("not allowed", result.stderr)


class ExecutionTests(unittest.TestCase):
    def setUp(self):
        self.broker = load_broker()
        self.memo = {
            "verdict": "Keep the boundary for now.",
            "evidence": ["src/core.py:10 has one caller."],
            "risks": ["The caller may grow."],
            "alternatives": ["Revisit after instrumentation."],
            "recommendation": "Measure first.",
            "confidence": "high",
        }

    def _write_executable(self, path, source):
        path.write_text(source)
        path.chmod(0o755)

    def test_runs_claude_and_extracts_structured_memo(self):
        self.assertTrue(
            hasattr(self.broker, "run_consultation"),
            "consultation runner is missing",
        )
        with tempfile.TemporaryDirectory() as root:
            root_path = Path(root)
            bin_dir = root_path / "bin"
            repo = root_path / "repo"
            bin_dir.mkdir()
            repo.mkdir()
            envelope = json.dumps({"structured_output": self.memo})
            self._write_executable(
                bin_dir / "claude",
                "#!/bin/sh\nread request\nprintf '%s' '" + envelope + "'\n",
            )
            env = dict(os.environ, PATH=f"{bin_dir}:{os.environ['PATH']}")
            route = self.broker.select_route("codex", "standard")

            memo = self.broker.run_consultation(
                route,
                repo,
                "Review this design.",
                SCRIPT.with_name("memo.schema.json"),
                env=env,
            )

        self.assertEqual(memo, self.memo)

    def test_runs_codex_and_reads_temporary_structured_memo(self):
        self.assertTrue(
            hasattr(self.broker, "run_consultation"),
            "consultation runner is missing",
        )
        with tempfile.TemporaryDirectory() as root:
            root_path = Path(root)
            bin_dir = root_path / "bin"
            repo = root_path / "repo"
            bin_dir.mkdir()
            repo.mkdir()
            memo_json = json.dumps(self.memo)
            self._write_executable(
                bin_dir / "codex",
                "#!/bin/sh\n"
                "while [ \"$#\" -gt 0 ]; do\n"
                "  if [ \"$1\" = \"--output-last-message\" ]; then\n"
                "    shift\n"
                f"    printf '%s' '{memo_json}' > \"$1\"\n"
                "    exit 0\n"
                "  fi\n"
                "  shift\n"
                "done\n"
                "exit 9\n",
            )
            env = dict(os.environ, PATH=f"{bin_dir}:{os.environ['PATH']}")
            route = self.broker.select_route("claude", "standard")

            memo = self.broker.run_consultation(
                route,
                repo,
                "Review this design.",
                SCRIPT.with_name("memo.schema.json"),
                env=env,
            )

        self.assertEqual(memo, self.memo)


if __name__ == "__main__":
    unittest.main()
