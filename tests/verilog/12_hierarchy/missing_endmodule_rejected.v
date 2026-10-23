// IEEE 1364-2005 §12.1, p. 163: "A module definition shall be enclosed between
// the keywords module and endmodule."
//
// The module below has no endmodule: the source ends inside its definition.
// Legal neighbour: module_header_forms.v, whose modules all close.
//! lrm 6.2
//! lrm 6.2:1
//! inherited IEEE 1364-2005 12.1
//! reject E0207
//! reject found end of file
//! neighbour module_header_forms.v
module b_12_1_missing_endmodule_rejected;
  initial $display("unclosed");
