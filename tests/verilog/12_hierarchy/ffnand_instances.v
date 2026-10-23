// IEEE 1364-2005 §12.1.2, p. 166: "When a list of port connections is given
// using the ordered port connection method, the first element in the list
// shall connect to the first port declared in the module, the second to the
// second port, and so on." ... "A blank port connection shall represent the
// situation where the port is not to be connected. When connecting ports by
// name, an unconnected port can be indicated either by omitting it in the port
// list or by providing no expression in the parentheses [i.e., .port_name ()]."
//
// The clause's Examples 1 and 2 in one waveform module: ff connects all four
// ports in order (Example 1); ff1 leaves qbar blank and ff2 connects by name
// with .q() empty (Example 2). All three see the same preset/clear, so
// ff.q = ff1.q and ff.qbar = ff2.qbar. The nand pair: q = ~(qbar & preset),
// qbar = ~(q & clear).
//   t=10 in1=0, in2=1: q = ~(x & 0) = 1; qbar = ~(1 & 1) = 0.  -> 1 0 1 0
//   t=21 in1=1:        q = ~(0 & 1) = 1 holds, qbar = 0.       -> 1 0 1 0
//   t=32 in2=0:        qbar = ~(1 & 0) = 1; q = ~(1 & 1) = 0;
//                      qbar = ~(0 & 0) = 1 stable.             -> 0 1 0 1
//   t=43 in2=1:        qbar = ~(0 & 1) = 1 holds, q = 0.       -> 0 1 0 1
// Each line prints at +1 after its change, so the gates have settled.
// Columns: ff.q ff.qbar ff1.q(out1) ff2.qbar(out2).
//! inherited IEEE 1364-2005 12.1.2 12.3.5 12.3.6
`timescale 1ns/1ns
module ffnand (q, qbar, preset, clear);
  output q, qbar;
  input preset, clear;
  nand g1 (q, qbar, preset),
       g2 (qbar, q, clear);
endmodule
module b_12_1_2_ffnand_instances;
  wire o1, o2, out1, out2;
  reg in1, in2;
  parameter d = 10;
  ffnand ff(o1, o2, in1, in2);
  ffnand ff1(out1, , in1, in2),
         ff2(.qbar(out2), .clear(in2), .preset(in1), .q());
  initial begin
    #d in1 = 0; in2 = 1;
    #1 $display("%b %b %b %b", o1, o2, out1, out2);
    #d in1 = 1;
    #1 $display("%b %b %b %b", o1, o2, out1, out2);
    #d in2 = 0;
    #1 $display("%b %b %b %b", o1, o2, out1, out2);
    #d in2 = 1;
    #1 $display("%b %b %b %b", o1, o2, out1, out2);
  end
endmodule
