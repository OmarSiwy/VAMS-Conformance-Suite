// IEEE 1364-2005 §17.2.1 Table 17-7: "w" "Truncate to zero length or create
// for writing", "a" "Append; open for writing at end of file (EOF), or create
// for writing", "r" "Open for reading". "If type is omitted, the file is
// opened for writing, and a multichannel descriptor mcd is returned", "a
// 32-bit reg in which a single bit is set ... The least significant bit
// (bit 0) of an mcd always refers to the standard output"; an fd has "the
// most significant bit (bit 31) ... always set". "The $fopen function shall
// reuse channels that have been closed."
// §17.2.2: $fdisplay and $fwrite "accept the same type of arguments as the
// tasks upon which they are based, with one exception: The first argument
// shall be either a multichannel descriptor or a file descriptor", and mcds
// are OR-ed "to direct output to multiple files", bit 0 adding stdout.
//
// HAND DERIVATION.
//   fd = $fopen(w_file, "w"): bit 31 set.        $fwrite "ab", $fdisplay 12
//     -> the file holds "ab12\n".
//   fa = $fopen(w_file, "a"): $fwriteh 8'hc3 appends "c3" -> "ab12\nc3".
//   Both closed, so the first channel is free again and the mcd open takes
//   it: the lowest bit above bit 0, mcd = 2.
//   $fdisplay(mcd | 1, "both %0d", 7) writes "both 7\n" to the file AND to
//   stdout, so the transcript shows it once here.
//   Reading both files back with $fgetc prints their bytes between [ ].
//! inherited IEEE 1364-2005 17.2.1 ($fopen w, a, mcd; channel reuse)
//! inherited IEEE 1364-2005 17.2.2 ($fdisplay, $fwrite, mcd OR-ing)
module audit_fopen_write_append_mcd;
  integer fd, fa, mcd, c;
  initial begin
    fd = $fopen("audit_fopen_w.txt", "w");
    $fwrite(fd, "ab");
    $fdisplay(fd, "%0d", 12);
    $fclose(fd);
    fa = $fopen("audit_fopen_w.txt", "a");
    $fwriteh(fa, 8'hc3);
    $fclose(fa);
    mcd = $fopen("audit_fopen_m.txt");
    $display("mcd=%0d fd_msb=%b", mcd, fd[31]);
    $fdisplay(mcd | 1, "both %0d", 7);
    $fclose(mcd);
    fd = $fopen("audit_fopen_w.txt", "r");
    $write("[");
    c = $fgetc(fd);
    while (c != -1) begin $write("%c", c); c = $fgetc(fd); end
    $display("]");
    $fclose(fd);
    fd = $fopen("audit_fopen_m.txt", "r");
    $write("[");
    c = $fgetc(fd);
    while (c != -1) begin $write("%c", c); c = $fgetc(fd); end
    $display("]");
  end
endmodule
