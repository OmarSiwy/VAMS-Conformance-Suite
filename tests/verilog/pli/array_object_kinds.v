// Required host graph probe. Values need not be initialized: the plugin reads
// only declaration shape and constant index expressions, not variable values.
module audit_array_object_kinds;
  reg [7:0] memory[1:0];
  real samples[1:0];
  initial $finish(0);
endmodule
