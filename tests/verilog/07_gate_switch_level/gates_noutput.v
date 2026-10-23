// D08 — n-output gate primitives: buf and not.
//
// Verilog-AMS 2.4 Annex A.3.4:
//     n_output_gatetype ::= buf | not
// Annex A.3.1:
//     n_output_gatetype [drive_strength] [delay2] n_output_gate_instance
//         { , n_output_gate_instance } ;
//     n_output_gate_instance ::= [ name_of_gate_instance ]
//         ( output_terminal { , output_terminal } , input_terminal )
// §7.8.5.1: "For N-output gates (buf, not) The input will be named in, and the
// outputs reading from left to right will be named out1, out2, out3, and so
// forth." §1.1 makes IEEE Std 1364-2005 clause 7 the normative value tables.
//
// WHY THIS FIXTURE EXISTS SEPARATELY FROM THE n-INPUT ONE. buf/not are the only
// primitives whose terminal list runs the other way: EVERY terminal is an
// output except the LAST one, which is the single input. A compiler that reuses
// the n-input shape (first terminal is the output) gets `buf b1 (o1,o2,o3,in)`
// exactly backwards — it would drive o2, o3 and `in` from the undriven net o1,
// leaving o1 at z. So the first column of this transcript is the whole test of
// the terminal-order rule: if o1 reads z, the direction was inferred wrongly.
//
// HAND DERIVATION. buf is the identity on logic values, not is the complement,
// and both COERCE a z input to x, because a gate delivers a logic value and has
// no way to transmit high impedance (contrast switch_mos.v). Every output
// terminal of one instance gets the same value.
//
//     in :  0      1      x      z
//     buf:  0      1      x      x
//     not:  1      0      x      x
//
// Three buf outputs therefore read 000 / 111 / xxx / xxx and two not outputs
// read 11 / 00 / xx / xx.
//
//! lrm A.3.1
//! lrm A.3.4
//! lrm 1.1
//! lrm 7.8.5.1
//! lrm A.3.1:1000
//! lrm A.3.4:1000
//! inherited IEEE 1364-2005 7.3
`timescale 1ns/1ns
module d08_gates_noutput;
  reg in;
  wire o1, o2, o3;
  wire q1, q2;

  buf b1 (o1, o2, o3, in);
  not n1 (q1, q2, in);

  initial begin
    in = 1'b0; #1
      $display("in=0 got buf=%b%b%b not=%b%b want buf=000 not=11", o1, o2, o3, q1, q2);
    in = 1'b1; #1
      $display("in=1 got buf=%b%b%b not=%b%b want buf=111 not=00", o1, o2, o3, q1, q2);
    in = 1'bx; #1
      $display("in=x got buf=%b%b%b not=%b%b want buf=xxx not=xx", o1, o2, o3, q1, q2);
    in = 1'bz; #1
      $display("in=z got buf=%b%b%b not=%b%b want buf=xxx not=xx", o1, o2, o3, q1, q2);
  end
endmodule
