// IEEE 1364-2005 §7.10, p. 88: "In addition to a signal value, a net shall
// have either a single unambiguous strength level or an ambiguous strength
// consisting of more than one level. When signals combine, their strengths
// and values shall determine the strength and value of the resulting signal
// in accordance with the principles in 7.10.1 through 7.10.4."
// §7.10.2, p. 89: "When two signals of equal strength and opposite value
// combine, the result shall be a value x" (Figure 7-4: We1 + We0 -> WeX).
// p. 91 (Figure 7-9, a PuH and a WeL): "The result is a value x because its
// range includes the values 1 and 0."
// p. 93 (Figure 7-16): "and (strong1,highz0) N1(a,b); and (strong1, weak0)
// N2(c,d);" with a=1, b=x, c=0, d=0 -> StH + We0 -> 36X.
// §7.10.3, p. 94: "a) The strength levels of the ambiguous strength signal
// that are greater than the strength level of the unambiguous signal shall
// remain in the result. b) The strength levels of the ambiguous strength
// signal that are smaller than or equal to the strength level of the
// unambiguous signal shall disappear from the result, subject to rule c."
//
//   w74: (weak1, weak0) 1 and (weak1, weak0) 0 -> x (Figure 7-4).
//   w79: bufif1 (pull1, pull0) data 1, control x -> PuH (Pu1..HiZ);
//        bufif0 (weak1, weak0) data 0, control x -> WeL (We0..HiZ);
//        the range spans 0 and 1 -> x (Figure 7-9, 35X).
//   w716: Figure 7-16 -> x (36X).
//   Then b = 1: N1 drives St1, N2 We0 -> 1 (§7.10.1); b = 0: N1 drives
//        HiZ0 (highz0), N2 We0 -> 0.
//   wr: bufif1 (pull1, pull0) data 1, control x -> PuH, plus a strong 0:
//        rule b removes every level of PuH (all <= 6); rule c adds nothing
//        above St0 -> St0 -> 0.
// Lines: "xxx 0", "1", "0".
//! inherited IEEE 1364-2005 7.10
`timescale 1ns/1ns
module b_7_10_figure_combinations;
  reg a, b, c, d, one, zero, ctl;
  wire w74, w79, w716, wr;
  assign (weak1, weak0) w74 = one;
  assign (weak1, weak0) w74 = zero;
  bufif1 (pull1, pull0) g1(w79, one, ctl);
  bufif0 (weak1, weak0) g2(w79, zero, ctl);
  and (strong1, highz0) N1(w716, a, b);
  and (strong1, weak0) N2(w716, c, d);
  bufif1 (pull1, pull0) g3(wr, one, ctl);
  assign (strong1, strong0) wr = zero;
  initial begin
    one = 1; zero = 0; ctl = 1'bx;
    a = 1; b = 1'bx; c = 0; d = 0;
    #1 $display("%b%b%b %b", w74, w79, w716, wr);
    b = 1;
    #1 $display("%b", w716);
    b = 0;
    #1 $display("%b", w716);
    $finish(0);
  end
endmodule
