// Runtime design for callback_object_relations.c. At time 0, q and r are zero;
// q changes to one at 2 ns and to zero at 4 ns. The application registers
// callbacks after initialization, so its surviving value callback runs twice.
`timescale 1ns/1ns
module b26_callbacks;
  reg q, r;
  initial begin
    q = 0;
    r = 0;
    #2 q = 1;
    #2 q = 0;
    #4 $finish(0);
  end
endmodule
