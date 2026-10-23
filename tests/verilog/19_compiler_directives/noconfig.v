// IEEE 1364-2005 §19.11, p. 361, Syntax 19-10: version_specifier ::=
// 1364-1995 | 1364-2001 | 1364-2001-noconfig | 1364-2005. p. 363: "The
// version_specifier "1364-2001-noconfig" behaves similarly to the "1364-2001"
// version_specifier, with the exception that the following identifiers are
// excluded from the reserved list in Table 19-3: cell config design endconfig
// incdir include instance liblist library use Because these identifiers are
// not reserved when using the "1364-2001-noconfig" version_specifier, they
// may be used as normal Verilog identifiers within the corresponding
// `begin_keywords...`end_ keywords region."
//
// config, cell and design as reg names under "1364-2001-noconfig":
// config = 1, cell = 1, design = 0 -> "110".
//! inherited IEEE 1364-2005 19.11
`begin_keywords "1364-2001-noconfig"
module b_19_11_noconfig;
  reg config, cell, design;
  initial begin
    config = 1; cell = 1; design = 0;
    $display("%b%b%b", config, cell, design);
    $finish(0);
  end
endmodule
`end_keywords
