//! inherited IEEE 1364-2005 A.1.4
//! reject not a module item: found `;`
// A.1.4 has no null module item, so the ';' after endtask leaves a stray
// token in the module (decl_before_use6).
module triage_stray_semicolon_after_endtask_rejected;
  task t;
    begin
    end
  endtask;

  initial t;
endmodule
