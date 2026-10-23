// IEEE 1364-2005 §6.1.2, pp. 69-70: "The continuous assignment statement shall
// place a continuous assignment on a net data type." ... "Assignments on nets
// shall be continuous and automatic. In other words, whenever an operand in
// the right-hand expression changes value, the whole right-hand side shall be
// evaluated. If the new value is different from the previous value, then the
// new value shall be assigned to the left-hand side." Example 3 (p. 70) is
// the select_bus module below, verbatim; "a) The value of s, a bus selector
// input variable, is checked in the assign statement. Based on the value of
// s, the net data receives the data from one of the four input buses.
// b) The setting of data net triggers the continuous assignment in the net
// declaration for busout. If enable is set, the contents of data are assigned
// to busout; if enable is 0, the contents of Zee are assigned to busout."
//
// bus0..bus3 = 1111, 2222, 3333, 4444 (hex), enable = 1. For each s the one
// assignment whose comparison holds drives its bus onto data, the other three
// drive 16'bz, and a z driver loses to a driven value (§7.10.1), so
//   s = 0 -> 1111, s = 1 -> 2222, s = 2 -> 3333, s = 3 -> 4444.
// enable = 0 (s still 3): busout = Zee -> zzzz, data still 4444.
// Each read is one time unit after the change.
//! inherited IEEE 1364-2005 6.1 6.1.2
module select_bus(busout, bus0, bus1, bus2, bus3, enable, s);
parameter n = 16;
parameter Zee = 16'bz;
output [1:n] busout;
input [1:n] bus0, bus1, bus2, bus3;
input enable;
input [1:2] s;
tri [1:n] data;         // net declaration
// net declaration with continuous assignment
tri [1:n] busout = enable ? data : Zee;
// assignment statement with four continuous assignments
assign
      data = (s == 0) ? bus0 : Zee,
      data = (s == 1) ? bus1 : Zee,
      data = (s == 2) ? bus2 : Zee,
      data = (s == 3) ? bus3 : Zee;
endmodule

module b_6_1_2_select_bus;
  reg [1:16] b0, b1, b2, b3;
  reg en;
  reg [1:2] sel;
  wire [1:16] out;
  select_bus u(out, b0, b1, b2, b3, en, sel);
  initial begin
    b0 = 16'h1111; b1 = 16'h2222; b2 = 16'h3333; b3 = 16'h4444;
    en = 1;
    sel = 0;
    #1 $display("%h", out);
    sel = 1;
    #1 $display("%h", out);
    sel = 2;
    #1 $display("%h", out);
    sel = 3;
    #1 $display("%h", out);
    en = 0;
    #1 $display("%h %h", out, u.data);
    $finish(0);
  end
endmodule
