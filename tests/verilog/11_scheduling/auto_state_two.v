// IEEE1364-2005 §4.2.2: a reg starts x; §9.2.2: a nonblocking update lands
// after every blocking one of its time step. Every variable here is known by
// the end of time 0 except t and sum, and each read of those follows a
// write in the same activation, so `vera --emit-exe`'s default
// `--state=auto` runs the rest 2-state (`// native-state: 2`); its
// transcript is the 4-state one either way.
// clk rises x->1 at time 0, a posedge, so no negedge fires before #1. Falls
// at ticks 1, 3, 5, 7: pass k (count = k) sets mem[k] <= mem[k] + k, so mem
// = {0, 1+1, 2+2, 3+3} = {0, 2, 4, 6}; count = 4, twice = 8, sum = 12.
//! inherited IEEE 1364-2005 4.2.2 9.2.2
// native-state: 2
module auto_state_two;
  reg clk;
  reg [7:0] count, t, sum;
  reg [7:0] mem [0:3];
  integer i;
  wire [7:0] twice = count + count;
  always @(negedge clk) begin
    t = mem[count[1:0]];
    mem[count[1:0]] <= t + count;
    count <= count + 1;
  end
  initial begin
    count = 0;
    for (i = 0; i < 4; i = i + 1) mem[i] = i;
    clk = 1;
    repeat (8) #1 clk = ~clk;
    #1 sum = 0;
    for (i = 0; i < 4; i = i + 1) sum = sum + mem[i];
    $display("count=%0d twice=%0d sum=%0d", count, twice, sum);
    $finish(0);
  end
endmodule
