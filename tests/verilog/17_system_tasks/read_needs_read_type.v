// IEEE 1364-2005 §17.2.4, p. 290: "Files opened using file descriptors can be
// read from only if they were opened with either the r or r+ type values."
// §17.2.4.1, p. 290: "c = $fgetc ( fd ); reads a byte from the file specified
// by fd. If an error occurs reading from the file, then c is set to EOF (-1)."
// Table 17-7 (p. 287): "w" "Truncate to zero length or create for writing";
// "r" "Open for reading"; "r+" "Open for update (reading and writing)".
//
//   "w"  the file is created and "Q" (81) written; a $fgetc on the same fd
//        is a read of a file not opened for reading: an error -> -1.
//   "r+" the same file reopened for update: the first byte is Q -> 81.
//   "r"  reopened for reading: again 81.
//! inherited IEEE 1364-2005 17.2.4 17.2.4.1
module b_17_2_4_read_needs_read_type;
  integer fd, c;
  initial begin
    fd = $fopen("b_17_2_4_read_needs_read_type.txt", "w");
    $fwrite(fd, "Q");
    c = $fgetc(fd);
    $display("w: %0d", c);
    $fclose(fd);
    fd = $fopen("b_17_2_4_read_needs_read_type.txt", "r+");
    c = $fgetc(fd);
    $display("r+: %0d", c);
    $fclose(fd);
    fd = $fopen("b_17_2_4_read_needs_read_type.txt", "r");
    c = $fgetc(fd);
    $display("r: %0d", c);
    $fclose(fd);
    $finish(0);
  end
endmodule
