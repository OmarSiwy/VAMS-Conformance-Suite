//! inherited IEEE 1364-2005 17.8
//! reject $itor and $bitstoreal an integral value
// $itor is defined for an integer argument only; a real argument is
// unspecified and VerA refuses it (itor_rtoi).
module triage_itor_real_argument_rejected;
  real r;

  initial r = $itor(10.4);
endmodule
