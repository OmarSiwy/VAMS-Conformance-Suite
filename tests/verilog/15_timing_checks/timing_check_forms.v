// IEEE 1364-2005 §15.1, p. 237: "Timing checks can be placed in specify
// blocks to verify the timing performance of a design by making sure critical
// events occur within given time limits." Syntax 15-1 (p. 238) gives twelve
// commands, $setup to $nochange, each with an optional notifier; Syntax 15-2
// (p. 239) gives timing_check_event ::= [timing_check_event_control]
// specify_terminal_descriptor [ &&& timing_check_condition ]. p. 240:
// "Although they begin with a $, timing checks are not system tasks." ...
// "Like expressions for module path delays, timing check limit values are
// constant expressions that can include specparams."
// §15.4, pp. 258-259: "Edge-control specifiers contain the keyword edge
// followed by a square-bracketed list of from one to six pairs of edge
// transitions between 0, 1, and x" ... "Edge transitions involving z are
// treated the same way as edge transitions involving x." ... "posedge clr is
// equivalent to the following: edge[01, 0x, x1] clr" ... "negedge clr is the
// same as the following: edge[10, x0, 1x] clr".
//
// The cell's specify block holds eight of the twelve commands ($setup,
// $hold, $setuphold, $recovery, $removal, $recrem, $period, $width; the
// skew checks and $nochange have fixtures of their own), each with a
// notifier, the limits written as numbers
// and as specparams, a &&& condition, and three edge-control specifiers:
// posedge's spelling, negedge's spelling, and a list with z transitions.
//
// The stimulus meets every check, so no violation is reported (no W1199), no
// notifier toggles, and the transcript is the flop's alone:
//   t = 1:   d = 1, clr = 1, en = 1, clk x -> 0, clkb x -> 1. clr's x -> 1
//            is a posedge; d's x -> 1 is a data event of every check on d
//            (z1 counts as x1, §15.4); clk's x -> 0 and clkb's x -> 1 are
//            only the derived data events of the two $width checks (§15.3.4:
//            "reference event signal with opposite edge"), with no pulse
//            open to close. No reference event precedes any of them, so
//            nothing is measured. The one timecheck among them is
//            $removal's (Table 15-4: its reference event, clr, is the
//            timecheck event): no clk posedge is stamped before it.
//   t = 100: clk rises. $setup, $setuphold, the edge[01, 0x, x1] $setup (en
//            is 1): d last moved at 1, and 100 - 1 >= 10. $recovery,
//            $recrem: clr's one edge is at 1, 99 away. $removal: this is
//            its timestamp event, and no clr edge follows it. $period: the
//            first posedge, nothing to measure.
//   t = 102: clkb falls: the edge[10, x0, 1x] $width opens a low pulse.
//   t = 200: clk falls: $width's high pulse is 100, not below 5.
//   t = 202: clkb rises: the low pulse is 100, not below 5.
//   t = 250: d falls (edge 10): $hold, $setuphold, the edge-list $hold:
//            250 - 100 = 150, not within 10 of the posedge.
//   t = 300: prints q: the one posedge (t = 100) took d = 1, so q=1.
//! inherited IEEE 1364-2005 15.1 15.4
`timescale 1ns/1ns
module b_15_1_timing_check_forms_ff(clk, clkb, d, clr, en, q);
  input clk, clkb, d, clr, en;
  output q;
  reg q;
  reg ntfr;
  always @(posedge clk) q <= d;
  specify
    specparam tSU = 10, tH = 10;
    $setup(d, posedge clk, tSU, ntfr);
    $hold(posedge clk, d, tH, ntfr);
    $setuphold(posedge clk, d, tSU, tH, ntfr);
    $recovery(posedge clr, posedge clk, 10, ntfr);
    $removal(posedge clr, posedge clk, 10, ntfr);
    $recrem(posedge clr, posedge clk, 10, 10, ntfr);
    $period(posedge clk, 20, ntfr);
    $width(posedge clk, 5, 1, ntfr);
    $setup(d, edge[01, 0x, x1] clk &&& en, tSU);
    $width(edge[10, x0, 1x] clkb, 5);
    $hold(posedge clk, edge[01, 10, 0z, z1] d, tH);
  endspecify
endmodule

module b_15_1_timing_check_forms;
  reg clk, clkb, d, clr, en;
  wire q;
  b_15_1_timing_check_forms_ff u(clk, clkb, d, clr, en, q);
  initial begin
    #1 d = 1; clr = 1; en = 1; clk = 0; clkb = 1;
    #99 clk = 1;
    #2 clkb = 0;
    #98 clk = 0;
    #2 clkb = 1;
    #48 d = 0;
    #50 $display("t=300 q=%b", q);
  end
endmodule
