#!/usr/bin/env python3
"""Write external/<suite>.manifest from each pinned submodule.

    python3 external/manifests.py

Each upstream suite keeps its own format and expected results; this script
reads them and writes one manifest row per selected test (the format is in
README.md, "Manifests"). Rerun it after moving a submodule. The selection
rules are the upstream runners' own where one exists; what a rule leaves out
is counted in the manifest's header.
"""
import json
import re
from collections import Counter
from pathlib import Path

EXT = Path(__file__).resolve().parent

# --- IEEE 1364-2005 helpers (from VerA's tools/external_digital.py) --------

# IEEE 1364-2005's normative system tasks and functions.
SYSTF_1364 = set("""
acos acosh asin asinh atan atan2 atanh bitstoreal ceil clog2 cos cosh display
displayb displayh displayo dist_chi_square dist_erlang dist_exponential
dist_normal dist_poisson dist_t dist_uniform dumpall dumpfile dumpflush
dumplimit dumpoff dumpon dumpports dumpportsall dumpportsflush dumpportslimit
dumpportsoff dumpportson dumpvars exp fclose fdisplay fdisplayb fdisplayh
fdisplayo feof ferror fflush fgetc fgets finish floor fmonitor fmonitorb
fmonitorh fmonitoro fopen fread fscanf fseek fstrobe fstrobeb fstrobeh fstrobeo
ftell fullskew fwrite fwriteb fwriteh fwriteo hold hypot itor ln log10 monitor
monitorb monitorh monitoro monitoroff monitoron nochange period pow
printtimescale q_add q_exam q_full q_initialize q_remove random readmemb
readmemh realtime realtobits recovery recrem removal rewind rtoi sdf_annotate
setup setuphold sformat signed sin sinh skew sqrt sscanf stime stop strobe
strobeb strobeh strobeo swrite swriteb swriteh swriteo tan tanh time timeformat
timeskew ungetc unsigned width write writeb writeh writeo test$plusargs
value$plusargs
""".split())
SYSTF_1364 |= {f"{s}$and${k}" for s in ("async", "sync") for k in ("array", "plane")}
SYSTF_1364 |= {f"{s}${g}${k}" for s in ("async", "sync") for g in ("nand", "or", "nor") for k in ("array", "plane")}

# IEEE 1800-2017 keywords that IEEE 1364-2005 does not reserve.
SV_KEYWORDS = set("""
accept_on alias always_comb always_ff always_latch assert assume before bind
bins binsof bit break byte chandle checker class clocking const constraint
context continue cover covergroup coverpoint cross dist do endchecker endclass
endclocking endgroup endinterface endpackage endprogram endproperty endsequence
enum eventually expect export extends extern final first_match foreach
forkjoin global iff ignore_bins illegal_bins implements implies import inside
int interconnect interface intersect join_any join_none let local logic
longint matches modport nettype new nexttime null package packed priority
program property protected pure rand randc randcase randsequence ref
reject_on restrict return s_always s_eventually s_nexttime s_until
s_until_with sequence shortint shortreal soft solve static string strong
struct super sync_accept_on sync_reject_on tagged this throughout
timeprecision timeunit type typedef union unique unique0 until until_with
untyped var virtual void wait_order weak within
""".split())
SV_TOKENS = re.compile(r"'\{|'[01xXzZ](?![0-9a-zA-Z_])|\w'\(|\+\+|--|[-+*/%&|^]=|<<=|>>=|::|##|\.\*|\[\s*\$|:\s*\$\s*\]"
                       r"|\{\s*(?:<<|>>)|\b\d+(?:\.\d+)?(?:fs|ps|ns|us|ms|s)\b|@\s*\(\s*edge\b|#\s*\(\s*[A-Za-z_]\w*\s*="
                       r"|\b(?:end\w*|join)\s*:\s*[A-Za-z_]|\bbegin\s+(?:integer|reg|real|realtime|time|event|parameter|localparam)\b|(?:^|;)\s*[A-Za-z_]\w*\s*:\s*(?:begin|fork)\b", re.M)
SV_PP = re.compile(r"`\"|`\\`\"|``|`undefineall|`__FILE__|`__LINE__|`define\s+\w+\([^)]*=|\"[^\"\n]*\\\n")


