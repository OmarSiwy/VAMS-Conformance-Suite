// IEEE 1364-2005 A.2.1.3, p. 490:
//   event_declaration ::= event list_of_event_identifiers ;
//   integer_declaration ::= integer list_of_variable_identifiers ;
//   net_declaration ::=
//       net_type [ signed ] [ delay3 ] list_of_net_identifiers ;
//     | net_type [ drive_strength ] [ signed ] [ delay3 ] list_of_net_decl_assignments ;
//     | net_type [ vectored | scalared ] [ signed ] range [ delay3 ] list_of_net_identifiers ;
//     | net_type [ drive_strength ] [ vectored | scalared ] [ signed ] range [ delay3 ] list_of_net_decl_assignments ;
//     | trireg [ charge_strength ] [ signed ] [ delay3 ] list_of_net_identifiers ;
//     | trireg [ drive_strength ] [ signed ] [ delay3 ] list_of_net_decl_assignments ;
//     | trireg [ charge_strength ] [ vectored | scalared ] [ signed ] range [ delay3 ] list_of_net_identifiers ;
//     | trireg [ drive_strength ] [ vectored | scalared ] [ signed ] range [ delay3 ] list_of_net_decl_assignments ;
//   real_declaration ::= real list_of_real_identifiers ;
//   realtime_declaration ::= realtime list_of_real_identifiers ;
//   reg_declaration ::= reg [ signed ] [ range ] list_of_variable_identifiers ;
//   time_declaration ::= time list_of_variable_identifiers ;
//
// All eight net_declaration alternatives, one per net below (n1..n8), and
// each of the other six declarations. Values, read at t=1:
//   n1 = r (1 bit)                  -> 1
//   n2 (strong0, strong1), signed = 1'b0            -> 0
//   n3 vectored, [3:0], driven by assign n3 = 4'd6  -> 0110
//   n4 (pull0, pull1) scalared [3:0] = 4'd9         -> 1001
//   n5 trireg (medium), driven by assign n5 = r     -> 1
//   n6 trireg (strong0, strong1) = 1'b1             -> 1
//   n7 trireg (small) vectored [1:0], assign 2'b10   -> 10
//   n8 trireg (weak0, weak1) scalared [1:0] = 2'b01  -> 01
//   ev is triggered once, at t=0 after `#0`: the always block reached
//   @(ev) in the active region before the inactive #0 resumed, so c = 1.
//   i = -4, x = 0.5, rt = 1.5, t = 3, sr = 4'sb1111 printed %0d -> -1.
// Output: "1 0 0110 1001 1 1 10 01 c=1 i=-4 x=0.50 rt=1.50 t=3 sr=-1".
//! inherited IEEE 1364-2005 A.2.1.3
`timescale 1ns/1ns
module b_A_2_1_3_type_declarations;
  reg r;
  wire n1;
  wire (strong0, strong1) signed n2 = 1'b0;
  wire vectored [3:0] n3;
  wire (pull0, pull1) scalared [3:0] n4 = 4'd9;
  trireg (medium) n5;
  trireg (strong0, strong1) n6 = 1'b1;
  trireg (small) vectored [1:0] n7;
  trireg (weak0, weak1) scalared [1:0] n8 = 2'b01;
  assign n1 = r;
  assign n3 = 4'd6;
  assign n5 = r;
  assign n7 = 2'b10;
  event ev;
  integer i, c;
  real x;
  realtime rt;
  time t;
  reg signed [3:0] sr;
  always @(ev) c = c + 1;
  initial begin
    r = 1;
    c = 0;
    i = -4;
    x = 0.5;
    rt = 1.5;
    t = 3;
    sr = 4'sb1111;
    #0 -> ev;
    #1 $display("%b %b %b %b %b %b %b %b c=%0d i=%0d x=%.2f rt=%.2f t=%0d sr=%0d",
                n1, n2, n3, n4, n5, n6, n7, n8, c, i, x, rt, t, sr);
    $finish(0);
  end
endmodule
