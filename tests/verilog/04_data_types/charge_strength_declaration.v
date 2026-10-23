// IEEE 1364-2005 §4.4, p. 25: "Two types of strengths can be specified in a
// net declaration as follows: — Charge strength shall only be used when
// declaring a net of type trireg. — Drive strength shall only be used when
// placing a continuous assignment on a net in the same statement that
// declares the net."
//
// The legal form of the first rule: a charge strength on a trireg
// declaration. (Its illegal form is reject_charge_strength_on_wire.v;
// the second rule's legal form is net_declaration_drive_strength.v
// and its illegal form drive_strength_without_assignment_rejected.v.)
//   trireg (large) tr1, driven by bufif1 g(tr1, d, en): d = 1, en = 1 -> 1;
//   en = 0 releases it (bufif1 outputs z) and tr1 keeps its charge (§4.6.3,
//   capacitive state) -> 1.
// The size itself (large) is observable only against another trireg through
// a switch (§4.6.3.1) or with %v; this fixture pins only that the declaration
// is accepted and yields a trireg.
//! inherited IEEE 1364-2005 4.4
module b_4_4_charge_strength_declaration;
  reg d, en;
  trireg (large) tr1;
  bufif1 g(tr1, d, en);
  initial begin
    d = 1;
    en = 1;
    #1 $display("%b", tr1);
    en = 0;
    #1 $display("%b", tr1);
    $finish(0);
  end
endmodule
