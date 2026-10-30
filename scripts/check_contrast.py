#!/usr/bin/env python3
"""Check both shipped token palettes using WCAG2 relative luminance; stdlib only."""
import json
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
def luminance(value):
    value = value.lstrip("#")
    if len(value) == 3: value = "".join(x * 2 for x in value)
    channels = [int(value[i:i+2], 16) / 255 for i in (0, 2, 4)]
    channels = [c / 12.92 if c <= .04045 else ((c + .055) / 1.055) ** 2.4 for c in channels]
    return sum(c * w for c, w in zip(channels, (.2126, .7152, .0722)))
def check(colors, pairs):
    failures = []
    for pair in pairs:
        fg, bg = pair[:2]
        kind = pair[2] if len(pair) > 2 else "normal"
        a, b = sorted((luminance(colors[fg]), luminance(colors[bg])))
        value = (b + .05) / (a + .05)
        threshold = 3 if kind in ("large", "ui") else 4.5
        if value < threshold: failures.append({"pair": pair, "ratio": value})
    return failures
if __name__ == "__main__":
    tokens = json.loads((ROOT / "replica/design/tokens.json").read_text())
    reports = []
    for name, colors in [("default", tokens["color"]), ("likeness", {**tokens["color"], **{k:v for k,v in tokens["theme-likeness"].items() if not k.startswith("_")}})]:
        failures = check(colors, tokens["pairs"])
        reports.append({"palette": name, "pairs": len(tokens["pairs"]), "failures": failures})
    print(json.dumps(reports, indent=2))
    raise SystemExit(any(x["failures"] for x in reports))
