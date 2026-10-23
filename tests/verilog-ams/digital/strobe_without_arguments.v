// An argumentless $strobe still emits a newline at the end of the slot.
//! lrm 9.4.1:1002
module strobe_without_arguments;
  initial begin
    $write("before");
    $strobe;
    #1 $display("after");
    $finish(0);
  end
endmodule
