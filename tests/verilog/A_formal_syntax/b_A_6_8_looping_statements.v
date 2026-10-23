// IEEE 1364-2005 A.6.8, p. 499:
//   loop_statement ::= forever statement | repeat ( expression ) statement
//     | while ( expression ) statement
//     | for ( variable_assignment ; expression ; variable_assignment ) statement
//
// for (i = 0; i < 4; i = i + 1) s = s + i        -> s = 0+1+2+3 = 6
// while (s > 2) s = s - 2                          -> 6, 4, 2: s = 2
// repeat (s + 1) r = r * 2, r = 1                  -> three doublings: r = 8
// forever in a named block, disabled on its fifth pass: f = 5
// Output: "s=2 r=8 f=5".
//! inherited IEEE 1364-2005 A.6.8
module b_A_6_8_looping_statements;
  integer i, s, r, f;
  initial begin
    s = 0;
    for (i = 0; i < 4; i = i + 1) s = s + i;
    while (s > 2) s = s - 2;
    r = 1;
    repeat (s + 1) r = r * 2;
    f = 0;
    begin : loop
      forever begin
        f = f + 1;
        if (f == 5) disable loop;
      end
    end
    $display("s=%0d r=%0d f=%0d", s, r, f);
    $finish(0);
  end
endmodule
