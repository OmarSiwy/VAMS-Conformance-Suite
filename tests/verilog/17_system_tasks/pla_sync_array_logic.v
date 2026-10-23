// IEEE 1364-2005 17.5–17.5.4: ascending input/output and personality ranges.
// Direct assignment is explicitly permitted; no readmem dependency is needed.
// Row1 selects both inputs; row2 selects only input1. With input10:
// AND=(0,1), OR=(1,1); NAND/NOR complement these two result bits.
// With inputx0: AND=(0,x), OR=(x,x); complements give (1,x),(x,x).
// This is input uncertainty, NOT an x-valued array personality encoding.
//! lrm 9.8
//! inherited IEEE 1364-2005 17.5
//! expect stdout pla_sync_array_logic.expected.txt
module audit_pla_sync_array_logic;
  reg [1:2] personality [1:2];
  reg [1:2] inputs;
  reg [1:2] yand, yor, ynand, ynor;
  initial begin
    personality[1] = 2'b11;
    personality[2] = 2'b10;
    inputs = 2'b10;
    $sync$and$array(personality, inputs, yand);
    $sync$or$array(personality, inputs, yor);
    $sync$nand$array(personality, inputs, ynand);
    $sync$nor$array(personality, inputs, ynor);
    $display("known and=%b or=%b nand=%b nor=%b", yand, yor, ynand, ynor);
    inputs = 2'bx0;
    $sync$and$array(personality, inputs, yand);
    $sync$or$array(personality, inputs, yor);
    $sync$nand$array(personality, inputs, ynand);
    $sync$nor$array(personality, inputs, ynor);
    $display("unknown and=%b or=%b nand=%b nor=%b", yand, yor, ynand, ynor);
    $finish(0);
  end
endmodule
