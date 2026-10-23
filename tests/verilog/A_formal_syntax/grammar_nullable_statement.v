// IEEE/AMS A.6.3/.6/.7: begin/end may contain zero statements; case needs
// an item, but a default item can have a null statement with optional colon.
// Both conditional arms may be null; these constructs leave the value3 intact.
//! inherited IEEE 1364-2005 A.6.3 A.6.6 A.6.7
//! expect stdout grammar_nullable_statement.expected.txt
module audit_grammar_nullable_statement;
  integer value;
  initial begin
    value = 3;
    begin end
    if (1) ; else ;
    case (1) default ; endcase
    case (1) default: ; endcase
    $display("%0d", value);
    $finish(0);
  end
endmodule
