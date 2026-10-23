// IEEE1364-2005 §§4.6.1/2 Tables4-2/3/4: all sixteen ordered pairs
// of equal-strength0/1/x/z, MSB first. wire=tri, wand=triand, wor=trior.
// Expected each group is read independently from its source truth table.
//! inherited IEEE 1364-2005 4.6.1 4.6.2
`timescale 1ns/1ns
module audit_type_net_resolution_tables;
  reg [15:0] a, b;
  wire [15:0] w;
  tri [15:0] t;
  wand [15:0] wa;
  triand [15:0] ta;
  wor [15:0] wo;
  trior [15:0] to;
  assign w=a, w=b, t=a, t=b, wa=a, wa=b, ta=a, ta=b;
  assign wo=a, wo=b, to=a, to=b;
  initial begin
    a=16'b00001111xxxxzzzz;
    b=16'b01xz01xz01xz01xz;
    #1 $display("wire=%b tri=%b", w, t);
    $display("wand=%b triand=%b", wa, ta);
    $display("wor=%b trior=%b", wo, to);
    $finish(0);
  end
endmodule
