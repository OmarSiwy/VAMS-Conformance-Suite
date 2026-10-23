//@ std 1364-2005
//! inherited IEEE 1364-2005 19.11 B
// Annex B reserves none of connect and sqrt for 1364-2005, so they are
// ordinary identifiers in a module name and an instance's module name, not
// only in declarations (fread/pr2930506/pr3296466b/sqrt32).
`begin_keywords "1364-2005"
module connect(input a, output b);
  assign b = a;
endmodule

module sqrt(input a, output b);
  assign b = ~a;
endmodule

module triage_ams_keywords_instance_names;
  wire a, b, c;

  assign a = 1'b1;
  connect connect1(a, b);
  sqrt sqrt1(b, c);

  initial #1 if (c === 1'b0) $display("PASSED"); else $display("FAILED %b", c);
endmodule
`end_keywords
