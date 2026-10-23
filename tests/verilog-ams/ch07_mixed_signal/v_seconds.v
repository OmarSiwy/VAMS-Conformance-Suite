// W1155: with no `timescale the tick is IEEE 1364 §19.8's simulator default,
// 1 s for VerA, so the device still builds and says so.
module v_seconds(a, y);
  input a;
  output y;
  assign y = a;
endmodule
