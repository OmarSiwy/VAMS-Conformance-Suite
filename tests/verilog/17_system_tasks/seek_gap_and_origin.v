// IEEE 1364-2005 §17.2.5, pp. 294-295: "The new position is at the signed
// distance offset bytes from the beginning, from the current position, or
// from the end of the file, according to an operation value of 0, 1, and 2"
// ... "$rewind is equivalent to $fseek (fd,0,0);" ... "$fseek() allows the
// file position indicator to be set beyond the end of the existing data in
// the file. If data are later written at this point, subsequent reads of data
// in the gap shall return zero until data are actually written into the gap.
// $fseek, by itself, does not extend the size of the file." ... "If an error
// occurs repositioning the file, then code is set to -1. Otherwise, code is
// set to 0." $ftell (p. 294) "returns in pos the offset from the beginning of
// the file of the current byte of the file fd".
//
// The file is written with "w" and reopened with "r+" (Table 17-7: "Open for
// update (reading and writing)"), because §17.2.4 (p. 290) says "Files opened
// using file descriptors can be read from only if they were opened with
// either the r or r+ type values."
//   "w": write "AB", close; "r+": $fseek(fd, 4, 0) past the end -> code 0,
//     $ftell 4
//     -> "seek=0 tell=4"
//   write "C" at 4: the file is A B gap gap C (5 bytes)
//   $rewind, then six $fgetc: 65 66, the gap reads 0 0, 67, then EOF -1
//     -> "65 66 0 0 67 -1"
//   $rewind, two $fgetc (position 2), $fseek(fd, -1, 1): current 2 - 1 = 1
//     -> code 0, $fgetc = B -> "rel=0 66"
//   $fseek(fd, 10, 0) with no write after it, then $fseek(fd, 0, 2): the
//     size is still 5 -> "size=5"
//   $fseek(fd, -10, 0): no byte -10 exists -> "bad=-1"
//! lrm 9.5.5
//! lrm 9.5.5:4
//! lrm 9.5.5:3
//! inherited IEEE 1364-2005 17.2.5
module b_17_2_5_seek_gap_and_origin;
  integer fd, r, c;
  initial begin
    fd = $fopen("b_17_2_5_seek_gap_and_origin.txt", "w");
    $fwrite(fd, "AB");
    $fclose(fd);
    fd = $fopen("b_17_2_5_seek_gap_and_origin.txt", "r+");
    r = $fseek(fd, 4, 0);
    $display("seek=%0d tell=%0d", r, $ftell(fd));
    $fwrite(fd, "C");
    r = $rewind(fd);
    c = $fgetc(fd); $write("%0d ", c);
    c = $fgetc(fd); $write("%0d ", c);
    c = $fgetc(fd); $write("%0d ", c);
    c = $fgetc(fd); $write("%0d ", c);
    c = $fgetc(fd); $write("%0d ", c);
    c = $fgetc(fd); $display("%0d", c);
    r = $rewind(fd);
    c = $fgetc(fd);
    c = $fgetc(fd);
    r = $fseek(fd, -1, 1);
    c = $fgetc(fd);
    $display("rel=%0d %0d", r, c);
    r = $fseek(fd, 10, 0);
    r = $fseek(fd, 0, 2);
    $display("size=%0d", $ftell(fd));
    r = $fseek(fd, -10, 0);
    $display("bad=%0d", r);
    $fclose(fd);
    $finish(0);
  end
endmodule
