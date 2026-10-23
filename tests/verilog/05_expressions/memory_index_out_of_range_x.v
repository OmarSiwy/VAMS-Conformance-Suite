//! inherited IEEE 1364-2005 5.2.2
// An index outside the declared range reads x: array[a] with a = -1 and
// array[b] with b = 2**120 + 7 both return xxxx (signed_a).
module triage_memory_index_out_of_range_x;
  reg [3:0] array [1:8];
  reg signed [2:0] a;
  reg signed [127:0] b;
  reg [4*8:1] res;

  initial begin
    array[7] = 4'b1001;
    a = -1;
    $sformat(res, "%b", array[a]);
    if (res !== "xxxx") $display("FAILED a %s", res);
    else begin
      b = 7;
      b[120] = 1'b1;
      $sformat(res, "%b", array[b]);
      if (res !== "xxxx") $display("FAILED b %s", res);
      else $display("PASSED");
    end
  end
endmodule
