// IEEE1364-2005 13.3.1.1/13.4.4: design selects top despite other
// uninstantiated cells. No hierarchy, duplicate names, or library map required;
// both source modules are in default library work (13.2.1).
//! lrm A.1.5
//! lrm A.1.5:1000
//! inherited IEEE 1364-2005 13.2.1 13.3.1.1 13.4.4
//! expect stdout config_design_select.expected.txt
config choose_design;
  design work.config_selected;
endconfig
module config_selected;
  initial begin $display("selected"); $finish(0); end
endmodule
module config_unselected;
  initial $display("unselected");
endmodule
