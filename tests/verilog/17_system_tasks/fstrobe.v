//! inherited IEEE 1364-2005 17.2.2
// $fstrobe writes its line once, at the end of the current time step, with
// the values the arguments hold then: s 3 (fmonitor1/fmonitor2/pr2842621).
module triage_fstrobe;
  integer fd;
  integer value;
  reg [8*32:1] line;

  initial begin
    fd = $fopen("triage_fstrobe.log", "w");
    value = 0;
    $fstrobe(fd, "s %0d", value);
    value = 3;
    #1;
    $fclose(fd);

    fd = $fopen("triage_fstrobe.log", "r");
    while ($fgets(line, fd)) $write("%0s", line);
    $fclose(fd);
    $display("PASSED");
  end
endmodule