def strip(text):
    """`text` without comments and string contents."""
    return re.sub(r'//[^\n]*|/\*.*?\*/|"(?:\\.|[^"\\\n])*"',
                  lambda m: '""' if m.group(0).startswith('"') else " ", text, flags=re.S)


def non_1364_systf(code):
    return sorted({m for m in re.findall(r"(?<![\w\\])\$([A-Za-z_][\w$]*)", code)} - SYSTF_1364)


def sv_reasons(code, raw=""):
    words = set(re.findall(r"(?<![\w$`\\])[A-Za-z_]\w*", code)) & SV_KEYWORDS
    return sorted(words) + sorted(set(SV_TOKENS.findall(code))) + sorted(set(SV_PP.findall(raw)))


# Annex C: what Verilog-A does not have (the split tests/ was made with).
VAMS_RE = re.compile(
    r"\b(connect|connectmodule|connectrules|driver_update|endconnectrules|merged|resolveto|split|wreal|discrete"
    r"|always|initial|reg|posedge|negedge|casex|casez|fork|task|primitive|specify|event"
    r"|wire|tri|wand|wor|triand|trior|tri0|tri1|supply0|supply1|trireg|uwire)\b"
    r"|(^|;)\s*(and|or|nand|nor|xor|xnor|buf|not|bufif0|bufif1|notif0|notif1|nmos|pmos|cmos|tran|rtran|pullup|pulldown)\s+(#|\w+\s*\(|\()"
    r"|`default_discipline|===|!==|'[sS]?[bBoOdDhH]\s*[0-9a-fA-F_]*[xXzZ?]|\b(input|output|inout)\s+real\b", re.M)


def read(p):
    return p.read_text(errors="replace")


def write(name, root, rows, skipped, note):
    out = EXT / f"{name}.manifest"
    head = [f"# {name}: generated by external/manifests.py; do not edit.", f"# {note}"]
    for why, n in Counter(skipped.values()).most_common():
        head.append(f"# left out: {n} {why}")
    rel = Path(root).relative_to(EXT)
    out.write_text("\n".join(head + [f"#root {rel}"] + ["\t".join(r) for r in rows]) + "\n")
    print(f"{out.name}: {len(rows)} tests, {len(skipped)} left out")


# --- ivtest ------------------------------------------------------------------

# Lines the standard leaves to the tool, dropped from both sides: the
# simulator's own $finish/$stop report (17.4.1), compiler warnings in a gold
# file, VCD banners. Blank lines go too.
IV_FILTER = ("grep -Ev '^(\\$finish at tick .*|\\$stop at tick .*|[^ ]+:[0-9]+: \\$(finish|stop)(\\([0-9]\\))? called at .*"
             "|[^ ]+:[0-9]+: (warning|sorry|error): .*|[^ ]+:[0-9]+: +: .*|VCD (info|warning): .*"
             "|[[:space:]]+using existing file \\(.*\\)\\.|WARNING: .*|\\*\\* VVP Stop\\(0\\) \\*\\*"
             "|\\*\\* Flushing output streams\\.|\\*\\* Current simulation time is .*|\\*\\* Continue with \\$stop\\."
             "|\\*\\*\\* This is .*|[[:space:]]*)$' | tr -d '\\r'")
IVL_STD = {"-g2005": "1364-2005", "-g2001": "1364-2001", "-g2001-noconfig": "1364-2001", "-g1995": "1364-1995",
           "-g1": "1364-1995", "-g2": "1364-2001", "-gspecify": None}


