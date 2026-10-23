// IEEE 1364-2005 §4.10, p. 35-36: "Parameters are not variables; they are
// constants." "Both types of parameters accept a range specification. By
// default, parameters and specparams shall be as wide as necessary to contain
// the value of the constant, except when a range specification is present."
//
// P = 8'hA5 has no range: 8 bits, 10100101. Q = 8'hA5 with range [3:0]: the
// low four bits, 0101. S, a specparam with range [3:0], = 6'b110011: 0011
// (§4.10.3's specparam_declaration takes [ range ]).
// Output: "P=10100101 Q=0101 S=0011".
//! inherited IEEE 1364-2005 4.10
module b_4_10_parameter_widths;
  parameter P = 8'hA5;
  parameter [3:0] Q = 8'hA5;
  specparam [3:0] S = 6'b110011;
  initial begin
    $display("P=%b Q=%b S=%b", P, Q, S);
    $finish(0);
  end
endmodule
