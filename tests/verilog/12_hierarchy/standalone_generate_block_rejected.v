//! inherited IEEE 1364-2005 12.4 A.4.2
//! reject not a module item: found `begin`
// A generate_block is only the body of a loop or conditional generate; a
// bare begin...end module item was removed in 1364-2005 (br988).
module triage_standalone_generate_block_rejected;
  parameter P = 1'b1;

  generate
    if (P) begin : outer
      begin : inner
        reg [1:0] a = 2;
      end
    end
  endgenerate
endmodule
