// IEEE 1364-2005 §15.5 (p. 259): "The notifier is a reg, declared in the
// module where timing check tasks are invoked"; Tables 15-1 to 15-12 type
// every notifier "Reg"; A.7.5.2 `notifier ::= variable_identifier`.
//
// $setup(d, posedge clk, 5, nn) names the wire nn as its notifier, which no
// violation can toggle as Table 15-13 says. Legal neighbour:
// notifier.v, the same check with a reg notifier.
//! inherited IEEE 1364-2005 15.5
//! reject-only E1147
//! neighbour notifier.v
`timescale 1ns/1ns
module b_15_5_notifier_net_rejected(clk, d);
  input clk, d;
  wire nn;
  specify
    $setup(d, posedge clk, 5, nn);
  endspecify
endmodule
