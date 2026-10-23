// IEEE 1364-2005 §17.2.9: $readmemh loads "data into a memory from a file"
// of white space, comments and hexadecimal numbers, and `@hh...` addresses.
// The clause bounds no file size. VerA read the file whole and refused one
// past 4 MiB (E1100) until 2026-10 (#29); it now reads it as a stream, one
// token at a time.
//
// HAND DERIVATION. The run writes the file itself (§17.2.1 $fopen "w",
// §17.2.2 $fwrite), so no large file is committed: 4100 lines, each 1023
// `/` characters and a newline, are 4100 * 1024 = 4198400 bytes, past
// 4 MiB = 4194304. Each line is a `//` comment. Then `@2`, `5a`, `c3`:
// address 2, so mem[2] = 8'h5a and mem[3] = 8'hc3. mem[0] and mem[1] are
// never written and keep a reg's initial x (§3.2): "xx". The file gives an
// address, so §17.2.9's word-count warning does not apply.
//! inherited IEEE 1364-2005 17.2.9
//! expect stdout readmem_file_past_4mib.expected.txt
module b_17_2_9_readmem_file_past_4mib;
  reg [8*1023-1:0] line;
  reg [7:0] mem [0:3];
  integer fd, i;
  initial begin
    line = {1023{"/"}};
    fd = $fopen("b_17_2_9_readmem_file_past_4mib.mem", "w");
    for (i = 0; i < 4100; i = i + 1) $fwrite(fd, "%s\n", line);
    $fwrite(fd, "@2\n5a\nc3\n");
    $fclose(fd);
    $readmemh("b_17_2_9_readmem_file_past_4mib.mem", mem);
    $display("%h %h %h %h", mem[0], mem[1], mem[2], mem[3]);
  end
endmodule
