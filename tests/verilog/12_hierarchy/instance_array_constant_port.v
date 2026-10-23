//! inherited IEEE 1364-2005 12.1.2
// A constant and a net may be connected across an instance array: each of the
// four instances gets in_0 = 1'b1 and drives test_val (pr1878909).
module test_mod(in_0, out_0);
  input in_0;
  output out_0;

  function test;
    input moo;
    begin
      test = ~moo;
    end
  endfunction

  assign out_0 = test(in_0);
endmodule

module triage_instance_array_constant_port;
  wire [3:0] test_val;

  test_mod test_mod0 [3:0](
    .in_0(1'b1),
    .out_0(test_val)
  );

  initial begin
    #1;
    if (test_val !== 4'b0000) $display("FAILED %b", test_val);
    else $display("PASSED");
  end
endmodule
