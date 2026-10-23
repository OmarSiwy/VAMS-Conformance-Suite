// IEEE 1364-2005 §12.2.2.1, p. 170: "The order of the assignments in the module
// instance parameter value assignment by ordered list shall follow the order of
// declaration of the parameters within the module. It is not necessary to
// assign values to all of the parameters within a module when using this
// method." p. 171: "Local parameters cannot be overridden; therefore, they are
// not considered part of the ordered list for parameter value assignment. In
// the following example, addr_width will be assigned the value 12, and
// data_width will be assigned the value 16. mem_size will not be explicitly
// assigned a value due to the ordered list, but will have the value 4096 due to
// its declaration expression." §12.2.2.2, p. 171: "The parameter expression is
// optional so that the instantiating module can document the existence of a
// parameter without assigning anything to it. The parentheses are required,
// and in this case the parameter retains its default value." p. 172: "It shall
// be legal to instantiate modules using different types of parameter
// redefinition in the same top-level module."
//
// The clauses' tb1 and tb2 instances in one module (tb3's mixture), vdff with
// size=5, delay=1. The parent prints each instance's parameters by
// hierarchical name, one line per instance, in source order:
//   tb1: a1 #(10,15) -> 10 15; b1 -> 5 1; c1 #(5,12) -> 5 12; d1 #(10) -> 10 1
//   tb2: a2 #(.size(10),.delay(15)) -> 10 15; b2 -> 5 1;
//        c2 #(.delay(12)) -> 5 12; d2 #(.delay( ),.size(10)) -> 10 1
//   my_mem #(12, 16): addr_width 12, mem_size 1 << 12 = 4096, data_width 16.
//! inherited IEEE 1364-2005 12.2.2 12.2.2.1 12.2.2.2
module vdff;
  parameter size=5, delay=1;
endmodule
module my_mem;
  parameter addr_width = 16;
  localparam mem_size = 1 << addr_width;
  parameter data_width = 8;
endmodule
module b_12_2_2_parameter_assignment_forms;
  vdff #(10,15) a1();
  vdff          b1();
  vdff #( 5,12) c1();
  vdff #(10)    d1();
  vdff #(.size(10),.delay(15)) a2();
  vdff                         b2();
  vdff #(.delay(12))           c2();
  vdff #(.delay( ),.size(10) ) d2();
  my_mem #(12, 16) m();
  initial begin
    $display("%0d %0d", a1.size, a1.delay);
    $display("%0d %0d", b1.size, b1.delay);
    $display("%0d %0d", c1.size, c1.delay);
    $display("%0d %0d", d1.size, d1.delay);
    $display("%0d %0d", a2.size, a2.delay);
    $display("%0d %0d", b2.size, b2.delay);
    $display("%0d %0d", c2.size, c2.delay);
    $display("%0d %0d", d2.size, d2.delay);
    $display("%0d %0d %0d", m.addr_width, m.mem_size, m.data_width);
  end
endmodule
