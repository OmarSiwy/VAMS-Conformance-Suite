// IEEE 1364-2005 §10.4.1, p. 153: "If used, function_range_or_type shall
// specify that the return value of the function is a real, an integer, a
// time, a realtime, or a vector (optionally signed) with a range of [n:m]
// bits." §10.4.2, p. 154: "This variable either defaults to a 1-bit reg or is
// the same type as the type specified in the function declaration."
//
// real_f(3) = 3 / 2.0 = 1.5 (a real, §5.5.1), realtime_f(4) = 4 * 0.25 = 1.0.
//   r = real_f(3) keeps 1.5                     -> "1.500000"
//   realtime_f(4) + 0.5 = 1.5                   -> "1.500000"
//   k = real_f(3): 1.5 to integer rounds away from zero (§4.8.2) -> "2"
//! inherited IEEE 1364-2005 10.4.1 10.4.2
// native-required
module b_10_4_1_real_function_return;
  real r;
  integer k;
  function real real_f;
    input integer v;
    real_f = v / 2.0;
  endfunction
  function realtime realtime_f;
    input integer v;
    realtime_f = v * 0.25;
  endfunction
  initial begin
    r = real_f(3);
    $display("%f", r);
    $display("%f", realtime_f(4) + 0.5);
    k = real_f(3);
    $display("%0d", k);
    $finish(0);
  end
endmodule
