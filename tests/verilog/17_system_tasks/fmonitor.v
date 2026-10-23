//! inherited IEEE 1364-2005 17.2.2
// $fmonitor writes its line whenever a monitored value changes, including
// once when the task executes (fmonitor1).
module triage_fmonitor;
  integer fd;
  integer a;
  reg [8*32:1] line;

  initial begin
    fd = $fopen("triage_fmonitor.log", "w");
    a = 0;
    $fmonitor(fd, "m %0d", a);
    #1 a = 1;
    #1 a = 2;
    #1;
    $fclose(fd);

    fd = $fopen("triage_fmonitor.log", "r");
    while ($fgets(line, fd)) $write("%0s", line);
    $fclose(fd);
    $display("PASSED");
  end
endmodule
