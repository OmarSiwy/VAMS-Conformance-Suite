// VCD-ORACLE-001: this retained golden is an implementation snapshot.
// Compare semantic checkpoints/values, not arbitrary IDs, layout or ordering;
// retain metadata independently. See docs/conformance-vcd-review.md at 8b1514d4.
//
// The checkpoint half of the inherited §18.1 VCD task family: $dumpoff,
// $dumpon and $dumpall. 11_vcd_dumpvars.v pins the file format; this file pins
// the three tasks that SUSPEND and RESUME dumping, and it uses a single scalar
// so nothing but the checkpoint records can move.
//
//   $dumpoff  stops dumping and writes a checkpoint in which every selected
//             variable is dumped as x. The all-x checkpoint is the marker that
//             says "from here the file does not know these values" — it is not
//             a claim that the variables BECAME unknown.
//   $dumpon   resumes dumping and writes a checkpoint holding the CURRENT
//             value of every selected variable, so a reader can re-synchronize
//             after the gap.
//   $dumpall  writes a checkpoint of the current value of every selected
//             variable without changing whether dumping is on.
//
// HAND DERIVATION of vcd_dumpoff_on.expected.vcd, `timescale 1ns/1ns`,
// one scalar `reg a` which therefore takes identifier code `!`:
//
//   t=0  $dumpfile, $dumpvars(0, d09_vcd_off), then a <- 0.
//          #0 / $dumpvars / 0! / $end
//   t=1  a <- 1.                                   #1 / 1!
//   t=2  $dumpoff. Checkpoint with every variable as x, INSIDE a $dumpoff
//        section. a is actually 1 at this instant; the record says x anyway.
//          #2 / $dumpoff / x! / $end
//   t=3  a <- 0. Dumping is off, so NOTHING is written — there is no #3
//        value-change record. An empty #3 timestamp is not a changed value.
//        The absence of an ordinary update is the point of the
//        fixture: an implementation that writes the checkpoint but keeps
//        dumping produces a #3 with `0!` here.
//   t=4  $dumpon. Checkpoint with current values. a is 0, the value written
//        while dumping was off, so the resume record is 0 and not the 1 that
//        was last visible in the file.
//          #4 / $dumpon / 0! / $end
//   t=5  a <- 1, ordinary change now that dumping is on again.
//          #5 / 1!
//   t=6  $dumpall. Checkpoint of the current value, a = 1. This record is
//        redundant with the #5 change, which is exactly what makes it a test:
//        $dumpall writes state unconditionally, so it appears even though
//        nothing changed in step 6.
//          #6 / $dumpall / 1! / $end
//        The snapshot ends here. Exact final-line formatting and an implied
//        $finish flush rule are not derived from the $dumpflush clause.
//
//   The value sequence in the file is therefore 0, 1, x, (gap), 0, 1, 1 while
//   the variable's actual sequence is 0, 1, 1, 0, 0, 1, 1. Those two differ at
//   three positions and each difference is produced by one of the three tasks.
//
// The same CONVENTION as 11_vcd_dumpvars.v applies: identifier codes assigned
// from `!` in $var declaration order, and $date/$version/$comment deleted and
// the $timescale body stripped of whitespace before comparison, by the
// token-based normaliser in tests/fixtures/ch09_system_tasks/d09_SPEC.md at 8b1514d4 (a line-oriented `sed` range mis-deletes
// when `$date … $end` lands on a single line).
//
//! inherited IEEE 1364-2005 18.1 ($dumpoff, $dumpon, $dumpall)
//! inherited IEEE 1364-2005 18.2 (checkpoint records)
// The golden lives in ch09_system_tasks/; see vcd_dumpvars.v.
//! expect vcd d09_vcd_off.vcd == vcd_dumpoff_on.expected.vcd
`timescale 1ns/1ns
module d09_vcd_off;
  reg a;
  initial begin
    $dumpfile("d09_vcd_off.vcd");
    $dumpvars(0, d09_vcd_off);
    a = 1'b0;
    #1 a = 1'b1;
    #1 $dumpoff;
    #1 a = 1'b0;
    #1 $dumpon;
    #1 a = 1'b1;
    #1 $dumpall;
       $finish(0);
  end
endmodule
