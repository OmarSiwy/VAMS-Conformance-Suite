// IEEE 1364-2005 §9.5.2, p. 129: "A constant expression can be used for case
// expression. The value of the constant expression shall be compared against
// case item expressions."
// The clause's example, a 3-bit priority encoder with case (1).
//
// case (1) against encode[2], encode[1], encode[0]: the constant 1 is 32 bits
// and signed, each item is a 1-bit unsigned bit-select, so all are compared as
// 32-bit unsigned (§9.5); the first item whose bit is 1 matches.
//   encode = 3'b110 -> encode[2] = 1        -> "Select Line 2"
//   encode = 3'b011 -> encode[2] = 0, [1] = 1 -> "Select Line 1"
//   encode = 3'b001 -> only [0]             -> "Select Line 0"
//   encode = 3'b000 -> no item matches      -> the default
//! inherited IEEE 1364-2005 9.5.2
module b_9_5_2_constant_case_expression;
  reg [2:0] encode;

  task show;
    case (1)
      encode[2] : $display("Select Line 2") ;
      encode[1] : $display("Select Line 1") ;
      encode[0] : $display("Select Line 0") ;
      default $display("Error: One of the bits expected ON");
    endcase
  endtask

  initial begin
    encode = 3'b110; show;
    encode = 3'b011; show;
    encode = 3'b001; show;
    encode = 3'b000; show;
    $finish(0);
  end
endmodule
