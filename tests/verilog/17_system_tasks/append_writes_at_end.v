// IEEE 1364-2005 §17.2.5, p. 295: "When a file is opened for append (that is,
// when type is "a" or "a+"), it is impossible to overwrite information
// already in the file. $fseek can be used to reposition the file pointer to
// any position in the file, but when output is written to the file, the
// current file pointer is disregarded. All output is written at the end of
// the file and causes the file pointer to be repositioned at the end of the
// output."
//
//   "w": write "AB", close. "a": $fseek(fd, 0, 0) succeeds (code 0); the
//   write of "C" disregards that position and lands at the end, leaving the
//   pointer after it at 3 -> "seek=0 tell=3".
//   Reopened "r": A B C then EOF -> "65 66 67 -1".
//! inherited IEEE 1364-2005 17.2.5
module b_17_2_5_append_writes_at_end;
  integer fd, r, c;
  initial begin
    fd = $fopen("b_17_2_5_append_writes_at_end.txt", "w");
    $fwrite(fd, "AB");
    $fclose(fd);
    fd = $fopen("b_17_2_5_append_writes_at_end.txt", "a");
    r = $fseek(fd, 0, 0);
    $fwrite(fd, "C");
    $display("seek=%0d tell=%0d", r, $ftell(fd));
    $fclose(fd);
    fd = $fopen("b_17_2_5_append_writes_at_end.txt", "r");
    c = $fgetc(fd); $write("%0d ", c);
    c = $fgetc(fd); $write("%0d ", c);
    c = $fgetc(fd); $write("%0d ", c);
    c = $fgetc(fd); $display("%0d", c);
    $fclose(fd);
    $finish(0);
  end
endmodule
