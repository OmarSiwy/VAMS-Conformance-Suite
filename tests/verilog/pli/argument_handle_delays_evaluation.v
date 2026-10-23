// IEEE26.6.19(e): an unread PLI function-call argument never executes.
// The plugin obtains both handles but reads bump() only on the second call.
// Therefore calls is first 0, then 1; eager argument evaluation gives 1,2.
// Required-positive HOST application, not a standalone digital fixture.
module top;
  integer calls;
  function integer bump;
    input integer ignored;
    begin
      calls = calls + 1;
      bump = calls;
    end
  endfunction
  initial begin
    calls = 0;
    $audit_lazy_arguments(0, bump(0));
    $display("unread=%0d", calls);
    $audit_lazy_arguments(1, bump(0));
    $display("read=%0d", calls);
    $finish(0);
  end
endmodule
