// IEEE 1364-2005 §17.1.2, pp. 285-286: "The system task $strobe provides the
// ability to display simulation data at a selected time. That time is the end
// of the current simulation time, when all the simulation events have
// occurred for that simulation time, just before simulation time is
// advanced. The arguments for this task are specified in exactly the same
// manner as for the $display system task--including the use of escape
// sequences for special characters and format specifications (see 17.1.1)."
// Syntax 17-2: strobe_task_name ::= $strobe | $strobeb | $strobeo | $strobeh.
//
// One $strobe per time step, so no order between two strobes of one step is
// assumed. $strobeb/o/h print an argument with no format specification in
// binary/octal/hex, as $displayb/o/h do (§17.1.1.2); $strobe with no argument
// prints only a newline, as $display does (§17.1.1).
//   t=0  a = 1; $strobe queued; $display prints "display a=1" at once;
//        a = 2; the #0 resumes in the same time step and a = 3. At the end
//        of the step the strobe samples a = 3 -> "strobe a=3".
//   t=1  a = 8'h1f; $strobeh queued; a = 8'hc4 -> "c4" (8 bits, two digits).
//   t=2  $strobeb queued; a = 8'h0f -> "00001111".
//   t=3  $strobeo queued, a still 8'h0f = 00 001 111 -> "017" (8 bits, three
//        octal digits, leading zeros kept, §17.1.1.3).
//   t=4  $strobe with no argument -> an empty line.
//! inherited IEEE 1364-2005 17.1.2
`timescale 1ns/1ns
module b_17_1_2_strobe_end_of_step;
  reg [7:0] a;
  initial begin
    a = 8'd1;
    $strobe("strobe a=%0d", a);
    $display("display a=%0d", a);
    a = 8'd2;
    #0 a = 8'd3;
    #1 a = 8'h1f;
    $strobeh(a);
    a = 8'hc4;
    #1 $strobeb(a);
    a = 8'h0f;
    #1 $strobeo(a);
    #1 $strobe;
  end
endmodule
