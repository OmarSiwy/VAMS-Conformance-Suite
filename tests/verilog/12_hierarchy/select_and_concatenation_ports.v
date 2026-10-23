// IEEE 1364-2005 §12.3.2, p. 174: "The port reference for each port in the list
// of ports at the top of each module declaration can be one of the following:
// - A simple identifier or escaped identifier - A bit-select of a vector
// declared within the module - A part-select of a vector declared within the
// module - A concatenation of any of the above". §12.3.3, pp. 175-176, gives
// the examples used here: complex_ports ({c,d}, .e(f)) ("Nets {c,d} receive
// the first port bits."), split_ports (a[7:4], a[3:0]), same_port (.a(i),
// .b(i)), renamed_concat (.a({b,c}), f, .g(h[1])), same_input (a,a) ("This is
// legal. The inputs are tied together.") and mixed_direction (.p({a, e})).
//
// Values, each module printing its own line at its own time:
//   t=1 complex_ports gets 4'b1001: {c,d} = 10,01; f = {d,c} = 0110.
//   t=2 split_ports gets 4'hA, 4'h5: a = {4'hA, 4'h5} = 8'hA5 -> "a5".
//   t=3 same_port: port a driven 1 outside, port b reads the same net i -> 1.
//   t=4 renamed_concat .a(2'b10) -> b=1, c=0; .g(1) -> h[1]=1; f = b^c^h[1]
//       = 0.
//   t=5 same_input(1, 1): a = 1.
//   t=6 mixed_direction .p({pa, pe}) with pa = 0: e = ~a = 1 drives pe -> 1.
//! inherited IEEE 1364-2005 12.3.2 12.3.3
// native-required
`timescale 1ns/1ns
module complex_ports ({c,d}, .e(f));
  input [1:0] c, d;
  output [3:0] f;
  assign f = {d, c};
endmodule
module split_ports (a[7:4], a[3:0]);
  input [7:0] a;
  initial #2 $display("split %h", a);
endmodule
module same_port (.a(i), .b(i));
  inout i;
endmodule
module renamed_concat (.a({b,c}), f, .g(h[1]));
  input b, c;
  output f;
  input [1:0] h;
  assign f = b ^ c ^ h[1];
endmodule
module same_input (a,a);
  input a;
  initial #5 $display("same_input %b", a);
endmodule
module mixed_direction (.p({a, e}));
  input a;
  output e;
  assign e = ~a;
endmodule
module b_12_3_2_select_and_concatenation_ports;
  wire [3:0] cf;
  wire sa, sb, rf, pa, pe;
  assign sa = 1'b1;
  assign pa = 1'b0;
  complex_ports u1(4'b1001, cf);
  split_ports u2(4'hA, 4'h5);
  same_port u3(sa, sb);
  renamed_concat u4(.a(2'b10), .f(rf), .g(1'b1));
  same_input u5(1'b1, 1'b1);
  mixed_direction u6({pa, pe});
  initial begin
    #1 $display("complex %b", cf);
    #2 $display("same_port %b", sb);
    #1 $display("renamed %b", rf);
    #2 $display("mixed %b", pe);
  end
endmodule
