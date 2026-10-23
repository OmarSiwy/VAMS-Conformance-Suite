//! inherited IEEE 1364-2005 9.3.2
// force's left side may be a net-array element: force/release of array1[1] is
// legal, and a forced expression follows its operands (array_lval_select4a).
module triage_force_wire_array_element;
  wire [1:0] array1 [2:1];
  reg [1:0] var1;
  reg failed;

  assign array1[1] = 2'd0;
  assign array1[2] = 2'd0;

  initial begin
    failed = 0;

    force array1[1] = 2'd1;
    #1 if (array1[1] !== 2'd1 || array1[2] !== 2'd0) failed = 1;
    release array1[1];
    #1 if (array1[1] !== 2'd0) failed = 1;

    force array1[2] = var1;
    var1 = 2'd1;
    #1 if (array1[2] !== 2'd1) failed = 1;
    var1 = 2'd2;
    #1 if (array1[2] !== 2'd2) failed = 1;
    release array1[2];
    #1 if (array1[2] !== 2'd0) failed = 1;

    if (failed) $display("FAILED"); else $display("PASSED");
  end
endmodule
