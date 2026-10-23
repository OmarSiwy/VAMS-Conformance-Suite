// IEEE 1364-2005 §13.1.1, p. 199: "The cell name shall be the same as the
// name of the module/primitive/config being processed." p. 200: "The optional
// :config extension shall be used explicitly to refer to a config in the case
// where a config has the same name as a module/primitive." §13.3.1.1, p. 202:
// "The cell or cells identified cannot be configurations themselves. It is
// possible the design identified can have the same name as configs, however."
//
// The config and the module are both named top. Syntax 13-1's
// library_cell work.top without the :config suffix names the module (the
// suffix is what selects a config of the same name, and Syntax 13-4's
// design_statement admits no suffix), so the design statement selects module
// top as the top-level module. The uninstantiated module other is not listed,
// so it is not a top and never prints (§13.4.4, p. 206: "the specified cell
// shall be the top-level module, regardless of the presence of any
// uninstantiated cells"); without the config, top and other would both be
// tops. top's %l is its library.cell: work.top (§13.6; unmapped source is in
// work, §13.2.1). Output: "top work.top".
// Annex A.1.2, p. 487: "description ::= module_declaration | udp_declaration
// | config_declaration": this source_text mixes a config_declaration with
// module_declarations (the refused neighbours are
// library_declaration_rejected.v and include_statement_rejected.v).
//! inherited IEEE 1364-2005 13.1.1 13.3.1.1 A.1.2
config top;
  design work.top;
endconfig
module other;
  initial $display("other");
endmodule
module top;
  initial begin
    $display("%m %l");
    $finish(0);
  end
endmodule
