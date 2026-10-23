// IEEE 1364-2005 §17.2.10: "The $sdf_annotate system task reads timing data
// from an SDF file into a specified region of the design." §16.1: "The term
// SDF annotator refers to any tool capable of backannotating SDF data to a
// Verilog simulator."
//
// VerA is not an SDF annotator: clause 16 is out of scope (CLAUSES.tsv).
// Carrying on past the call would run a design whose timing the SDF file was
// meant to set, so the call is refused by name (E1102), never skipped. The
// file need not exist: the refusal is at compile time.
//
// Legal neighbour: 04_data_types/specparam_module_body_delay.v writes the
// same kind of timing value in the source, where VerA does apply it.
//! inherited IEEE 1364-2005 17.2.10 16 16.1
//! reject E1102
module sdf_annotate_rejected;
  reg a;
  initial begin
    $sdf_annotate("sdf_annotate_rejected.sdf");
    a = 1'b0;
  end
endmodule
