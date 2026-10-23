//! inherited IEEE 1364-2005 6.1.4 7.10
// Drive strengths on continuous assignments to two different part-selects of
// one net are kept per bit: (pull1,strong0) drivers on w[1:0] and w[3:2]
// resolve 1000 (br918a).
module triage_part_select_drive_strengths;
  reg [1:0] v1, v2, v3, v4;
  wire [3:0] w;

  assign (pull1, strong0) w[1:0] = v1;
  assign (pull1, strong0) w[1:0] = v2;
  assign (pull1, strong0) w[3:2] = v3;
  assign (pull1, strong0) w[3:2] = v4;

  initial begin
    v1 = 2'b00;
    v2 = 2'b10;
    v3 = 2'b11;
    v4 = 2'b10;
    #1 if (w === 4'b1000) $display("PASSED"); else $display("FAILED %b", w);
  end
endmodule
