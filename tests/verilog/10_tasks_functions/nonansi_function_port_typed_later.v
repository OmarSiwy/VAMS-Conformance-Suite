//! inherited IEEE 1364-2005 10.4.1
// A non-ANSI function input may be given its type by a following declaration
// (function7's clog2).
module triage_nonansi_function_port_typed_later;
  localparam mxbit = 15;

  function integer clog2;
    input value;
    integer value;
    for (clog2 = 0; value > 0; clog2 = clog2 + 1) value = value >> 1;
  endfunction

  localparam cntrw = clog2(mxbit);

  initial begin
    if (cntrw === 4 && clog2(7) === 3)
      $display("PASSED");
    else
      $display("FAILED %0d", cntrw);
  end
endmodule
