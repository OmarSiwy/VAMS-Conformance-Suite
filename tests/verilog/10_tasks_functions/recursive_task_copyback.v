// IEEE 1364-2005 §10.2.3: "All variables of an automatic task shall be
// replicated on each concurrent task invocation". §10.2.2 passes arguments
// by value and copies output/inout values to the enabling statement's
// variables on return. A recursive return therefore writes the caller's
// locals, including a bit-select using the caller's index.
//
// HAND DERIVATION. sum(0) gives total=0, wide=2**64+1, real=0.5, and
// increments count. Each returning level adds 3, 1, 0.25, and n respectively.
// sum(2), count initially 4: total=6, wide=2**64+3, real=1.0, count=8.
// sum(3), count initially 10: total=9, wide=2**64+4, real=1.25, count=17.
// sum(4), count initially 0: total=12, wide=2**64+5, real=1.5, count=11.
// In the last call the integral total converts to real 12.0 and the real
// output rounds to integer 2 (§4.8.2). mark(0) returns 1; mark(1) receives
// it in its own bits[1], then mark(2) receives it in its own bits[0], so
// selected=1. No data value makes copy-back invalid. The separate invalid
// lvalue neighbour is task_output_expression_rejected.v.
//! inherited IEEE 1364-2005 4.8.2 10.2.2 10.2.3
module b_10_2_recursive_task_copyback;
  integer result, tally, rounded;
  reg [69:0] wide;
  real real_result, converted;
  reg selected;
  task automatic sum(input integer n, output integer total,
      output [69:0] wide_total, output real real_total, inout integer count);
    integer below;
    reg [69:0] wide_below;
    real real_below;
    begin
      if (n == 0) begin
        total = 0;
        wide_total = 70'h10000000000000001;
        real_total = 0.5;
        count = count + 1;
      end else begin
        sum(n - 1, below, wide_below, real_below, count);
        total = below + 3;
        wide_total = wide_below + 1;
        real_total = real_below + 0.25;
        count = count + n;
      end
    end
  endtask
  task automatic mark(input integer n, output bit_result);
    reg [1:0] bits;
    integer i;
    begin
      if (n == 0) bit_result = 1;
      else begin
        bits = 0;
        i = n % 2;
        mark(n - 1, bits[i]);
        bit_result = bits[i];
      end
    end
  endtask
  initial begin
    tally = 4;
    sum(2, result, wide, real_result, tally);
    $display("sum2=%0d wide=%0d real=%0d count=%0d", result,
        wide === 70'h10000000000000003, real_result == 1.0, tally);
    tally = 10;
    sum(3, result, wide, real_result, tally);
    $display("sum3=%0d wide=%0d real=%0d count=%0d", result,
        wide === 70'h10000000000000004, real_result == 1.25, tally);
    tally = 0;
    sum(4, converted, wide, rounded, tally);
    $display("sum4=%0d wide=%0d rounded=%0d count=%0d", converted == 12.0,
        wide === 70'h10000000000000005, rounded, tally);
    mark(2, selected);
    $display("selected=%b", selected);
  end
endmodule
