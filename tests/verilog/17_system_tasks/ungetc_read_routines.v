// IEEE 1364-2005 §17.2.4.1: $ungetc "inserts the character specified by c
// into the buffer specified by file descriptor fd. The character c shall be
// returned by the next $fgetc call on that file descriptor." The clause names
// only $fgetc, but the character goes into the descriptor's buffer, which
// every read routine of §17.2.4 reads, as C's fgets/fscanf/fread read what
// ungetc pushed. VerA's reading (specification/Vague_Decisions.md VD-084): $fgets,
// $fscanf and $fread read the pushback before the file, and pushback a read
// does not consume is still the next input.
//
// HAND DERIVATION. The file is "abc\n12 x\nmn".
//   $fgetc -> "a"; push "Z"            stream "Zbc\n12 x\nmn"
//   $fgets into 4 characters -> 4, "Zbc\n" (shown without the newline)
//   $fgetc -> "1"; push "7"            stream "72 x\nmn"
//   $fscanf "%d" -> 1, v = 72          stream " x\nmn"
//   $fgetc twice -> " ", "x"; push "Q" stream "Q\nmn"
//   $fscanf "%d" -> 0: "Q" is no digit (§17.2.4.3 "the offending input
//     character is left unread"), v stays 72
//   $fgetc -> "Q", the pushed character, not the file's "x" under it
//   $fgetc -> "\n"; push "P"           stream "Pmn"
//   $fread into 16 bits -> 2, "Pm"
//   $fgetc -> "n"
//
// No rejection fixture: every call is legal, and $ungetc's error case (the
// 17th push) is ungetc_pushback_limit.v.
//! inherited IEEE 1364-2005 17.2.4.1
//! inherited IEEE 1364-2005 17.2.4.2
//! inherited IEEE 1364-2005 17.2.4.3
//! inherited IEEE 1364-2005 17.2.4.4
module b_17_2_4_1_ungetc_read_routines;
  integer fd, c, n, r, v;
  reg [8*4:1] s;
  reg [15:0] w;
  initial begin
    fd = $fopen("b_17_2_4_1_ungetc_read_routines.dat", "w");
    $fwrite(fd, "abc\n12 x\nmn");
    $fclose(fd);
    fd = $fopen("b_17_2_4_1_ungetc_read_routines.dat", "r");
    c = $fgetc(fd);
    c = $ungetc("Z", fd);
    n = $fgets(s, fd);
    $display("fgets n=%0d s=%s", n, s[32:9]);
    c = $fgetc(fd);
    c = $ungetc("7", fd);
    r = $fscanf(fd, "%d", v);
    $display("fscanf r=%0d v=%0d", r, v);
    c = $fgetc(fd);
    c = $fgetc(fd);
    c = $ungetc("Q", fd);
    r = $fscanf(fd, "%d", v);
    c = $fgetc(fd);
    $display("fscanf r=%0d v=%0d next=%s", r, v, c[7:0]);
    c = $fgetc(fd);
    c = $ungetc("P", fd);
    r = $fread(w, fd);
    c = $fgetc(fd);
    $display("fread r=%0d w=%s next=%s", r, w, c[7:0]);
    $fclose(fd);
    $finish(0);
  end
endmodule
