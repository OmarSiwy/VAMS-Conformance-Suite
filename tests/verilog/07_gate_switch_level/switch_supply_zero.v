//! inherited IEEE 1364-2005 7.11
// A MOS or tran switch whose data terminal is a supply0 net passes a strong 0
// (nmos(o, vss, 1) and tranif1(o, vss, 1) read 0, not z) (br_gh1122).
module triage_switch_supply_zero;
  supply0 vss;
  wire o_mos, o_tran;
  reg en;

  nmos n1(o_mos, vss, en);
  tranif1 t1(o_tran, vss, en);

  initial begin
    en = 1;
    #1;
    if (o_mos === 1'b0 && o_tran === 1'b0)
      $display("PASSED");
    else
      $display("FAILED %b %b", o_mos, o_tran);
  end
endmodule
