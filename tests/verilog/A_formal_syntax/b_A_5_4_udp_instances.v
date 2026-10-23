// IEEE 1364-2005 A.5.4, p. 497:
//   udp_instantiation ::= udp_identifier [ drive_strength ] [ delay2 ]
//     udp_instance { , udp_instance } ;
//   udp_instance ::= [ name_of_udp_instance ] ( output_terminal , input_terminal
//     { , input_terminal } )
//   name_of_udp_instance ::= udp_instance_identifier [ range ]
//
// b_A_5_4_and2 is a combinational AND UDP. Instantiated:
//   u1 with no name, strength or delay: y1 = 1 & 1 = 1
//   (pull0, pull1) #(2, 3) with two named instances u2 (y2, 1, 0) and
//     u3 (y3, 1, 1): y2 = 0, y3 = 1; y3 also carries an assign
//     (weak0, weak1) y3 = 0, which the pull1 output overrides (§7.10.1)
// (An instance array is b_A_5_4_udp_instance_array.v.)
// Read at t=5, after every delay: "y1=1 y2=0 y3=1".
//! inherited IEEE 1364-2005 A.5.4
`timescale 1ns/1ns
primitive b_A_5_4_and2 (y, a, b);
  output y;
  input a, b;
  table
    1 1 : 1;
    0 ? : 0;
    ? 0 : 0;
  endtable
endprimitive
module b_A_5_4_udp_instances;
  wire y1, y2, y3;
  assign (weak0, weak1) y3 = 1'b0;
  b_A_5_4_and2 (y1, 1'b1, 1'b1);
  b_A_5_4_and2 (pull0, pull1) #(2, 3) u2 (y2, 1'b1, 1'b0), u3 (y3, 1'b1, 1'b1);
  initial #5 begin
    $display("y1=%b y2=%b y3=%b", y1, y2, y3);
    $finish(0);
  end
endmodule
