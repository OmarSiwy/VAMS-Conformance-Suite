// IEEE 1364-2005 §12.4.2, p. 187: "If a generate block in a conditional
// generate construct consists of only one item that is itself a conditional
// generate construct and if that item is not surrounded by begin/end keywords,
// then this generate block is not treated as a separate scope. The generate
// construct within this block is said to be directly nested. The generate
// blocks of the directly nested construct are treated as if they belong to the
// outer construct. Therefore, they can have the same name as the generate
// blocks of the outer construct". p. 188: "When nesting if-generate
// constructs, the else always belongs to the nearest if construct." ...
// "Conditional generate constructs make it possible for a module to contain an
// instantiation of itself. ... With proper use of parameters, the resulting
// recursion can be made to terminate, resulting in a legitimate model
// hierarchy."
//
// The clause's Example 1 (p. 187), each block u1 printing which gate it holds
// at t = D, D distinct per instance so the lines cannot race:
//   {p,q} = {1,0} -> and; {1,2} -> or; {1,1} -> the `else ;` null block,
//   nothing; {2,1} -> case 0,1,2 -> xor; {2,7} -> default -> xnor; {0,0} ->
//   no branch, nothing.
// Recursion: r #(N) instantiates r #(N-1) while N > 0, so r #(2) makes r #(2),
// r #(1), r #(0), each printing "r N" at t = 10 + N: r 0, r 1, r 2.
//! inherited IEEE 1364-2005 12.4.2
`timescale 1ns/1ns
module test;
  parameter p = 0, q = 0, D = 1;
  wire a, b, c;
  if (p == 1)
    if (q == 0)
      begin : u1
        and g1(a, b, c);
        initial #D $display("p=%0d q=%0d and", p, q);
      end
    else if (q == 2)
      begin : u1
        or g1(a, b, c);
        initial #D $display("p=%0d q=%0d or", p, q);
      end
    else ;
  else if (p == 2)
    case (q)
      0, 1, 2:
        begin : u1
          xor g1(a, b, c);
          initial #D $display("p=%0d q=%0d xor", p, q);
        end
      default:
        begin : u1
          xnor g1(a, b, c);
          initial #D $display("p=%0d q=%0d xnor", p, q);
        end
    endcase
endmodule
module r;
  parameter N = 2;
  if (N > 0) begin : sub
    r #(N - 1) inner();
  end
  initial #(10 + N) $display("r %0d", N);
endmodule
module b_12_4_2_direct_nesting_and_recursion;
  test #(1, 0, 1) t10();
  test #(1, 2, 2) t12();
  test #(1, 1, 3) t11();
  test #(2, 1, 4) t21();
  test #(2, 7, 5) t27();
  test #(0, 0, 6) t00();
  r top_r();
endmodule
