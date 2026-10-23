// IEEE 1364-2005 §8.2, p. 109: "In combinational UDPs, the output state is
// determined solely as a function of the current input states. Whenever an
// input state changes, the UDP is evaluated and the output state is set to
// the value indicated by the row in the state table that matches all the
// input states. All combinations of the inputs that are not explicitly
// specified will drive the output state to the unknown value x." ... "The
// input combination 0xx (control=0, dataA=x, dataB=x) is not specified. If
// this combination occurs during simulation, the value of output port mux
// will become x." ... "Using ?, the description of a multiplexer can be
// abbreviated as follows:"
//
// multiplexer is the clause's first table verbatim; mux_q its abbreviation
// with ?. The loop visits all 27 input combinations, control outermost, then
// dataA, then dataB, each over 0, 1, x; each line is one control value, nine
// outputs in dataA-major order.
//   control 0: dataA 1 -> 1 whatever dataB; dataA 0 -> 0; dataA x matches no
//     row -> x                               -> 000111xxx
//   control 1: dataB 1 -> 1, dataB 0 -> 0 whatever dataA; dataB x -> x
//                                            -> 01x01x01x
//   control x: only 00 -> 0 and 11 -> 1 are listed -> 0xxx1xxxx
// The abbreviated table gives the same 27 outputs: a ? row covers exactly
// the three rows it replaces.
//! inherited IEEE 1364-2005 8.2
`timescale 1ns/1ns
primitive multiplexer (mux, control, dataA, dataB);
  output mux;
  input control, dataA, dataB;
  table
  // control dataA dataB mux
     0 1 0 : 1 ;
     0 1 1 : 1 ;
     0 1 x : 1 ;
     0 0 0 : 0 ;
     0 0 1 : 0 ;
     0 0 x : 0 ;
     1 0 1 : 1 ;
     1 1 1 : 1 ;
     1 x 1 : 1 ;
     1 0 0 : 0 ;
     1 1 0 : 0 ;
     1 x 0 : 0 ;
     x 0 0 : 0 ;
     x 1 1 : 1 ;
  endtable
endprimitive

primitive mux_q (mux, control, dataA, dataB);
  output mux;
  input control, dataA, dataB;
  table
  // control dataA dataB mux
     0 1 ? : 1 ;
     0 0 ? : 0 ;
     1 ? 1 : 1 ;
     1 ? 0 : 0 ;
     x 0 0 : 0 ;
     x 1 1 : 1 ;
  endtable
endprimitive

module b_8_2_multiplexer;
  reg control, dataA, dataB;
  reg [8:0] full, abbrev;
  wire m1, m2;
  integer c, a, b;
  multiplexer u1(m1, control, dataA, dataB);
  mux_q u2(m2, control, dataA, dataB);

  function level;
    input integer k;
    level = k == 0 ? 1'b0 : k == 1 ? 1'b1 : 1'bx;
  endfunction

  initial begin
    for (c = 0; c < 3; c = c + 1) begin
      for (a = 0; a < 3; a = a + 1)
        for (b = 0; b < 3; b = b + 1) begin
          control = level(c);
          dataA = level(a);
          dataB = level(b);
          #1 full[8 - (3 * a + b)] = m1;
          abbrev[8 - (3 * a + b)] = m2;
        end
      $display("%b %b", full, abbrev);
    end
    $finish(0);
  end
endmodule
