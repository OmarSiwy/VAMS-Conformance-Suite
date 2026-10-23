// IEEE 1364-2005 A.2.2.3, p. 491:
//   delay3 ::= # delay_value
//     | # ( mintypmax_expression [ , mintypmax_expression [ , mintypmax_expression ] ] )
//   delay2 ::= # delay_value | # ( mintypmax_expression [ , mintypmax_expression ] )
//   delay_value ::= unsigned_number | real_number | identifier
//
// Every form but a min:typ:max triple (b_A_2_2_3_mintypmax_delay.v), on continuous assignments (delay3) and gates (delay2), all
// driven by one step of r from 0 to 1 at t=10 (`timescale 1ns/1ns):
//   n1  assign #3                 unsigned_number        rises at 13
//   n2  assign #2.0               real_number            rises at 12
//   n3  assign #D, D = 4          identifier             rises at 14
//   n4  assign #(5)               one mintypmax          rises at 15
//   n5  assign #(6, 1)            rise 6, fall 1         rises at 16
//   n6  assign #(7, 1, 1)         rise 7                 rises at 17
//   g1  buf #9                    delay2 delay_value     rises at 19
//   g2  buf #(1, 2)               delay2, rise 1         rises at 11
// Before t=10 every net has settled to r = 0 (the longest fall, g1's 9, ends
// at t=9). Sampled at t=15, after `#5 #0`: n4's rise is an active update at
// t=15 and the #0 resumes in the inactive region after it, so n1..n4 = 1,
// n5, n6 = 0, g1 = 0, g2 = 1. At t=20 all are 1.
// Output: "15: 111100 g=01" then "20: 111111 g=11".
//! inherited IEEE 1364-2005 A.2.2.3
`timescale 1ns/1ns
module b_A_2_2_3_delays;
  parameter D = 4;
  reg r;
  wire n1, n2, n3, n4, n5, n6, g1, g2;
  assign #3 n1 = r;
  assign #2.0 n2 = r;
  assign #D n3 = r;
  assign #(5) n4 = r;
  assign #(6, 1) n5 = r;
  assign #(7, 1, 1) n6 = r;
  buf #9 (g1, r);
  buf #(1, 2) (g2, r);
  initial begin
    r = 0;
    #10 r = 1;
    #5 #0 $display("%0d: %b%b%b%b%b%b g=%b%b", $time, n1, n2, n3, n4, n5, n6, g1, g2);
    #5 $display("%0d: %b%b%b%b%b%b g=%b%b", $time, n1, n2, n3, n4, n5, n6, g1, g2);
    $finish(0);
  end
endmodule
