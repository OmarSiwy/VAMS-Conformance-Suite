// IEEE 1364-2005 §3.3, p. 8: "A block comment shall start with /* and end
// with */. Block comments shall not be nested."
//
// In /* a /* b */ c */ the first */ ends the comment, so `c */` is source
// text: an identifier followed by `*` is not a statement. Legal neighbour:
// comment_forms.v, whose /* outer /* inner */ is followed by a
// statement.
//! inherited IEEE 1364-2005 3.3
//! reject E0214
//! reject found `*`
//! neighbour comment_forms.v
module b_3_3_nested_block_comment_rejected;
  reg a;
  initial begin
    /* a /* b */ c */
    a = 1;
    $display("%b", a);
  end
endmodule
