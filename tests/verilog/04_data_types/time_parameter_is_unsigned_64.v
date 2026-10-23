//! inherited IEEE 1364-2005 4.10.1 4.8
// A time-typed parameter or localparam is unsigned 64-bit: -1 is
// 18446744073709551615 and equals a time variable holding -1
// (localparam_type/parameter_type).
module triage_time_parameter_is_unsigned_64 #(parameter time P = -1);
  localparam time T = -1;
  time v;

  initial begin
    v = -1;
    if (T == 64'hffffffff_ffffffff && P == T && v == T)
      $display("PASSED");
    else
      $display("FAILED %0d", T);
  end
endmodule
