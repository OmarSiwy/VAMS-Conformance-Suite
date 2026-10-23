// IEEE 1364-2005 §19.11, p. 361: "A pair of directives, `begin_keywords and
// `end_keywords, can be used to specify what identifiers are reserved as
// keywords within a block of source code, based on a specific version of IEEE
// Std 1364." ... "The `begin_keywords...`end_keywords directive pair can be
// nested. Each nested pair is stacked so that when an `end_keywords directive
// is encountered, the implementation returns to using the version_ specifier
// that was in effect prior to the matching `begin_keywords directive."
// p. 362: "The version_specifier "1364-1995" specifies that only the
// identifiers listed as reserved keywords in IEEE Std 1364-1995 are
// considered to be reserved words." p. 364: "The source code within the
// module uses the identifier uwire as a net name. The `begin_keywords
// directive would be necessary in this example if an implementation uses IEEE
// Std 1364-2005 as its default set of keywords because uwire is a reserved
// keyword in this standard."
//
// generate, localparam, signed and uwire are not in Table 19-2 (1364-1995),
// so under "1364-1995" they are ordinary identifiers: b_19_11_m95 declares
// regs by those names; generate = 1, localparam = 0, signed = 1, uwire = 1
//   -> "95 1011" at time 1.
// Nested "1364-2005" around b_19_11_m05 (which names none of them), then its
//   `end_keywords returns to "1364-1995": b_19_11_m95b again declares a reg
//   generate = 0 -> "95b 0" at time 2.
// "1364-2001" (Table 19-3 has no uwire): the clause's m2, wire [63:0] uwire,
//   assigned 64'd5 -> "01 5" at time 3.
//! inherited IEEE 1364-2005 19.11
`timescale 1ns/1ns
`begin_keywords "1364-1995"
module b_19_11_m95;
  reg generate, localparam, signed, uwire;
  initial begin
    generate = 1; localparam = 0; signed = 1; uwire = 1;
    #1 $display("95 %b%b%b%b", generate, localparam, signed, uwire);
  end
endmodule
`begin_keywords "1364-2005"
module b_19_11_m05;
  initial #4 $finish(0);
endmodule
`end_keywords
module b_19_11_m95b;
  reg generate;
  initial begin
    generate = 0;
    #2 $display("95b %b", generate);
  end
endmodule
`end_keywords
`begin_keywords "1364-2001"
module b_19_11_m2;
  wire [63:0] uwire;
  assign uwire = 64'd5;
  initial #3 $display("01 %0d", uwire);
endmodule
`end_keywords
module b_19_11_keyword_versions;
  b_19_11_m95 a();
  b_19_11_m05 b();
  b_19_11_m95b c();
  b_19_11_m2 d();
endmodule
