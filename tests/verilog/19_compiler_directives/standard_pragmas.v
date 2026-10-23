// IEEE 1364-2005 §19.10.1, p. 361: "The reset and resetall pragmas shall
// restore the default values and state of pragma_keywords associated with the
// affected pragmas. These default values shall be the values that the tool
// defines before any Verilog text has been processed. The reset pragma shall
// reset the state for all pragma_names that appear as pragma_keywords in the
// directive. The resetall pragma shall reset the state of all pragma_names
// recognized by the implementation."
// §19.10, p. 360: "Unless otherwise specified, pragma directives for
// pragma_names that are not recognized by an implementation shall have no
// effect on interpretation of the Verilog source text."
//
// VerA recognizes no pragma_name that has state (its one recognized name,
// §28's protect, is refused: 28_protected_envelopes/). So resetall, and reset
// of two unrecognized names, restore every pragma to the state it was in
// before any text was read, which is the state it is in: the module compiles
// and computes as it would without them. q = 3 at time 0 -> "q=3".
//! inherited IEEE 1364-2005 19.10.1
`pragma resetall
`pragma reset vera_unrecognized, another_unrecognized
module b_19_10_1_standard_pragmas;
  integer q;
  initial begin
    q = 3;
    $display("q=%0d", q);
    $finish(0);
  end
endmodule
`pragma resetall
