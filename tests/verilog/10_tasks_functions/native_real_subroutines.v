// IEEE 1364-2005 §10.4.1: the implicit function-name variable has the
// declared return type. §§10.2.3, 10.4.2 allocate a fresh automatic frame;
// §4.8 makes each real local, array element, and result initially zero.
// The static result retains 1.25; an unassigned automatic result is zero.
//
// rec(3) sums .25+1.25+2.25+3.25=7.0 and rec(1)=1.5. Each recursive
// caller must retain its own saved[1], and every activation's saved[0]
// starts at zero (bad stays zero). The task copies a real input/inout
// value into its frame and copies results back on return (§10.2.2).
// First, held=1.25-5=-3.75 and real output -2.5 rounds to integer -3
// (§4.8.2). Next, held=-3.75+5=1.25 and array output=2.5.
// Legal real/realtime results neighbor the existing illegal function
// output/NBA/timing fixtures in this directory; no new prohibition here.
//! inherited IEEE 1364-2005 4.8 4.8.2 10.2.2 10.2.3 10.4.1 10.4.2
// native-required
module native_real_subroutines;
  real a[0:2], answer;
  integer bad, rounded;
  function real retained(input integer set);
    if (set) retained = 1.25;
  endfunction
  function automatic realtime fresh(input integer set);
    if (set) fresh = 1.25;
  endfunction
  function automatic real rec(input integer n);
    real saved[1:0], child;
    begin
      if (saved[0] != 0.0 || saved[1] != 0.0 || child != 0.0) bad = bad + 1;
      saved[1] = n + 0.25;
      if (n == 0) rec = saved[1];
      else begin child = rec(n-1); rec = saved[1] + child; end
    end
  endfunction
  task automatic transfer(input realtime x, inout real held, output real out);
    real temp[0:1];
    begin
      if (temp[0] != 0.0 || temp[1] != 0.0 || out != 0.0) bad = bad + 1;
      temp[1] = x; held = held + temp[1]; out = temp[1] / 2.0;
    end
  endtask
  initial begin
    bad = 0;
    answer = retained(1); answer = retained(0);
    $display("static %.2f", answer);
    answer = fresh(1); answer = fresh(0);
    $display("fresh %.2f", answer);
    answer = rec(3); $display("recursive %.2f", answer);
    answer = rec(1); $display("again %.2f", answer);
    a[1] = 1.25; transfer(-5.0, a[1], rounded);
    $display("copy-int %.2f %0d", a[1], rounded);
    transfer(5.0, a[1], a[2]);
    $display("copy-real %.2f %.2f defaults=%0d", a[1], a[2], bad);
    $finish(0);
  end
endmodule
