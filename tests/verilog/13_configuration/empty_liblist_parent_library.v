// IEEE 1364-2005 §13.3.1.5, p. 204: "liblist_clause ::= liblist {
// library_identifier }" (Syntax 13-8). "The current library list is selected
// by the selection clauses. If no library list clause is selected or if the
// selected library list is empty, then the library list contains the single
// name that is the library in which the cell containing the unbound instance
// is found (i.e., the parent cell's library)."
//
// `{ library_identifier }` allows zero names. Both liblists below are empty,
// so the list searched for top.u is top's library: work (no map, §13.2.1),
// which holds leaf. Output, t=0 then t=1: "top work.top", "top.u work.leaf".
// With work the only library this is also the output of no config at all,
// so what the fixture tells apart is Syntax 13-8's empty list being accepted;
// the parent-library search across libraries is cfg4_instance_liblist.v
// (an instance liblist, inherited) and parent_library_by_map.v.
//! inherited IEEE 1364-2005 13.3.1.5
`timescale 1ns/1ns
config cfg;
  design work.top;
  default liblist;
  instance top.u liblist;
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
