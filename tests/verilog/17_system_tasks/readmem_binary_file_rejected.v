// IEEE 1364-2005 §17.2.9: a memory file holds "white space (spaces, new
// lines, tabs, and form-feeds), comments (both types of comment are
// allowed), [and] binary or hexadecimal numbers". A NUL byte is none of
// them. /dev/zero, a file every POSIX host has, starts with one and never
// ends: VerA reads a memory file as a stream (readmem_file_past_4mib.v
// loads one past the 4 MiB VerA once capped), so its first byte is refused
// as a malformed word instead of the file being read to an end it lacks.
//
// Legal neighbour: readmem_address_restart.v loads a small file.
//! inherited IEEE 1364-2005 17.2.9
//! reject E1100
//! reject the memory file has a malformed data word
//! neighbour readmem_address_restart.v
module b_17_2_9_readmem_binary_file_rejected;
  reg [7:0] mem [0:3];
  initial begin
    $readmemh("/dev/zero", mem);
    $display("accepted");
  end
endmodule
