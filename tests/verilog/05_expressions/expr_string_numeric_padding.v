// IEEE1364-2005 §5.2.3: strings are packed8-bitASCII numbers. Padding
// remains in concatenation:16-bit"A" plus16-bit"B" is00410042, not"AB".
// Nullstring isASCII NUL0, distinctfromASCII digit"0" (30hex).
//! inherited IEEE 1364-2005 5.2.3
module audit_expr_string_numeric_padding;
  reg [15:0] a,b;
  reg [31:0] joined;
  reg [7:0] empty;
  initial begin
    a="A"; b="B"; joined={a,b}; empty="";
    $display("packed=%h equal=%b null=%b digit=%b",joined,joined=="AB",empty==8'h00,empty=="0");
    $finish(0);
  end
endmodule
