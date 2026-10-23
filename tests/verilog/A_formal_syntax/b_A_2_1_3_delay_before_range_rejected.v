// IEEE 1364-2005 A.2.1.3 writes a net declaration's range before its delay:
//     net_type [ signed ] range [ delay3 ] list_of_net_decl_assignments ;
// and A.2.2.3's unparenthesized delay is one delay_value (unsigned_number |
// real_number | identifier), not an expression. `wire #3 [7:0] dw = a;`
// puts the range after the delay, which no alternative derives: a syntax
// error at the `[`. Before #63 VerA read `#3 [7:0]` as a part-select of the
// literal 3 and failed late with a select error.
// Legal neighbour: b_A_2_1_3_range_then_delay.v (`wire [7:0] #3 dw = a;`).
//! inherited IEEE 1364-2005 A.2.1.3 A.2.2.3
//! reject E0207
//! reject a net's range comes before its delay
//! neighbour b_A_2_1_3_range_then_delay.v
module b_A_2_1_3_delay_before_range_rejected;
  reg [7:0] a;
  wire #3 [7:0] dw = a;
  initial $display("unreachable");
endmodule
