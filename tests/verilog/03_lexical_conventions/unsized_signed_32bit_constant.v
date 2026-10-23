//! inherited IEEE 1364-2005 3.5.1
// 'shffffffff is a 32-bit signed unsized constant, negative one (pr3522653).
module triage_unsized_signed_32bit_constant;
  initial begin
    if ('shffffffff === -1 && $signed('shffffffff) === -1)
      $display("PASSED");
    else
      $display("FAILED");
  end
endmodule
