// IEEE 1364-2005 §17.2.6, p. 295: "$fflush ( mcd ); $fflush ( fd );
// $fflush ( ); writes any buffered output to the file(s) specified by mcd, to
// the file specified by fd, or if $fflush is invoked with no arguments, to all
// open files."
//
// Both writers stay open. After the three forms of $fflush, the byte each
// wrote is in its file, so a second descriptor opened for reading sees it:
//   fd wrote "P" (80), mcd wrote "M" (77) -> "80 77"
//! lrm 9.5.6
//! lrm 9.5.6:1000
//! inherited IEEE 1364-2005 17.2.6
module b_17_2_6_fflush;
  integer fd, mcd, rd, c1, c2;
  initial begin
    fd = $fopen("b_17_2_6_fflush_fd.txt", "w");
    mcd = $fopen("b_17_2_6_fflush_mcd.txt");
    $fwrite(fd, "P");
    $fwrite(mcd, "M");
    $fflush(fd);
    $fflush(mcd);
    $fflush();
    rd = $fopen("b_17_2_6_fflush_fd.txt", "r");
    c1 = $fgetc(rd);
    $fclose(rd);
    rd = $fopen("b_17_2_6_fflush_mcd.txt", "r");
    c2 = $fgetc(rd);
    $fclose(rd);
    $display("%0d %0d", c1, c2);
    $fclose(fd);
    $fclose(mcd);
    $finish(0);
  end
endmodule
