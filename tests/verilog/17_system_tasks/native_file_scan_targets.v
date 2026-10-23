// IEEE 1364-2005 §17.2.4.3: formatted reads assign converted values and leave
// an offending character unread. An unknown format returns EOF. The format
// here is a register, and the outputs are an array element, a real and a
// 96-bit string. These are legal destinations; the shared variable-only
// output rule is pinned by sscanf_to_net_rejected.v (E1100).
//
// The bytes are "10 2.5 abcdefghijkl\nq 1234!". An unknown format consumes
// nothing and preserves the initialized target. The three conversions then
// consume 19 bytes: 2+1+3+1+12. A decimal conversion skips the newline, fails
// on q, and leaves the target at 10. Reading q returns ASCII 113. %2d then
// reads 12, a second %d reads 34, and ! is still available as ASCII 33.
// A subsequent conversion returns EOF without changing 34. An unknown
// descriptor also returns EOF and leaves the destination alone.
//! inherited IEEE 1364-2005 17.2.4.3
// native-required
// native-state: 4
module native_file_scan_targets;
  integer fd, code, values [0:1];
  reg [127:0] format;
  reg [95:0] word;
  real fraction;
  initial begin
    fd = $fopen("native_file_scan_targets.txt", "w");
    $fwrite(fd, "10 2.5 abcdefghijkl\nq 1234!");
    $fclose(fd);
    fd = $fopen("native_file_scan_targets.txt", "r");
    values[1] = 99;
    format = 'bx;
    code = $fscanf(fd, format, values[1]);
    $display("unknown-format %0d %0d %0d", code, values[1], $ftell(fd));
    format = "%d %f %s";
    code = $fscanf(fd, format, values[1], fraction, word);
    $display("converted %0d %0d %.1f %s %0d", code, values[1], fraction, word, $ftell(fd));
    code = $fscanf(fd, "%d", values[1]);
    $display("mismatch %0d %0d", code, values[1]);
    code = $fgetc(fd);
    $display("left-unread %0d", code);
    code = $fscanf(fd, "%2d", values[1]);
    $display("width %0d %0d", code, values[1]);
    code = $fscanf(fd, "%d", values[1]);
    $display("remaining %0d %0d", code, values[1]);
    code = $fgetc(fd);
    $display("punctuation %0d", code);
    code = $fscanf(fd, "%d", values[1]);
    $display("eof %0d %0d", code, values[1]);
    code = $fscanf(32'bx, "%d", values[1]);
    $display("unknown-fd %0d %0d", code, values[1]);
    $fclose(fd);
    $finish(0);
  end
endmodule
