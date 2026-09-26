#!/usr/bin/env python3
"""Sync strings.xml and colors.xml from ServiceMusic into music_app."""

from __future__ import annotations

import json
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
SERVICE = REPO.parent / "ServiceMusic"
STRINGS_XML = SERVICE / "app/src/main/res/values/strings.xml"
COLORS_XML = SERVICE / "app/src/main/res/values/colors.xml"
ARB_OUT = REPO / "lib/l10n/app_vi.arb"
COLORS_DART = REPO / "lib/core/theme/app_colors.dart"

# Android % placeholders -> ARB named placeholders (order matters for %1$s style).
STRING_PLACEHOLDERS: dict[str, list[tuple[str, str]]] = {
    "downloaded_songs_count": [("count", "int")],
    "singer_detail_songs_count": [("count", "int")],
    "recent_history_count": [("count", "int")],
    "category_songs_count": [("count", "int")],
    "favourite_songs_count": [("count", "int")],
    "playlist_song_count": [("count", "int")],
    "playlist_meta_public": [("songCount", "int")],
    "playlist_meta_private": [("songCount", "int")],
    "playlist_added": [("playlistName", "String")],
    "sleep_timer_cancel_remaining": [("remaining", "String")],
    "sleep_timer_remaining_text": [("remaining", "String")],
    "mini_player_singer_format": [("singer", "String")],
}


def decode_android_string(text: str) -> str:
    text = text.replace("\\n", "\n")
    text = text.replace("\\'", "'")
    text = text.replace('\\"', '"')
    text = re.sub(r"\\(.)", r"\1", text)
    text = text.replace("&amp;", "&")
    text = text.replace("&lt;", "<")
    text = text.replace("&gt;", ">")
    return text


def android_format_to_arb(name: str, value: str) -> tuple[str, dict | None]:
    spec = STRING_PLACEHOLDERS.get(name)
    if not spec:
        if re.search(r"%(\d+\$)?[dfs]", value):
            print(f"Warning: unmapped placeholders in {name}: {value!r}", file=sys.stderr)
        return value, None

    meta: dict[str, dict] = {"placeholders": {}}
    out = value
    for idx, (pname, ptype) in enumerate(spec):
        pos = idx + 1
        out = re.sub(rf"%{pos}\$[ds]", "{" + pname + "}", out, count=1)
    out = re.sub(r"%d", "{" + spec[0][0] + "}", out, count=1)
    for pname, ptype in spec:
        meta["placeholders"][pname] = {"type": ptype}
    return out, meta


def parse_strings() -> dict:
    root = ET.parse(STRINGS_XML).getroot()
    entries: dict = {"@@locale": "vi"}
    for node in root.findall("string"):
        name = node.get("name")
        if not name or node.text is None:
            continue
        raw = decode_android_string(node.text.strip())
        text, meta = android_format_to_arb(name, raw)
        entries[name] = text
        if meta:
            entries[f"@{name}"] = meta
    return entries


def android_color_to_flutter(value: str) -> str:
    value = value.strip()
    if not value.startswith("#"):
        return "0xFF000000"
    hex_digits = value[1:]
    if len(hex_digits) == 8:
        aa, rr, gg, bb = hex_digits[0:2], hex_digits[2:4], hex_digits[4:6], hex_digits[6:8]
        return f"0x{aa.upper()}{rr.upper()}{gg.upper()}{bb.upper()}"
    if len(hex_digits) == 6:
        return f"0xFF{hex_digits.upper()}"
    return "0xFF000000"


def dart_identifier(name: str) -> str:
    parts = name.split("_")
    return parts[0] + "".join(p.capitalize() for p in parts[1:])


def parse_colors_dart() -> str:
    root = ET.parse(COLORS_XML).getroot()
    lines = [
        "import 'package:flutter/material.dart';",
        "",
        "/// Colors from ServiceMusic `res/values/colors.xml`.",
        "/// Regenerate: `python3 tool/sync_android_resources.py`",
        "abstract final class AppColors {",
    ]
    for node in root.findall("color"):
        name = node.get("name")
        if not name or not node.text:
            continue
        val = node.text.strip()
        if val.startswith("//"):
            continue
        field = dart_identifier(name)
        flutter = android_color_to_flutter(val)
        lines.append(f"  static const Color {field} = Color({flutter});")
    lines.append("}")
    lines.append("")
    return "\n".join(lines)


def main() -> int:
    if not STRINGS_XML.is_file() or not COLORS_XML.is_file():
        print("ServiceMusic resource files not found.", file=sys.stderr)
        return 1

    ARB_OUT.parent.mkdir(parents=True, exist_ok=True)
    COLORS_DART.parent.mkdir(parents=True, exist_ok=True)

    arb = parse_strings()
    ARB_OUT.write_text(json.dumps(arb, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    COLORS_DART.write_text(parse_colors_dart(), encoding="utf-8")

    string_count = sum(1 for k in arb if not k.startswith("@"))
    color_count = parse_colors_dart().count("static const Color")
    print(f"Wrote {ARB_OUT} ({string_count} strings)")
    print(f"Wrote {COLORS_DART} ({color_count} colors)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
