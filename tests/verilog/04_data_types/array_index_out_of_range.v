//! inherited IEEE 1364-2005 5.2.2
// An index outside the declared range reads x: both a negative index and a
// 128-bit index whose low bits are in range are out of range (signed_a).
module triage_array_index_out_of_range;
  reg [3:0] array [1:8];
  reg signed [2:0] neg;
  reg signed [127:0] wide;

  initial begin
    array[7] = 4'b1001;
    neg = -1;
    wide = 7;
    wide[120] = 1'b1;
    if (array[neg] === 4'bxxxx && array[wide] === 4'bxxxx)
      $display("PASSED");
    else
      $display("FAILED %b %b", array[neg], array[wide]);
  end
endmodule
