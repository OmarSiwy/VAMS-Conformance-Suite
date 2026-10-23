//! inherited IEEE 1364-2005 A.2.1.3 9.7.3
// An event_identifier may carry dimensions, so event arrays are legal
// (event_array).
module triage_event_array;
  event ev [0:1];

  initial fork
    begin
      #1 -> ev[0];
    end
    begin
      @(ev[0]) $display("PASSED");
    end
  join
endmodule
