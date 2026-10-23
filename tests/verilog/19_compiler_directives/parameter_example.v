// IEEE 1364-2005 §19.8, p. 359: "The following example shows a `timescale
// directive in the context of a module:
//     `timescale 10 ns / 1 ns
//     module test;
//     reg set;
//     parameter d = 1.55;
//     initial begin
//           #d set = 0;
//           #d set = 1;
//     end
//     endmodule
// The `timescale 10 ns / 1 ns compiler directive specifies that the time unit
// for module test is 10 ns. As a result, the time values in the module are
// multiples of 10 ns, rounded to the nearest 1 ns; therefore, the value
// stored in parameter d is scaled to a delay of 16 ns. In other words, the
// value 0 is assigned to reg set at simulation time 16 ns (1.6 × 10 ns), and
// the value 1 at simulation time 32 ns. Parameter d retains its value no
// matter what timescale is in effect."
//
// The example as written, with a $display after each assignment: set = 0 at
// $realtime 1.6 (16 ns) and set = 1 at 3.2 (32 ns). "retains its value": d
// itself still prints 1.55 (%g) at the end. §4.10.1, p. 36: "A parameter
// declaration with no type or range specification shall default to the type
// and range of the final value assigned to the parameter", here real.
//! inherited IEEE 1364-2005 19.8
`timescale 10 ns / 1 ns
module b_19_8_parameter_example;
  reg set;
  parameter d = 1.55;
  initial begin
    #d set = 0;
    $display("set=%b at %g", set, $realtime);
    #d set = 1;
    $display("set=%b at %g", set, $realtime);
    $display("d=%g", d);
    $finish(0);
  end
endmodule
