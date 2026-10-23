#!/bin/sh
# The harness fed a fake tool whose behaviour each test scripts beside itself
# (<stem>.out is printed, <stem>.exit is the exit status). Every verdict is
# known in advance; any other verdict fails this script.
# usage: sh harness/selftest.sh [path/to/conform]
set -eu
CONFORM=${1:-$(dirname "$0")/conform}
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
mkdir -p "$T/s/include" "$T/s/verilog-a" "$T/s/verilog" "$T/s/spice"

cat > "$T/tool.conf" <<'EOF'
run.verilog-a = cat "$CONFORM_DIR/$CONFORM_STEM.out" 2>/dev/null; s=$(cat "$CONFORM_DIR/$CONFORM_STEM.exit" 2>/dev/null || echo 0); [ "$s" = segv ] && kill -SEGV $$; [ "$s" = hang ] && sleep 30; exit $s
run.verilog = cat "$CONFORM_DIR/$CONFORM_STEM.out" 2>/dev/null; exit $(cat "$CONFORM_DIR/$CONFORM_STEM.exit" 2>/dev/null || echo 0)
EOF
printf 'compile.verilog-a = exit 0\n' > "$T/compile-only.conf"

# case <dir> <name> <directives> <stdout> <exit>
case_() {
    printf '%b\nmodule %s; endmodule\n' "$3" "$2" > "$T/s/$1/$2.va"
    printf '%b' "$4" > "$T/s/$1/$2.out"
    echo "$5" > "$T/s/$1/$2.exit"
}
case_ verilog-a pass '//! bias V(p) = 1\n`CHECK("x", 1, 1, 0);' 'x ok=1\n' 0
case_ verilog-a wrong_want '//! bias V(p) = 1' 'x ok=1\ny ok=0\n' 0
case_ verilog-a checks_off_by_one '//! checks 2' 'x ok=1\n' 0
case_ verilog-a no_assertion_ran '//! lrm 4.1\n`CHECK("x", 1, 1, 0);' '' 0
case_ verilog-a run_failed '//! bias V(p) = 1' '' 1
case_ verilog-a reject_ok '//! reject E0001' '' 1
case_ verilog-a reject_accepted '//! reject E0001' '' 0
case_ verilog-a reject_crash '//! reject E0001' '' segv
case_ verilog-a reject_run_ok '//! reject-run out of range' '' 1
case_ verilog-a exit_code '//! exit 3' '' 3
case_ verilog-a stdout_line '//! stdout t=20 reached' 'p: t=20 reached\n' 0
case_ verilog-a timeout '//! bias V(p) = 1' '' hang
case_ verilog-a xfail '//! bias V(p) = 1' 'ok=0\n' 0
case_ verilog-a xpass '//! bias V(p) = 1' 'ok=1\n' 0
case_ verilog-a tool_cannot '//! bias V(p) = 1' '' 77
case_ spice no_command '//! bias V(p) = 1' '' 0
printf 'module g; endmodule\n' > "$T/s/verilog/golden.v"
printf 'hi\n' > "$T/s/verilog/golden.expected.txt"
printf 'hi\n' > "$T/s/verilog/golden.out"
printf 'module h; endmodule\n' > "$T/s/verilog/golden_diff.v"
printf 'hi\n' > "$T/s/verilog/golden_diff.expected.txt"
printf 'ho\n' > "$T/s/verilog/golden_diff.out"
printf 'module support; endmodule\n' > "$T/s/verilog/support_only.v"
# An upstream-style suite driven by a manifest: its own gold, its own filter.
mkdir -p "$T/up/t" "$T/up/gold"
printf 'module a; endmodule\n' > "$T/up/t/a.v"
cp "$T/up/t/a.v" "$T/up/t/b.v"; cp "$T/up/t/a.v" "$T/up/t/c.v"; cp "$T/up/t/a.v" "$T/up/t/d.v"
printf 'banner 1.0\nvalue 3\n' > "$T/up/t/a.out"; printf 'banner 2.0\nvalue 3\n' > "$T/up/gold/a.gold"
printf 'value 4\n' > "$T/up/t/b.out"; printf 'value 3\n' > "$T/up/gold/b.gold"
printf 'all\n PASSED\n' > "$T/up/t/c.out"
printf 'FAILED\n' > "$T/up/t/d.out"
cat > "$T/s/up.manifest" <<'EOF2'
#root ../up
verilog	ok	t/a.v	gold/a.gold	FILTER=grep -v banner
verilog	ok	t/b.v	gold/b.gold	FILTER=grep -v banner
verilog	passed	t/c.v
verilog	passed	t/d.v
EOF2
printf 'verilog-a/xfail.va  # a known bug\nverilog-a/xpass.va\n' > "$T/xfail"

"$CONFORM" -t "$T/tool.conf" -x "$T/xfail" -T 2 -j 4 -o "$T/got.tsv" "$T/s" > /dev/null && exit_status=0 || exit_status=$?
"$CONFORM" -t "$T/compile-only.conf" -o "$T/compile.tsv" "$T/s/verilog-a/pass.va" "$T/s/verilog-a/reject_ok.va" > /dev/null || true

cut -f1,2 "$T/got.tsv" "$T/compile.tsv" | cat | sort > "$T/got"
sort > "$T/want" <<'EOF'
PASS	verilog-a/pass.va
FAIL	verilog-a/wrong_want.va
FAIL	verilog-a/checks_off_by_one.va
FAIL	verilog-a/no_assertion_ran.va
FAIL	verilog-a/run_failed.va
PASS	verilog-a/reject_ok.va
FAIL	verilog-a/reject_accepted.va
FAIL	verilog-a/reject_crash.va
PASS	verilog-a/reject_run_ok.va
PASS	verilog-a/exit_code.va
PASS	verilog-a/stdout_line.va
FAIL	verilog-a/timeout.va
XFAIL	verilog-a/xfail.va
XPASS	verilog-a/xpass.va
SKIP	verilog-a/tool_cannot.va
SKIP	spice/no_command.va
PASS	verilog/golden.v
FAIL	verilog/golden_diff.v
PASS	up/t/a.v
FAIL	up/t/b.v
PASS	up/t/c.v
FAIL	up/t/d.v
PASS	verilog-a/pass.va
FAIL	verilog-a/reject_ok.va
EOF
diff "$T/want" "$T/got"
[ "$exit_status" = 1 ] || { echo "conform exited $exit_status, want 1"; exit 1; }
grep -q 'compile-only' "$T/compile.tsv" || { echo "compile-only pass not labelled"; exit 1; }
echo "selftest: ok"
