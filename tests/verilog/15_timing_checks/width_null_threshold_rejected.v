// IEEE 1364-2005 §15.3.4 (p. 256): "If the notifier is present, a non-null
// value for the threshold shall also be present." Among its "Illegal Calls":
// "$width ( negedge clr, lim, , notif );". A.7.5.1 writes the optional pair
// `[ , threshold [ , notifier ] ]`, neither argument nullable on its own.
//
// $width(negedge clr, 5, , ntfr) leaves the threshold null before a
// notifier. Legal neighbour: width.v's $width(negedge clk, 4, 0,
// n2), the threshold written as 0.
//! inherited IEEE 1364-2005 15.3.4
//! reject E0207
//! reject not null arguments
//! neighbour width.v
`timescale 1ns/1ns
module b_15_3_4_width_null_threshold_rejected(clr);
  input clr;
  reg ntfr;
  specify
    $width(negedge clr, 5, , ntfr);
  endspecify
endmodule
