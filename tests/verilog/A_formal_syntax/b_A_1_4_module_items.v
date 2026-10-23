// IEEE 1364-2005 A.1.4, p. 488:
//   module_item ::= port_declaration ; | non_port_module_item
//   module_or_generate_item ::= { attribute_instance } module_or_generate_item_declaration
//     | { attribute_instance } local_parameter_declaration ;
//     | { attribute_instance } parameter_override
//     | { attribute_instance } continuous_assign
//     | { attribute_instance } gate_instantiation
//     | { attribute_instance } udp_instantiation
//     | { attribute_instance } module_instantiation
//     | { attribute_instance } initial_construct
//     | { attribute_instance } always_construct
//     | { attribute_instance } loop_generate_construct
//     | { attribute_instance } conditional_generate_construct
//   module_or_generate_item_declaration ::= net_declaration | reg_declaration
//     | integer_declaration | real_declaration | time_declaration
//     | realtime_declaration | event_declaration | genvar_declaration
//     | task_declaration | function_declaration
//   non_port_module_item ::= module_or_generate_item | generate_region
//     | specify_block | { attribute_instance } parameter_declaration ;
//     | { attribute_instance } specparam_declaration
//   parameter_override ::= defparam list_of_defparam_assignments ;
//
// One module body holding every module_item alternative but
// port_declaration ; (b_A_1_3_ports.v's b_A_1_3_old declares its ports that
// way), udp_instantiation (b_A_5_4_udp_instances.v) and attribute instances
// (b_A_9_1_attributes.v): all ten
// module_or_generate_item_declarations, a local_parameter_declaration, a
// parameter_declaration, a specparam_declaration, a parameter_override, a
// continuous_assign, a gate_instantiation, a module_instantiation, an
// always_construct, an initial_construct, a generate_region holding a
// loop_generate_construct, a conditional_generate_construct outside any
// region, and a specify_block.
//
// Values at t=2, all 4-bit unless noted:
//   r = 1, then the task bump makes it 2; n = r + L = 2 + 3 = 5.
//   na = not r[0] = not 0 = 1.
//   c.K = 1 overridden by the defparam to 6; c.k = 6.
//   the loop generate runs g = 0, 1: w0 = 0 + P = 2, w1 = 1 + P = 3.
//   the if generate's condition P == 2 holds: c2 = 9.
//   dbl(r) = 2 * 2 = 4.
//   -> e at t=1, when the always block is waiting at @(e) (it reached it at
//   t=0): i = 0 + 1 = 1.
//   x = 1.5, t = 5, rt = 2.5, the specparam S = 4.
// Output: "n=5 na=1 k=6 w0=2 w1=3 c2=9 dbl=4 i=1 x=1.5 t=5 rt=2.5 S=4".
// The specify block holds a specparam only, which elaborates as a constant,
// so a digital run has nothing in it to warn about (W0251 is for path
// delays and pulse controls).
//! inherited IEEE 1364-2005 A.1.4
`timescale 1ns/1ns
module b_A_1_4_child;
  parameter K = 1;
  wire [3:0] k = K;
endmodule
module b_A_1_4_module_items;
  wire [3:0] n;
  reg [3:0] r;
  integer i;
  real x;
  time t;
  realtime rt;
  event e;
  genvar g;
  localparam L = 3;
  parameter P = 2;
  specparam S = 4;
  defparam c.K = 6;
  assign n = r + L;
  wire na;
  not (na, r[0]);
  b_A_1_4_child c ();
  task bump; r = r + 1; endtask
  function [3:0] dbl(input [3:0] v); dbl = v * 2; endfunction
  wire [3:0] w0, w1, c2;
  generate
    for (g = 0; g < 2; g = g + 1) begin : blk
      if (g == 0) assign w0 = g + P;
      else assign w1 = g + P;
    end
  endgenerate
  if (P == 2) begin : yes
    assign c2 = 4'd9;
  end
  specify
    specparam D = 1;
  endspecify
  always @(e) i = i + 1;
  initial begin
    i = 0;
    r = 4'd1;
    x = 1.5;
    t = 5;
    rt = 2.5;
    bump;
    #1 -> e;
    #1 $display("n=%0d na=%b k=%0d w0=%0d w1=%0d c2=%0d dbl=%0d i=%0d x=%.1f t=%0d rt=%.1f S=%0d",
                n, na, c.k, w0, w1, c2, dbl(r), i, x, t, rt, S);
    $finish(0);
  end
endmodule
