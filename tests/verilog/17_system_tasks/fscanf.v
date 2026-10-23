// IEEE 1364-2005 §17.2.4.3, pp. 291-293: "code = $fscanf ( fd, format, args );
// ... $fscanf reads from the files specified by the file descriptor fd."
// "If conversion terminates on a conflicting input character, the offending
// input character is left unread in the input stream." ... "If the input ends
// before the first matching failure or conversion, EOF is returned."
//
// The file is written first: "10 20\nq".
//   $fscanf(fd, "%d %d", a, b): 10 and 20 -> "2 10 20"
//   $fscanf(fd, "%d", a): the blank-skip of %d passes the newline; q is no
//     decimal digit, a matching failure -> 0; q is left unread
//   $fgetc(fd): the q left unread -> 113
//   $fscanf(fd, "%d", a): the input ends before any conversion -> EOF, -1
//! inherited IEEE 1364-2005 17.2.4.3
// native-required
module b_17_2_4_3_fscanf;
  integer fd, code, a, b;
  initial begin
    fd = $fopen("b_17_2_4_3_fscanf.txt", "w");
    $fwrite(fd, "10 20\nq");
    $fclose(fd);
    fd = $fopen("b_17_2_4_3_fscanf.txt", "r");
    code = $fscanf(fd, "%d %d", a, b);
    $display("%0d %0d %0d", code, a, b);
    code = $fscanf(fd, "%d", a);
    $display("%0d", code);
    $display("%0d", $fgetc(fd));
    code = $fscanf(fd, "%d", a);
    $display("%0d", code);
    $fclose(fd);
    $finish(0);
  end
endmodule
