// IEEE 1364-2005 §17.2.3, p. 289: "The first argument to $swrite shall be a
// reg variable to which the resulting string shall be written, instead of a
// variable specifying the file to which to write the resulting string."
// Syntax 17-6: string_output_tasks ::= string_output_task_name ( output_reg ,
// list_of_arguments ) ;
//
// w is a net, not a reg variable. Legal neighbour: string_output.v,
// whose $swrite targets reg [8*8:1] s.
//! inherited IEEE 1364-2005 17.2.3
//! reject E1100
//! reject there is no procedural assignment to a net
//! neighbour string_output.v
module b_17_2_3_swrite_to_net_rejected;
  wire [8*8:1] w;
  initial $swrite(w, "v=%0d", 8'd42);
endmodule
