#!/usr/bin/env python3
"""Run a compiled OSDI model (CONFORM_WORK/<stem>.osdi) in ngspice at the
operating point a test's `//!` lines describe, and print its `ok=` lines.

The testbench subset: `bias` (every port is held by a voltage source, 0 V
unless biased, except an unbiased port the model drives itself), `param` (model card), `temp`, `analysis dc`/`op`. Any other
testbench directive exits 77 (SKIP): this adapter cannot express it yet.

ngspice evaluates an OSDI device's `$strobe` on every Newton iteration, not
once per converged point (LRM 9.4.6 says accepted iterations only), so only the last line printed for each
check label is kept: the evaluation at the converged solution.
"""
import os, re, subprocess, sys

IGNORED = {"lrm", "inherited", "lrm-reject", "inherited-reject", "neighbour", "checks", "print", "warn", "nowarn"}
SKIP = 77

src = os.environ["CONFORM_SRC"]
work = os.environ["CONFORM_WORK"]
osdi = os.path.join(work, os.environ["CONFORM_STEM"] + ".osdi")
text = open(src, encoding="utf-8", errors="replace").read()

bias, params, temp = {}, [], None
for line in text.splitlines():
    s = line.strip()
    if not s.startswith("//!"):
        continue
    kw, _, rest = s[3:].strip().partition(" ")
    rest = rest.strip()
    if kw in IGNORED:
        continue
    if kw == "bias":
        for b in rest.split(","):
            m = re.fullmatch(r"\s*(?:V\(\s*(\w+)\s*\)|(\w+))\s*=\s*(\S+)\s*", b)
            if not m:
                print(f"unsupported bias `{b}`", file=sys.stderr)
                sys.exit(SKIP)
            bias[m.group(1) or m.group(2)] = m.group(3)
    elif kw == "param":
        params += [p.strip() for p in rest.split(",") if p.strip()]
    elif kw == "temp":
        temp = rest
    elif kw == "analysis" and rest.split()[0] in ("dc", "op"):
        pass
    else:
        print(f"unsupported testbench directive `{kw}`", file=sys.stderr)
        sys.exit(SKIP)

# The top module: the last one no other module instantiates.
body = re.sub(r"/\*.*?\*/|//[^\n]*", " ", text, flags=re.S)
mods = re.findall(r"\b(?:module|macromodule)\s+(\w+)\s*(?:#\s*\(.*?\)\s*)?(\((.*?)\))?\s*;", body, flags=re.S)
if not mods:
    print("no module", file=sys.stderr)
    sys.exit(SKIP)
names = [m[0] for m in mods]
used = {n for n in names if re.search(rf"^\s*{n}\s+(#\s*\(.*?\)\s*)?\w+\s*\(", body, flags=re.M | re.S)}
top = [m for m in mods if m[0] not in used][-1]
ports = [p for p in re.findall(r"\b\w+\b", top[2]) if p not in {"input", "output", "inout", "electrical", "wire", "real"}]

deck = [f"conform {top[0]}", ".control", f"pre_osdi {osdi}", ".endc"]
deck.append(f".model dut {top[0]} " + " ".join(params))
deck.append("N1 " + " ".join(f"n_{p}" for p in ports) + " dut")
# A port the model drives with a potential contribution cannot also be held by
# a source: unless biased it hangs on 1 Gohm to ground.
driven = {m for m in re.findall(r"\bV\s*\(\s*(\w+)[^;]*?\)\s*<\+", body)}
for p in ports:
    if p in driven and p not in bias:
        deck.append(f"R_{p} n_{p} 0 1G")
    else:
        deck.append(f"V_{p} n_{p} 0 {bias.get(p, '0')}")
if temp:
    deck.append(f".temp {float(temp) - 273.15}")
deck += [".op", ".end", ""]
with open(os.path.join(work, "deck.sp"), "w") as f:
    f.write("\n".join(deck))

r = subprocess.run(["ngspice", "-b", "deck.sp"], cwd=work, capture_output=True, text=True)
out = r.stdout + r.stderr
sys.stderr.write(out)
if r.returncode or re.search(r"^(Error|.*no simulations run|.*simulation\(s\) aborted)", out, re.M | re.I):
    sys.exit(1)
last = {}
for line in out.splitlines():
    line = re.sub(r"^OSDI\(debug\) \S+: ", "", line)
    m = re.match(r"(.*?) got=", line)
    if m and "ok=" in line:
        last[m.group(1)] = line
print("\n".join(last.values()))
