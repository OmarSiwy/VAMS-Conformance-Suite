// IEEE1364-2005 §4.2.2: a reg nothing writes keeps its initial x, and
// reading it gives x. `never` is read at tick 1 and tick 2 with no write
// before either read, so no time step begins with the design free of a live
// x and the default `--state=auto` stays 4-state throughout
// (`// native-state: 4`). known: 9, then 9 + 1 = 10.
//! inherited IEEE 1364-2005 4.2.2
// native-state: 4
module auto_state_never_written;
  reg [3:0] never, known;
  initial begin
    known = 4'd9;
    #1 $display("never=%b known=%0d", never, known);
    #1 known = known + 1;
    $display("never=%b known=%0d", never, known);
  end
endmodule
