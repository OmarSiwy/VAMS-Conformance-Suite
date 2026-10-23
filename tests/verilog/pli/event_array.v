// IEEE 1364-2005 §9.7.3 / AMS §5.10.4. Distinct event elements hold no data.
// At t=1 and 3 eva[0] occurs; at t=4 eva[1] occurs. i changes at t=2,
// but that does not cause an event. Thus c0=2, c1=1, selected=2 at t=5.
// The C application adds one eva[1], descending[3], matrix[0][3] and scalar
// occurrence at t=6; their waiters must run before its read-only callback.
// The constant source references include wide integer indices; VPI must
// canonicalize them to the same persistent element objects as narrow ones.
`timescale 1ns/1ns
module b26_event_array;
  parameter LO = -1;
  event eva [0:1], descending [3:2], matrix [LO:0][4:3], scalar;
  integer c0, c1, selected, desc_hits, matrix_hits, scalar_hits, i, task_hits, block_hits, retained_hits;
  task work;
    event local_ev [3:2];
    integer local_index;
    begin
      local_index = 2;
      fork
        begin @(local_ev[local_index]); task_hits = task_hits + 1; end
        begin #1 -> local_ev[local_index]; end
      join
    end
  endtask
  task automatic auto_work(input integer automatic_index);
    event local_ev [0:0];
    -> local_ev[automatic_index];
  endtask
  initial begin #7 work(); end
  initial begin #8 auto_work(0); end
  initial begin #8 -> eva[$event_index()]; end
  initial begin : local_block
    event local_ev [1:-1];
    block_hits = 0;
    fork
      begin @(local_ev[-1]); block_hits = block_hits + 1; end
      begin #7 -> local_ev[-1]; end
    join
  end
  initial begin
    c0 = 0; c1 = 0; selected = 0; desc_hits = 0;
    matrix_hits = 0; scalar_hits = 0; task_hits = 0; i = 0; retained_hits = 0;
    #1 -> eva[130'd0];
    #1 i = 1;
    #1 -> eva[0];
    #1 -> eva[i];
    #1 begin -> descending[130'd2]; -> matrix[-130'sd1][130'd4]; -> scalar; end
    #5 $finish(0);
  end
  always @(eva[0]) c0 = c0 + 1;
  always @(eva[1]) c1 = c1 + 1;
  always @(eva[i]) selected = selected + 1;
  always @(descending[2] or descending[3]) desc_hits = desc_hits + 1;
  always @(matrix[-1][4], matrix[0][3]) matrix_hits = matrix_hits + 1;
  always @(scalar) scalar_hits = scalar_hits + 1;
  always @(work.local_ev[2]) retained_hits = retained_hits + 1;
endmodule
