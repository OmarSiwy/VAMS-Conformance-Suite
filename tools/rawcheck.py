#!/usr/bin/env python3
"""Run a SPICE simulator on a deck and judge its binary raw file against the
deck's `.expected.json` oracle, one `ok=` line per check.

    python3 rawcheck.py 'ngspice -b ${RAW:+-r "$RAW"} "$DECK"'
    python3 rawcheck.py --selftest

The command runs under `sh` in the deck's directory (so relative `.include`
paths keep their meaning) with DECK (the deck's file name), RAW (where the
raw file goes) and TOKENIZER (the oracle's input dialect, default ngspice)
set. Without an `.expected.json`, RAW is unset and the command's stdout
passes through, for decks judged by a gold file instead (external manifests).

A port of ESPice's tests/test_correctness.zig judge, tool-neutral:
- `status: error` passes on a diagnosed failure (exit 1-125). ESPice also
  matches its own error category, which other tools do not print.
- plots: the `exact`, `selected_rows`, `samples` and `unordered` match
  modes, |got - want| <= atol + rtol*|want| on the complex plane.
- checks: `measure` (a `.meas` line on stdout). The other check kinds exit 77
  (SKIP). ponytail: port them from test_correctness.zig when a tool needs them.
"""
import json, math, os, re, struct, subprocess, sys

SKIP = 77
PORTED = {"measure"}


def parse_raw(data):
    """[(plotname, [column names], rows, complex, values[row][col])]"""
    plots, pos = [], 0

    def line():
        nonlocal pos
        end = data.index(b"\n", pos)
        text = data[pos:end].decode(errors="replace").strip()
        pos = end + 1
        return text

    while pos < len(data):
        if data[pos:pos + 1] in (b"\n", b"\r"):
            pos += 1
            continue
        if not line().startswith("Title:"):
            raise ValueError("raw: no Title")
        head = {}
        while (t := line()).lower() != "variables:":
            k, _, v = t.partition(":")
            head[k.strip().lower()] = v.strip()
        cols, rows = int(head["no. variables"]), int(head["no. points"])
        cplx = head["flags"].lower() == "complex"
        names = [line().split()[1] for _ in range(cols)]
        if line().lower() != "binary:":
            raise ValueError("raw: not a binary raw file")
        width = 2 if cplx else 1
        n = rows * cols * width
        vals = struct.unpack_from(f"<{n}d", data, pos)
        pos += n * 8
        table = [[complex(vals[(r * cols + c) * 2], vals[(r * cols + c) * 2 + 1]) if cplx else complex(vals[r * cols + c], 0)
                  for c in range(cols)] for r in range(rows)]
        plots.append((head["plotname"], names, rows, cplx, table))
    if not plots:
        raise ValueError("raw: no plots")
    return plots


def canonical(name):
    """The spellings ngspice and espice use for the same column, folded."""
    n = name.lower()
    tf = {"v(transfer_function)": "transfer_function"}
    if n in tf:
        return tf[n]
    if "#input_impedance" in n:
        return "input_resistance"
    if n.startswith("v(output_impedance_at_"):
        return "output_resistance"
    return n[:-7] if n.endswith("#branch") else n


def column(plot, name):
    hits = [i for i, n in enumerate(plot[1]) if canonical(n) == canonical(name)]
    if len(hits) != 1:
        raise KeyError(f"column {name}: {len(hits)} matches")
    return hits[0]


def close(got, want, rtol, atol):
    return abs(got - want) <= atol + rtol * abs(want)


def scalar(v):
    return complex(v[0], v[1]) if isinstance(v, list) else complex(v, 0)


def plot_name(actual, want):
    a, w = actual.lower(), want.lower()
    return a == w or (w.startswith("fourier analysis") and a.startswith(w) and a[len(w):].startswith(" (thd = "))


