// Pair with the C plugin. Callback execution is proven by its mandatory
// stderr marker, not by this trivially terminating HDL program's exit status.
module audit_end_compile_objects;
  initial $finish(0);
endmodule
