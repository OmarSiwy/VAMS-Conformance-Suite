// AMS §2.6.2's unscaled real notation remains legal in all delay2/delay3
// contexts. Under 1ns/1ps, 0.25 and 2.5e-1 each delay a transition 250 ticks.
// Source a is set to 0 at t=0, so all buffers have settled by the first
// sample at 0.5ns. It changes 0->1 at t=1ns. Every buffer therefore changes
// at 1.250ns: the preceding 1.249ns sample retains 0, and #0 at the delivery
// drains active updates before observing 1.
// Columns are net, continuous assignment, gate, UDP. Invalid neighbours are
// scaled_delay_net_rejected.v, scaled_delay_continuous_rejected.v and
// scaled_delay_udp_rejected.v. All use the same digital delay productions.
//! lrm 2.6.2
//! expect stdout digital_delay_primitive_notation.expected.txt
`timescale 1ns/1ps
primitive digital_delay_buffer(q, a);
  output q;
  input a;
  table
    0 : 0;
    1 : 1;
  endtable
endprimitive
module digital_delay_primitive_notation;
  reg a;
  wire #0.25 net_d;
  wire cont_d, gate_d, udp_d;
  assign net_d = a;
  assign #2.5e-1 cont_d = a;
  buf #0.25 g(gate_d, a);
  digital_delay_buffer #(0.25, 2.5e-1) u(udp_d, a);
  initial begin
    a = 0;
    #0.5 $display("settled %0.3f %b%b%b%b", $realtime, net_d, cont_d, gate_d, udp_d);
    #0.5 a = 1;
    #0.249 $display("before %0.3f %b%b%b%b", $realtime, net_d, cont_d, gate_d, udp_d);
    #0.001 #0 $display("at %0.3f %b%b%b%b", $realtime, net_d, cont_d, gate_d, udp_d);
    $finish(0);
  end
endmodule