def sample(plot, axis, col, t, rtol, atol):
    """Column `col` linearly interpolated at axis value `t`."""
    tab, rows = plot[4], plot[2]
    xs = [tab[r][axis].real for r in range(rows)]
    if not rows:
        raise ValueError("no samples")
    if t < xs[0] or t > xs[-1]:
        end = 0 if t < xs[0] else rows - 1
        if close(complex(xs[end], 0), complex(t, 0), rtol, atol):
            return tab[end][col]
        raise ValueError(f"axis does not reach {t}")
    lo, hi = 0, rows - 1
    while hi - lo > 1:
        mid = (lo + hi) // 2
        lo, hi = (mid, hi) if xs[mid] <= t else (lo, mid)
    if xs[hi] == xs[lo]:
        return tab[lo][col]
    f = (t - xs[lo]) / (xs[hi] - xs[lo])
    return tab[lo][col] + f * (tab[hi][col] - tab[lo][col])


def judge_plot(want, plot):
    """[(label, ok, detail)] for one expected plot against its raw plot."""
    out = []
    if want.get("row_count") is not None and want["row_count"] != plot[2]:
        return [(f"{want['name']} rows", False, f"got={plot[2]} want={want['row_count']}")]
    mode, axis, cols = want["match"], want.get("axis"), want["columns"]
    if mode == "unordered":
        # Bipartite match, expected rows onto actual rows (augmenting paths).
        idx = {n: column(plot, n) for n in cols}
        ax = axis and column(plot, axis["name"])
        owner = [None] * plot[2]

        def fits(r, c):
            ok = all(close(plot[4][c][idx[n]], scalar(col["values"][r]), col["rtol"], col["atol"]) for n, col in cols.items())
            return ok and (not axis or close(plot[4][c][ax], complex(axis["values"][r], 0), axis["rtol"], axis["atol"]))

        def assign(r, seen):
            for c in range(plot[2]):
                if c in seen or not fits(r, c):
                    continue
                seen.add(c)
                if owner[c] is None or assign(owner[c], seen):
                    owner[c] = r
                    return True
            return False

        ok = all(assign(r, set()) for r in range(plot[2]))
        return [(f"{want['name']} rows (unordered)", ok, "")]
    rows = want.get("row_indices") if mode == "selected_rows" else None
    if axis and mode != "samples":
        a = column(plot, axis["name"])
        bad = [(j, plot[4][rows[j] if rows else j][a]) for j, v in enumerate(axis["values"])
               if not close(plot[4][rows[j] if rows else j][a], complex(v, 0), axis["rtol"], axis["atol"])]
        out.append((f"{want['name']}:{axis['name']}", not bad, f"got={bad[0][1]} want={axis['values'][bad[0][0]]}" if bad else ""))
    for name, col in cols.items():
        c = column(plot, name)
        first = None
        for j, v in enumerate(col["values"]):
            if mode == "samples":
                a = column(plot, axis["name"])
                got = sample(plot, a, c, axis["values"][j], axis["rtol"], axis["atol"])
            else:
                got = plot[4][rows[j] if rows else j][c]
            w = scalar(v)
            if col.get("magnitude"):
                got, w = complex(abs(got), 0), complex(abs(w), 0)
            if not close(got, w, col["rtol"], col["atol"]):
                first = (j, got, w)
                break
        detail = f"[{first[0]}] got={first[1]:.9g} want={first[2]:.9g}" if first else f"got={len(col['values'])} points want={len(col['values'])}"
        out.append((f"{want['name']}:{name}", first is None, detail))
    return out


def measure(stdout, check):
    for text in stdout.splitlines():
        name, eq, rest = text.partition("=")
        if eq and name.strip().lower() == check["name"].lower():
            try:
                got = float(rest.split()[0])
            except (ValueError, IndexError):
                break
            return close(complex(got, 0), complex(check["value"], 0), check["rtol"], check["atol"]), f"got={got:.9g} want={check['value']:.9g}"
    return False, f"got=missing want={check['value']:.9g}"


