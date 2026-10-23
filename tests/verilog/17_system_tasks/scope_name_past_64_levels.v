// IEEE 1364-2005 §17.1.1.6: "The %m format specifier does not accept an
// argument. Instead, it causes the display task to print the hierarchical name
// of the module, task, function, or named block that invokes the system task
// containing the format specifier." No depth is bounded. VerA used to gather the scopes in a 64-entry table and drop the
// outermost past it, and the named blocks in another, where which were
// dropped depended on hash order.
//
// HAND DERIVATION. The display sits inside 70 nested loop generates g0..g69,
// each run once, so each is the scope gK[0] (§12.4.1), and, within the
// initial, 70 nested named blocks b0..b69. %m prints the module, each
// generate scope and each named block, outermost first, joined by periods.
//! inherited IEEE 1364-2005 17.1.1.6
//! expect stdout scope_name_past_64_levels.expected.txt
module b_17_1_1_6_scope_name_past_64_levels;
  genvar i0, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23, i24, i25, i26, i27, i28, i29, i30, i31, i32, i33, i34, i35, i36, i37, i38, i39, i40, i41, i42, i43, i44, i45, i46, i47, i48, i49, i50, i51, i52, i53, i54, i55, i56, i57, i58, i59, i60, i61, i62, i63, i64, i65, i66, i67, i68, i69;
  generate
  for (i0 = 0; i0 < 1; i0 = i0 + 1) begin : g0
  for (i1 = 0; i1 < 1; i1 = i1 + 1) begin : g1
  for (i2 = 0; i2 < 1; i2 = i2 + 1) begin : g2
  for (i3 = 0; i3 < 1; i3 = i3 + 1) begin : g3
  for (i4 = 0; i4 < 1; i4 = i4 + 1) begin : g4
  for (i5 = 0; i5 < 1; i5 = i5 + 1) begin : g5
  for (i6 = 0; i6 < 1; i6 = i6 + 1) begin : g6
  for (i7 = 0; i7 < 1; i7 = i7 + 1) begin : g7
  for (i8 = 0; i8 < 1; i8 = i8 + 1) begin : g8
  for (i9 = 0; i9 < 1; i9 = i9 + 1) begin : g9
  for (i10 = 0; i10 < 1; i10 = i10 + 1) begin : g10
  for (i11 = 0; i11 < 1; i11 = i11 + 1) begin : g11
  for (i12 = 0; i12 < 1; i12 = i12 + 1) begin : g12
  for (i13 = 0; i13 < 1; i13 = i13 + 1) begin : g13
  for (i14 = 0; i14 < 1; i14 = i14 + 1) begin : g14
  for (i15 = 0; i15 < 1; i15 = i15 + 1) begin : g15
  for (i16 = 0; i16 < 1; i16 = i16 + 1) begin : g16
  for (i17 = 0; i17 < 1; i17 = i17 + 1) begin : g17
  for (i18 = 0; i18 < 1; i18 = i18 + 1) begin : g18
  for (i19 = 0; i19 < 1; i19 = i19 + 1) begin : g19
  for (i20 = 0; i20 < 1; i20 = i20 + 1) begin : g20
  for (i21 = 0; i21 < 1; i21 = i21 + 1) begin : g21
  for (i22 = 0; i22 < 1; i22 = i22 + 1) begin : g22
  for (i23 = 0; i23 < 1; i23 = i23 + 1) begin : g23
  for (i24 = 0; i24 < 1; i24 = i24 + 1) begin : g24
  for (i25 = 0; i25 < 1; i25 = i25 + 1) begin : g25
  for (i26 = 0; i26 < 1; i26 = i26 + 1) begin : g26
  for (i27 = 0; i27 < 1; i27 = i27 + 1) begin : g27
  for (i28 = 0; i28 < 1; i28 = i28 + 1) begin : g28
  for (i29 = 0; i29 < 1; i29 = i29 + 1) begin : g29
  for (i30 = 0; i30 < 1; i30 = i30 + 1) begin : g30
  for (i31 = 0; i31 < 1; i31 = i31 + 1) begin : g31
  for (i32 = 0; i32 < 1; i32 = i32 + 1) begin : g32
  for (i33 = 0; i33 < 1; i33 = i33 + 1) begin : g33
  for (i34 = 0; i34 < 1; i34 = i34 + 1) begin : g34
  for (i35 = 0; i35 < 1; i35 = i35 + 1) begin : g35
  for (i36 = 0; i36 < 1; i36 = i36 + 1) begin : g36
  for (i37 = 0; i37 < 1; i37 = i37 + 1) begin : g37
  for (i38 = 0; i38 < 1; i38 = i38 + 1) begin : g38
  for (i39 = 0; i39 < 1; i39 = i39 + 1) begin : g39
  for (i40 = 0; i40 < 1; i40 = i40 + 1) begin : g40
  for (i41 = 0; i41 < 1; i41 = i41 + 1) begin : g41
  for (i42 = 0; i42 < 1; i42 = i42 + 1) begin : g42
  for (i43 = 0; i43 < 1; i43 = i43 + 1) begin : g43
  for (i44 = 0; i44 < 1; i44 = i44 + 1) begin : g44
  for (i45 = 0; i45 < 1; i45 = i45 + 1) begin : g45
  for (i46 = 0; i46 < 1; i46 = i46 + 1) begin : g46
  for (i47 = 0; i47 < 1; i47 = i47 + 1) begin : g47
  for (i48 = 0; i48 < 1; i48 = i48 + 1) begin : g48
  for (i49 = 0; i49 < 1; i49 = i49 + 1) begin : g49
  for (i50 = 0; i50 < 1; i50 = i50 + 1) begin : g50
  for (i51 = 0; i51 < 1; i51 = i51 + 1) begin : g51
  for (i52 = 0; i52 < 1; i52 = i52 + 1) begin : g52
  for (i53 = 0; i53 < 1; i53 = i53 + 1) begin : g53
  for (i54 = 0; i54 < 1; i54 = i54 + 1) begin : g54
  for (i55 = 0; i55 < 1; i55 = i55 + 1) begin : g55
  for (i56 = 0; i56 < 1; i56 = i56 + 1) begin : g56
  for (i57 = 0; i57 < 1; i57 = i57 + 1) begin : g57
  for (i58 = 0; i58 < 1; i58 = i58 + 1) begin : g58
  for (i59 = 0; i59 < 1; i59 = i59 + 1) begin : g59
  for (i60 = 0; i60 < 1; i60 = i60 + 1) begin : g60
  for (i61 = 0; i61 < 1; i61 = i61 + 1) begin : g61
  for (i62 = 0; i62 < 1; i62 = i62 + 1) begin : g62
  for (i63 = 0; i63 < 1; i63 = i63 + 1) begin : g63
  for (i64 = 0; i64 < 1; i64 = i64 + 1) begin : g64
  for (i65 = 0; i65 < 1; i65 = i65 + 1) begin : g65
  for (i66 = 0; i66 < 1; i66 = i66 + 1) begin : g66
  for (i67 = 0; i67 < 1; i67 = i67 + 1) begin : g67
  for (i68 = 0; i68 < 1; i68 = i68 + 1) begin : g68
  for (i69 = 0; i69 < 1; i69 = i69 + 1) begin : g69
    initial begin
begin : b0
begin : b1
begin : b2
begin : b3
begin : b4
begin : b5
begin : b6
begin : b7
begin : b8
begin : b9
begin : b10
begin : b11
begin : b12
begin : b13
begin : b14
begin : b15
begin : b16
begin : b17
begin : b18
begin : b19
begin : b20
begin : b21
begin : b22
begin : b23
begin : b24
begin : b25
begin : b26
begin : b27
begin : b28
begin : b29
begin : b30
begin : b31
begin : b32
begin : b33
begin : b34
begin : b35
begin : b36
begin : b37
begin : b38
begin : b39
begin : b40
begin : b41
begin : b42
begin : b43
begin : b44
begin : b45
begin : b46
begin : b47
begin : b48
begin : b49
begin : b50
begin : b51
begin : b52
begin : b53
begin : b54
begin : b55
begin : b56
begin : b57
begin : b58
begin : b59
begin : b60
begin : b61
begin : b62
begin : b63
begin : b64
begin : b65
begin : b66
begin : b67
begin : b68
begin : b69
      $display("%m");
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
    end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
  endgenerate
endmodule
