// IEEE 1364-2005 §§9.7.3–9.7.4, 9.7.7: an indexed event selects an
// occurrence; changing the index does not trigger it. Event-or resumes
// once, retiring its other terms. Intra-assignment controls retain the RHS
// sampled before suspension, including a repeated nonblocking control.
//
// DERIVATION: ix changes from -1 to 1 before ev[-1] at t=1, so only the
// fixed -1 waiter fires. Invalid trigger indices name no event; an unsigned
// 64-bit all-ones index is out of range, not signed -1. other at t=2 wakes
// the OR waiter once even though it occurs twice before that waiter runs.
// ev[1] at t=3 is the second NBA-control event: held=7, nba=9, although
// source has become 99. The indexed waiter has its first occurrence then.
// ix becomes 0 at t=4; ev[0] at t=4,5,6 makes its final count 4 and the OR
// count 5. The repeat body runs twice. X/Z indices select nothing; changing
// unknown_index to 0 before t=5 permits exactly two occurrences. A pure
// function index sees the same ix. The t=6 trigger function executes once.
// Invalid syntax neighbors: b_9_7_3_event_array_*_rejected.v.
//! inherited IEEE 1364-2005 9.7.3
//! inherited IEEE 1364-2005 9.7.4
//! inherited IEEE 1364-2005 9.7.7
// native-required
`timescale 1ns/1ns
module b_9_7_3_event_array_native_selection;
  event ev [-1:1], other;
  integer ix, hits, fixed_hits, or_hits, wide_hits, x_hits, fn_hits;
  integer source, held, nba, repeat_hits, trigger_calls;
  reg [63:0] unsigned_index;
  reg [1:0] unknown_index;
  function integer index_of(input integer unused);
    index_of = ix;
  endfunction
  function integer trigger_index(input integer unused);
    begin trigger_calls = trigger_calls + 1; trigger_index = 0; end
  endfunction
  initial begin
    ix = -1; hits = 0; fixed_hits = 0; or_hits = 0; wide_hits = 0;
    x_hits = 0; fn_hits = 0; source = 7; held = 0; nba = 0;
    repeat_hits = 0; trigger_calls = 0;
    unsigned_index = 64'hffffffffffffffff; unknown_index = 2'bxx;
    #1 begin
      ix = 1; source = 99;
      -> ev[-1]; -> ev[64'hffffffffffffffff]; -> ev[2]; -> ev[2'bxx];
    end
    #1 begin
      $display("early: hits=%0d fixed=%0d or=%0d wide=%0d x=%0d held=%0d nba=%0d", hits, fixed_hits, or_hits, wide_hits, x_hits, held, nba);
      -> other; -> other;
    end
    #1 -> ev[1];
    #1 begin
      $display("sampled: hits=%0d or=%0d held=%0d nba=%0d repeat=%0d", hits, or_hits, held, nba, repeat_hits);
      ix = 0; unknown_index = 2'bzz; -> ev[0];
    end
    #1 begin unknown_index = 0; -> ev[0]; end
    #1 begin unsigned_index = 0; -> ev[trigger_index(0)]; end
    #1 begin
      $display("final: hits=%0d fixed=%0d or=%0d wide=%0d x=%0d function=%0d held=%0d nba=%0d repeat=%0d calls=%0d", hits, fixed_hits, or_hits, wide_hits, x_hits, fn_hits, held, nba, repeat_hits, trigger_calls);
      $finish(0);
    end
  end
  always @(ev[ix]) hits = hits + 1;
  always @(ev[-1]) fixed_hits = fixed_hits + 1;
  always @(ev[ix] or other) or_hits = or_hits + 1;
  always @(ev[unsigned_index]) wide_hits = wide_hits + 1;
  always @(ev[unknown_index]) x_hits = x_hits + 1;
  always @(ev[index_of(0)]) fn_hits = fn_hits + 1;
  initial held = @(ev[ix]) source;
  initial nba <= repeat(2) @(ev[ix] or other) 9;
  initial repeat(2) begin @(ev[ix]); repeat_hits = repeat_hits + 1; end
endmodule
