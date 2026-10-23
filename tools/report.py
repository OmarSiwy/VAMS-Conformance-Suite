#!/usr/bin/env python3
"""Turn results/<tool>.tsv (and <tool>.version) into one conformance chart per
language, docs/conformance/<category>.svg, and the table between README.md's
`<!-- conformance:start -->` and `<!-- conformance:end -->` markers.

    python3 tools/report.py results

A test's category comes from its language: the directory under tests/, or a
manifest row's first column. A tool's conformance in a category is the
tests it passes over every test in that category, so a test it cannot run
counts against it; "not supported" is the share it skipped.
"""
import datetime, html, re, sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TOOLS = ["vera", "openvaf", "iverilog", "verilator", "ngspice", "espice"]
NAMES = {"vera": "VerA", "openvaf": "OpenVAF-Reloaded", "iverilog": "Icarus Verilog", "verilator": "Verilator",
         "ngspice": "ngspice", "espice": "ESPice"}
CATEGORIES = [("verilog", "Verilog (IEEE 1364-2005)"), ("verilog-a", "Verilog-A"), ("verilog-ams", "Verilog-AMS"),
              ("spice", "SPICE")]
# language -> category. Annex E (tests/spice/) is Verilog-AMS's SPICE
# compatibility, judged in a Verilog-AMS compiler; SPICE is the simulators.
LANG = {"verilog": "verilog", "vpi": "verilog", "verilog-a": "verilog-a", "verilog-ams": "verilog-ams",
        "spice": "verilog-ams", "netlist": "spice"}


def languages():
    """test name -> language, for manifest rows (file tests use their path)."""
    out = {}
    for m in (ROOT / "external").glob("*.manifest"):
        for line in m.read_text().splitlines():
            if line and not line.startswith("#"):
                col = line.split("\t")
                out[f"{m.stem}/{col[2]}"] = col[0]
    return out


def category(name, langs):
    lang = langs.get(name) or name.split("/", 1)[0]
    return LANG.get(lang)


def svg(title, rows):
    """A horizontal stacked bar per tool: passed, failed, then the empty
    track for what it does not support. `rows`: [(tool, version, pass, fail, skip)]."""
    w, left, bar, right, top, step = 760, 150, 430, 180, 64, 34
    h = top + step * max(len(rows), 1) + 16
    out = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}" '
           f'role="img" aria-labelledby="t"><title id="t">{html.escape(title)} conformance</title>',
           '<style>text{font:13px system-ui,-apple-system,"Segoe UI",sans-serif;fill:#0b0b0b}'
           '.m{fill:#52514e}.h{font-size:15px;font-weight:600}.bg{fill:#fcfcfb}.trk{fill:#ebeae6}'
           '.p{fill:#2a78d6}.f{fill:#eb6834}'
           '@media (prefers-color-scheme:dark){text{fill:#fff}.m{fill:#c3c2b7}.bg{fill:#1a1a19}'
           '.trk{fill:#2c2c2a}.p{fill:#3987e5}.f{fill:#d95926}}</style>',
           f'<rect class="bg" width="{w}" height="{h}" rx="8"/>',
           f'<text class="h" x="16" y="26">{html.escape(title)}</text>']
    lx = 16
    for cls, label in (("p", "Passed"), ("f", "Failed"), ("trk", "Not supported")):
        out.append(f'<rect class="{cls}" x="{lx}" y="38" width="12" height="12" rx="3"/>'
                   f'<text class="m" x="{lx + 18}" y="48">{label}</text>')
        lx += 30 + 8 * len(label)
    if not rows:
        out.append(f'<text class="m" x="16" y="{top + 16}">No tool has run these tests yet.</text>')
    for i, (tool, version, p, f, s) in enumerate(rows):
        y, total = top + i * step, p + f + s
        out.append(f'<text x="16" y="{y + 13}">{html.escape(NAMES.get(tool, tool))}</text>')
        out.append(f'<rect class="trk" x="{left}" y="{y}" width="{bar}" height="18" rx="4">'
                   f'<title>{s} not supported</title></rect>')
        x = left
        for cls, n, what in (("p", p, "passed"), ("f", f, "failed")):
            width = bar * n / total if total else 0
            if width >= 1:
                # 2px surface gap between segments; rounded data-ends.
                out.append(f'<rect class="{cls}" x="{x:.1f}" y="{y}" width="{max(width - 2, 1):.1f}" height="18" rx="4">'
                           f'<title>{n} {what} ({100 * n / total:.1f}%)</title></rect>')
            x += width
        pct = 100 * p / total if total else 0
        out.append(f'<text x="{left + bar + 12}" y="{y + 13}"><tspan font-weight="600">{pct:.1f}%</tspan>'
                   f'<tspan class="m"> {p} / {total}</tspan></text>')
    out.append("</svg>")
    return "\n".join(out) + "\n"


def main():
    results = Path(sys.argv[1] if len(sys.argv) > 1 else "results")
    langs = languages()
    counts = {}  # (category, tool) -> Counter of PASS/FAIL/SKIP
    versions = {}
    for tool in TOOLS:
        tsv = results / f"{tool}.tsv"
        if not tsv.is_file():
            continue
        v = results / f"{tool}.version"
        versions[tool] = v.read_text().strip() if v.is_file() else ""
        for line in tsv.read_text().splitlines():
            status, name = line.split("\t")[:2]
            cat = category(name, langs)
            if cat:
                status = {"XFAIL": "FAIL", "XPASS": "PASS"}.get(status, status)
                counts.setdefault((cat, tool), Counter())[status] += 1
    out_dir = ROOT / "docs/conformance"
    out_dir.mkdir(parents=True, exist_ok=True)
    table = ["| Language | Tool | Version | Passed | Failed | Not supported | Conformance |", "|---|---|---|---:|---:|---:|---:|"]
    for cat, title in CATEGORIES:
        rows = []
        for tool in TOOLS:
            c = counts.get((cat, tool))
            if not c or c["PASS"] + c["FAIL"] == 0:
                continue  # the tool runs nothing in this language
            rows.append((tool, versions[tool], c["PASS"], c["FAIL"], c["SKIP"]))
        rows.sort(key=lambda r: -r[2] / (r[2] + r[3] + r[4]))
        (out_dir / f"{cat}.svg").write_text(svg(title, rows))
        for tool, version, p, f, s in rows:
            table.append(f"| {title} | {NAMES[tool]} | {version} | {p} | {f} | {s} | {100 * p / (p + f + s):.1f}% |")
    stamp = datetime.date.today().isoformat()
    block = "\n".join(
        [f"Measured {stamp} by `.github/workflows/conformance.yml`, each tool at its latest version (`tools/ci.sh` says which).", ""]
        + [f"![{title} conformance](docs/conformance/{cat}.svg)" for cat, title in CATEGORIES]
        + ["", "<details><summary>The numbers</summary>", "", *table, "", "</details>"])
    readme = ROOT / "README.md"
    text = readme.read_text()
    new = re.sub(r"(<!-- conformance:start -->\n).*?(\n<!-- conformance:end -->)", lambda m: m.group(1) + block + m.group(2),
                 text, flags=re.S)
    readme.write_text(new)


if __name__ == "__main__":
    main()
