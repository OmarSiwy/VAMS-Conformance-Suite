// IEEE 1364-2005 §26.6.19(e), paired with retained_arguments_evaluate_on_each_read.c.
// Calls occur at distinct times, so the retained handle is read after the
// child's process has run and after the named block's offset changed.
// No expression is evaluated by merely obtaining or retaining its handle.
module b26_lazy;
  integer calls;
  b26_lazy_leaf u();

  function integer bump;
    input integer amount;
    begin
      calls = calls + 1;
      bump = calls + amount;
    end
  endfunction

  function real rbump;
    input real x;
    begin
      calls = calls + 1;
      rbump = x + 0.5;
    end
  endfunction

  function [71:0] wide;
    input integer unused;
    begin
      calls = calls + 1;
      wide = 72'h12abcdef00112233xz;
    end
  endfunction

  initial begin : sample
    integer offset;
    calls = 0;
    offset = 10;
    $lazy_probe(0, bump(offset));
    offset = 20;
    #3;
    $lazy_probe(1, bump(0) + bump(0), rbump(1.5), wide(0), $lazy_inner(bump(0)));
    $display("root_calls=%0d", calls);
    #1 $finish(0);
  end
endmodule

module b26_lazy_leaf;
  integer calls;
  function integer bump;
    input integer unused;
    begin
      calls = calls + 1;
      bump = calls;
    end
  endfunction
  initial begin
    calls = 100;
    #1 $lazy_probe(2, bump(0));
  end
endmodule
