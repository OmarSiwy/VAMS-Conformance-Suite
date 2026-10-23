// IEEE 1364-2005 §26.6.20 design for frames.c: an automatic task
// holding one reg, called once at t=1, and a static reg s.
`timescale 1ns/1ns
module b26_frames;
  reg s;
  task automatic at;
    reg x;
    begin
      x = 1'b1;
      s = x;
    end
  endtask
  initial begin
    s = 1'b0;
    #1 at;
    #1 $finish(0);
  end
endmodule
