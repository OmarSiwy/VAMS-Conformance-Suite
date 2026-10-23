// IEEE 1364-2005 17.5.1/.3: async reevaluates on input OR memory changes;
// sync waits for reinvocation. Row11 ANDs both inputs, row10 selects input1.
// Observe after a positive time separation, not a race in the update region.
// This checks reevaluation by the later observation, not same-step timing or
// exact scheduler-region order.
//! lrm 9.8
//! lrm 9.8:1000
//! inherited IEEE 1364-2005 17.5.1,17.5.3
//! expect stdout pla_async_personality.expected.txt
module audit_pla_async_personality;
  reg [1:2] personality [1:1];
  reg [1:2] inputs;
  reg asynchronous, synchronous;
  initial begin
    personality[1] = 2'b11;
    inputs = 2'b11;
    $async$and$array(personality, inputs, asynchronous);
    $sync$and$array(personality, inputs, synchronous);
    #1 $display("initial async=%b sync=%b", asynchronous, synchronous);
    inputs = 2'b10;
    #1 $display("input async=%b sync=%b", asynchronous, synchronous);
    personality[1] = 2'b10;
    #1 $display("memory async=%b sync=%b", asynchronous, synchronous);
    inputs = 2'b00;
    #1 $display("held async=%b sync=%b", asynchronous, synchronous);
    $sync$and$array(personality, inputs, synchronous);
    $display("called async=%b sync=%b", asynchronous, synchronous);
    $finish(0);
  end
endmodule
