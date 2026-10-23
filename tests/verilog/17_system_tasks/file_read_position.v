// IEEE1364-2005 §§17.2.1,17.2.4.1,17.2.5,17.2.8.
// The control file is ASCII A,B,newline. fd bit31 distinguishes a real fd.
// ungetc pushes Z without modifying the file; rewind cancels another pushed
// Z, exposing A again. Seeking -1 from EOF reaches the final newline.
// EOF is detected by the following failed read, not merely reaching its offset.
//! lrm 9.5.5
//! lrm 9.5.5:2
//! inherited IEEE 1364-2005 17.2.1 17.2.4.1 17.2.5 17.2.8
//! data audit_file_ab.txt
module audit_file_read_position;
  reg [31:0] fd;
  integer c, result;
  initial begin
    fd = $fopen("audit_file_ab.txt", "r");
    $display("fd_valid=%0d", fd != 0 && fd[31] == 1);
    c = $fgetc(fd);
    $display("first=%0d position=%0d", c, $ftell(fd));
    result = $ungetc(90, fd);
    c = $fgetc(fd);
    $display("push=%0d character=%0d", result, c);
    result = $ungetc(90, fd);
    result = $rewind(fd);
    c = $fgetc(fd);
    $display("rewind=%0d character=%0d", result, c);
    result = $fseek(fd, -1, 2);
    c = $fgetc(fd);
    $display("seek=%0d last=%0d", result, c);
    c = $fgetc(fd);
    $display("eof_char=%0d detected=%0d", c, $feof(fd) != 0);
    $fclose(fd);
    $finish(0);
  end
endmodule
