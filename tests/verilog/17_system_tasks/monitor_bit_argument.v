//! inherited IEEE 1364-2005 17.1.3
// $monitor prints only when an argument's value changes; bs[1] changes once
// even though the vector bs changes four times (pr2785294).
module triage_monitor_bit_argument;
  reg [7:0] bs;
  integer i;

  initial begin
    bs = 8'b0;
    $monitor("m %b", bs[1]);
    for (i = 0; i < 4; i = i + 1)
      #1 bs[i] = 1'b1;
    #1 $finish(0);
  end
endmodule
