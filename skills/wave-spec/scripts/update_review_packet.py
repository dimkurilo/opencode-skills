#!/usr/bin/env python3
"""Deterministic review-synthesis packet updater.

Creates a review-synthesis packet from the canonical frozen template
(``assets/templates/review-synthesis.md.tmpl``) or applies coordinator-prepared
JSON section updates atomically. The script is a helper: it validates structure
and writes; it never chooses the review mode or verdict, never closes material
findings, and never substitutes for the approve / LAUNCH / In Review gate.
No model calls, no shell invocation.
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass
import datetime as _dt
import json
import os
from pathlib import Path
import re
import sys
import tempfile
from typing import Any

SCRIPT_DIR = Path(__file__).resolve().parent
TEMPLATE_PATH = SCRIPT_DIR.parent / "assets" / "templates" / "review-synthesis.md.tmpl"

# Allowlisted section IDs mapped to exact canonical H2 heading text (frozen template).
# Only these IDs may be targeted via ``--updates-json``.
SECTION_MAP = {
    "review_mode": "Review mode",
    "verdict": "Verdict (coordinator)",
    "findings": "Findings (single-reviewer modes: Simple / Ordinary)",
    "complementary_lenses": "Complementary lenses (Strong only — 2 reviewers)",
    "contradiction_resolution": "Contradiction resolution (Strong — stricter wins)",
    "closure_list": "Material-finding closure list",
    "owner_decision": "Owner decision needed",
    "residual": "Residual",
}
ALLOWED_IDS = frozenset(SECTION_MAP)
# Reverse lookup: canonical heading text -> section_id.
HEADING_TO_ID = {v: k for k, v in SECTION_MAP.items()}

# Constant canonical sections — must be present, but NOT updateable via the script.
CONSTANT_HEADINGS = (
    "Fix-round contract (unchanged by Review modes)",
    "Follow-up review",
)
CANONICAL_HEADINGS = tuple(SECTION_MAP.values()) + CONSTANT_HEADINGS
CANONICAL_SET = frozenset(CANONICAL_HEADINGS)

REVIEW_MODES = ("Mechanical", "Simple", "Ordinary", "Strong")
VERDICTS = ("APPROVED", "NEEDS_CHANGES", "BLOCKED")

# Legacy verdict markers — their presence means the packet predates the frozen
# contract and must be refused (no silent migration).
_LEGACY_MARKERS = (
    (re.compile(rb"\bAPPROVE_WITH_CHANGES\b"), "APPROVE_WITH_CHANGES"),
    (re.compile(rb"\bCHANGES_REQUESTED\b"), "CHANGES_REQUESTED"),
    (re.compile(rb"\bAPPROVE\b"), "APPROVE (legacy; canonical form is APPROVED)"),
)

_HEADING_RE = re.compile(rb"^(#{1,2})[ \t]+(.*?)[ \t]*$")
_FENCE_OPEN_RE = re.compile(rb"^[ \t]{0,3}(`{3,}|~{3,})")


class UpdateError(ValueError):
    """Raised for invalid packet structure or update payload."""


@dataclass(frozen=True)
class Heading:
    level: int
    text: str
    line_start: int
    line_end: int  # byte offset just past the trailing newline


@dataclass(frozen=True)
class Section:
    heading: Heading
    section_id: str | None  # canonical allowlisted ID, else None (constant or foreign)
    body_start: int
    body_end: int


@dataclass(frozen=True)
class Packet:
    data: bytes
    prefix: bytes  # H1 title + meta header (everything before the first H2)
    sections: tuple[Section, ...]


def _iter_lines(data: bytes):
    start = 0
    n = len(data)
    while start < n:
        nl = data.find(b"\n", start)
        if nl == -1:
            yield start, n, data[start:]
            return
        content = data[start:nl]
        if content.endswith(b"\r"):
            content = content[:-1]
        yield start, nl + 1, content
        start = nl + 1


def _line_number(data: bytes, offset: int) -> int:
    """1-based line number of the given byte offset."""
    return data.count(b"\n", 0, offset) + 1


def _fence_closes(content: bytes, marker: bytes) -> bool:
    # Contract: a fence closes only with the SAME char (``` vs ~~~) AND the SAME
    # marker length as the opening (not >= ). Longer/mismatched closers leave the
    # fence open so headings inside are not mistaken for canonical sections.
    char = re.escape(marker[:1])
    pat = rb"^[ \t]{0,3}" + char + rb"{" + str(len(marker)).encode() + rb"}[ \t]*$"
    return re.fullmatch(pat, content) is not None


def _heading_events(data: bytes) -> list[Heading]:
    """Collect H1/H2 heading events outside fenced code blocks."""
    events: list[Heading] = []
    fence: bytes | None = None
    for line_start, line_end, content in _iter_lines(data):
        if fence is not None:
            if _fence_closes(content, fence):
                fence = None
            continue
        m = _FENCE_OPEN_RE.match(content)
        if m is not None:
            fence = m.group(1)
            continue
        hm = _HEADING_RE.fullmatch(content)
        if hm is not None:
            level = len(hm.group(1))
            text = hm.group(2).decode("utf-8", errors="replace").rstrip()
            events.append(Heading(level, text, line_start, line_end))
    return events


def parse_packet(data: bytes) -> Packet:
    """Validate packet topology and return byte spans for section bodies."""
    events = _heading_events(data)
    h1 = [e for e in events if e.level == 1]
    h2 = [e for e in events if e.level == 2]

    if not h1:
        raise UpdateError("packet must start with an H1 title ('# ...'); no H1 found")
    if h1[0].line_start != 0:
        first_h1_line = _line_number(data, h1[0].line_start)
        raise UpdateError(
            "packet must start with an H1 title ('# ...'); first H1 at line "
            + str(first_h1_line)
        )

    canonical_seen: dict[str, Heading] = {}
    for e in h2:
        if e.text in CANONICAL_SET:
            if e.text in canonical_seen:
                dup_line = _line_number(data, e.line_start)
                raise UpdateError(
                    "duplicate canonical heading '## " + e.text + "' at line " + str(dup_line)
                )
            canonical_seen[e.text] = e

    missing = [h for h in CANONICAL_HEADINGS if h not in canonical_seen]
    if missing:
        # MINOR-1: a missing canonical section is a packet-level structural
        # defect — it has no heading line of its own (it is absent), so we
        # anchor at line 1 (the H1 title, whose position 0 is validated just
        # above). This matches the line-anchor contract for structural errors
        # and is stable across packets.
        raise UpdateError(
            "missing canonical section(s) at line 1: " + ", ".join(missing)
        )

    for pat, name in _LEGACY_MARKERS:
        m = pat.search(data)
        if m:
            legacy_line = _line_number(data, m.start())
            raise UpdateError(
                "legacy packet refused: contains " + name + " at line " + str(legacy_line)
            )

    sections: list[Section] = []
    for i, e in enumerate(h2):
        body_start = e.line_end
        body_end = h2[i + 1].line_start if i + 1 < len(h2) else len(data)
        sid = HEADING_TO_ID.get(e.text)  # None for constant canonical + foreign
        sections.append(Section(e, sid, body_start, body_end))

    prefix = data[0:h2[0].line_start] if h2 else data
    return Packet(data, prefix, tuple(sections))


def _reject_duplicate_keys(pairs):
    d: dict[str, Any] = {}
    for k, v in pairs:
        if k in d:
            raise ValueError("duplicate JSON key: " + str(k))
        d[k] = v
    return d


def parse_updates(updates_str: str) -> dict[str, Any]:
    try:
        value = json.loads(updates_str, object_pairs_hook=_reject_duplicate_keys)
    except json.JSONDecodeError as exc:
        raise UpdateError(
            "malformed JSON: " + exc.msg + " (line " + str(exc.lineno) + ", col " + str(exc.colno) + ")"
        )
    except ValueError as exc:
        raise UpdateError(str(exc))
    if not isinstance(value, dict):
        raise UpdateError("updates JSON must be an object")
    return value


def _validate_canonical_values(section_id: str, content: bytes, line: int | None = None) -> None:
    # M1: validate the EXACT canonical field value, not any enum word in the body.
    # HTML comments like `<!-- Mechanical | ... -->` must not satisfy the check;
    # only the value of `**Mode:** X` / the `**X**` verdict marker counts.
    loc = " at line " + str(line) if line is not None else ""
    if section_id == "review_mode":
        m = re.search(rb"-\s*\*\*Mode:\*\*\s*([A-Za-z]+)", content)
        if m is None:
            raise UpdateError(
                "review_mode body must contain canonical field '- **Mode:** <mode>'" + loc
            )
        value = m.group(1).decode("utf-8", errors="replace")
        if value not in REVIEW_MODES:
            raise UpdateError(
                "review_mode canonical value '" + value + "' is not one of "
                + ", ".join(REVIEW_MODES) + loc
            )
    elif section_id == "verdict":
        m = re.search(rb"\*\*([A-Za-z_]+)\*\*", content)
        if m is None:
            raise UpdateError(
                "verdict body must contain canonical marker '**<VERDICT>**'" + loc
            )
        value = m.group(1).decode("utf-8", errors="replace")
        if value not in VERDICTS:
            raise UpdateError(
                "verdict canonical value '" + value + "' is not one of "
                + ", ".join(VERDICTS) + loc
            )


def _normalize_body(content: bytes, is_last: bool) -> bytes:
    suffix = b"\n" if is_last else b"\n\n"
    return b"\n" + content + suffix


def _body_content(body_bytes: bytes) -> bytes:
    """Strip structural newlines to get logical body content."""
    s = body_bytes
    if s[:1] == b"\n":
        s = s[1:]
    return s.rstrip(b"\r\n")


def _resolve_operation(
    section_id: str, value: Any, existing_body: bytes, is_last: bool, heading_line: int
) -> bytes:
    loc = " at line " + str(heading_line)
    if isinstance(value, str):
        if not value.strip():
            raise UpdateError("empty body for section '" + section_id + "'" + loc)
        content = value.strip("\r\n").encode("utf-8")
    elif isinstance(value, dict):
        keys = set(value)
        if keys == {"file"}:
            file_path = value["file"]
            if not isinstance(file_path, str) or not file_path.strip():
                raise UpdateError(
                    '{"file": ...} value for section "' + section_id + '"' + loc
                    + " must be a non-empty path string"
                )
            try:
                raw = Path(file_path).read_bytes()
            except FileNotFoundError:
                raise UpdateError(
                    "file not found for section '" + section_id + "'" + loc + ": " + file_path
                )
            except OSError:
                raise UpdateError(
                    "cannot read file for section '" + section_id + "'" + loc + ": " + file_path
                )
            if not raw.strip():
                raise UpdateError(
                    "file is empty for section '" + section_id + "'" + loc + ": " + file_path
                )
            # M2: file payloads must satisfy the strict UTF-8 packet contract.
            # Binary payloads are refused with a section/line error that contains
            # NO file content; the source packet is left unchanged.
            try:
                raw.decode("utf-8")
            except UnicodeDecodeError:
                raise UpdateError(
                    "file payload for section '" + section_id + "'" + loc
                    + " is not valid UTF-8: " + file_path
                )
            content = raw
        elif keys == {"append"}:
            append_val = value["append"]
            if not isinstance(append_val, str):
                raise UpdateError(
                    "append value for section '" + section_id + "'" + loc + " must be a string"
                )
            if not append_val.strip():
                raise UpdateError("empty append value for section '" + section_id + "'" + loc)
            existing = _body_content(existing_body)
            append_bytes = append_val.strip("\r\n").encode("utf-8")
            content = existing + b"\n" + append_bytes if existing else append_bytes
        else:
            raise UpdateError(
                "unsupported operation for section '" + section_id + "'" + loc
                + ": keys " + ", ".join(sorted(keys))
                + ' (allowed: string | {"append": "..."} | {"file": "..."})'
            )
    else:
        raise UpdateError(
            "value for section '" + section_id + "'" + loc
            + " must be a string or operation object"
        )

    _validate_canonical_values(section_id, content, heading_line)
    return _normalize_body(content, is_last)


def _render_update(packet: Packet, updates: dict[str, Any]) -> bytes:
    unknown = [k for k in updates if k not in ALLOWED_IDS]
    if unknown:
        # Line-anchor contract (MINOR-2): line anchors ("at line N") are
        # attached to errors that map to a packet byte offset — packet-heading
        # errors (duplicate canonical heading, legacy marker) and section-body
        # operation errors (file/append/value validation, empty body, UTF-8).
        # JSON payload-structure errors (unknown section id, duplicate JSON
        # key) have NO packet byte offset to anchor to: the JSON is a CLI
        # argument string parsed before any packet byte offset exists for the
        # offending key. These errors identify the offending key by name plus
        # the allowlist (for unknown id) so the coordinator can correct the
        # payload without a misleading line number.
        raise UpdateError(
            "unknown section id(s): " + ", ".join(unknown) + " (allowed: " + ", ".join(sorted(ALLOWED_IDS)) + ")"
        )

    # M1: validate EXISTING review_mode and verdict canonical values on ANY update
    # (including untouched sections), before applying changes. A packet whose
    # mode/verdict was already corrupted must not pass _render_update just because
    # the current update targets a different section (e.g. residual).
    for sid in ("review_mode", "verdict"):
        for sec in packet.sections:
            if sec.section_id == sid:
                existing = packet.data[sec.body_start:sec.body_end]
                line = _line_number(packet.data, sec.heading.line_start)
                _validate_canonical_values(sid, existing, line)
                break

    total = len(packet.sections)
    new_bodies: dict[str, bytes] = {}
    for idx, sec in enumerate(packet.sections):
        if sec.section_id is not None and sec.section_id in updates:
            is_last = idx == total - 1
            existing = packet.data[sec.body_start:sec.body_end]
            line = _line_number(packet.data, sec.heading.line_start)
            new_bodies[sec.section_id] = _resolve_operation(
                sec.section_id, updates[sec.section_id], existing, is_last, line
            )

    chunks: list[bytes] = [packet.prefix]
    for sec in packet.sections:
        chunks.append(packet.data[sec.heading.line_start:sec.heading.line_end])
        if sec.section_id in new_bodies:
            chunks.append(new_bodies[sec.section_id])
        else:
            chunks.append(packet.data[sec.body_start:sec.body_end])
    result = b"".join(chunks)
    result.decode("utf-8")  # M2 defensive: strict UTF-8 check before atomic replace
    parse_packet(result)  # re-validate the rendered result
    return result


def _atomic_replace(path: Path, data: bytes) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp_name = tempfile.mkstemp(prefix="." + path.name + ".", dir=str(path.parent))
    tmp = Path(tmp_name)
    try:
        with os.fdopen(fd, "wb") as f:
            f.write(data)
            f.flush()
            os.fsync(f.fileno())
        os.replace(tmp, path)
    finally:
        try:
            tmp.unlink()
        except FileNotFoundError:
            pass


_CREATE_DEFAULTS = {
    "SELECTION_BASIS": "default (see SKILL.md §Review modes)",
    "REVIEW_DISPATCHES": "1",
    "STRONG_SESSION_USED": "n/a",
    "FOLLOW_UP_ELIGIBILITY": "none",
    "REVIEW_PATHS": "(coordinator fills via --updates-json)",
    "REVIEWERS": "(coordinator fills via --updates-json)",
    "REVIEW_MODE": "Ordinary",
    "VERDICT": "NEEDS_CHANGES",
    "STATIC_REVIEWER": "Qwen 3.8 Max",
    "BEHAVIORAL_REVIEWER": "gpt-5.6-luna",
}


def create_from_template(slug: str | None = None, date_str: str | None = None) -> bytes:
    if not TEMPLATE_PATH.exists():
        raise UpdateError("template not found: " + str(TEMPLATE_PATH))
    tmpl = TEMPLATE_PATH.read_text(encoding="utf-8")
    subs = dict(_CREATE_DEFAULTS)
    subs["SLUG"] = slug or "review-synthesis"
    subs["DATE"] = date_str or _dt.date.today().isoformat()
    for key, val in subs.items():
        tmpl = tmpl.replace("${" + key + "}", val)
    result = tmpl.encode("utf-8")
    parse_packet(result)
    return result


def update_packet(packet_path: Path, updates_str: str) -> None:
    updates = parse_updates(updates_str)
    data = packet_path.read_bytes()
    data.decode("utf-8")  # strict UTF-8 preflight
    packet = parse_packet(data)
    result = _render_update(packet, updates)
    _atomic_replace(packet_path, result)


def create_packet(packet_path: Path, slug: str | None = None, date_str: str | None = None) -> None:
    result = create_from_template(slug, date_str)
    _atomic_replace(packet_path, result)


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        prog="update_review_packet.py",
        description=(
            "Deterministic review-synthesis packet updater. Creates a packet from the"
            " canonical frozen template or applies coordinator-prepared JSON section"
            " updates atomically. No model calls, no shell invocation."
        ),
    )
    p.add_argument("packet", metavar="PACKET", help="Path to the review-synthesis packet (.md).")
    p.add_argument(
        "--updates-json",
        metavar="UPDATES",
        help=(
            'JSON object string, e.g. \'{"verdict": "**NEEDS_CHANGES**"}\'. '
            "Operations per section: string (replace body), "
            '{"append": "..."} (append to body), {"file": "path"} (replace body with file content). '
            "Allowlisted section IDs: " + ", ".join(sorted(ALLOWED_IDS)) + "."
        ),
    )
    p.add_argument(
        "--create",
        action="store_true",
        help="Create packet from assets/templates/review-synthesis.md.tmpl with canonical defaults.",
    )
    p.add_argument("--slug", default=None, help="Slug for --create (default: review-synthesis).")
    p.add_argument("--date", default=None, help="Date YYYY-MM-DD for --create (default: today).")
    return p


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    packet_path = Path(args.packet)

    if args.create and args.updates_json:
        print("error: --create and --updates-json are mutually exclusive", file=sys.stderr)
        return 2
    if not args.create and not args.updates_json:
        print("error: one of --create or --updates-json is required", file=sys.stderr)
        return 2

    try:
        if args.create:
            create_packet(packet_path, args.slug, args.date)
            return 0
        if not packet_path.exists():
            print("error: packet not found: " + str(packet_path), file=sys.stderr)
            return 1
        update_packet(packet_path, args.updates_json)
        return 0
    except UpdateError as exc:
        print("error: " + str(exc), file=sys.stderr)
        return 1
    except UnicodeDecodeError as exc:
        print("error: packet is not valid UTF-8: " + str(exc), file=sys.stderr)
        return 1
    except OSError as exc:
        print("error: " + str(exc), file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
