// IEEE1364-2005 10.3 printed150-152; block lifecycle also9.8 and11.4.1.
//! lrm 1.1
//! inherited IEEE 1364-2005 10.3
//! expect stdout disable_self_block.expected.txt
// Self-disable exits the named block immediately. r starts0, becomes1;
// the skipped assignment99 cannot execute; following statement adds2 ->3.
module audit_disable_self_block;
  integer r;
  initial begin
    r=0;
    begin : work
      r=1; disable work; r=99;
    end
    r=r+2; $display("self=%0d",r); $finish(0);
  end
endmodule
