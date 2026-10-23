//! inherited IEEE 1364-2005 19.9
// `unconnected_drive's pull1 operand may be on the next line; the unconnected
// input port of leaf, whose definition sits between the directives, is then
// pulled high (br_gh782c). §19.9 pulls "unconnected input ports of a module
// appearing between the directives": the definition's region, as in
// b_19_6_resetall_restores_defaults.
module triage_unconnected_drive_operand_next_line;
  leaf u();
endmodule

`unconnected_drive
pull1
module leaf(in);
  input in;

  initial #1 if (in === 1'b1) $display("PASSED"); else $display("FAILED %b", in);
endmodule
`nounconnected_drive
