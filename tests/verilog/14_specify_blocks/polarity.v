// IEEE 1364-2005 §14.2.7, p. 220: "The polarity of a module path is an
// arbitrary specification indicating whether the direction of a signal
// transition is inverted as it propagates from the input to the output. This
// arbitrary polarity description does not affect the actual propagation of
// data or events through the model" ... "Module paths may specify any of
// three polarities: — Unknown polarity — Positive polarity — Negative
// polarity"
// §14.2.7.1, p. 221: "A module path specified either as a full connection or
// as a parallel connection, but without a polarity operator + or -, shall be
// treated as a module path with unknown polarity." Example:
//   (In1 => q) = In_to_q ;
//   (s   *> q) = s_to_q ;
// §14.2.7.2, p. 221: "A module path with positive polarity shall be specified
// by prefixing the + polarity operator to => or *>." Example:
//   (In1 +=> q) = In_to_q ;
//   (s   +*> q) = s_to_q ;
// §14.2.7.3, p. 221: "A module path with negative polarity shall be specified
// by prefixing the - polarity operator to => or *>." Example:
//   (In1 -=> q) = In_to_q ;
//   (s   -*> q) = s_to_q ;
//
// The three examples, each on an output of its own (q, qp, qn) so no path is
// declared twice, with the specparams In_to_q = 3 and s_to_q = 4. Each
// output's logic is one the polarity describes: q = In1 ^ s (a rise at a
// source may raise or lower q: unknown), qp = In1 | s (a source's rise never
// lowers it: positive), qn = ~(In1 & s) (a source's rise never raises it:
// negative). The polarity is not applied to anything (the clause: it "does
// not affect the actual propagation"); each output change takes its paths'
// delay (§14.3.3), and the transcript is sampled 50 after each change, past
// the longest delay (4):
//   t = 1:   In1 = 0, s = 1: q = 1, qp = 1, qn = ~0 = 1
//   t = 51:  In1 = 1:        q = 0, qp = 1, qn = ~1 = 0
//   t = 101: s = 0:          q = 1, qp = 1, qn = 1
//! inherited IEEE 1364-2005 14.2.7 14.2.7.1 14.2.7.2 14.2.7.3
`timescale 1ns/1ns
module b_14_2_7_polarity_cell(In1, s, q, qp, qn);
  input In1, s;
  output q, qp, qn;
  assign q = In1 ^ s;
  assign qp = In1 | s;
  assign qn = ~(In1 & s);
  specify
    specparam In_to_q = 3, s_to_q = 4;
    // Unknown polarity
    (In1 => q) = In_to_q ;
    (s   *> q) = s_to_q ;
    // Positive polarity
    (In1 +=> qp) = In_to_q ;
    (s   +*> qp) = s_to_q ;
    // Negative polarity
    (In1 -=> qn) = In_to_q ;
    (s   -*> qn) = s_to_q ;
  endspecify
endmodule

module b_14_2_7_polarity;
  reg In1, s;
  wire q, qp, qn;
  b_14_2_7_polarity_cell u(In1, s, q, qp, qn);
  initial begin
    #1 In1 = 0; s = 1;
    #50 $display("t=51 q=%b qp=%b qn=%b", q, qp, qn);
    In1 = 1;
    #50 $display("t=101 q=%b qp=%b qn=%b", q, qp, qn);
    s = 0;
    #50 $display("t=151 q=%b qp=%b qn=%b", q, qp, qn);
  end
endmodule
