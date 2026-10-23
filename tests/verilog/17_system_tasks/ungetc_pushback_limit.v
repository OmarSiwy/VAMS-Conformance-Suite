// IEEE 1364-2005 §17.2.4.1: $ungetc "inserts the character specified by c
// into the buffer specified by file descriptor fd. ... If an error occurs
// pushing a character onto a file descriptor, then code is set to EOF.
// Otherwise, code is set to zero." Its NOTE: "The features of the underlying
// implementation of file I/O on the host system limit the number of
// characters that can be pushed back onto a stream." VerA's limit is 16
// characters per descriptor (specification/Vague_Decisions.md); the 17th push is the
// clause's error, EOF (-1), not a silently lost character.
//
// HAND DERIVATION. The file holds the 26 letters and a newline. 20 $fgetc
// calls read "a" to "t". 17 pushes of "Z" (90) follow: the first 16 return 0,
// the 17th returns -1. The next $fgetc returns the last pushed character, 90.
//! inherited IEEE 1364-2005 17.2.4.1
module b_17_2_4_1_ungetc_pushback_limit;
  integer fd, c, k, ok, last;
  initial begin
    fd = $fopen("b_17_2_4_1_ungetc_pushback_limit.dat", "w");
    $fwrite(fd, "abcdefghijklmnopqrstuvwxyz\n");
    $fclose(fd);
    fd = $fopen("b_17_2_4_1_ungetc_pushback_limit.dat", "r");
    for (k = 0; k < 20; k = k + 1) c = $fgetc(fd);
    ok = 0;
    for (k = 0; k < 16; k = k + 1) if ($ungetc(90, fd) == 0) ok = ok + 1;
    last = $ungetc(90, fd);
    $display("pushed=%0d seventeenth=%0d next=%0d", ok, last, $fgetc(fd));
    $fclose(fd);
    $finish(0);
  end
endmodule
