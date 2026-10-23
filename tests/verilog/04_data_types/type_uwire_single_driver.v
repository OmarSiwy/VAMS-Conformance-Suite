// IEEE1364-2005 §4.6.5 legal neighbor: exactly one continuous driver;
// observe both driven polarities so syntax acceptance alone is insufficient.
//! inherited IEEE 1364-2005 4.6.5
`timescale 1ns/1ns
module audit_type_uwire_single_driver;
  reg source;
  uwire one;
  assign one=source;
  initial begin
    source=0;
    #1 $display("zero=%b", one);
    source=1;
    #1 $display("one=%b", one);
    $finish(0);
  end
endmodule