def ivtest():
    iv = EXT / "iverilog/ivtest"
    seen, entries = set(), {}
    # upstream precedence (perl-lib/RegressionList.pm): ivl1 first, first entry wins;
    # only regress-vlg.list ("any simulator that supports standard Verilog") counts
    for lst in ("regress-ivl1.list", "regress-vlg.list"):
        for line in read(iv / lst).split("\n"):
            f = re.sub(r"#.*", "", line).split()
            if not f or ":" in f[0] or f[0] in seen:
                continue
            seen.add(f[0])
            if lst == "regress-vlg.list" and len(f) >= 3:
                ty, *args = f[1].split(",")
                gold = f[3][5:] if len(f) > 3 and f[3].startswith("gold=") else None
                entries[f[0]] = (ty, args, f"{f[2]}/{f[0]}.v", gold and f"gold/{gold}")
    for line in read(iv / "regress-vvp.list").split("\n"):
        f = re.sub(r"#.*", "", line).split()
        if len(f) < 2 or f[0] in seen:
            continue
        try:
            j = json.loads(read(iv / f[1]))
        except ValueError:
            continue
        gold = j.get("gold")
        entries[f[0]] = (j["type"], j.get("iverilog-args", []), f"ivltests/{j['source']}",
                         gold and f"gold/{gold}-vvp-stdout.gold")
    rows, skipped = [], {}
    want = {"normal": "ok", "CE": "reject", "RE": "reject-run", "CO": "compile", "CN": "compile"}
    for name, (ty, args, src, gold) in sorted(entries.items()):
        if ty not in want:
            skipped[name] = f"of type {ty}"
            continue
        bad = [a for a in args if a not in IVL_STD and not a.startswith("-W")]
        if bad:
            skipped[name] = "needing an Icarus option"
            continue
        if not (iv / src).is_file():
            skipped[name] = "with no source"
            continue
        if non_1364_systf(strip(read(iv / src))):
            skipped[name] = "calling a non-1364 system task"
            continue
        std = next((IVL_STD[a] for a in args if IVL_STD.get(a)), "1364-2005")
        w = want[ty]
        if w == "ok" and not gold:
            w = "passed"
        rows.append(["verilog", w, src, gold or "-", f"STD={std}", "INCDIR=ivltests"] + ([f"FILTER={IV_FILTER}"] if gold else []))
    write("ivtest", iv, rows, skipped, "Icarus Verilog's regression suite, the regress-vlg.list selection (GPL-2.0).")


# --- sv-tests (chipsalliance) -------------------------------------------------

def sv_tests():
    sv = EXT / "sv-tests/tests"
    rows, skipped = [], {}
    for p in sorted(sv.rglob("*")):
        if p.suffix not in (".sv", ".v") or not p.is_file():
            continue
        rel = str(p.relative_to(sv))
        if not rel.startswith("chapter-"):
            continue
        text = read(p)
        meta = dict(re.findall(r"(?m)^:([a-zA-Z_-]+):\s*(.+)$", text))
        if "name" not in meta:
            continue
        code = strip(text)
        if "uvm" in meta.get("tags", "").split() or set(meta) & {"defines", "files", "incdirs", "top_module"}:
            skipped[rel] = "needing runner flags or UVM"
        elif sv_reasons(code, text):
            skipped[rel] = "using SystemVerilog"
        elif non_1364_systf(code):
            skipped[rel] = "calling a non-1364 system task"
        elif not re.search(r"\bmodule\b", code):
            skipped[rel] = "with no module (a preprocessor-only test)"
        else:
            fail = "should_fail_because" in meta or meta.get("should_fail") == "1"
            sim = "simulation" in meta.get("type", "")
            rows.append(["verilog", "reject" if fail else "ok" if sim else "compile", rel, "-", "STD=1364-2005"])
    write("sv-tests", sv, rows, skipped, "chipsalliance/sv-tests, its IEEE 1364-2005 subset (ISC). `:assert:` lines are not judged yet.")


# --- ISP RAS ieee-1364-2005 ---------------------------------------------------

def ispras():
    d = EXT / "ispras-sv-tests/ieee-1364-2005"
    rows, skipped = [], {}
    for p in sorted(d.glob("*.v")):
        m = re.search(r"//\s*!\s*TYPE:\s*(\w+)", read(p))
        ty = m and m.group(1)
        if ty == "POSITIVE":
            rows.append(["verilog", "compile", p.name, "-", "STD=1364-2005"])
        elif ty == "NEGATIVE":
            rows.append(["verilog", "reject", p.name, "-", "STD=1364-2005"])
        else:
            skipped[p.name] = f"of type {ty} (tool-specific)"
    write("ispras-1364", d, rows, skipped, "ISP RAS, the IEEE 1364-2005 standard's examples (BSD-3-Clause).")


# --- OpenVAF-Reloaded -------------------------------------------------------------

