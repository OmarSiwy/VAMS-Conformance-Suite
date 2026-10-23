// IEEE 1364-2005 A.2.8, p. 493:
//   block_item_declaration ::=
//       { attribute_instance } reg [ signed ] [ range ] list_of_block_variable_identifiers ;
//     | { attribute_instance } integer list_of_block_variable_identifiers ;
//     | { attribute_instance } time list_of_block_variable_identifiers ;
//     | { attribute_instance } real list_of_block_real_identifiers ;
//     | { attribute_instance } realtime list_of_block_real_identifiers ;
//     | { attribute_instance } event_declaration
//     | { attribute_instance } local_parameter_declaration ;
//     | { attribute_instance } parameter_declaration ;
//   list_of_block_variable_identifiers ::= block_variable_type { , block_variable_type }
//   list_of_block_real_identifiers ::= block_real_type { , block_real_type }
//   block_variable_type ::= variable_identifier { dimension }
//   block_real_type ::= real_identifier { dimension }
//
// A task's { block_item_declaration } (A.2.7's second task_declaration form)
// declares the five variable kinds: reg signed [3:0] rs and a reg array
// ra[0:1]; integer i, j; time t; real x and a real array xa[0:1]; realtime
// rt. (The event, localparam and parameter alternatives are
// b_A_2_8_event_and_parameter_items.v; attribute instances,
// b_A_9_1_attributes.v; declarations in a named begin block,
// b_A_6_3_named_block_declarations.v.) Then:
//   rs = -5 -> "-5";  ra[1] = 4'd9;  i = 5;  j = i * 2 = 10;
//   t = 7;  x = 0.5;  xa[1] = 1.25;  rt = 2.5.
// Output: "rs=-5 ra1=9 i=5 j=10 t=7 x=0.50 xa1=1.25 rt=2.50".
//! inherited IEEE 1364-2005 A.2.8
// native-required
module b_A_2_8_block_item_declarations;
  task run ();
    reg signed [3:0] rs;
    reg [3:0] ra [0:1];
    integer i, j;
    time t;
    real x, xa [0:1];
    realtime rt;
  begin
    rs = -5;
    ra[1] = 4'd9;
    i = 5;
    j = i * 2;
    t = 7;
    x = 0.5;
    xa[1] = 1.25;
    rt = 2.5;
    $display("rs=%0d ra1=%0d i=%0d j=%0d t=%0d x=%.2f xa1=%.2f rt=%.2f", rs, ra[1], i, j, t, x, xa[1], rt);
  end
  endtask
  initial begin
    run;
    $finish(0);
  end
endmodule
