// Two child module instances, indexed1 and0, and a nonarray top control.
// The paired plugin checks graph membership at the legal end-compile phase.
module audit_module_array;
  audit_array_leaf u[1:0]();
  initial $finish(0);
endmodule
module audit_array_leaf;
endmodule
