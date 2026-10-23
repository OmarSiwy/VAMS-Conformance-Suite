// IEEE 1364-2005 §17.2.1, Syntax 17-4, p. 287:
//   file_close_task ::= $fclose ( multi_channel_descriptor ) ;
//                     | $fclose ( fd ) ;
// "The $fclose system task closes the file specified by fd or closes the
// file(s) specified by the multichannel descriptor mcd." (p. 288)
//
// Both alternatives take exactly one descriptor; $fclose(a, b) gives two
// (Syntax 3-2's generic argument list is narrowed by Syntax 17-4, the
// definition of $fclose, as §3.7.3 defers to Clause 17). (To
// close several mcd channels at once they are OR-ed into one descriptor.)
// Legal neighbour: fopen_write_append_mcd.v's one-argument $fclose.
//! inherited IEEE 1364-2005 17.2.1
//! reject E1100
//! reject $fclose takes one descriptor
//! neighbour fopen_write_append_mcd.v
module b_17_2_1_fclose_two_descriptors_rejected;
  integer a, b;
  initial begin
    a = $fopen("b_17_2_1_fclose_two_descriptors_rejected_a.txt");
    b = $fopen("b_17_2_1_fclose_two_descriptors_rejected_b.txt");
    $fclose(a, b);
  end
endmodule
