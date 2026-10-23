// IEEE 1364-2005 §13.3.1, p. 203, Syntax 13-4:
//   config_rule_statement ::= default_clause liblist_clause ;
//     | inst_clause liblist_clause ; | inst_clause use_clause ;
//     | cell_clause liblist_clause ; | cell_clause use_clause ;
// "If the library identifier is omitted, then the library that contains the
// config shall be used to search for the cell." §13.3.1.3, p. 203: "The
// instance name associated with the instance clause is a Verilog hierarchical
// name, starting at the top-level module of the config (i.e., the name of the
// cell in the design statement)." §13.3.1.5, p. 204: "liblists are inherited
// hierarchically downward as instances are bound." §13.3.1.6, p. 204: "It
// specifies the exact library and cell to which a selected cell or instance is
// bound." p. 205: "If the library name is omitted, the library shall be
// inherited from the parent cell." "It can be common in practice to specify
// multiple config rule statements, one of which specifies a binding and the
// other of which specifies a library list." (p. 204)
//
// One of each of the five forms. Every rule names library work, the only
// library (no map, §13.2.1), and every use binds leaf to leaf, so the binding
// is the one the default search gives:
//   `design top;` omits the library -> the config's library, work: work.top.
//   instance top.u starts at the design cell top.
//   `use leaf` omits the library -> the parent cell's (top's), work: work.leaf.
// Output, t=0 then t=1:  "top work.top", "top.u work.leaf".
//! inherited IEEE 1364-2005 13.3.1 13.3.1.3 13.3.1.5 13.3.1.6
`timescale 1ns/1ns
config cfg;
  design top;
  default liblist work;
  instance top.u liblist work;
  instance top.u use work.leaf;
  cell leaf liblist work;
  cell leaf use leaf;
endconfig
module leaf;
  initial #1 $display("%m %l");
endmodule
module top;
  leaf u();
  initial begin
    $display("%m %l");
    #2 $finish(0);
  end
endmodule
