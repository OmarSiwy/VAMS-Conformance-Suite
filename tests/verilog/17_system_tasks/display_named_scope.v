// IEEE1364-2005 17.1.1.6: %m identifies invoking named block as well
// as module and consumes no argument; the following %0d must still consume7.
//! inherited IEEE 1364-2005 17.1.1.6
//! expect stdout display_named_scope.expected.txt
module audit_display_named_scope;
  initial begin
    $display("module=%m value=%0d", 4'd7);
    begin : inner
      $display("block=%M value=%0d", 4'd7);
    end
    $finish(0);
  end
endmodule
