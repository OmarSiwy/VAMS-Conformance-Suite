// IEEE/AMS A.6.7 require at least one case_item. A default with null body
// is legal and observed by grammar_nullable_statement.v; zero items is not.
//! inherited IEEE 1364-2005 A.6.7
//! reject E1100
//! reject a case statement requires at least one item
//! neighbour grammar_nullable_statement.v
module audit_grammar_empty_case_rejected;
  initial begin
    case (1) endcase
    $finish(0);
  end
endmodule
