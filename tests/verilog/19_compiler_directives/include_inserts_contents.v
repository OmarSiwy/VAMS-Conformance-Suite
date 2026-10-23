// IEEE 1364-2005 §19.5, p. 356: "The file inclusion (`include) compiler
// directive is used to insert the entire contents of a source file in another
// file during compilation. The result is as though the contents of the
// included source file appear in place of the `include compiler directive."
// ... "The compiler directive `include can be specified anywhere within the
// Verilog HDL description." ... "Only white space or a comment may appear on
// the same line as the `include compiler directive." §19, p. 349: "The scope
// of a compiler directive extends from the point where it is processed,
// across all files processed".
//
// The file: `vera --run` is given no include directory, and VerA resolves a
// relative file name only through its -I directories and, by base name, its
// built-in Verilog-AMS annex D headers. So the file included is annex D.2's
// constants.vams, whose whole body is
//   `ifdef CONSTANTS_VAMS `else `define CONSTANTS_VAMS 1 ... `define M_PI
//   3.14159265358979323846 ... `define M_E 2.7182818284590452354 ... `endif
// (--run prepends no annex D prelude, so nothing defines these before the
// `include.)
// Before the `include, `ifdef M_PI takes its `else arm: before = 0.
// The `include line carries a trailing // comment, which is allowed.
// After it, the contents' `defines are in effect in this file: M_PI with %f
//   (6 decimals) -> 3.141593, M_E -> 2.718282, and CONSTANTS_VAMS -> 1.
// A second `include of the same file inside the begin-end block ("anywhere")
//   reads CONSTANTS_VAMS as defined and so inserts nothing but directives:
//   the block still holds only its $display statements.
//! inherited IEEE 1364-2005 19 19.5
`ifdef M_PI
`define BEFORE 1
`else
`define BEFORE 0
`endif
`include "constants.vams" // annex D.2
module b_19_5_include_inserts_contents;
  initial begin
    $display("before=%0d", `BEFORE);
    `include "constants.vams"
    $display("%f %f %0d", `M_PI, `M_E, `CONSTANTS_VAMS);
    $finish(0);
  end
endmodule
