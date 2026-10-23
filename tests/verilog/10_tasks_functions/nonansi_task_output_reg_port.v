//! inherited IEEE 1364-2005 10.2.1
// A non-ANSI output port's type and range may come from the following
// reg declaration (task_iotypes).
module triage_nonansi_task_output_reg_port;
  reg [7:0] result;
  reg [3:0] in;

  task t;
    input [3:0] i;
    output [7:0] o;
    reg [7:0] o;
    begin
      o = i + 1;
    end
  endtask

  initial begin
    in = 4'd7;
    t(in, result);
    if (result === 8'd8)
      $display("PASSED");
    else
      $display("FAILED %0d", result);
  end
endmodule
