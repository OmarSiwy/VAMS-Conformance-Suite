// IEEE 1364-2005 §10.2.1, p. 147: "There are two alternate task declaration
// syntaxes. The first syntax shall begin with the keyword task, followed by
// the optional keyword automatic, followed by a name for the task and a
// semicolon, and ending with the keyword endtask." ... "The second syntax
// shall begin with the keyword task, followed by a name for the task and a
// parenthesis-enclosed task_port_list. The task_port_list shall consist of
// zero or more comma separated task_port_items. There shall be a semicolon
// after the close parenthesis. The task body shall follow and then the
// keyword endtask." Syntax 10-1 (p. 146): task_port_type ::= integer | real
// | realtime | time.
//
// my_task from §10.2.2, in each form, with the same body:
//   c = c + a; d = a & b; e = a | b.
// Enabled as my_task1(v, w, x, y, z) with v = 4'b0101, w = 4'b0011, x = 4'd9:
//   c = 9 + 5 = 14 -> x = 1110; d = 0101 & 0011 = 0001; e = 0101 | 0011 = 0111.
//   "first 1110 0001 0111", and the second form gives the same line.
// Zero-argument forms: `task automatic tick;` (first form with automatic) and
// `task tock();` (second form, empty task_port_list) each add 1 to n, n = 0:
//   "ticks 2".
// Typed ports: `task half(input real r, output integer i)`, i = r / 2 with
//   r = 5.0: 2.5 converted to integer rounds away from zero (§4.8.2) -> 3:
//   "half 3".
//! inherited IEEE 1364-2005 10.2.1
module b_10_2_1_task_declaration_forms;
  reg [3:0] v, w, x, y, z;
  integer n, h;

  task my_task1;
    input [3:0] a, b;
    inout [3:0] c;
    output [3:0] d, e;
    begin
      c = c + a;
      d = a & b;
      e = a | b;
    end
  endtask

  task my_task2 (input [3:0] a, b, inout [3:0] c, output [3:0] d, e);
    begin
      c = c + a;
      d = a & b;
      e = a | b;
    end
  endtask

  task automatic tick;
    n = n + 1;
  endtask

  task tock();
    n = n + 1;
  endtask

  task half(input real r, output integer i);
    i = r / 2;
  endtask

  initial begin
    v = 4'b0101;
    w = 4'b0011;
    x = 4'd9;
    my_task1(v, w, x, y, z);
    $display("first %b %b %b", x, y, z);
    x = 4'd9;
    y = 0;
    z = 0;
    my_task2(v, w, x, y, z);
    $display("second %b %b %b", x, y, z);
    n = 0;
    tick;
    tock;
    $display("ticks %0d", n);
    half(5.0, h);
    $display("half %0d", h);
    $finish(0);
  end
endmodule
