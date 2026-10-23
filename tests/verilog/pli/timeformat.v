// Runtime design for timeformat.c. Calls execute at 1, 2, 4 and
// 5 ns, in the top, a.set_format, b.set_format and the top respectively.
// The two child calls share one source token but belong to different
// instances. The final call uses §17.3.2's no-argument defaults.
`timescale 1ns/1ns
module b26_timeformat;
  timeformat_child #(.D(2)) a();
  timeformat_child #(.D(4)) b();
  initial begin
    #1 $timeformat(-9, 2, " ns", 0);
    #4 $timeformat;
    #2 $finish(0);
  end
endmodule

module timeformat_child;
  parameter D = 2;
  task set_format;
    $timeformat(-12, 1, " ps", 0);
  endtask
  initial #D set_format;
endmodule
