// IEEE 1364-2005 §3.7.2, p. 15: "Keywords are predefined nonescaped
// identifiers that are used to define the language constructs. A Verilog HDL
// keyword preceded by an escape character is not interpreted as a keyword.
// All keywords are defined in lowercase only."
//
// \wire is the identifier wire, not the net keyword; Wire and MODULE are not
// keywords because keywords are lowercase. Each is an ordinary reg:
// \wire = 1, Wire = 0, MODULE = 1, and \begin (another keyword, escaped) = 0.
// Printed: "1010".
//! inherited IEEE 1364-2005 3.7.2
module b_3_7_2_escaped_keyword;
  reg \wire , Wire, MODULE, \begin ;
  initial begin
    \wire = 1;
    Wire = 0;
    MODULE = 1;
    \begin = 0;
    $display("%b%b%b%b", \wire , Wire, MODULE, \begin );
    $finish(0);
  end
endmodule
