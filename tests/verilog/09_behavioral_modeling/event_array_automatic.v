// IEEE 1364-2005 §§9.7.3, 10.2.1–10.2.3: every automatic invocation
// allocates its own declared items. An indexed wait reads that invocation's
// formal, and two local events with the same declaration/index are distinct.
//
// DERIVATION: three recursive select invocations reach depth=0 at t=2.
// The sender fires global_ev[0] at t=3 and global_ev[1] at t=4; the two
// readers have ix=0 and ix=1, so global_mask becomes 1 then 3. Dispatching
// either occurrence must restore the sender's ix=2 before it continues.
// Two recursive local invocations reach depth=0 at t=1, with id=0 and 1.
// Each waits for its own local_ev[0], scalar and named-block nested_ev[0].
// Their senders fire at t=3 and t=4 respectively, so the three local masks
// are 1 at t=3 and 3 at t=5.
// The trailing delays keep these activations alive through both observations.
// Scalar events are the legal neighbor; invalid array references are covered
// by b_9_7_3_event_array_*_rejected.v.
//! inherited IEEE 1364-2005 9.7.3
//! inherited IEEE 1364-2005 10.2.1
//! inherited IEEE 1364-2005 10.2.3
// native-required
`timescale 1ns/1ns
module b_9_7_3_event_array_automatic;
  event global_ev [0:1];
  integer global_mask, local_mask, scalar_mask, nested_mask, restore_errors;
  task automatic select(input integer depth, input integer ix, input integer send);
    begin
      if (depth != 0) begin #1 select(depth-1, ix, send); end
      else if (send) begin
        #1 -> global_ev[0];
        if (ix != 2) restore_errors = restore_errors + 1;
        #1 -> global_ev[1];
        if (ix != 2) restore_errors = restore_errors + 1;
      end else begin
        @(global_ev[ix]);
        global_mask = global_mask | (1 << ix);
      end
    end
  endtask
  task automatic local(input integer depth, input integer id);
    event local_ev [0:0], scalar;
    begin : named_local
      event nested_ev [0:0];
      if (depth != 0) begin #1 local(depth-1, id); end
      else fork
        begin @(local_ev[0]); local_mask = local_mask | (1 << id); #20; end
        begin @(scalar); scalar_mask = scalar_mask | (1 << id); #20; end
        begin @(nested_ev[0]); nested_mask = nested_mask | (1 << id); #20; end
        begin #(id+2) -> local_ev[0]; -> scalar; -> nested_ev[0]; #20; end
      join
    end
  endtask
  initial select(2, 0, 0);
  initial select(2, 1, 0);
  initial select(2, 2, 1);
  initial local(1, 0);
  initial local(1, 1);
  initial begin
    global_mask = 0; local_mask = 0; scalar_mask = 0; nested_mask = 0; restore_errors = 0;
    #3 #0 $display("first: global=%0d local=%0d scalar=%0d nested=%0d restore=%0d", global_mask, local_mask, scalar_mask, nested_mask, restore_errors);
    #2 $display("both: global=%0d local=%0d scalar=%0d nested=%0d restore=%0d", global_mask, local_mask, scalar_mask, nested_mask, restore_errors);
    $finish(0);
  end
endmodule
