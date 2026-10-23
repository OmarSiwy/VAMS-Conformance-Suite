// IEEE1364-2005 §5.1.5: "if the second operand of a division or modulus
// operator is zero, then the entire result value shall be x". q starts x but
// is written before each read, so `--state=auto` turns 2-state at tick 1.
// At tick 2 it prints a / 0, an x it computes as 4-state does, then stores
// one into q, which a 2-state run cannot hold: it reruns the design 4-state
// and prints only what follows (`// native-state: rerun`).
// q = 12 / 4 = 3; 12 / 0 = x, printed and stored; 12 % 5 = 2.
//! inherited IEEE 1364-2005 5.1.5
// native-state: rerun
module auto_state_rerun;
  reg [7:0] a, b, q;
  initial begin
    a = 8'd12;
    b = 8'd4;
    #1 q = a / b;
    $display("q=%0d", q);
    b = 0;
    #1 $display("a/b=%0d", a / b);
    q = a / b;
    $display("q=%0d", q);
    #1 q = a % 8'd5;
    $display("q=%0d", q);
  end
endmodule
