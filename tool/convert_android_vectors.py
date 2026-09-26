#!/usr/bin/env python3
"""Convert ServiceMusic Android vector drawables to SVG for Flutter assets."""

from __future__ import annotations

import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

ANDROID_NS = "http://schemas.android.com/apk/res/android"
NS = {"android": ANDROID_NS}


def _attr(elem: ET.Element, name: str) -> str | None:
    return elem.get(f"{{{ANDROID_NS}}}{name}") or elem.get(name)


def load_colors(colors_xml: Path) -> dict[str, str]:
    colors: dict[str, str] = {}
    root = ET.parse(colors_xml).getroot()
    for node in root.findall("color"):
        name = node.get("name")
        if name and node.text:
            colors[name] = node.text.strip()
    return colors


def resolve_color(raw: str | None, colors: dict[str, str]) -> str:
    if not raw:
        return "#000000"
    raw = raw.strip()
    if raw.startswith("#"):
        if len(raw) == 9:
            return f"#{raw[3:9]}"
        return raw
    match = re.match(r"@color/(\w+)", raw)
    if match:
        return resolve_color(colors.get(match.group(1), "#000000"), colors)
    return "#000000"


def convert_vector(xml_path: Path, out_path: Path, colors: dict[str, str]) -> tuple[bool, str]:
    root = ET.parse(xml_path).getroot()
    tag = root.tag.split("}")[-1] if "}" in root.tag else root.tag
    if tag != "vector":
        return False, "not vector"

    vw = _attr(root, "viewportWidth")
    vh = _attr(root, "viewportHeight")
    if not vw or not vh:
        return False, "missing viewport"

    path_lines: list[str] = []
    for elem in root.iter():
        local = elem.tag.split("}")[-1] if "}" in elem.tag else elem.tag
        if local != "path":
            continue
        path_data = _attr(elem, "pathData")
        if not path_data:
            continue
        fill = resolve_color(_attr(elem, "fillColor"), colors)
        stroke = _attr(elem, "strokeColor")
        stroke_width = _attr(elem, "strokeWidth")
        attrs = f'fill="{fill}"'
        if stroke:
            attrs += f' stroke="{resolve_color(stroke, colors)}"'
        if stroke_width:
            attrs += f' stroke-width="{stroke_width}"'
        d = " ".join(path_data.split())
        path_lines.append(f'  <path d="{d}" {attrs}/>')

    if not path_lines:
        return False, "no paths"

    svg = (
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {vw} {vh}">\n'
        + "\n".join(path_lines)
        + "\n</svg>\n"
    )
    out_path.write_text(svg, encoding="utf-8")
    return True, "ok"


def main() -> int:
    repo = Path(__file__).resolve().parents[1]
    service_music = repo.parent / "ServiceMusic"
    drawable = service_music / "app/src/main/res/drawable"
    colors_xml = service_music / "app/src/main/res/values/colors.xml"
    out_dir = repo / "assets/icons"

    if not drawable.is_dir():
        print(f"Missing drawable dir: {drawable}", file=sys.stderr)
        return 1

    colors = load_colors(colors_xml) if colors_xml.is_file() else {}
    out_dir.mkdir(parents=True, exist_ok=True)

    converted = 0
    skipped = 0
    for xml_file in sorted(drawable.glob("*.xml")):
        ok, _ = convert_vector(xml_file, out_dir / f"{xml_file.stem}.svg", colors)
        if ok:
            converted += 1
        else:
            skipped += 1

    print(f"Wrote {converted} SVG(s) to {out_dir} ({skipped} non-vector skipped).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
