//@ std 1364-2005
//! inherited IEEE 1364-2005 12.3.8
// A port and its connected expression may differ in width: an input port
// takes the expression zero-extended or truncated (br_gh127a).
module copy(output [1:0] out, input [1:0] in);
  assign out = in;
endmodule

module triage_port_input_width_extends;
  reg [2:0] r;
  wire [0:0] i1;
  wire [2:0] i3;
  wire [1:0] o1;
  wire [1:0] o3;

  assign i1 = r;
  assign i3 = r;
  copy c1(o1, i1);
  copy c3(o3, i3);

  initial begin
    r = 3'b111;
    #1;
    if (o1 === 2'b01 && o3 === 2'b11)
      $display("PASSED");
    else
      $display("FAILED %b %b", o1, o3);
  end
endmodule
