// IEEE1364-2005 10.2.3 printed149: static task output formals retain
// values between invocations; automatic outputs initialize afresh to x.
// An output is NOT copied in from the caller. Set first formal to0101,
// change actual to1010, then leave formal unwritten. Static returns0101;
// automatic returnsxxxx. Do not assume any integer default is zero.
//! lrm 1.1
//! inherited IEEE 1364-2005 10.2.3
//! expect stdout task_output_lifetime.expected.txt
module audit_task_output_lifetime;
  reg [3:0] s, a;
  task retained(input set_value, output [3:0] out);
    if (set_value) out = 4'b0101;
  endtask
  task automatic fresh(input set_value, output [3:0] out);
    if (set_value) out = 4'b0101;
  endtask
  initial begin
    retained(1'b1,s); fresh(1'b1,a);
    $display("first %b %b",s,a);
    s=4'b1010; a=4'b1010;
    retained(1'b0,s); fresh(1'b0,a);
    $display("second %b %b",s,a);
    $finish(0);
  end
endmodule
