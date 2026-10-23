// IEEE 1364-2005 §13.1, p. 199: "From this module's source description, the
// instantiated modules (or children) are found, then the source descriptions
// for the module definitions of these subinstances shall be located, and so
// on until every instance in the design is mapped to a source description."
// §13.6, p. 208: "The format specifier %l or %L shall print out the
// library.cell binding information for the module instance containing the
// display (or other textual output) command." §13.2.1, p. 201: "Any file
// encountered by the compiler that does not match any library's
// file_path_spec shall by default be compiled into a library named work."
//
// No library map is given, so every cell is in library work. top instantiates
// mid as u; mid instantiates leaf as v. Each level is located and each
// prints its own %m (§17.1.1.6) and %l / %L binding, at distinct times so no
// two displays share a time step (no §11.4.2 ordering is assumed):
//   t=0  top     -> "top work.top work.top"
//   t=1  top.u   -> "top.u work.mid work.mid"
//   t=2  top.u.v -> "top.u.v work.leaf work.leaf"
//! inherited IEEE 1364-2005 13.1 13.6
`timescale 1ns/1ns
module leaf;
  initial #2 $display("%m %l %L");
endmodule
module mid;
  leaf v();
  initial #1 $display("%m %l %L");
endmodule
module top;
  mid u();
  initial begin
    $display("%m %l %L");
    #3 $finish(0);
  end
endmodule
