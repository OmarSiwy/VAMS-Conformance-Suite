// IEEE1364-2005 §17.2.4.3 printed293: unknown bits in either format or
// sscanf input require EOF(-1), not a partial conversion or successful zero.
// Explicit packed reg assignment isolates four-state input from host files.
//! inherited IEEE 1364-2005 17.2.4.3
module audit_sscanf_unknown_input;
  reg [15:0] text;
  reg [15:0] format;
  integer status, value;
  initial begin
    text = 16'h31xx;
    format = 16'h2564;
    value = 73;
    status = $sscanf(text, format, value);
    $display("unknown_input=%0d", status);
    text = 16'h3132;
    format = 16'h25zz;
    status = $sscanf(text, format, value);
    $display("unknown_format=%0d", status);
    $finish(0);
  end
endmodule
