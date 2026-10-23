// IEEE1364-2005 10.3 printed150-152; block lifecycle also9.8 and11.4.1.
//! lrm 1.1
//! inherited IEEE 1364-2005 10.3
//! expect stdout disable_ancestor_block.expected.txt
// Inner block disables its enclosing named block. Both inner99 and outer88
// assignments are skipped. Caller continuation adds4 to the completed1 ->5.
module audit_disable_ancestor_block;
  integer r;
  initial begin
    r=0;
    begin : outer
      begin : inner
        r=1; disable outer; r=99;
      end
      r=88;
    end
    r=r+4; $display("ancestor=%0d",r); $finish(0);
  end
endmodule
