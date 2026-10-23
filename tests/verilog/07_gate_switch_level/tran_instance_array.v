//! inherited IEEE 1364-2005 7.1.5 7.1.6
// An array of tran instances takes vector terminals, one bit per instance:
// tran t[1:0](a, b) joins a[0]-b[0] and a[1]-b[1] (pr3296466c).
module triage_tran_instance_array;
  reg foo, bar;
  tri [1:0] a, b;

  assign a[0] = foo;
  assign b[1] = bar;

  tran t[1:0](a, b);

  initial begin
    foo = 1'b1;
    bar = 1'b0;
    #1 if (a === 2'b01 && b === 2'b01) $display("PASSED"); else $display("FAILED %b %b", a, b);
  end
endmodule
