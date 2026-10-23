// IEEE 1364-2005 §13.5, p. 206, file top.v, with its `...` written out: each
// instance prints its %m and %l (§13.6) at its own time D, so no §11.4.2
// order is assumed. Support source for the 13_configuration/b_13_5_* cases.
module top;
  adder #(1) a1();
  adder #(2) a2();
  initial begin
    $display("%m %l");
    #30 $finish(0);
  end
endmodule
module foo;
  parameter D = 0;
  initial #D $display("%m %l"); // rtl
endmodule
