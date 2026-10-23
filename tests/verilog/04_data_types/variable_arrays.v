// IEEE 1364-2005 §4.9.2, p. 34: "Arrays for all variables types (reg,
// integer, time, real, realtime) shall be possible."
//
// One array of each of the five types; one element of each is written and
// read back:
//   ra[1] = 4'hA      -> a        (4-bit reg element, %h)
//   ia[2] = -5        -> -5       (integer is signed, §4.8)
//   ta[0] = 64'd7     -> 7        (time element)
//   xa[1] = 2.5       -> 2.50     (real element)
//   rta[3] = 1.25     -> 1.25     (realtime element, declared [2:3])
// Output: "a -5 7 2.50 1.25".
//! inherited IEEE 1364-2005 4.9.2
// native-required
module b_4_9_2_variable_arrays;
  reg [3:0] ra [0:1];
  integer ia [1:2];
  time ta [0:1];
  real xa [0:1];
  realtime rta [2:3];
  initial begin
    ra[1] = 4'hA;
    ia[2] = -5;
    ta[0] = 64'd7;
    xa[1] = 2.5;
    rta[3] = 1.25;
    $display("%h %0d %0d %0.2f %0.2f", ra[1], ia[2], ta[0], xa[1], rta[3]);
    $finish(0);
  end
endmodule
