//! inherited IEEE 1364-2005 9.3.1
//! reject a procedural continuous assignment names one whole variable or net
// assign/deassign name one whole variable; a bit-select of a reg is not one
// (assign3.2E).
module triage_assign_to_reg_select_rejected;
  reg [3:0] value;

  initial begin
    assign {value[3], value[2], value[1], value[0]} = 4'h2;
  end
endmodule
