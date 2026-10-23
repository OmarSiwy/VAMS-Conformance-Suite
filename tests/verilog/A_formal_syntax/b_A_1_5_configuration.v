// IEEE 1364-2005 A.1.5, p. 489:
//   config_declaration ::= config config_identifier ; design_statement
//     {config_rule_statement} endconfig
//   design_statement ::= design { [library_identifier.]cell_identifier } ;
//   config_rule_statement ::= default_clause liblist_clause ;
//     | inst_clause liblist_clause ; | inst_clause use_clause ;
//     | cell_clause liblist_clause ; | cell_clause use_clause ;
//   default_clause ::= default
//   inst_clause ::= instance inst_name
//   inst_name ::= topmodule_identifier{.instance_identifier}
//   cell_clause ::= cell [ library_identifier.]cell_identifier
//   liblist_clause ::= liblist { library_identifier }
//   use_clause ::= use [library_identifier.]cell_identifier[:config]
//
// The config derives every alternative: a design_statement naming one cell
// with its library (work.b_A_1_5_top); all five config_rule_statement forms;
// an inst_name of two identifiers (b_A_1_5_top.u); a cell_clause with and
// without a library; a liblist of one library and an empty liblist; use
// clauses with and without a library. The cell_clause with a library takes
// the use_clause: §13.3.1.4, p. 204, "It is an error if a library name is
// included in a cell selection clause and the corresponding expansion clause
// is a library list expansion clause." The only library is work (no map,
// §13.2.1), and every use binds b_A_1_5_leaf to itself, so the binding is the
// default one: u is work.b_A_1_5_leaf. §13.3.1.5, p. 204: "If no library list
// clause is selected or if the selected library list is empty, then the
// library list contains the single name that is the library in which the cell
// containing the unbound instance is found (i.e., the parent cell's library)."
// Output: t=0 "b_A_1_5_top", t=1 "b_A_1_5_top.u".
// With work the only library this is also the output with no config at all,
// so what the fixture establishes is that every production above is
// accepted, not the binding.
//! inherited IEEE 1364-2005 A.1.5
`timescale 1ns/1ns
config b_A_1_5_cfg;
  design work.b_A_1_5_top;
  default liblist work;
  instance b_A_1_5_top.u liblist;
  instance b_A_1_5_top.u use b_A_1_5_leaf;
  cell work.b_A_1_5_leaf use work.b_A_1_5_leaf;
  cell b_A_1_5_leaf liblist work;
endconfig
module b_A_1_5_leaf;
  initial #1 $display("%m");
endmodule
module b_A_1_5_top;
  b_A_1_5_leaf u();
  initial begin
    $display("%m");
    #2 $finish(0);
  end
endmodule
