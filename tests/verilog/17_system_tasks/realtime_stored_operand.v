// IEEE 1364-2005 §17.7.3, printed310/physical340: realtime is a real-valued
// expression in the invoking module's units, not a display-only placeholder.
// unit10ns/precision100ps: #0.25 is2.5ns=25ticks, returning0.25 units.
// Save that value; after another0.5units time is0.75 and saved remains0.25.
// Multiplication by4 yields exactly1 and3, proving operand and storage behavior
// while avoiding floating-point display-rounding ties. A display-only special
// case, raw tick count, or late reevaluation of saved cannot satisfy all lines.
//! lrm 9.10
//! inherited IEEE 1364-2005 17.7.3
//! expect stdout realtime_stored_operand.expected.txt
`timescale 10ns/100ps
module audit_realtime_stored_operand;
  real saved;
  real current_scaled;
  initial begin
    #0.25;
    saved = $realtime;
    $display("first saved=%.2f product=%.2f", saved, saved * 4.0);
    #0.5;
    current_scaled = $realtime * 4.0;
    $display("later saved=%.2f current=%.2f", saved, current_scaled);
    $finish(0);
  end
endmodule
