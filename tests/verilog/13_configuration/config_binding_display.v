// IEEE1364-2005 13.2.1/13.6: unmapped source belongs to work;
// both %l and %L report library.cell, not instance hierarchy or literal l.
// No arguments are consumed by these binding format specifiers.
//! inherited IEEE 1364-2005 13.2.1 13.6
//! expect stdout config_binding_display.expected.txt
module audit_config_binding_display;
  initial begin
    $display("lower=%l upper=%L");
    $finish(0);
  end
endmodule
