// IEEE1364-2005 10.2.2 printed147-148: input/inout copy in at enable;
// output/inout copy out only at return, all by value. Input formal writes
// do not write its actual. Distinct time1/time2 observations avoid races.
// At enable i=2, io=11; task sets o=4, io=13, i=99. At time1 callers
// still show out9/io11, and caller source changes to7. At time2 copy-out
// yields out4/io13 while input source remains7, not99.
//! lrm 1.1
//! inherited IEEE 1364-2005 10.2.2
//! expect stdout task_copy_timing.expected.txt
`timescale 1ns/1ns
module audit_task_copy_timing;
  integer source, result, shared_value;
  task transfer;
    input integer i;
    output integer o;
    inout integer io;
    begin
      o = i + 2; io = io + i; i = 99;
      #2;
    end
  endtask
  initial begin
    source = 2; result = 9; shared_value = 11;
    transfer(source, result, shared_value);
    $display("return input=%0d output=%0d inout=%0d", source, result, shared_value);
    $finish(0);
  end
  initial begin
    #1;
    source = 7;
    $display("during output=%0d inout=%0d", result, shared_value);
  end
endmodule
