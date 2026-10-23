// IEEE 1364-2005 §17.2.4.2: characters are read until "str is filled, or a
// newline character is read and transferred to str, or an EOF condition is
// encountered". The partial most-significant byte does not supply capacity.
// §17.2.7: after a successful operation, "the reg str shall be cleared".
//
// The file holds ABCDEFGHIJK\nxy\nZ. A 96-bit destination receives the first
// 12 bytes, including newline, and its event observer runs once before the
// next tick. A selected 16-bit memory word receives xy (0x7879). A 7-bit
// destination has zero complete bytes: it keeps 0x55 and leaves the newline
// for $fgetc (10). The final Z returns 1; the next read returns 0 and leaves
// the destination unchanged. No claim is made about an unfilled high byte.
// An unknown descriptor similarly reads nothing and leaves the target alone.
// A failed open must report a nonzero error and nonempty description; the
// next successful open clears both. The error's number/text are not fixed.
// Existing b_17_2_*_rejected cases pin invalid calls; this legal runtime
// fixture pins output lvalues, wide stores and their event notifications.
//! inherited IEEE 1364-2005 17.2.4.2
//! inherited IEEE 1364-2005 17.2.7
// native-required
// native-state: 4
`timescale 1ns/1ns
module native_file_input_targets;
  integer fd, code, changes, index, unknown_fd;
  reg [95:0] line, saved_line;
  reg [15:0] mem [1:2], saved;
  reg [6:0] partial;
  reg [639:0] error_text;
  always @(line) changes = changes + 1;
  initial begin
    line = 0;
    changes = 0;
    #1;
    changes = 0;
    fd = $fopen("native_file_input_targets.txt", "w");
    $fwrite(fd, "ABCDEFGHIJK\nxy\nZ");
    $fclose(fd);
    fd = $fopen("native_file_input_targets.txt", "r");
    code = $fgets(line, fd);
    $display("wide %0d %h", code, line);
    #1;
    $display("changed %0d", changes);
    index = 1;
    code = $fgets(mem[index], fd);
    $display("array %0d %h", code, mem[1]);
    partial = 7'h55;
    code = $fgets(partial, fd);
    $display("partial %0d %h %0d", code, partial, $fgetc(fd));
    code = $fgets(mem[2], fd);
    $display("tail %0d", code);
    saved = mem[2];
    code = $fgets(mem[2], fd);
    $display("eof %0d %0d", code, mem[2] === saved);
    saved_line = line;
    unknown_fd = 32'bx;
    code = $fgets(line, unknown_fd);
    $display("unknown %0d %0d", code, line === saved_line);
    $fclose(fd);
    fd = $fopen("native_file_input_targets_missing/none.txt", "r");
    code = $ferror(fd, error_text);
    $display("error %0d %0d", code != 0, error_text != 0);
    fd = $fopen("native_file_input_targets.txt", "r");
    code = $ferror(fd, error_text);
    $display("cleared %0d %0d", code, error_text == 0);
    $fclose(fd);
    $finish(0);
  end
endmodule
