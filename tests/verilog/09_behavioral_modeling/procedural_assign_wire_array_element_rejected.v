//! inherited IEEE 1364-2005 9.2
//! reject-only there is no procedural assignment to a net
// A procedural assignment's lvalue is a variable; icim[0] <= ... writes an
// element of a wire array and must be refused (pr2597278b), with the
// checkTarget net message. VerA's array path skips the net check, so the
// fixture is expected to FAIL, verifying the vera-bug claim.
module triage_procedural_assign_wire_array_element_rejected;
  reg [1:0] q;
  wire [4:0] icim [1:0];

  always @(q) begin
    icim[0] <= #1 0;
    icim[1] <= #1 1;
  end

  initial q = 2'd1;
endmodule
