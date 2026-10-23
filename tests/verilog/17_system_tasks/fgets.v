// IEEE 1364-2005 §17.2.4.2, pp. 290-291: "code = $fgets ( str, fd ); reads
// characters from the file specified by fd into the reg str until str is
// filled, or a newline character is read and transferred to str, or an EOF
// condition is encountered. If str is not an integral number of bytes in
// length, the most significant partial byte is not used in order to determine
// the size. If an error occurs reading from the file, then code is set to
// zero. Otherwise, the number of characters read is returned in code."
//
// The file is written first: "AB\nCDEFGH\n" (10 bytes).
//   $fgets(s3, fd), s3 24 bits = 3 bytes: A, B, then the newline is read and
//     transferred -> 3 characters, s3 = 41 42 0a -> "3 41420a"
//   $fgets(s3, fd): C D E fills s3 -> "3 434445"
//   $fgets(odd, fd), odd 19 bits: the partial top byte (3 bits) is not used,
//     so odd holds 2 characters: F G -> "2 4647" (odd[15:0])
//   $fgets(s3, fd): H, then the newline is read and transferred -> 2
//     characters; only the count is printed, since the clause does not say
//     what the unfilled byte of s3 holds -> "2"
//   $fgets(s3, fd) at EOF: no character is read -> 0 either way -> "0"
//! inherited IEEE 1364-2005 17.2.4.2
// native-required
module b_17_2_4_2_fgets;
  integer fd, code;
  reg [8*3:1] s3;
  reg [18:0] odd;
  initial begin
    fd = $fopen("b_17_2_4_2_fgets.txt", "w");
    $fwrite(fd, "AB\nCDEFGH\n");
    $fclose(fd);
    fd = $fopen("b_17_2_4_2_fgets.txt", "r");
    code = $fgets(s3, fd);
    $display("%0d %h", code, s3);
    code = $fgets(s3, fd);
    $display("%0d %h", code, s3);
    code = $fgets(odd, fd);
    $display("%0d %h", code, odd[15:0]);
    code = $fgets(s3, fd);
    $display("%0d", code);
    code = $fgets(s3, fd);
    $display("%0d", code);
    $fclose(fd);
    $finish(0);
  end
endmodule
