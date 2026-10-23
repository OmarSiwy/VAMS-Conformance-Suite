// IEEE 1364-2005 §7.1.1, p. 76: "A gate or switch instance declaration shall
// begin with the keyword that specifies the gate or switch primitive being
// used by the instances that follow in the declaration. Table 7-1 lists the
// keywords that shall begin a gate or a switch instance declaration."
// Table 7-1 lists 26 keywords: and nand nor or xnor xor, buf not, bufif0
// bufif1 notif0 notif1, pulldown pullup, cmos nmos pmos rcmos rnmos rpmos,
// rtran rtranif0 rtranif1 tran tranif0 tranif1.
//
// One unnamed instance of each, values from Tables 7-3 to 7-6, §7.6 and §7.8.
// Each pass switch's first terminal is a net driven from a (t1a..t6a); its
// second terminal (t1b..t6b) has no other driver, so it reads a when the switch
// conducts and z when it is off.
// Row 1: a=1 b=0 c=1 n=1 p=1
//   and 0 nand 1 or 1 nor 0 xor 1 xnor 0          -> 011010
//   buf 1 not 0                                   -> 10
//   bufif0 (c=1) z, bufif1 1, notif0 z, notif1 0  -> z1z0
//   pulldown 0, pullup 1                          -> 01
//   cmos (n=1: nmos on) 1, nmos 1, pmos (p=1) z, rcmos 1, rnmos 1, rpmos z
//                                                 -> 11z11z
//   tran 1, rtran 1, tranif0 (c=1) z, tranif1 1, rtranif0 z, rtranif1 1
//                                                 -> 11z1z1
// Row 2: a=0 b=0 c=0 n=0 p=0
//   and 0 nand 1 or 0 nor 1 xor 0 xnor 1          -> 010101
//   buf 0 not 1                                   -> 01
//   bufif0 (c=0) 0, bufif1 z, notif0 1, notif1 z  -> 0z1z
//   pulldown 0, pullup 1                          -> 01
//   cmos (p=0: pmos on) 0, nmos (n=0) z, pmos 0, rcmos 0, rnmos z, rpmos 0
//                                                 -> 0z00z0
//   tran 0, rtran 0, tranif0 0, tranif1 z, rtranif0 0, rtranif1 z
//                                                 -> 000z0z
//! inherited IEEE 1364-2005 7.1.1
// native-required
`timescale 1ns/1ns
module b_7_1_1_every_primitive;
  reg a, b, c, n, p;
  wire o_and, o_nand, o_or, o_nor, o_xor, o_xnor, o_buf, o_not;
  wire o_bif0, o_bif1, o_nif0, o_nif1, o_pd, o_pu;
  wire o_cmos, o_nmos, o_pmos, o_rcmos, o_rnmos, o_rpmos;
  wire t1a, t1b, t2a, t2b, t3a, t3b, t4a, t4b, t5a, t5b, t6a, t6b;
  and (o_and, a, b);
  nand (o_nand, a, b);
  or (o_or, a, b);
  nor (o_nor, a, b);
  xor (o_xor, a, b);
  xnor (o_xnor, a, b);
  buf (o_buf, a);
  not (o_not, a);
  bufif0 (o_bif0, a, c);
  bufif1 (o_bif1, a, c);
  notif0 (o_nif0, a, c);
  notif1 (o_nif1, a, c);
  pulldown (o_pd);
  pullup (o_pu);
  cmos (o_cmos, a, n, p);
  nmos (o_nmos, a, n);
  pmos (o_pmos, a, p);
  rcmos (o_rcmos, a, n, p);
  rnmos (o_rnmos, a, n);
  rpmos (o_rpmos, a, p);
  assign t1a = a; tran (t1a, t1b);
  assign t2a = a; rtran (t2a, t2b);
  assign t3a = a; tranif0 (t3a, t3b, c);
  assign t4a = a; tranif1 (t4a, t4b, c);
  assign t5a = a; rtranif0 (t5a, t5b, c);
  assign t6a = a; rtranif1 (t6a, t6b, c);
  initial begin
    a = 1; b = 0; c = 1; n = 1; p = 1;
    #1 $display("%b%b%b%b%b%b %b%b %b%b%b%b %b%b", o_and, o_nand, o_or, o_nor, o_xor, o_xnor,
      o_buf, o_not, o_bif0, o_bif1, o_nif0, o_nif1, o_pd, o_pu);
    $display("%b%b%b%b%b%b %b%b%b%b%b%b", o_cmos, o_nmos, o_pmos, o_rcmos, o_rnmos, o_rpmos,
      t1b, t2b, t3b, t4b, t5b, t6b);
    a = 0; b = 0; c = 0; n = 0; p = 0;
    #1 $display("%b%b%b%b%b%b %b%b %b%b%b%b %b%b", o_and, o_nand, o_or, o_nor, o_xor, o_xnor,
      o_buf, o_not, o_bif0, o_bif1, o_nif0, o_nif1, o_pd, o_pu);
    $display("%b%b%b%b%b%b %b%b%b%b%b%b", o_cmos, o_nmos, o_pmos, o_rcmos, o_rnmos, o_rpmos,
      t1b, t2b, t3b, t4b, t5b, t6b);
    $finish(0);
  end
endmodule
