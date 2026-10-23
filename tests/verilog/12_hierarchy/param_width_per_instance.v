// IEEE 1364-2005 §12.2: a parameter is a constant whose value "can be
// overridden" per module instance (§12.2.2 module instance parameter value
// assignment), so every width a parameter decides is decided per INSTANCE.
// Three instances of one definition, two of them overridden to different
// widths, each compute the same three expressions:
//
//   §5.5.1 Table 5-22, `i op j` for + - * ...: "max(L(i),L(j))".
//     r = r - 1 with r = 0: `1` is 32 bits, so the operands are extended to
//     max(W, 32) = 32 bits, 0 - 1 = 32'hFFFFFFFF, and the assignment keeps
//     the low W bits: W=4 -> 4'b1111 = 15, W=8 -> 8'hFF = 255.
//   §5.2.1 a part-select s[W-1:0] of s = 8'hFF is W bits, all ones.
//   §5.1.14 a replication {W{1'b1}} is W ones.
//
// Each instance prints at its own delay #ID, so the order is not a race.
// Typing an expression once for every instance of the definition gives the
// first instance's widths to all three: b would print r=15 sel=1111 rep=1111.
//! inherited IEEE 1364-2005 12.2 5.5.1 5.2.1 5.1.14
module leaf;
  parameter W = 4;
  parameter ID = 1;
  reg [W-1:0] r;
  reg [7:0] s;
  initial begin
    r = 0;
    r = r - 1;
    s = 8'hff;
    #ID $display("%m W=%0d r=%0d sel=%b rep=%b", W, r, s[W-1:0], {W{1'b1}});
  end
endmodule

module audit_param_width_per_instance;
  leaf #(4, 1) a();
  leaf #(8, 2) b();
  leaf #(4, 3) c();
  initial #4 $finish(0);
endmodule
