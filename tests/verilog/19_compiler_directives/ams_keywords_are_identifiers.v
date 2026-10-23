//@ std 1364-2005
//! inherited IEEE 1364-2005 19.11 B
// Annex B reserves none of connect, sqrt or string for 1364-2005, so all three
// are ordinary identifiers here (fread/pr2930506/sqrt32).
`begin_keywords "1364-2005"
module triage_ams_keywords_are_identifiers;
  localparam connect = 4;
  localparam sqrt = 5;
  reg string;

  initial begin
    string = 1'b1;
    if (connect === 4 && sqrt === 5 && string === 1'b1)
      $display("PASSED");
    else
      $display("FAILED");
  end
endmodule
`end_keywords
