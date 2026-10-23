// IEEE1364-2005 3.6–3.6.3: string operands are unsigned packed ASCII.
// Right-justify and zero-pad AZ to32 bits; truncate ABC to low16 bits BC.
// Escapes consume1–3 octal digits: \1Q,\12R,\1018 give01,51,0a,52,41,38.
// Hex observations verify stored bytes, not formatter string round trips.
//! inherited IEEE 1364-2005 3.6 3.6.1 3.6.2 3.6.3
//! expect stdout lexical_packed_strings.expected.txt
module audit_lexical_packed_strings;
  reg [31:0] padded;
  reg [15:0] truncated;
  reg [47:0] octal;
  reg [31:0] special;
  initial begin
    padded = "AZ";
    truncated = "ABC";
    octal = "\1Q\12R\1018";
    special = "\n\t\\\"";
    $display("pad %h", padded);
    $display("truncate %h", truncated);
    $display("octal %h", octal);
    $display("special %h", special);
    $finish(0);
  end
endmodule
