// IEEE 1364-2005 §14.3, p. 222: "The delay values shall be constant
// expressions containing literals or specparams, and there may be a delay
// expression of the form min:typ:max." Its example:
//   specparam tRise_clk_q = 45:150:270, tFall_clk_q=60:200:350;
//   specparam tRise_Control = 35:40:45, tFall_control=40:50:65;
//   (clk => q) = (tRise_clk_q, tFall_clk_q);
//   (clr, pre *> q) = (tRise_control, tFall_control);
// §14.3.1, p. 222: "Each path delay expression may be a single
// value—representing the typical delay—or a colon-separated list of three
// values—representing a minimum, typical, and maximum delay, in that order."
// Its example's min:typ:max forms (p. 223):
//   (C => Q) = 10:14:20;
//   specparam tPLH2 = 12:16:22, tPHL2 = 16:22:25;
//   (C => Q) = ( tPLH2, tPHL2 ) ;
//   specparam tPLH2 = 12:14:30, tPHL2 = 16:22:40, tPz2 = 22:30:34;
//   (C => Q) = (tPLH2, tPHL2, tPz2);
//   specparam T01 = 12:14:24, T10 = 16:18:20, T0z = 13:16:30 ;
//   specparam Tz1 = 10:12:16, T1z = 14:23:36, Tz0 = 15:19:34 ;
//   (C => Q) = ( T01, T10, T0z, Tz1, T1z, Tz0) ;
// The single-value forms are path_delay_values.v.
//
// Two corrections make the examples one legal module. §14.3's example
// declares tRise_Control and reads tRise_control, and §3.7 (p. 14) says
// "Identifiers shall be case sensitive", so the declaration here is spelled
// tRise_control. §14.3.1's alternatives are for one path and redeclare
// tPLH2 and tPHL2, so each drives its own output (Q1, Q2, Q3, Q6) and the
// three-value set is named tPLH3, tPHL3, tPz3.
//
// Logic: q = (clk | pre) & ~clr; every Qk = C. Each output change takes its
// paths' delay (§14.3.3); the longest any min:typ:max selection gives is 350
// (tFall_clk_q's max), so the transcript is sampled 1000 after each change,
// where every selection agrees:
//   t = 1:    clk=1 clr=0 pre=0 C=1: q = (1|0) & ~0 = 1; Q1 Q2 Q3 Q6 = 1111,
//             printed at t = 1001
//   t = 1001: clr=1 C=0:             q = 1 & ~1 = 0;     Q1 Q2 Q3 Q6 = 0000,
//             printed at t = 2001
//! inherited IEEE 1364-2005 14.3 14.3.1
`timescale 1ns/1ns
module b_14_3_1_mintypmax_path_delays_cell(clk, clr, pre, q, C, Q1, Q2, Q3, Q6);
  input clk, clr, pre, C;
  output q, Q1, Q2, Q3, Q6;
  assign q = (clk | pre) & ~clr;
  assign Q1 = C;
  assign Q2 = C;
  assign Q3 = C;
  assign Q6 = C;
  specify
    // Specify Parameters
    specparam tRise_clk_q = 45:150:270, tFall_clk_q=60:200:350;
    specparam tRise_control = 35:40:45, tFall_control=40:50:65;
    // Module Path Assignments
    (clk => q) = (tRise_clk_q, tFall_clk_q);
    (clr, pre *> q) = (tRise_control, tFall_control);

    (C => Q1) = 10:14:20;
    specparam tPLH2 = 12:16:22, tPHL2 = 16:22:25;
    (C => Q2) = ( tPLH2, tPHL2 ) ;
    specparam tPLH3 = 12:14:30, tPHL3 = 16:22:40, tPz3 = 22:30:34;
    (C => Q3) = (tPLH3, tPHL3, tPz3);
    specparam T01 = 12:14:24, T10 = 16:18:20, T0z = 13:16:30 ;
    specparam Tz1 = 10:12:16, T1z = 14:23:36, Tz0 = 15:19:34 ;
    (C => Q6) = ( T01, T10, T0z, Tz1, T1z, Tz0) ;
  endspecify
endmodule

module b_14_3_1_mintypmax_path_delays;
  reg clk, clr, pre, C;
  wire q, Q1, Q2, Q3, Q6;
  b_14_3_1_mintypmax_path_delays_cell u(clk, clr, pre, q, C, Q1, Q2, Q3, Q6);
  initial begin
    #1 clk = 1; clr = 0; pre = 0; C = 1;
    #1000 $display("t=1001 q=%b Q=%b%b%b%b", q, Q1, Q2, Q3, Q6);
    clr = 1; C = 0;
    #1000 $display("t=2001 q=%b Q=%b%b%b%b", q, Q1, Q2, Q3, Q6);
  end
endmodule
