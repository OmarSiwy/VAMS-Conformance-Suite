// IEEE 1364-2005 §15.7 (p. 266): "Either or both signals in a timing check
// can be a vector. This shall be interpreted as a single timing check where
// the transition of one or more bits of a vector is considered a single
// transition of that vector." Its example: "$setup (DAT, posedge CLK, 10);
// ... If DAT transitions from 'b00101110 to 'b01010011 at time 100 and if CLK
// transitions from 0 to 1 at time 105, then the $setup timing check shall
// still only report a single timing violation." A.7.3: a terminal may be a
// constant bit- or part-select, `input_identifier [ [
// constant_range_expression ] ]`; its data events are its own bits'.
//
// The cell runs the example, its notifier ntfr 0 from t=1: one violation is
// one toggle, so ntfr ends 1 (six, one per changed bit, would leave it 0).
// Three more copies watch selects of dat, each with its own notifier:
//   dat[0]   0 -> 1 at 100: a data event, so it violates: nb = 1
//   dat[3:2] 2'b11 -> 2'b00 at 100: a data event: np = 1
//   dat[7]   0 -> 0: no event at 100, and the last one, at 0, is outside
//            (95, 105): nh = 0
// DERIVATION: t=0 clk x -> 0 (no posedge) and dat x -> 'b00101110 (a data
// event); t=100 dat -> 'b01010011; t=105 clk rises: (95, 105) holds 100.
//! inherited IEEE 1364-2005 15.7
`timescale 1ns/1ns
module b_15_7_vector_ff(clk, dat);
  input clk;
  input [7:0] dat;
  reg ntfr, nb, np, nh;
  initial #1 begin
    ntfr = 0; nb = 0; np = 0; nh = 0;
  end
  specify
    $setup(dat, posedge clk, 10, ntfr);
    $setup(dat[0], posedge clk, 10, nb);
    $setup(dat[3:2], posedge clk, 10, np);
    $setup(dat[7], posedge clk, 10, nh);
  endspecify
endmodule

module b_15_7_vector;
  reg clk;
  reg [7:0] dat;
  b_15_7_vector_ff u(clk, dat);
  initial begin
    clk = 0; dat = 'b00101110;
    #100 dat = 'b01010011;
    #5 clk = 1;
    #5 $display("t=%0d ntfr=%b nb=%b np=%b nh=%b", $time, u.ntfr, u.nb, u.np, u.nh);
    $finish(0);
  end
endmodule
