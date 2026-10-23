// IEEE 1364-2005 §17.2.4.4 reads bytes big-endian, ignoring start/count for
// a packed reg. A memory starts at its lowest numeric address even when
// declared descending, and each word takes ceil(width/8) bytes. Bits above
// a non-byte-aligned width are discarded.
//
// "ABCDEFGHIJKLmnop" is 16 bytes. The first 12 become the 96-bit packed
// word, despite irrelevant x/zero start/count arguments. A zero memory
// count reads nothing. The remaining four bytes
// are 6d 6e 6f 70: the two nine-bit words are 16e and 170 at addresses 1
// and 2. Address 3 stays 155. Only mem[2]'s changed value wakes its observer.
// Reading at EOF leaves wide alone. After
// rewind, a singleton memory at maxInt64 takes byte 41 once; advancing past
// its last address must not overflow the host. Invalid memory dimensions
// are separately refused by fread_multidim_rejected.v.
//! inherited IEEE 1364-2005 17.2.4.4
// native-required
// native-state: 4
module native_binary_file_targets;
  integer fd, code, changes;
  reg [95:0] wide;
  reg [8:0] mem [3:1];
  reg [7:0] edge_mem [64'sh7fffffffffffffff:64'sh7fffffffffffffff];
  always @(mem[2]) changes = changes + 1;
  initial begin
    changes = 0;
    mem[1] = 9'h155; mem[2] = 9'h155; mem[3] = 9'h155;
    #1 changes = 0;
    fd = $fopen("native_binary_file_targets.bin", "wb");
    $fwrite(fd, "ABCDEFGHIJKLmnop");
    $fclose(fd);
    fd = $fopen("native_binary_file_targets.bin", "rb");
    code = $fread(wide, fd, 32'bx, 0);
    $display("wide %0d %h", code, wide);
    code = $fread(mem, fd, 1, 0);
    $display("zero-count %0d %0d", code, $ftell(fd));
    code = $fread(mem, fd, , 2);
    #0 $display("memory %0d %h %h %h changes=%0d", code, mem[1], mem[2], mem[3], changes);
    code = $fread(wide, fd);
    $display("eof %0d %h", code, wide);
    code = $rewind(fd);
    code = $fread(edge_mem, fd);
    $display("last-address %0d %h %0d", code, edge_mem[64'sh7fffffffffffffff], $ftell(fd));
    $fclose(fd);
    $finish(0);
  end
endmodule