def judge(oracle, rc, stdout, raw):
    """[(label, ok, detail)] for the whole oracle."""
    exp = oracle["expect"]
    if exp["status"] == "error":
        return [("rejected with a diagnostic", 1 <= rc <= 125, f"got=exit {rc} want=exit 1-125")]
    if rc != 0:
        return [("simulation succeeded", False, f"got=exit {rc} want=exit 0")]
    try:
        plots = parse_raw(raw)
    except (ValueError, KeyError, OSError, struct.error) as e:
        return [("raw file", False, f"got={e} want=a binary raw file")]
    out, used = [], set()
    for want in exp.get("plots", []):
        cands = [i for i, p in enumerate(plots) if i not in used and plot_name(p[0], want["name"])]
        src = want.get("input_source")
        if src:  # repeated .tf plots: the one whose impedance column names the source
            named = [i for i in cands if any(n.lower().startswith(f"{src.lower()}#input_impedance") or
                                             n.lower().startswith(f"v({src.lower()})#input_impedance") for n in plots[i][1])]
            cands = named or cands
        if not cands:
            out.append((f"plot {want['name']}", False, "got=missing want=present"))
            continue
        used.add(cands[0])
        try:
            out += judge_plot(want, plots[cands[0]])
        except (KeyError, ValueError) as e:
            out.append((f"plot {want['name']}", False, f"got={e} want=columns present"))
    for check in exp.get("checks", []):
        if check["kind"] == "measure":
            ok, detail = measure(stdout, check)
            out.append((f"measure {check['name']}", ok, detail))
    return out


def main():
    cmd = sys.argv[1]
    src, work = os.environ["CONFORM_SRC"], os.environ["CONFORM_WORK"]
    env = dict(os.environ, DECK=os.path.basename(src))
    expected = os.path.splitext(src)[0] + ".expected.json"
    oracle = None
    if os.path.exists(expected):
        oracle = json.load(open(expected))
        kinds = {c["kind"] for c in oracle["expect"].get("checks", [])} - PORTED
        if kinds:
            print(f"oracle check kind not ported to rawcheck.py: {', '.join(sorted(kinds))}", file=sys.stderr)
            sys.exit(SKIP)
        env.update(RAW=os.path.join(work, "result.raw"), TOKENIZER=oracle.get("tokenizer") or "ngspice")
    p = subprocess.run(["sh", "-c", cmd], cwd=os.path.dirname(src), env=env, capture_output=True, text=True, errors="replace")
    sys.stderr.write(p.stderr)
    if oracle is None:
        sys.stdout.write(p.stdout)
        sys.exit(p.returncode)
    raw = open(env["RAW"], "rb").read() if os.path.exists(env["RAW"]) else b""
    for label, ok, detail in judge(oracle, p.returncode, p.stdout, raw):
        print(f"{label} {detail} ok={int(ok)}")


def selftest():
    hdr = b"Title: t\nPlotname: Transient Analysis\nFlags: real\nNo. Variables: 2\nNo. Points: 3\nVariables:\n\t0\ttime\ttime\n\t1\tv(out)\tvoltage\nBinary:\n"
    raw = hdr + struct.pack("<6d", 0, 0, 1, 2, 2, 4)
    tol = {"rtol": 1e-6, "atol": 1e-12}
    def oracle(match, **kw):
        return {"expect": {"status": "success", "plots": [dict(name="transient analysis", match=match, **kw)],
                           "checks": [{"kind": "measure", "name": "vmax", "value": 4, **tol}]}}
    exact = oracle("exact", row_count=3, columns={"V(OUT)": dict(values=[0, 2, 4], **tol)})
    assert all(ok for _, ok, _ in judge(exact, 0, "vmax = 4.0e+00 at 2", raw))
    samples = oracle("samples", axis=dict(name="time", values=[0.5, 1.5], **tol), columns={"v(out)": dict(values=[1, 3], **tol)})
    assert all(ok for _, ok, _ in judge(samples, 0, "vmax = 4", raw))
    wrong = oracle("exact", row_count=3, columns={"v(out)": dict(values=[0, 2, 5], **tol)})
    assert [ok for _, ok, _ in judge(wrong, 0, "vmax = 4", raw)] == [False, True]
    unordered = oracle("unordered", row_count=3, columns={"v(out)": dict(values=[4, 0, 2], **tol)})
    assert all(ok for _, ok, _ in judge(unordered, 0, "vmax = 4", raw))
    assert judge({"expect": {"status": "error"}}, 1, "", b"")[0][1]
    assert not judge({"expect": {"status": "error"}}, 0, "", b"")[0][1]
    assert not judge(exact, 0, "", b"")[0][1]  # no raw file
    print("rawcheck selftest: ok")


if __name__ == "__main__":
    selftest() if sys.argv[1:] == ["--selftest"] else main()
