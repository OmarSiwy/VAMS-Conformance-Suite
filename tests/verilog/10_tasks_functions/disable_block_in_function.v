// IEEE 1364-2005 §10.3, p. 150: "The disable statement can be used to disable
// named blocks within a function, but cannot be used to disable functions."
// ... "Either form of disable statement shall terminate the activity of a task
// or a named block. Execution shall resume at the statement following the
// block or following the task-enabling statement."
//
// first_set(v) scans v from bit 0 in a for loop inside the named block scan
// and disables scan at the first 1; execution resumes after scan, which
// returns the index (or 8 if no bit is set):
//   first_set(8'b0010_1000) -> bit 3 is the lowest 1 -> 3
//   first_set(8'b0000_0000) -> the loop runs out -> 8
//   "3 8"
//! inherited IEEE 1364-2005 10.3
module b_10_3_disable_block_in_function;
  function integer first_set;
    input [7:0] v;
    integer i;
    begin
      first_set = 8;
      begin : scan
        for (i = 0; i < 8; i = i + 1)
          if (v[i]) begin
            first_set = i;
            disable scan;
          end
      end
    end
  endfunction
  initial begin
    $display("%0d %0d", first_set(8'b0010_1000), first_set(8'b0000_0000));
    $finish(0);
  end
endmodule
