// IEEE 1364-2005 §9.5, p. 127: "The default statement shall be optional. Use of
// multiple default statements in one case statement shall be illegal."
//
// Two default items in one case. Legal neighbour: case_linear_search.v,
// whose second case has exactly one default (written first).
//! inherited IEEE 1364-2005 9.5
//! reject E1100
//! reject multiple default items
//! neighbour case_linear_search.v
module b_9_5_multiple_default_rejected;
  reg [1:0] s;
  initial begin
    s = 2'b01;
    case (s)
      default: $display("first default");
      2'b00: $display("zero");
      default: $display("second default");
    endcase
  end
endmodule
