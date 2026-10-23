// IEEE 1364-2005 §19.8, p. 358: "The `timescale compiler directive specifies
// the unit of measurement for time and delay values and the degree of
// accuracy for delays in all modules that follow this directive until
// another `timescale compiler directive is read." ... "The time_precision
// argument specifies how delay values are rounded before being used in
// simulation." p. 359: "`timescale 1 ns / 1 ps Here, all time values in the
// modules that follow the directive are multiples of 1 ns because the
// time_unit argument is "1 ns." Delays are rounded to real numbers with three
// decimal places". p. 360: "a) The value of parameter d is rounded from 1.55
// to 1.6 according to the time precision. b) The time unit of the module is
// 10 ns, and the precision is 1 ns; therefore, the delay of parameter d is
// scaled from 1.6 to 16. c) The assignment of 0 to reg set is scheduled at
// simulation time 16 ns, and the assignment of 1 at simulation time 32 ns.
// The time values are not rounded when the assignments are scheduled."
//
// b_19_8_fine, under `timescale 1 ns / 1 ps: #1.2346 is 1.2346 ns, rounded to
//   three decimals (1 ps) -> 1.235 ns; $realtime in its 1 ns unit -> 1.235.
// b_19_8_units_and_precision, under `timescale 10 ns / 1 ns (the clause's
//   example, with the delay written as the literal 1.55; the parameter form is
//   parameter_example.v): 1.55 -> 1.6 units = 16 ns, set = 0 then;
//   another 1.6 units -> 32 ns, set = 1. $realtime in its 10 ns unit: 1.6 and
//   3.2. (1.55 units is 15.5 ns, half-way between 15 and 16; the clause
//   itself fixes the rounding up to 16.)
// Printed in time order: 1.235 ns, 16 ns, 32 ns.
//! inherited IEEE 1364-2005 19.8
`timescale 1 ns / 1 ps
module b_19_8_fine;
  initial #1.2346 $display("fine %g", $realtime);
endmodule
`timescale 10 ns / 1 ns
module b_19_8_units_and_precision;
  reg set;
  b_19_8_fine f();
  initial begin
    #1.55 set = 0;
    $display("set=%b at %g", set, $realtime);
    #1.55 set = 1;
    $display("set=%b at %g", set, $realtime);
    $finish(0);
  end
endmodule
