// IEEE 1364-2005 17.1.3: "each time a variable or an expression in the
// argument list changes value" triggers an end-of-time-step monitor display,
// with the stated time-function exceptions and coalescing of same-time changes.
// AMS 9.4.1 separately defines ANALOG monitoring by accepted-step comparison;
// that wording must not replace the inherited digital trigger rule here.
//
// Table 9-1 additionally gives $monitoron and $monitoroff "Supported in
// digital context: Yes" and "Supported in analog context: No", which is why
// this row is D09's and not reachable through the analog backend. Their
// inherited IEEE 1364-2005 §17.1 semantics are: $monitoroff disables the
// monitoring mechanism, $monitoron re-enables it AND immediately produces a
// display of the current values so the transcript has a resumption checkpoint,
// and at most one $monitor is active at a time — a later $monitor replaces the
// mechanism the earlier one set up rather than adding a second one.
//
// HAND DERIVATION, `timescale 1ns/1ns`, one initial block:
//
//  t=0  a=0, b=0, then $monitor is invoked.
//       The call establishes the mechanism; the setup display shows the values
//       at the end of step 0.                      -> "mon a=0 b=0"
//  t=1  a <- 1.  One argument changed.             -> "mon a=1 b=0"
//  t=2  a <- 2 and b <- 2 in the SAME step. The quoted sentence forces ONE
//       line, not two.                             -> "mon a=2 b=2"
//  t=3  a is assigned 2 again. Its value does not change, so this step produces
//       NO line.
//       This is the suppression half of the rule and is the reason the value
//       is re-assigned rather than left alone: a mechanism that fires on
//       ASSIGNMENT instead of on VALUE CHANGE prints a fourth line here.
//  t=4  $monitoroff runs, then a <- 3. Monitoring is disabled for the rest of
//       the step, so the change produces NO line.
//  t=5  $monitoron runs. It re-enables and immediately reports the CURRENT
//       values, which are a=3 (changed while off) and the unchanged b=2.
//                                                  -> "mon a=3 b=2"
//       The end-of-step change check then compares against the values
//       $monitoron just reported, so it adds nothing and the step yields
//       exactly one line.
//  t=6  a <- 4.                                    -> "mon a=4 b=2"
//  t=7  a second $monitor is invoked with a DIFFERENT format and a single
//       argument. It replaces the first mechanism, and its own setup display
//       runs at the end of this step.              -> "new a=4"
//       If both mechanisms stayed live this step would print two lines and
//       every later step would print the old format too.
//  t=8  a <- 5. Only the replacement mechanism reports.
//                                                  -> "new a=5"
//  t=9  $finish(0), silent.
//
// %0d is used throughout so the transcript carries the decimal digits with no
// field padding; the padded default-decimal width is pinned separately by
// 01_display_radix.v and is not what this file is about.
//
//! lrm 9.4.1
//! inherited IEEE 1364-2005 17.1 ($monitoron/$monitoroff, single active monitor)
//! expect stdout monitor.expected.txt
`timescale 1ns/1ns
module d09_monitor;
  reg [3:0] a, b;
  initial begin
    a = 4'd0;
    b = 4'd0;
    $monitor("mon a=%0d b=%0d", a, b);
    #1 a = 4'd1;
    #1 a = 4'd2;
       b = 4'd2;
    #1 a = 4'd2;
    #1 $monitoroff;
       a = 4'd3;
    #1 $monitoron;
    #1 a = 4'd4;
    #1 $monitor("new a=%0d", a);
    #1 a = 4'd5;
    #1 $finish(0);
  end
endmodule
