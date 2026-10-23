// IEEE 1364-2005 A.2.7, p. 492-493:
//   task_declaration ::=
//       task [ automatic ] task_identifier ; { task_item_declaration } statement_or_null endtask
//     | task [ automatic ] task_identifier ( [ task_port_list ] ) ; { block_item_declaration }
//         statement_or_null endtask
//   task_item_declaration ::= block_item_declaration
//     | { attribute_instance } tf_input_declaration ;
//     | { attribute_instance } tf_output_declaration ;
//     | { attribute_instance } tf_inout_declaration ;
//   task_port_list ::= task_port_item { , task_port_item }
//   tf_input_declaration ::= input [ reg ] [ signed ] [ range ] list_of_port_identifiers
//     | input task_port_type list_of_port_identifiers
//   tf_output_declaration ::= output [ reg ] [ signed ] [ range ] list_of_port_identifiers
//     | output task_port_type list_of_port_identifiers
//   tf_inout_declaration ::= inout [ reg ] [ signed ] [ range ] list_of_port_identifiers
//     | inout task_port_type list_of_port_identifiers
//   task_port_type ::= integer | real | realtime | time
//
// Four tasks:
//   old    form 1: input reg [3:0] a, output [3:0] o, inout [3:0] io, and a
//          block_item_declaration reg [3:0] t. old(3, o, io=5): t = a + io = 8,
//          o = t = 8, io = io + 1 = 6.
//   ansi   form 2: (input integer n, output time t2, inout signed [3:0] s).
//          ansi(4, t2, s=-2): t2 = n * 10 = 40, s = s - n = -6.
//   nop    form 2 with an empty port list and a null statement_or_null.
//   down   automatic, recursive: down(3) adds 1 to the module's c three times
//          -> c = 3. (nop is enabled as `nop;`: A.6.9's task_enable has no
//          empty parentheses.)
// Output: "o=8 io=6 t2=40 s=-6 c=3".
//! inherited IEEE 1364-2005 A.2.7
module b_A_2_7_task_declarations;
  reg [3:0] o, io;
  time t2;
  reg signed [3:0] s;
  integer c;
  task old;
    input reg [3:0] a;
    output [3:0] o;
    inout [3:0] io;
    reg [3:0] t;
    begin
      t = a + io;
      o = t;
      io = io + 1;
    end
  endtask
  task ansi (input integer n, output time t2, inout signed [3:0] s);
    begin
      t2 = n * 10;
      s = s - n;
    end
  endtask
  task nop ();
    ;
  endtask
  task automatic down (input integer n);
    if (n > 0) begin
      c = c + 1;
      down(n - 1);
    end
  endtask
  initial begin
    io = 4'd5;
    old(4'd3, o, io);
    s = -2;
    ansi(4, t2, s);
    nop;
    c = 0;
    down(3);
    $display("o=%0d io=%0d t2=%0d s=%0d c=%0d", o, io, t2, s, c);
    $finish(0);
  end
endmodule
