// IEEE 1364-2005 §13.2.1.1, p. 201: "If a file name matches path
// specifications in multiple library definitions (after the above resolution
// rules have been applied), it shall be an error." §13.7.3, p. 210:
// "/proj/lib1/foover.v - ERROR // matches lib1 and lib4".
//
// The §13.7.3 map (libmap/proj/tb/lib.map); foover.v matches lib1's
// "foo*.v" and lib4's "*ver.v", both wildcarded filenames, so neither is
// resolved before the other. Legal neighbour: resolution_order.v,
// the same map and the example's other four files.
//@ libmap libmap/proj/tb/lib.map
//@ files libmap/proj/lib1/foover.v
//! inherited IEEE 1364-2005 13.2.1.1
//! reject E0244
//! reject libraries `lib1` and `lib4`
//! neighbour resolution_order.v
module top;
  foover u();
endmodule
