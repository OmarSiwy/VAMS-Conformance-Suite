//@ std 1364-2001
//! inherited IEEE 1364-2005 19.11
// "1364-2001-noconfig" is 1364-2001 without the config keywords, so config is
// an identifier under it (pr1758122).
`begin_keywords "1364-2001-noconfig"
module triage_begin_keywords_2001_noconfig;
  reg config;

  initial begin
    config = 1'b1;
    if (config === 1'b1)
      $display("PASSED");
    else
      $display("FAILED");
  end
endmodule
`end_keywords
