#!/usr/bin/env python3
"""Tests for the deterministic review-synthesis packet updater."""

from __future__ import annotations

import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest import mock

import update_review_packet as updater

SCRIPT_DIR = Path(__file__).resolve().parent
CLI = SCRIPT_DIR / "update_review_packet.py"


class ReviewPacketTests(unittest.TestCase):
    def setUp(self) -> None:
        self._tmp = tempfile.TemporaryDirectory(prefix="review-packet-test-")
        self.root = Path(self._tmp.name)
        self.packet = self.root / "review.md"

    def tearDown(self) -> None:
        self._tmp.cleanup()

    def _run_cli(self, *args: str) -> subprocess.CompletedProcess[str]:
        env = os.environ.copy()
        env["PYTHONDONTWRITEBYTECODE"] = "1"
        return subprocess.run(
            [sys.executable, "-B", str(CLI), *args],
            capture_output=True,
            text=True,
            env=env,
        )

    def _create(self) -> None:
        rc = self._run_cli(str(self.packet), "--create")
        self.assertEqual(rc.returncode, 0, rc.stderr)

    def _body_for(self, data: bytes, heading_text: str) -> bytes:
        pkt = updater.parse_packet(data)
        for sec in pkt.sections:
            if sec.heading.text == heading_text:
                return data[sec.body_start:sec.body_end]
        raise AssertionError("section not found: " + heading_text)

    # 1. create from template
    def test_create_from_template(self) -> None:
        result = self._run_cli(str(self.packet), "--create", "--slug", "demo", "--date", "2026-08-07")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(self.packet.exists())
        data = self.packet.read_bytes()
        pkt = updater.parse_packet(data)
        headings = {s.heading.text for s in pkt.sections}
        for h in updater.CANONICAL_HEADINGS:
            self.assertIn(h, headings, "missing canonical section: " + h)
        self.assertIn(b"Ordinary", self._body_for(data, "Review mode"))
        self.assertIn(b"NEEDS_CHANGES", self._body_for(data, "Verdict (coordinator)"))
        self.assertIn(b"# Review Synthesis", data)

    # 2. one-section update (string) — only target changed
    def test_one_section_update_string(self) -> None:
        self._create()
        updater.update_packet(self.packet, json.dumps({"verdict": "**APPROVED**\n\nAll clear."}))
        data = self.packet.read_bytes()
        self.assertIn(b"**APPROVED**", self._body_for(data, "Verdict (coordinator)"))
        self.assertNotIn(b"**APPROVED**", self._body_for(data, "Residual"))

    # 3. append update
    def test_append_update(self) -> None:
        self._create()
        base = updater._body_content(self._body_for(self.packet.read_bytes(), "Residual"))
        updater.update_packet(self.packet, json.dumps({"residual": {"append": "extra residual line"}}))
        body = self._body_for(self.packet.read_bytes(), "Residual")
        self.assertIn(b"extra residual line", body)
        self.assertIn(base, body)

    # 4. file update
    def test_file_update(self) -> None:
        self._create()
        src = self.root / "findings.md"
        src.write_text("F1 | MAJOR | overflow | reviewer | open\n", encoding="utf-8")
        updater.update_packet(self.packet, json.dumps({"findings": {"file": str(src)}}))
        body = self._body_for(self.packet.read_bytes(), updater.SECTION_MAP["findings"])
        self.assertIn(b"F1 | MAJOR | overflow", body)

    # 5. untouched foreign section byte equality
    def test_untouched_foreign_section_byte_equality(self) -> None:
        self._create()
        data = self.packet.read_bytes()
        foreign_block = b"## Custom foreign notes\n\nforeign line 1\nforeign line 2\n\n"
        idx = data.find(b"## Residual\n")
        self.packet.write_bytes(data[:idx] + foreign_block + data[idx:])
        before_foreign = self._body_for(self.packet.read_bytes(), "Custom foreign notes")

        updater.update_packet(self.packet, json.dumps({"verdict": "**APPROVED**"}))

        after_foreign = self._body_for(self.packet.read_bytes(), "Custom foreign notes")
        self.assertEqual(before_foreign, after_foreign)

    # 6. fenced heading safety
    def test_fenced_heading_safety(self) -> None:
        self._create()
        updater.update_packet(
            self.packet,
            json.dumps({"residual": {"append": "```\n## Not a real section\nstill inside fence\n```"}}),
        )
        pkt = updater.parse_packet(self.packet.read_bytes())
        texts = [s.heading.text for s in pkt.sections]
        self.assertNotIn("Not a real section", texts)
        self.assertIn("Residual", texts)

    # 7. missing canonical section refused, source untouched
    def test_missing_canonical_section_refused(self) -> None:
        self._create()
        corrupted = self.packet.read_bytes().replace(b"## Residual\n", b"## Foreign renamed\n", 1)
        self.packet.write_bytes(corrupted)
        before = self.packet.read_bytes()
        with self.assertRaises(updater.UpdateError):
            updater.update_packet(self.packet, json.dumps({"verdict": "**APPROVED**"}))
        self.assertEqual(self.packet.read_bytes(), before)

    # 8. duplicate canonical heading refused
    def test_duplicate_canonical_heading_refused(self) -> None:
        self._create()
        self.packet.write_bytes(self.packet.read_bytes() + b"\n## Residual\n\nduplicate body\n")
        with self.assertRaises(updater.UpdateError):
            updater.parse_packet(self.packet.read_bytes())

    # 9. malformed JSON refused with concise error
    def test_malformed_json_refused(self) -> None:
        self._create()
        before = self.packet.read_bytes()
        with self.assertRaises(updater.UpdateError):
            updater.update_packet(self.packet, "{not json")
        self.assertEqual(self.packet.read_bytes(), before)

    # 10. empty body refused
    def test_empty_body_refused(self) -> None:
        self._create()
        before = self.packet.read_bytes()
        for val in ("", "   ", "\n\t "):
            with self.subTest(val=repr(val)):
                with self.assertRaises(updater.UpdateError):
                    updater.update_packet(self.packet, json.dumps({"residual": val}))
                self.assertEqual(self.packet.read_bytes(), before)

    # 11a. invalid mode refused
    def test_invalid_mode_refused(self) -> None:
        self._create()
        before = self.packet.read_bytes()
        with self.assertRaises(updater.UpdateError):
            updater.update_packet(self.packet, json.dumps({"review_mode": "- **Mode:** BogusMode"}))
        self.assertEqual(self.packet.read_bytes(), before)

    # 11b. invalid verdict refused
    def test_invalid_verdict_refused(self) -> None:
        self._create()
        before = self.packet.read_bytes()
        with self.assertRaises(updater.UpdateError):
            updater.update_packet(self.packet, json.dumps({"verdict": "**MAYBE**"}))
        self.assertEqual(self.packet.read_bytes(), before)

    # 12. atomic failure leaves original unchanged
    def test_atomic_failure_leaves_original_unchanged(self) -> None:
        self._create()
        before = self.packet.read_bytes()
        with mock.patch.object(updater.os, "replace", side_effect=OSError("replace failed")):
            with self.assertRaises(OSError):
                updater.update_packet(self.packet, json.dumps({"verdict": "**APPROVED**"}))
        self.assertEqual(self.packet.read_bytes(), before)
        self.assertEqual(list(self.root.glob("." + self.packet.name + ".*")), [])

    # 13. UTF-8 content (cyrillic / unicode)
    def test_utf8_content(self) -> None:
        self._create()
        cyrillic = "- \u043d\u0430\u0445\u043e\u0434\u043a\u0430 MAJOR: \u043a\u0438\u0440\u0438\u043b\u043b\u0438\u0446\u0430 \u0438 \u044e\u043d\u0438\u043a\u043e\u0434"
        updater.update_packet(self.packet, json.dumps({"findings": cyrillic}))
        body = self._body_for(self.packet.read_bytes(), updater.SECTION_MAP["findings"])
        self.assertIn(cyrillic.encode("utf-8"), body)

    # 14. legacy packet refusal
    def test_legacy_packet_refusal(self) -> None:
        self._create()
        self.packet.write_bytes(
            self.packet.read_bytes().replace(b"NEEDS_CHANGES", b"APPROVE_WITH_CHANGES", 1)
        )
        before = self.packet.read_bytes()
        with self.assertRaises(updater.UpdateError):
            updater.parse_packet(self.packet.read_bytes())
        self.assertEqual(self.packet.read_bytes(), before)

    # 15. no shell / no model invocation (static source check)
    def test_no_shell_no_model_invocation(self) -> None:
        src = Path(updater.__file__).read_text(encoding="utf-8")
        self.assertNotIn("os.system", src)
        self.assertNotIn("subprocess", src)

    # 16. CLI contract: --help usage
    def test_cli_help_contract(self) -> None:
        result = self._run_cli("--help")
        self.assertEqual(result.returncode, 0)
        self.assertIn("PACKET", result.stdout)
        self.assertIn("--updates-json", result.stdout)
        self.assertIn("--create", result.stdout)

    # 17. CLI smoke: create + one-section update
    def test_cli_smoke_create_and_update(self) -> None:
        rc = self._run_cli(str(self.packet), "--create")
        self.assertEqual(rc.returncode, 0, rc.stderr)
        self.assertTrue(self.packet.exists())
        rc = self._run_cli(str(self.packet), "--updates-json", json.dumps({"verdict": "**NEEDS_CHANGES**"}))
        self.assertEqual(rc.returncode, 0, rc.stderr)

    # 18. unknown section id refused
    def test_unknown_section_id_refused(self) -> None:
        self._create()
        before = self.packet.read_bytes()
        with self.assertRaises(updater.UpdateError):
            updater.update_packet(self.packet, json.dumps({"unknown_section": "x"}))
        self.assertEqual(self.packet.read_bytes(), before)

    # 19. duplicate JSON key refused
    def test_duplicate_json_key_refused(self) -> None:
        self._create()
        with self.assertRaises(updater.UpdateError):
            updater.update_packet(self.packet, '{"verdict": "a", "verdict": "b"}')

    # 20. constant section not updateable via its heading-derived id
    def test_constant_section_not_updateable(self) -> None:
        self._create()
        before = self.packet.read_bytes()
        with self.assertRaises(updater.UpdateError):
            updater.update_packet(self.packet, json.dumps({"fix_round_contract": "override"}))
        self.assertEqual(self.packet.read_bytes(), before)

    # 21. M1: invalid mode with a valid enum word only in an HTML comment is refused
    def test_invalid_mode_with_enum_in_comment_refused(self) -> None:
        self._create()
        before = self.packet.read_bytes()
        with self.assertRaises(updater.UpdateError):
            updater.update_packet(
                self.packet,
                json.dumps(
                    {"review_mode": "- **Mode:** BogusMode <!-- Mechanical | Simple | Ordinary | Strong -->"}
                ),
            )
        self.assertEqual(self.packet.read_bytes(), before)

    # 22. M1: invalid verdict with a valid enum word only in an HTML comment is refused
    def test_invalid_verdict_with_enum_in_comment_refused(self) -> None:
        self._create()
        before = self.packet.read_bytes()
        with self.assertRaises(updater.UpdateError):
            updater.update_packet(
                self.packet,
                json.dumps({"verdict": "**MAYBE** <!-- APPROVED | NEEDS_CHANGES | BLOCKED -->"}),
            )
        self.assertEqual(self.packet.read_bytes(), before)

    # 23. M1: untouched but already-invalid review_mode refuses ANY update (e.g. residual)
    def test_untouched_invalid_mode_refused(self) -> None:
        self._create()
        corrupted = self.packet.read_bytes().replace(
            b"- **Mode:** Ordinary", b"- **Mode:** BogusMode", 1
        )
        self.packet.write_bytes(corrupted)
        before = self.packet.read_bytes()
        with self.assertRaises(updater.UpdateError):
            updater.update_packet(self.packet, json.dumps({"residual": "clean"}))
        self.assertEqual(self.packet.read_bytes(), before)

    # 24. M1: untouched but already-invalid verdict refuses ANY update (e.g. residual)
    def test_untouched_invalid_verdict_refused(self) -> None:
        self._create()
        corrupted = self.packet.read_bytes().replace(b"**NEEDS_CHANGES**", b"**BOGUS**", 1)
        self.packet.write_bytes(corrupted)
        before = self.packet.read_bytes()
        with self.assertRaises(updater.UpdateError):
            updater.update_packet(self.packet, json.dumps({"residual": "clean"}))
        self.assertEqual(self.packet.read_bytes(), before)

    # 25. M2: binary (non-UTF-8) file payload is refused; source byte-identical
    def test_binary_file_payload_refused(self) -> None:
        self._create()
        src = self.root / "bin.dat"
        src.write_bytes(b"\xff\xfe\x80\x00binary\xc3\x28non-utf8")
        before = self.packet.read_bytes()
        with self.assertRaises(updater.UpdateError):
            updater.update_packet(self.packet, json.dumps({"findings": {"file": str(src)}}))
        self.assertEqual(self.packet.read_bytes(), before)

    # 26. M3: a longer closing fence (4 backticks) does NOT close a 3-backtick fence;
    # the heading after the longer closer stays inside the open fence.
    def test_longer_closing_fence_keeps_heading_inside(self) -> None:
        data = b"```\n## Fake\n````\n## Real\n"
        events = updater._heading_events(data)
        texts = [e.text for e in events]
        self.assertNotIn("Real", texts)
        self.assertNotIn("Fake", texts)

    # 27. M3: mismatched fence type (``` does not close ~~~) keeps heading inside
    def test_mismatched_fence_type_regression(self) -> None:
        data = b"~~~\n## Inside\n```\n## StillInside\n~~~\n"
        events = updater._heading_events(data)
        texts = [e.text for e in events]
        self.assertNotIn("Inside", texts)
        self.assertNotIn("StillInside", texts)

    # 28. M3: tilde fences of the same length close correctly; heading after is parsed
    def test_tilde_fence_symmetric(self) -> None:
        data = b"~~~\n## A\n~~~\n## B\n"
        events = updater._heading_events(data)
        texts = [e.text for e in events]
        self.assertIn("B", texts)
        self.assertNotIn("A", texts)

    # 29. MINOR-2: duplicate canonical heading error includes a line anchor
    def test_duplicate_canonical_error_includes_line(self) -> None:
        self._create()
        self.packet.write_bytes(self.packet.read_bytes() + b"\n## Residual\n\ndup body\n")
        try:
            updater.parse_packet(self.packet.read_bytes())
        except updater.UpdateError as exc:
            msg = str(exc)
            self.assertIn("duplicate canonical heading", msg)
            self.assertIn("line", msg)
        else:
            self.fail("expected UpdateError for duplicate canonical heading")

    # 30. MINOR-2/M2: error messages carry section/line but never leak file payload
    def test_file_error_message_no_content_leak(self) -> None:
        self._create()
        marker = b"SECRET-MARKER-NO-LEAK"
        src = self.root / "bin.dat"
        src.write_bytes(b"\xff\xfe\x80" + marker)  # invalid UTF-8 with a marker
        try:
            updater.update_packet(self.packet, json.dumps({"findings": {"file": str(src)}}))
        except updater.UpdateError as exc:
            msg = str(exc)
            self.assertIn("findings", msg)  # section id present
            self.assertNotIn("SECRET-MARKER-NO-LEAK", msg)  # file content NOT leaked
        else:
            self.fail("expected UpdateError for binary file payload")

    # 31. MINOR-1: missing canonical section error includes a line anchor
    def test_missing_canonical_error_includes_line(self) -> None:
        self._create()
        corrupted = self.packet.read_bytes().replace(b"## Residual\n", b"## Foreign renamed\n", 1)
        self.packet.write_bytes(corrupted)
        try:
            updater.parse_packet(self.packet.read_bytes())
        except updater.UpdateError as exc:
            msg = str(exc)
            self.assertIn("missing canonical section", msg)
            self.assertIn("line", msg)
        else:
            self.fail("expected UpdateError for missing canonical section")

    # 32. MINOR-2: unknown section id error carries the offending id and the
    # allowlist. Line anchor is intentionally omitted for JSON payload-structure
    # errors (no packet byte offset exists for a CLI argument key); see the
    # line-anchor contract comment in _render_update.
    def test_unknown_section_id_error_format(self) -> None:
        self._create()
        try:
            updater.update_packet(self.packet, json.dumps({"bogus_section": "x"}))
        except updater.UpdateError as exc:
            msg = str(exc)
            self.assertIn("unknown section id", msg)
            self.assertIn("bogus_section", msg)
            self.assertIn("allowed:", msg)
        else:
            self.fail("expected UpdateError for unknown section id")


if __name__ == "__main__":
    unittest.main()
