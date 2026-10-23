// IEEE 1364-2005 §4.10.3: "Specify parameters (also called specparams) are
// permitted both within the specify block (see Clause 14) and in the main
// module body", and a specparam "can appear in any expression that is not
// assigned to a parameter". §6.1.3: "A delay given to a continuous
// assignment shall specify the time duration between a right-hand operand
// value change and the assignment made to the left-hand side."
//
// The supported way to give a design a timing value (the neighbour of
// 17_system_tasks/sdf_annotate_rejected.v, which asks for one from SDF).
// tpd = 3, so y follows a three time units late:
//   a = 0 at t = 0  ->  y = 0 at t = 3;   a = 1 at t = 5  ->  y = 1 at t = 8.
// Sampled away from both updates, so no same-time ordering is involved:
//   t = 4: 0      t = 7: still 0      t = 9: 1
// y at t = 7 and t = 9 brackets the second update in (7, 9), so the delay
// is in (2, 4): an integer delay there is 3, the specparam's value. Before
// t = 3 is not sampled: §4.2.1's "Nets with drivers shall assume the output
// value of their drivers" leaves a delayed assignment's value until its first
// update to a reading this fixture need not take.
//! inherited IEEE 1364-2005 4.10.3 6.1.3
//! expect stdout specparam_module_body_delay.expected.txt
module specparam_module_body_delay;
  specparam tpd = 3;
  reg a;
  wire y;
  assign #tpd y = a;
  initial begin
    a = 1'b0;
    #4 $display("t=4 y=%b", y);
    #1 a = 1'b1;
    #2 $display("t=7 y=%b", y);
    #2 $display("t=9 y=%b", y);
  end
endmodule
