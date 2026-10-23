// IEEE 1364-2005 §17.2.7, p. 295: "errno = $ferror ( fd, str ); A string
// description of type of error encountered by the most recent file I/O
// operation is written into str, which should be at least 640 bits wide. The
// integral value of the error code is returned in errno. If the most recent
// operation did not result in an error, then the value returned shall be
// zero, and the reg str shall be cleared."
// §17.2.1, p. 288: "If a file cannot be opened (either the file does not exist
// and the type specified is "r" ...), a zero is returned for the mcd or fd.
// Applications can call $ferror to determine the cause of the most recent
// error".
//
//   A successful "w" open, then $ferror(fd, str): no error -> 0, and str
//     is cleared -> "0 1" (str == 0).
//   A failed "r" open of a file that does not exist returns 0; $ferror on
//     that descriptor reports the error with a nonzero code. The value is
//     not fixed by the clause (CLAUSE-AUDIT §5.5), so only its being nonzero
//     is printed -> "1".
//! inherited IEEE 1364-2005 17.2.7
// native-required
module b_17_2_7_ferror;
  integer fd, errno;
  reg [639:0] str;
  initial begin
    str = "stale";
    fd = $fopen("b_17_2_7_ferror.txt", "w");
    errno = $ferror(fd, str);
    $display("%0d %0d", errno, str == 0);
    $fclose(fd);
    fd = $fopen("b_17_2_7_ferror_missing/none.txt", "r");
    errno = $ferror(fd, str);
    $display("%0d", errno != 0);
    $finish(0);
  end
endmodule
