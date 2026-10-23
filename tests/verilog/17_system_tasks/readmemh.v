// §9.5 Table 9-2 gives $readmemb and $readmemh "Supported in digital context:
// Yes / Supported in analog context: No". They are in lib/ir/lower.zig:6822's
// `isDigitalOnlySysFunc` refusal list and nowhere else as a digital behavior;
// lib/backend/file_kernels.zig mentions the names only in the analog file-I/O
// machinery. The conformance plan files the inherited definition as its 17.2.9
// row and notes it "Requires memories from D03" — the runner does have
// one-dimensional unpacked arrays (docs/digital-source-execution.md), so the
// memory itself is available and this row is about the LOADER.
//
// The inherited §17.2.9 rules this file pins:
//   - the file holds white space, comments and hexadecimal numbers (for
//     $readmemh);
//   - loading starts at the LOWEST index of the memory's declared address range
//     when no start address is given;
//   - an `@` followed by a hexadecimal address RELOCATES the load point, and
//     loading continues upward from there;
//   - addresses the file never mentions are LEFT ALONE — the task loads, it
//     does not clear.
//
// HAND DERIVATION with `reg [7:0] m [0:7]` and 08_readmemh.hex:
//
//     // a one-line comment, ignored ...
//     1a 2b
//     @4
//     c3
//     /* a block comment */ d4
//
//   declared range is [0:7], lowest index 0, so the load point starts at 0.
//     m[0] <- 8'h1a
//     m[1] <- 8'h2b
//   `@4` sets the load point to address 4 (hexadecimal 4 = 4).
//     m[4] <- 8'hc3
//     m[5] <- 8'hd4
//   m[2], m[3], m[6] and m[7] were never written and every variable in this
//   runner begins at X (docs/digital-source-execution.md: "Variable state
//   begins at X"), so each reads back as 8 unknown bits, which %h renders as
//   "xx" by the whole-group collapse pinned in 02_display_unknown_radix.v.
//
//   Printed in address order 0..7:
//       1a 2b xx xx c3 d4 xx xx
//
// The two comment forms and the interleaving of `@4` between data words are
// the reason the file is not simply four numbers: a loader that treats the
// comment text as data lands `a` (from "a one-line comment") in m[0]; a loader
// that ignores `@` fills m[0..3] and leaves m[4..7] unknown; a loader that
// clears the memory first turns the four `xx` fields into `00`. Each of those
// three mistakes changes a different column of the single expected line.
//
// The hexadecimal values were chosen so that every one of them contains a
// letter (1a, 2b, c3, d4): a loader that parses the file as DECIMAL cannot
// silently agree.
//
// The data file is resolved relative to the process working directory, so the
// runner must be invoked from this directory (see tests/fixtures/ch09_system_tasks/d09_SPEC.md at 8b1514d4).
//
//! lrm 9.5 (Table 9-2)
//! inherited IEEE 1364-2005 17.2.9 ($readmemh addressing and comments)
//! data 08_readmemh.hex
//! expect stdout 08_readmemh.expected.txt
`timescale 1ns/1ns
module d09_readmemh;
  reg [7:0] m [0:7];
  initial begin
    $readmemh("08_readmemh.hex", m);
    $display("%h %h %h %h %h %h %h %h",
             m[0], m[1], m[2], m[3], m[4], m[5], m[6], m[7]);
    $finish(0);
  end
endmodule
