// IEEE 1364-2005 §4.4.2, p. 25: "The drive strength specification allows a
// continuous assignment to be placed on a net in the same statement that
// declares that net." §4.4, p. 25: "Drive strength shall only be used when
// placing a continuous assignment on a net in the same statement that
// declares the net." §6.1.4, p. 71: "Whenever the continuous assignment
// drives the net, the strength of the value shall be simulated as
// specified."
//
// wire (pull1, pull0) w = a; and a second, default-strength (strong1,
// strong0, §6.1.4) driver assign w = b:
//   a = 0 drives pull0, b = 1 drives strong1: strong beats pull (§7.10.1)
//     -> 1 (an implementation that drops the declared strength sees two
//     strong drivers and resolves x)
//   a = 1 drives pull1, b = 0 drives strong0 -> 0
//! inherited IEEE 1364-2005 4.4.2 4.4
module b_4_4_2_net_declaration_drive_strength;
  reg a, b;
  wire (pull1, pull0) w = a;
  assign w = b;
  initial begin
    a = 0;
    b = 1;
    #1 $display("%b", w);
    a = 1;
    b = 0;
    #1 $display("%b", w);
    $finish(0);
  end
endmodule
