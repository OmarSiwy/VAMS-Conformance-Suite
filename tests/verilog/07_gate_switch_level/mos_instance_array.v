//! inherited IEEE 1364-2005 7.1.5 7.1.6
// An array of nmos instances takes vector terminals, one bit per instance:
// nmos buffer[7:0](value2, value1, 1'b1) passes value1 bit by bit (br_gh99j).
module triage_mos_instance_array;
  wire [7:0] value1, value2;

  assign value1[3:0] = 4'd2;

  nmos buffer [7:0] (value2, value1, 1'b1);

  initial begin
    #2;
    if (value2 === 8'bzzzz0010) $display("PASSED");
    else $display("FAILED %b", value2);
  end
endmodule
