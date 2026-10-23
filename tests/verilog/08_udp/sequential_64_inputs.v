// IEEE 1364-2005 §8.1.2: "Implementations may limit the maximum number of
// inputs to a UDP, but they shall allow at least 9 inputs for sequential UDPs
// and 10 inputs for combinational UDPs." VerA's limit is 64 inputs
// (specification/Vague_Decisions.md, E1017 past it). This UDP sits on the limit: 64
// inputs, and its one table row carries an edge, `(01)`, which is one symbol
// written in four characters. VerA used to count characters against a
// 64-character column and refused this legal row.
//
// HAND DERIVATION. q starts x (§8.1.3: no initial statement). The only row
// matches a rising clk whatever the other 63 inputs hold, and sets q to 1.
// At #1 clk rises: q = 1. Before it, q is x.
//! inherited IEEE 1364-2005 8.1.2
//! expect stdout sequential_64_inputs.expected.txt
primitive seq64(q, clk, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23, i24, i25, i26, i27, i28, i29, i30, i31, i32, i33, i34, i35, i36, i37, i38, i39, i40, i41, i42, i43, i44, i45, i46, i47, i48, i49, i50, i51, i52, i53, i54, i55, i56, i57, i58, i59, i60, i61, i62, i63);
  output q; reg q;
  input clk, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23, i24, i25, i26, i27, i28, i29, i30, i31, i32, i33, i34, i35, i36, i37, i38, i39, i40, i41, i42, i43, i44, i45, i46, i47, i48, i49, i50, i51, i52, i53, i54, i55, i56, i57, i58, i59, i60, i61, i62, i63;
  table
    (01) ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? : ? : 1;
  endtable
endprimitive
module b_8_1_2_sequential_64_inputs;
  reg clk;
  wire q;
  seq64 u(q, clk, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0);
  initial begin
    clk = 0;
    #1 $display("before q=%b", q);
    clk = 1;
    #1 $display("after q=%b", q);
    $finish(0);
  end
endmodule
