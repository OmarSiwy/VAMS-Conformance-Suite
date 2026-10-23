//! inherited IEEE 1364-2005 14.2
// A specify path's destination may have one driver on each bit; each of these
// buf gates drives one bit of P (specify1). The initial block makes the run
// observable: P must follow drive bit for bit, so an implementation that
// drops the buf tree or computes a path wrongly prints the wrong words.
module triage_specify_path_bit_drivers(A, P);
  input [15:0] A;
  output [15:0] P;

  reg [15:0] drive;

  buf b0(P[0], drive[0]);
  buf b1(P[1], drive[1]);
  buf b2(P[2], drive[2]);
  buf b3(P[3], drive[3]);
  buf b4(P[4], drive[4]);
  buf b5(P[5], drive[5]);
  buf b6(P[6], drive[6]);
  buf b7(P[7], drive[7]);
  buf b8(P[8], drive[8]);
  buf b9(P[9], drive[9]);
  buf b10(P[10], drive[10]);
  buf b11(P[11], drive[11]);
  buf b12(P[12], drive[12]);
  buf b13(P[13], drive[13]);
  buf b14(P[14], drive[14]);
  buf b15(P[15], drive[15]);

  specify
    (A => P) = 1;
  endspecify

  initial begin
    drive = 16'ha5c3;
    #1 $display("%h", P);
    drive = 16'h3c5a;
    #1 $display("%h", P);
  end
endmodule
