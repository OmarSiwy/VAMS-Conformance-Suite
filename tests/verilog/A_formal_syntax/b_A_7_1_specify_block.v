// IEEE 1364-2005 A.7.1, p. 500:
//   specify_block ::= specify { specify_item } endspecify
//   specify_item ::= specparam_declaration | pulsestyle_declaration
//     | showcancelled_declaration | path_declaration | system_timing_check
//   pulsestyle_declaration ::= pulsestyle_onevent list_of_path_outputs ;
//     | pulsestyle_ondetect list_of_path_outputs ;
//   showcancelled_declaration ::= showcancelled list_of_path_outputs ;
//     | noshowcancelled list_of_path_outputs ;
//
// b_A_7_1_buf's specify block holds every specify_item: a
// specparam_declaration, both pulsestyle_declarations, both
// showcancelled_declarations (over the two outputs y and z), a
// path_declaration and a system_timing_check; b_A_7_1_empty's is an empty
// specify block ({ specify_item } allows none).
// §14 path delays and pulse controls are not modelled by VerA (W0251, the
// §1 B scope), so what this establishes is the parse: the module runs as the
// plain buffer its continuous assignments make it. a = 1 -> y = 1, z = 0.
// The $width check runs and stays quiet: a's x -> 1 at 0 opens a high pulse
// that no fall closes. Output: "y=1 z=0".
//! inherited IEEE 1364-2005 A.7.1 14.6 14.6.4 14.6.4.1 14.6.4.2
`timescale 1ns/1ns
module b_A_7_1_buf (a, y, z);
  input a;
  output y, z;
  assign y = a;
  assign z = ~a;
  specify
    specparam tpd = 1;
    pulsestyle_onevent y;
    pulsestyle_ondetect z;
    showcancelled y;
    noshowcancelled z;
    (a => y) = tpd;
    $width(posedge a, 2);
  endspecify
endmodule
module b_A_7_1_empty;
  specify
  endspecify
endmodule
module b_A_7_1_specify_block;
  reg a;
  wire y, z;
  b_A_7_1_buf u (a, y, z);
  b_A_7_1_empty e ();
  initial begin
    a = 1;
    #5 $display("y=%b z=%b", y, z);
    $finish(0);
  end
endmodule
