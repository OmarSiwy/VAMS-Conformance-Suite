// IEEE 1364-2005 §13.5, p. 206, file adder.v (rtl). An adder at time D has
// its foo instances print at 10*D+1 and 10*D+2.
module adder;
  parameter D = 0;
  foo #(10*D+1) f1();
  foo #(10*D+2) f2();
  initial #D $display("%m %l"); // rtl
endmodule
module foo;
  parameter D = 0;
  initial #D $display("%m %l"); // rtl
endmodule
