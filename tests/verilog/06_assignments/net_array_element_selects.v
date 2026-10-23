//! inherited IEEE 1364-2005 6.1.1 A.8.5
// A constant bit- or part-select of a net array element is a net_lvalue:
// b[i][j] and out[0][1:0] (genvar_scopes/pr1820472).
module triage_net_array_element_selects;
  reg [1:0] a [1:0];
  wire [1:0] b [1:0];
  wire [1:0] out [1:0];
  genvar i, j;

  generate
    for (i = 0; i < 2; i = i + 1)
      for (j = 0; j < 2; j = j + 1) begin : g
        assign b[i][j] = a[i][j];
      end
  endgenerate

  assign out[0][1:0] = a[0];
  assign out[1][1:0] = a[1];

  initial begin
    a[0] = 2'b01;
    a[1] = 2'b10;
    #1;
    if (b[0] === 2'b01 && b[1] === 2'b10 && out[0] === 2'b01 && out[1] === 2'b10)
      $display("PASSED");
    else
      $display("FAILED %b %b %b %b", b[0], b[1], out[0], out[1]);
  end
endmodule
