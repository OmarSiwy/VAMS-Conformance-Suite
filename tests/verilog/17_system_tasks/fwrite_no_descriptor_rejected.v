// IEEE 1364-2005 §17.2.2 Syntax 17-5: `file_output_task_name (
// multi_channel_descriptor [ , list_of_arguments ] )` — "The first argument
// shall be either a multichannel descriptor or a file descriptor". A $fwrite
// with no argument list at all names no file to write to.
//! inherited IEEE 1364-2005 17.2.2
//! reject first argument is a descriptor
module audit_fwrite_no_descriptor_rejected;
  initial $fwrite;
endmodule
