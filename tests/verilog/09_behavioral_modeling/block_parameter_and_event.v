// IEEE 1364-2005 §9.8.3, pp. 141-142: "The naming of blocks serves several
// purposes: — It allows local variables, parameters, and named events to be
// declared for the block."
// §9.8.1, p. 140 (Syntax 9-13): "block_item_declaration ::= ... | {
// attribute_instance } event_declaration | { attribute_instance }
// local_parameter_declaration ; | { attribute_instance }
// parameter_declaration ;".
//
//   begin : blk declares parameter step = 5, localparam twice = 2 * step = 10
//   and event go; a fork inside waits on @go in one branch and triggers
//   #1 -> go in the other, so the waiting branch runs at t=1:
//   total = step + twice = 15 -> "15 1"
//! inherited IEEE 1364-2005 9.8.3
`timescale 1ns/1ns
module b_9_8_3_block_parameter_and_event;
  integer total;

  initial begin
    begin : blk
      parameter step = 5;
      localparam twice = 2 * step;
      event go;
      fork
        @go total = step + twice;
        #1 -> go;
      join
    end
    $display("%0d %0d", total, $time);
    $finish(0);
  end
endmodule
