// IEEE 1364-2005 §7.1, p. 74: "Multiple instances of the one type of gate or
// switch primitive can be declared as a comma-separated list. All such
// instances shall have the same drive strength and delay specification."
//
// nand (pull1, strong0) #2 n1(o1, a, b), n2(o2, c, d): the one (pull1,
// strong0) and the one #2 apply to both n1 and n2.
//   t=0: a=b=c=d=1, so both nand outputs become 0 (St0) at t=2; the first
//     sample is at t=3, after that delay.
//   t=10: a=0 and c=0, so both outputs go to 1 after the shared 2-unit delay:
//     t=11 both still 0 (strong 0 beats the weak 0 and the pull 0 below);
//     t=12 both now drive Pu1; sampled at t=13, clear of that update.
//   Each output also has a 0 driver of its own:
//     o1 also gets (weak1, weak0) 0: Pu1(5) beats We0(3) (§7.10.1) -> 1.
//     o2 also gets (pull1, pull0) 0: Pu1(5) meets Pu0(5), equal strength and
//       opposite value -> x. Had n2 kept the default strong1, St1(6) would
//       win and o2 would read 1; the x shows n2 took the list's pull1.
//   At t=3 each net is St0 plus a weaker 0 -> 0.
// Lines: "3 00", "11 00", "13 1x".
//! inherited IEEE 1364-2005 7.1
`timescale 1ns/1ns
module b_7_1_instance_list_shared_spec;
  reg a, b, c, d;
  wire o1, o2;
  nand (pull1, strong0) #2 n1(o1, a, b), n2(o2, c, d);
  assign (weak1, weak0) o1 = 1'b0;
  assign (pull1, pull0) o2 = 1'b0;
  initial begin
    a = 1; b = 1; c = 1; d = 1;
    #3 $display("%0d %b%b", $time, o1, o2);
    #7 a = 0; c = 0;
    #1 $display("%0d %b%b", $time, o1, o2);
    #2 $display("%0d %b%b", $time, o1, o2);
    $finish(0);
  end
endmodule
