// IEEE 1364-2005 §11.6.2, p. 161: "A procedural continuous assignment (which
// is the assign or force statement; see 9.3) corresponds to a process that is
// sensitive to the source elements in the expression. When the value of the
// expression changes, it causes an active update event to be added to the
// event queue, using current values to determine the target. A deassign or a
// release statement deactivates any corresponding assign or force
// statement(s)."
//
// q, s, t are reg [3:0]; every display is one time step after the change it
// observes, so the update has happened.
//   assign q = s + t, s = 3, t = 4       -> q = 7
//   s = 5: the assign tracks its source  -> q = 5 + 4 = 9
//   force q = s - 1                      -> q = 5 - 1 = 4
//   s = 9: the force tracks its source   -> q = 9 - 1 = 8
//   release q: §9.3.2 (p. 124) "Releasing a variable that currently has an
//     active assign procedural continuous assignment shall immediately
//     reestablish that assignment." The assign is still active, so
//     q = 9 + 4 = 13
//   deassign q, then s = 0: the assign no longer tracks s; q keeps 13.
//! inherited IEEE 1364-2005 11.6.2
`timescale 1ns/1ns
module b_11_6_2_procedural_continuous_tracks_sources;
  reg [3:0] q, s, t;
  initial begin
    s = 3; t = 4;
    assign q = s + t;
    #1 $display("assign: q=%0d", q);
    s = 5;
    #1 $display("assign tracks s: q=%0d", q);
    force q = s - 1;
    #1 $display("force: q=%0d", q);
    s = 9;
    #1 $display("force tracks s: q=%0d", q);
    release q;
    #1 $display("release: q=%0d", q);
    deassign q;
    s = 0;
    #1 $display("deassign: q=%0d", q);
    $finish(0);
  end
endmodule
