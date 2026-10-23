// IEEE 1364-2005 A.1.3: "port ::= [ port_expression ]"; the list repeats
// ports separated by commas, so more than one null port is legal, as is a
// null port beside a selected or concatenated port_reference. §12.1.2's
// ordered connections retain the header's positions.
//
// HAND DERIVATION. Three modules copy their input to their output, with two
// null ports, a selected input followed by a null port, and a concatenated
// input beside two null ports. Driving a=1, b=0 gives plain=1, selected=1,
// joined=10; reversing them gives plain=0, selected=0, joined=01. Each
// sample is one tick after the inputs change, with no scheduling race.
// Rejection neighbour: null_port_extra_connection_rejected.v isolates
// an extra positional connection beyond the null ports' header positions.
//! lrm 6.5.1
//! lrm 6.5.1:1
//! inherited IEEE 1364-2005 A.1.3 12.1.2
`timescale 1ns/1ns
module null_plain(a, , , y);
  input a;
  output y;
  assign y = a;
endmodule
module null_selected(a[0], , y);
  input [1:0] a;
  output y;
  assign y = a[0];
endmodule
module null_joined(, {a, b}, , y);
  input a, b;
  output [1:0] y;
  assign y = {a, b};
endmodule
module b_12_null_port_combinations;
  reg a, b;
  wire plain, selected;
  wire [1:0] joined;
  null_plain p(a, , , plain);
  null_selected s(a, , selected);
  null_joined j(, {a, b}, , joined);
  initial begin
    a = 1; b = 0;
    #1 $display("plain=%b selected=%b joined=%b", plain, selected, joined);
    a = 0; b = 1;
    #1 $display("plain=%b selected=%b joined=%b", plain, selected, joined);
  end
endmodule
