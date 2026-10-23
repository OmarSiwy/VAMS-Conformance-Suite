// IEEE 1364-2005 17.1.1.2: %h requires a following expression.
// Legal matching control: audit_display_write_runs uses %h with 8'h0a.
//! inherited IEEE 1364-2005 17.1.1.2
//! reject E1100
//! reject missing display argument
module audit_display_missing_argument_rejected;
  initial begin $display("%h"); $finish(0); end
endmodule
