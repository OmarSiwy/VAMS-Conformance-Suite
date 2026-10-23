// IEEE 1364-2005 §§5.2.2 and 9.7.3: an event array is selected by its
// integer address, including a wide sign-extended negative address. Its
// current selector is evaluated when an event occurs. The legal triggers
// at times 1 and 3 match -1 and -2 respectively. Neither the unmatched
// trigger at 2 nor a selector with high nonzero/x bits selects an element.
// No invalid form is invented for a legal wide index; the real-index
// rejection is native_wide_event_real_index_rejected.v.
//! inherited IEEE 1364-2005 5.2.2 9.7.3
// native-required
module native_wide_event_indices;
  event ready[-1:-2];
  reg signed [129:0] selected;
  integer wakes;
  initial begin
    wakes = 0; selected = -130'sd1;
    #1 -> ready[-130'sd1];
    #1 selected = -130'sd2;
       -> ready[-130'sd1];
    #1 -> ready[selected];
    #1 selected = (130'sd1 << 64) - 130'sd2;
       -> ready[-130'sd2];
    #1 selected = {66'bx, 64'hfffffffffffffffe};
       -> ready[-130'sd2];
    #1 $display("total %0d", wakes);
    $finish(0);
  end
  always @(ready[selected]) begin
    wakes = wakes + 1;
    $display("wake %0d %0d", wakes, $time);
  end
endmodule
