// IEEE 1364-2005 §19.10: "Unless otherwise specified, pragma directives for
// pragma_names that are not recognized by an implementation shall have no
// effect on interpretation of the Verilog source text."
//
// VerA recognizes no pragma_name but §28's protect (refused, E0146: the
// neighbours in 28_protected_envelopes/). Each directive below uses one arm
// of Syntax 19-9's pragma_expression (a bare keyword, keyword = value, a
// parenthesized list, a number, a string). With no effect, the module is the
// same as one without them: q takes 1 at t = 1 and prints it.
//! inherited IEEE 1364-2005 19.10
//! expect stdout pragma_unrecognized_no_effect.expected.txt
module pragma_unrecognized_no_effect;
  reg q;
`pragma vera_unrecognized
`pragma vera_unrecognized level = 3, (a, b = "s"), 42, "text"
  initial begin
    q = 1'b0;
    #1 q = 1'b1;
    $display("q=%b", q);
  end
endmodule
