// IEEE 1364-2005 §15.5 (pp. 259-260): "The notifier is a reg, declared in the
// module where timing check tasks are invoked, that is passed as the last
// argument to a system timing check. Whenever a timing violation occurs, the
// timing check updates the value of the notifier." Table 15-13, BEFORE
// violation -> AFTER violation: x -> "Either 0 or 1", 0 -> 1, 1 -> 0, z -> z.
// "The notifier is an optional argument to all system timing checks".
//
// The cell: four copies of $setup(d, posedge clk, 5, n), each with its own
// notifier, which start (at t=1) at x (nx is never assigned), 0, 1 and z, and
// a fifth copy with no notifier at all. Every copy sees the same events, so
// each violates when the others do.
//
// DERIVATION (t in ns; a reference event at T has the window (T-5, T)):
//   t=10 d rises; t=12 clk rises: 10 is in (7, 12): one violation each.
//   t=15 nx is 0 or 1, which the clause leaves to the tool, so the line
//        prints whether it is a known value, not which: nx_known=1; n0=1,
//        n1=0, nz=z.
//   t=18 clk falls; t=20 d falls; t=22 clk rises: 20 is in (17, 22): one
//        violation each again.
//   t=25 nx is still 0 or 1 (it toggled from one to the other); n0=0, n1=1,
//        nz=z.
// The notifier-free copy violates too, which only its W1199 report shows
// (each check reports its first violation, VD-105); it is here for running
// at all.
//! inherited IEEE 1364-2005 15.5
`timescale 1ns/1ns
module b_15_5_notifier_ff(clk, d);
  input clk, d;
  reg nx, n0, n1, nz;
  initial #1 begin
    n0 = 1'b0;
    n1 = 1'b1;
    nz = 1'bz;
  end
  specify
    $setup(d, posedge clk, 5, nx);
    $setup(d, posedge clk, 5, n0);
    $setup(d, posedge clk, 5, n1);
    $setup(d, posedge clk, 5, nz);
    $setup(d, posedge clk, 5);
  endspecify
endmodule

module b_15_5_notifier;
  reg clk, d;
  b_15_5_notifier_ff u(clk, d);
  initial begin
    clk = 0; d = 0;
    #10 d = 1;
    #2 clk = 1;
    #3 $display("t=%0d nx_known=%b n0=%b n1=%b nz=%b", $time, u.nx === 1'b0 || u.nx === 1'b1, u.n0, u.n1, u.nz);
    #3 clk = 0;
    #2 d = 0;
    #2 clk = 1;
    #3 $display("t=%0d nx_known=%b n0=%b n1=%b nz=%b", $time, u.nx === 1'b0 || u.nx === 1'b1, u.n0, u.n1, u.nz);
    $finish(0);
  end
endmodule
