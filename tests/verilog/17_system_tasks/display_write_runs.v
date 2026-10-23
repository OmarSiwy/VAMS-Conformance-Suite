// IEEE1364-2005 17.1.1/.2: write adds no newline, empty write no bytes;
// arguments retain order, null produces one space, following format strings
// consume following expressions. Radix write variants use declared widths.
//! inherited IEEE 1364-2005 17.1.1 17.1.1.2 17.1.1.3
//! expect stdout display_write_runs.expected.txt
module audit_display_write_runs;
  initial begin
    $write;
    $write("A%0d", 4'd3, "B%h", 8'h0a, , "C");
    $write;
    $display;
    $writeh(8'h0a);
    $writeb(4'b0101);
    $writeo(6'o07);
    $display;
    $finish(0);
  end
endmodule
