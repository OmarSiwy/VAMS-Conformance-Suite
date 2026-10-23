// IEEE 1364-2005 §8.1.2: "Implementations may limit the maximum number of
// inputs to a UDP, but they shall allow at least 9 inputs for sequential UDPs
// and 10 inputs for combinational UDPs." VerA capped them at 64 (E1017) until
// 2026-10 and now sets no cap. This combinational UDP has 65 inputs, one past
// the old cap; its one row is 65 ones.
// input_minimums.v pins the minimums the clause requires.
//
// HAND DERIVATION. §8.1.6: a combinational UDP's output is the row its inputs
// match, and x when they match no row.
//   all 65 inputs 1: the row matches, q = 1.
//   i64 = 0: no row matches, q = x.
//   i64 = 1 again: q = 1.
//! inherited IEEE 1364-2005 8.1.2
//! expect stdout udp_65_inputs.expected.txt
//! neighbour input_minimums.v
primitive and65(q, i0, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23, i24, i25, i26, i27, i28, i29, i30, i31, i32, i33, i34, i35, i36, i37, i38, i39, i40, i41, i42, i43, i44, i45, i46, i47, i48, i49, i50, i51, i52, i53, i54, i55, i56, i57, i58, i59, i60, i61, i62, i63, i64);
  output q;
  input i0, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23, i24, i25, i26, i27, i28, i29, i30, i31, i32, i33, i34, i35, i36, i37, i38, i39, i40, i41, i42, i43, i44, i45, i46, i47, i48, i49, i50, i51, i52, i53, i54, i55, i56, i57, i58, i59, i60, i61, i62, i63, i64;
  table
    1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 : 1;
  endtable
endprimitive
module b_8_1_2_udp_65_inputs;
  reg last;
  wire q;
  and65 u(q, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, last);
  initial begin
    last = 1;
    #1 $display("all ones q=%b", q);
    last = 0;
    #1 $display("one zero q=%b", q);
    last = 1;
    #1 $display("all ones again q=%b", q);
    $finish(0);
  end
endmodule
