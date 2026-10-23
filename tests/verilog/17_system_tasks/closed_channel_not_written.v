// IEEE 1364-2005 §17.2.1, p. 288: "The $fclose system task closes the
// channels specified by the multichannel descriptor and does not allow any
// further output to the closed channels." §17.2.7, p. 295: $ferror returns
// "the integral value of the error code" of "the most recent file I/O
// operation", zero when it "did not result in an error".
//
// "A" is written and the descriptor closed; the $fwrite of "B" after the
// close is not allowed, so it writes nothing (VerA warns, W1154) and is an
// error $ferror reports. The file, read back, holds "A" alone:
//   $ferror after the refused write -> nonzero -> "1"
//   the file: 65 (A), then EOF -> "65 -1"
//! inherited IEEE 1364-2005 17.2.1
// native-required
module b_17_2_1_closed_channel_not_written;
  integer fd, errno, c;
  reg [639:0] str;
  initial begin
    fd = $fopen("b_17_2_1_closed_channel.txt", "w");
    $fwrite(fd, "A");
    $fclose(fd);
    $fwrite(fd, "B");
    errno = $ferror(fd, str);
    $display("%0d", errno != 0);
    fd = $fopen("b_17_2_1_closed_channel.txt", "r");
    c = $fgetc(fd); $write("%0d ", c);
    c = $fgetc(fd); $display("%0d", c);
    $fclose(fd);
    $finish(0);
  end
endmodule
