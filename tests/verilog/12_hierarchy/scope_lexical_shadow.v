// IEEE 1364-2005 12.7, printed 195–197: a local declaration wins;
// unqualified variable lookup searches enclosing lexical scopes only up to
// the module boundary. The inner assignment must not change the outer value.
// Independent oracle: outer 11; inner initialized 23, then 24; outer still 11.
//! lrm 6.8
//! lrm 6.8:4
//! inherited IEEE 1364-2005 12.7
//! expect stdout scope_lexical_shadow.expected.txt
module audit_scope_lexical_shadow;
  integer value;
  initial begin
    value = 11;
    begin : inner
      integer value;
      value = 23;
      value = value + 1;
      $display("inner=%0d", value);
    end
    $display("outer=%0d", value);
    $finish(0);
  end
endmodule
