// IEEE 1364-2005 §§9.7.3, 10.2.1: each invocation of an automatic task
// allocates every declared item, including its events. A formal used as an
// event-array index belongs to the waiting invocation.
//
// DERIVATION: two nonrecursive automatic calls wait on global_ev[id] and
// on their own local_ev[0], scalar and named-block nested_ev[0]. Their
// senders fire at t=2 and t=3. Thus all four masks are 1 after the first
// occurrence and 3 after the second. The same local declaration/index in
// the second invocation must not wake at t=2. A second call through the
// same wrapper source verifies the inlined nested frame's identity too.
// #0 samples after active waiters; the long trailing delays keep both
// activations alive. Recursive timed tasks remain a separate native gap.
// Invalid neighbors: b_9_7_3_event_array_*_rejected.v.
//! inherited IEEE 1364-2005 9.7.3
//! inherited IEEE 1364-2005 10.2.1
//! inherited IEEE 1364-2005 10.2.3
// native-required
`timescale 1ns/1ns
module b_9_7_3_event_array_native_automatic;
  event global_ev [0:1];
  integer global_mask, local_mask, scalar_mask, nested_mask;
  task automatic local(input integer id);
    event local_ev [0:0], scalar;
    begin : named_local
      event nested_ev [0:0];
      fork
        begin @(global_ev[id]); global_mask = global_mask | (1 << id); #20; end
        begin @(local_ev[0]); local_mask = local_mask | (1 << id); #20; end
        begin @(scalar); scalar_mask = scalar_mask | (1 << id); #20; end
        begin @(nested_ev[0]); nested_mask = nested_mask | (1 << id); #20; end
        begin
          #(id+2) -> global_ev[id]; -> local_ev[0]; -> scalar; -> nested_ev[0];
          #20;
        end
      join
    end
  endtask
  task automatic wrapper(input integer id);
    local(id);
  endtask
  initial wrapper(0);
  initial wrapper(1);
  initial begin
    global_mask = 0; local_mask = 0; scalar_mask = 0; nested_mask = 0;
    #2 #0 $display("first: global=%0d local=%0d scalar=%0d nested=%0d", global_mask, local_mask, scalar_mask, nested_mask);
    #2 $display("both: global=%0d local=%0d scalar=%0d nested=%0d", global_mask, local_mask, scalar_mask, nested_mask);
    $finish(0);
  end
endmodule