def top_files(d, ext):
    """Files in `d` that declare a module and that no sibling includes."""
    files = sorted(p for p in d.glob(f"*{ext}") if p.is_file())
    included = {Path(m).name for p in files for m in re.findall(r'`include\s+"([^"]+)"', read(p))}
    return [p for p in files if p.name not in included and re.search(r"\bmodule\b", strip(read(p)))]


def openvaf():
    root = EXT / "OpenVAF-Reloaded"
    rows, skipped = [], {}
    for d in ("openvaf/test_data/ui", "openvaf/test_data/syn_ui"):
        for p in sorted((root / d).glob("*.va")):
            log = p.with_suffix(".log")
            if not log.is_file():
                skipped[str(p)] = "with no expected log"
                continue
            bad = re.search(r"(?mi)^error", read(log))
            rows.append(["verilog-a", "reject" if bad else "compile", str(p.relative_to(root))])
    for d in sorted((root / "integration_tests").iterdir()):
        if d.is_dir():
            rows += [["verilog-a", "compile", str(p.relative_to(root))] for p in top_files(d, ".va")]
    write("openvaf", root, rows, skipped, "OpenVAF-Reloaded's diagnostic tests and the models its integration tests compile (GPL-3.0).")


# --- gnucap-modelgen-verilog -------------------------------------------------------

def gnucap():
    d = EXT / "gnucap-modelgen-verilog/tests"
    rows, skipped = [], {}
    for p in sorted(d.glob("*.vams")):
        lang = "verilog-ams" if VAMS_RE.search(strip(read(p))) else "verilog-a"
        rows.append([lang, "reject" if ".error." in p.name else "compile", p.name])
    write("gnucap-modelgen", d, rows, skipped, "gnucap-modelgen-verilog's model tests; `.error.` names must be refused (GPL-3.0).")


# --- VA-Models ----------------------------------------------------------------------

def va_models():
    root = EXT / "VA-Models/code"
    rows = []
    for d in sorted({p.parent for p in root.rglob("*.va")}):
        rows += [["verilog-a", "compile", str(p.relative_to(root))] for p in top_files(d, ".va")]
    write("va-models", root, rows, {}, "dwarning/VA-Models: compact models used with ngspice and Xyce; each must compile.")


# --- ngspice regression --------------------------------------------------------------

# tests/bin/check.sh: three-digit exponents to two, its FILTER words dropped,
# then compared as `diff -B -w`.
NG_FILTER = ("sed -e 's/\\([.0-9][eE][+-]\\?\\)0\\([0-9]\\{2\\}\\)/\\1\\2/g' | grep -Ev "
             "'SPARSE|KLU|CPU|Dynamic|Note|Circuit|Trying|Reference|Date|Doing|---|v-sweep|time|est|Error|Warning|Data|Index"
             "|trans|acan|oise|nalysis|ole|Total|memory|urrent|Got|Added|BSIM|bsim|B4SOI|b4soi|codemodel|^binary raw file"
             "|^ngspice.*done|Operating' | sed -e 's/[[:space:]]\\+/ /g; s/^ //; s/ $//' | grep -v '^$'")


def ngspice():
    root = EXT / "ngspice/tests"
    rows, skipped = [], {}
    for mk in sorted(root.rglob("Makefile.am")):
        m = re.search(r"(?ms)^TESTS\s*=\s*(.*?)(?<!\\)\n", read(mk))
        if not m:
            continue
        for t in m.group(1).replace("\\\n", " ").split():
            cir = mk.parent / t
            if not t.endswith(".cir"):
                continue
            out = cir.with_suffix(".out")
            if not out.is_file():
                skipped[str(cir)] = "with no .out"
                continue
            rows.append(["netlist", "ok", str(cir.relative_to(root)), str(out.relative_to(root)), f"FILTER={NG_FILTER}", "RTOL=1e-4", "ATOL=1e-15"])
    write("ngspice", root, rows, skipped, "ngspice's `make check` regression decks and their .out files (BSD-3-Clause). Upstream diffs exactly against its own build; across builds (KLU vs Sparse, libm) numbers match to RTOL.")


if __name__ == "__main__":
    for f in (ivtest, sv_tests, ispras, openvaf, gnucap, va_models, ngspice):
        f()
