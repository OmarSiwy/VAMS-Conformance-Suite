// IEEE 1364-2005 §9.7.1, p. 141: "Specify parameters are permitted in the
// delay expression." §4.10.3: specparams "are permitted both within the
// specify block (see Clause 14) and in the main module body".
//
// d is declared inside the specify block (§14.2, in scope; only the path and
// timing-check simulation of §14.3.2 on is CLAUSE-AUDIT §5.7's), then used
// as a procedural delay: a goes 0 -> 1 at t = 7. The module-body form is
// 04_data_types/specparam_module_body_delay.v.
//! inherited IEEE 1364-2005 9.7.1 4.10.3
`timescale 1ns/1ns
module b_9_7_1_specify_block_specparam;
  specify
    specparam d = 7;
  endspecify
  reg a;
  initial begin
    a = 0;
    #d a = 1;
    $display("%0t a=%b", $time, a);
  end
endmodule
