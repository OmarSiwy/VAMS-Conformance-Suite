// IEEE 1364-2005 §14.3, p. 222: "In module path delay assignments, a module
// path description (see 14.2) is specified on the left-hand side, and one or
// more delay values are specified on the right-hand side. The delay values may
// be optionally enclosed in a pair of parentheses. There may be one, two,
// three, six, or twelve delay values assigned to a module path, as described
// in 14.3.1. The delay values shall be constant expressions containing
// literals or specparams, and there may be a delay expression of the form
// min:typ:max."
// §14.3.1, pp. 222-223: "Each path delay expression may be a single
// value—representing the typical delay—or a colon-separated list of three
// values" ... "Table 14-2 describes how different path delay values shall be
// associated with various transitions." Its example's single-value forms,
// one per column of Table 14-2:
//   (C => Q) = 20;
//   specparam tPLH1 = 12, tPHL1 = 25;
//   (C => Q) = ( tPLH1, tPHL1 ) ;
//   specparam tPLH1 = 12, tPHL1 = 22, tPz1 = 34;
//   (C => Q) = (tPLH1, tPHL1, tPz1);
//   specparam t01 = 12, t10 = 16, t0z = 13,
//               tz1 = 10, t1z = 14, tz0 = 34 ;
//   (C => Q) = ( t01, t10, t0z, tz1, t1z, tz0) ;
//   specparam t01=10, t10=12, t0z=14, tz1=15, t1z=29, tz0=36,
//               t0x=14, tx1=15, t1x=15, tx0=14, txz=20, tzx=30 ;
//   (C => Q) = (t01, t10, t0z, tz1, t1z, tz0,
//                 t0x, tx1, t1x, tx0, txz, tzx) ;
// The min:typ:max forms of the same example are
// mintypmax_path_delays.v.
//
// The example's alternatives are for one path and reuse specparam names with
// new values, so each alternative here drives its own output (Q1 for one
// value, Q2 two, Q3 three, Q6 six, Q12 twelve) and the redeclared specparams
// take new names (tPLH3, tPHL3, tPz3 for the three-value set; u01 to uzx for
// the twelve). One more output, Q2b, takes the same two values without the
// parentheses, `(C => Q2b) = tPLH1, tPHL1;`: Syntax 14-6's first arm,
// path_delay_value ::= list_of_path_delay_expressions.
//
// Logic: every output is C. Each output change takes its path's Table 14-2
// delay for the transition (x -> 1 at t = 1, Table 14-3's maximum rule);
// the longest delay is 36 (uz0), so the transcript is sampled 50 after each
// change:
//   t = 1:  C = 1: every output 1
//   t = 51: C = 0: every output 0
//! inherited IEEE 1364-2005 14.3 14.3.1 14.3.2
`timescale 1ns/1ns
module b_14_3_path_delay_values_cell(C, Q1, Q2, Q2b, Q3, Q6, Q12);
  input C;
  output Q1, Q2, Q2b, Q3, Q6, Q12;
  assign Q1 = C;
  assign Q2 = C;
  assign Q2b = C;
  assign Q3 = C;
  assign Q6 = C;
  assign Q12 = C;
  specify
    // one expression specifies all transitions
    (C => Q1) = 20;
    // two expressions specify rise and fall delays
    specparam tPLH1 = 12, tPHL1 = 25;
    (C => Q2) = ( tPLH1, tPHL1 ) ;
    (C => Q2b) = tPLH1, tPHL1;
    // three expressions specify rise, fall, and z transition delays
    specparam tPLH3 = 12, tPHL3 = 22, tPz3 = 34;
    (C => Q3) = (tPLH3, tPHL3, tPz3);
    // six expressions specify transitions to/from 0, 1, and z
    specparam t01 = 12, t10 = 16, t0z = 13,
              tz1 = 10, t1z = 14, tz0 = 34 ;
    (C => Q6) = ( t01, t10, t0z, tz1, t1z, tz0) ;
    // twelve expressions specify all transition delays explicitly
    specparam u01=10, u10=12, u0z=14, uz1=15, u1z=29, uz0=36,
              u0x=14, ux1=15, u1x=15, ux0=14, uxz=20, uzx=30 ;
    (C => Q12) = (u01, u10, u0z, uz1, u1z, uz0,
                  u0x, ux1, u1x, ux0, uxz, uzx) ;
  endspecify
endmodule

module b_14_3_path_delay_values;
  reg C;
  wire Q1, Q2, Q2b, Q3, Q6, Q12;
  b_14_3_path_delay_values_cell u(C, Q1, Q2, Q2b, Q3, Q6, Q12);
  initial begin
    #1 C = 1;
    #50 $display("t=51 %b%b%b%b%b%b", Q1, Q2, Q2b, Q3, Q6, Q12);
    C = 0;
    #50 $display("t=101 %b%b%b%b%b%b", Q1, Q2, Q2b, Q3, Q6, Q12);
  end
endmodule
