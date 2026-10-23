// IEEE 1364-2005 §9.8.3, pp. 141-142: "Both sequential and parallel blocks can
// be named by adding : name_of_block after the keywords begin or fork. The
// naming of blocks serves several purposes: — It allows local variables,
// parameters, and named events to be declared for the block. — It allows the
// block to be referenced in statements such as the disable statement (see
// 10.3). All variables shall be static; that is, a unique location exists for
// all variables, and leaving or entering blocks shall not affect the values
// stored in them. The block names give a means of uniquely identifying all
// variables at any simulation time."
//
//   The named sequential block acc declares integer count; it runs three
//   times (repeat), adding 5 to count each time and never resetting it
//   (count starts x, §4.2.2, and is set to 0 on the first entry only):
//   5, 10, 15. (Reading acc.count by the block's name from outside:
//   block_name_reference.v.)
//   (Declarations in a named parallel block: named_fork_declarations.v;
//   a block's parameters and events: block_parameter_and_event.v.)
//   The named block skip is disabled by name before its second statement:
//   k stays 1.
//! inherited IEEE 1364-2005 9.8.3
module b_9_8_3_named_block_variables;
  integer k;

  initial begin
    repeat (3) begin : acc
      integer count;
      if (count === 32'bx) count = 0;
      count = count + 5;
      $display("%0d", count);
    end
    k = 0;
    begin : skip
      k = 1;
      disable skip;
      k = 2;
    end
    $display("%0d", k);
    $finish(0);
  end
endmodule
