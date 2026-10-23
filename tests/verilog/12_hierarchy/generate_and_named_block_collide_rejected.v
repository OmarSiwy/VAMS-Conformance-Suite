//! inherited IEEE 1364-2005 4.11 12.4.1
//! reject E0230
// A generate block and a named block share the module's name space, so the
// two block1 declarations collide (pr1833754).
module triage_generate_and_named_block_collide_rejected;
  localparam up = 1;

  generate
    if (up) begin : block1
      wire count1;
    end
  endgenerate

  initial begin : block1
  end
endmodule
