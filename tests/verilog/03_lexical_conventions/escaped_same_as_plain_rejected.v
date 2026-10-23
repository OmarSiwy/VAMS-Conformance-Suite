// IEEE 1364-2005 §3.7.1, p. 14: "Neither the leading backslash character nor
// the terminating white space is considered to be part of the identifier.
// Therefore, an escaped identifier \cpu3 is treated the same as a nonescaped
// identifier cpu3." With §4.2.1, p. 21: "It is illegal to redeclare a name
// already declared by a net, parameter, or variable declaration (see 4.11)."
//
// reg cpu3 and reg \cpu3 declare the same name twice. Legal neighbour:
// ams_lexical_escaped_terminators.v, which declares \space_end and
// assigns it as space_end.
//! inherited IEEE 1364-2005 3.7.1
//! reject E1100
//! reject duplicate digital variable
//! neighbour ams_lexical_escaped_terminators.v
module b_3_7_1_escaped_same_as_plain_rejected;
  reg cpu3;
  reg \cpu3 ;
  initial begin
    cpu3 = 1;
    $display("%b", \cpu3 );
  end
endmodule
