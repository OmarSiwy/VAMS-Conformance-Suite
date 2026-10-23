# Required inherited PLI host probes

These files are not ordinary digital-runner tests. Each C application must be
linked/loaded into the actual simulator before elaboration, register through
the production startup mechanism, and execute its paired HDL. Compare the
complete HDL transcript with `.expected.txt`, require the final callback's
`.expected.stderr.txt` marker, and require successful process exit. The marker
is mandatory: matching values alone cannot prove both callbacks executed.
Do not substitute a mock implementation, call the callbacks manually,
or interpret registration/header compilation as execution evidence.

`audit_builtin_override` targets IEEE1364-2005 20.4, with callback mechanics
from26.1.1–26.1.4/27.34. The override's fixed40-bit return is independent of
the two argument widths. Both values are derived in the HDL header. C asserts
user_data preservation, build-before-runtime phases, one sizetf invocation,
per-source-call compiletf invocation, per-execution calltf and call/argument
widths. Different argument values distinguish the original built-in behavior.

Current disposition: runs in `build.zig`'s `vpi_runs` under `zig build test`,
its HDL transcript and stderr marker pinned.

`audit_end_compile_objects` is a separate plugin/deck. Startup performs only
the registration permitted by IEEE26.2.4; traversal and numeric/string type
queries run at cbEndOfCompile, where full API access becomes available. Require
exit0, empty HDL stdout and its mandatory `.expected.stderr.txt` marker. This
does not demand a particular diagnostic for forbidden early API calls. It is
also blocked by the missing production callback declarations/host integration.

`audit_module_array` separately tests IEEE26.6.1/26.6.2: array object versus
member object types, membership cardinality, reverse relationship, expression
index, direct indexed access and a successful absent index on the nonarray
top. Member iteration order is deliberately unconstrained. Require exit0,
empty HDL stdout and its `.expected.stderr.txt` marker. Header syntax checking
currently fails before linking; this is not executed object-graph coverage.

`audit_array_object_kinds` tests IEEE26.6.7–26.6.9 at end compile: legacy
memory/word methods return reg-array/reg types, word size counts bits, array
size counts members, and a real variable array exposes var-select objects.
It reads declaration/index expressions only, never uninitialized HDL values.
Require exit0, empty HDL stdout and its mandatory stderr marker. As with the
other probes, missing production APIs block compilation/execution today.
# Lazy argument evaluation

`argument_handle_delays_evaluation.c` + `.v` is the required-positive IEEE26.6.19(e)
application. Load before elaboration; compare HDL stdout to its
`.expected.txt`, stderr to `.expected.stderr.txt`, and require exit0.
The first unread side-effect function argument must not execute; the second
is evaluated when the plugin requests its value. It runs in `vpi_runs`;
`b_26_6_19_lazy_arguments` additionally checks repeated reads, a retained
handle's lexical scope, real and wide returns, nested user function calls,
and refusal of a NULL value pointer without evaluating the argument.

## Routine probes and compile-only visibility

The audit_vpi_value_formats, audit_vpi_event_handles and
audit_vpi_invalid_time_callback applications require the same real lifecycle
host. Their expected stdout markers must match exactly, with successful exit;
none is a standalone HDL conformance test. The event probe uses current zero,
predecessor one and replacement two to avoid requiring a handle for an
equal-current-value event. Cancelling the replacement must leave zero.

VerA's `zig build suite -- vpi` compiles these C clients only. A compile
pass does not assert the paired HDL, callback markers, event timing or runtime
results. Missing API compilation is a failure, never an expected rejection.
