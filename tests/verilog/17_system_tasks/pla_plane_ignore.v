// IEEE 1364-2005 17.5.4: plane0 complements, plane1 selects true input;
// plane z/? ignores it. Rows 0z,?1,zz mean !input1,input2,constant1
// for AND. input10 ->001; input0x ->1x1. Ignored unknown input must not
// poison the constant row. No expectation for personality x is invented.
//! lrm 9.8
//! inherited IEEE 1364-2005 17.5.4
//! expect stdout pla_plane_ignore.expected.txt
module audit_pla_plane_ignore;
  reg [1:2] personality [1:3];
  reg [1:2] inputs;
  reg [1:3] outputs;
  initial begin
    personality[1] = 2'b0z;
    personality[2] = 2'b?1;
    personality[3] = 2'bzz;
    inputs = 2'b10;
    $sync$and$plane(personality, inputs, outputs);
    $display("known=%b", outputs);
    inputs = 2'b0x;
    $sync$and$plane(personality, inputs, outputs);
    $display("unknown=%b", outputs);
    $finish(0);
  end
endmodule
