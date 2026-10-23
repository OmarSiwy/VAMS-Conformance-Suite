// Four-state operands under the Table 9-22 radix conversions (§9.4.3), which
// is the half of the 17.1 row the ANALOG printer cannot express at all: a
// Verilog-A operand is a real or an integer and has no x/z state, so
// lib/backend/cg_display.zig formats through Zig's `{x}`/`{b}` on a u64 bit
// pattern. A digital `reg` has four states and the radix conversions have to
// collapse whole GROUPS of bits.
//
// The governing rule is inherited IEEE 1364-2005 §17.1.1.4, "Unknown and
// high-impedance display" — NOT §17.1.1.2 ("Format specifications"), which is
// what this header cited until the review; specification/CLAUSE-AUDIT.md:276 is the
// repo's own mapping (17.1-06 = "17.1.1.4 unknown / high-impedance display").
// The sentence, filed by the conformance plan under its 17.1 row: within a
// hexadecimal or octal
// conversion, a group of bits that is ENTIRELY x prints as a single lowercase
// `x` and a group that is entirely z prints as a single lowercase `z`, while a
// group holding a mixture of known and unknown bits prints as the UPPERCASE
// `X` or `Z`. %b has no grouping, so it prints one character per bit and is
// the control: it shows exactly which bits the collapse was applied to.
//
// HAND DERIVATION, operand `reg [7:0] v`:
//
//   v = 8'b1010_xxxx   (b7..b0 = 1,0,1,0,x,x,x,x)
//     %b -> "1010xxxx"
//     %h -> nibble {b7..b4} = 1010 -> 'a'
//           nibble {b3..b0} = xxxx -> all unknown -> 'x'
//           => "ax"
//     %o -> group {b2,b1,b0} = x,x,x  -> all unknown        -> 'x'
//           group {b5,b4,b3} = 1,0,x  -> MIXED              -> 'X'
//           group {b7,b6}    = 1,0    -> 10 binary          -> '2'
//           => "2Xx"
//
//   v = 8'bzzzz_0011   (b7..b0 = z,z,z,z,0,0,1,1)
//     %b -> "zzzz0011"
//     %h -> nibble {b7..b4} = zzzz -> 'z'
//           nibble {b3..b0} = 0011 -> '3'
//           => "z3"
//     %o -> group {b2,b1,b0} = 0,1,1 -> 3
//           group {b5,b4,b3} = z,z,0 -> MIXED -> 'Z'
//           group {b7,b6}    = z,z   -> all z -> 'z'
//           => "zZ3"
//
//   v = 8'bxxxx_xxxx
//     %b -> "xxxxxxxx"
//     %h -> "xx"      (both nibbles entirely unknown)
//     %o -> "xxx"     (all three groups entirely unknown)
//     %d -> "  x"     (the operand is ENTIRELY unknown, so decimal prints the
//                      single character x right-justified in the 3-column
//                      field derived in 01_display_radix.v)
//
// The two MIXED-group cases are the whole point of the file: `2Xx` and `zZ3`
// are the only renderings in which the uppercase spelling appears, and the
// octal grouping is chosen over hexadecimal for them because 8 is not a
// multiple of 3 — so the top group is a PARTIAL two-bit group, and a printer
// that groups from the MSB instead of the LSB produces `4Xx`/`ZZ3` and fails
// here. That off-by-one is the actual bug this fixture is built to catch.
//
// %d is deliberately exercised only on the all-unknown operand. The mixed
// known/unknown decimal spelling is a separate inherited sentence and is left
// to the implementation phase rather than guessed at here; see tests/fixtures/ch09_system_tasks/d09_SPEC.md at 8b1514d4.
//
//! lrm 9.4.3
//! inherited IEEE 1364-2005 17.1 (17.1.1.4 unknown / high-impedance display)
//! expect stdout 02_display_unknown_radix.expected.txt
`timescale 1ns/1ns
module d09_display_unknown_radix;
  reg [7:0] v;
  initial begin
    v = 8'b1010_xxxx;
    $display("[%b][%h][%o]", v, v, v);
    v = 8'bzzzz_0011;
    $display("[%b][%h][%o]", v, v, v);
    v = 8'bxxxx_xxxx;
    $display("[%b][%h][%o][%d]", v, v, v, v);
    $finish(0);
  end
endmodule
