// IEEE 1364-2005 §17.2.4.4, pp. 293-294: "reads a binary data from the file
// specified by fd into the reg myreg or the memory mem. start is an optional
// argument. If present, start shall be used as the address of the first
// element in the memory to be loaded. If not present, the lowest numbered
// location in the memory shall be used. count is an optional argument. If
// present, count shall be the maximum number of locations in mem that shall
// be loaded. If not supplied, the memory shall be filled with what data are
// available." ... "The data in the file shall be read byte by byte to fulfill
// the request. An 8-bit wide memory is loaded using 1 byte per memory word
// ... The data are read from the file in a big endian manner; the first byte
// read is used to fill the most significant location in the memory element."
// ... "If an error occurs reading from the file, then code is set to zero.
// Otherwise, the number of characters read is returned in code."
//
// The file is written first: the 8 bytes 12 34 56 78 9a bc de f0.
//   $fread(r16, fd): 2 bytes, big endian -> r16 = 16'h1234 -> "2 1234"
//   $fread(mem, fd, 11, 2), mem [10:13] of 8 bits: start 11, at most 2
//     words -> mem[11] = 56, mem[12] = 78; mem[10], mem[13] still x
//     -> "2 xx 56 78 xx"
//   $fread(mem, fd): no start, so from the lowest address 10, filled with
//     what is left -> 9a bc de f0, 4 bytes -> "4 9a bc de f0"
//   $fread(r16, fd) at end of file: no character read -> "0"
//! inherited IEEE 1364-2005 17.2.4.4
// native-required
module b_17_2_4_4_fread;
  integer fd, code;
  reg [15:0] r16;
  reg [7:0] mem [10:13];
  initial begin
    fd = $fopen("b_17_2_4_4_fread.bin", "wb");
    $fwrite(fd, "%c%c%c%c%c%c%c%c", 8'h12, 8'h34, 8'h56, 8'h78, 8'h9a, 8'hbc, 8'hde, 8'hf0);
    $fclose(fd);
    fd = $fopen("b_17_2_4_4_fread.bin", "rb");
    code = $fread(r16, fd);
    $display("%0d %h", code, r16);
    code = $fread(mem, fd, 11, 2);
    $display("%0d %h %h %h %h", code, mem[10], mem[11], mem[12], mem[13]);
    code = $fread(mem, fd);
    $display("%0d %h %h %h %h", code, mem[10], mem[11], mem[12], mem[13]);
    code = $fread(r16, fd);
    $display("%0d", code);
    $fclose(fd);
    $finish(0);
  end
endmodule
