// IEEE 1364-2005 §3.7, p. 14: "A simple identifier shall be any sequence of
// letters, digits, dollar signs ($), and underscore characters (_). The first
// character of a simple identifier shall not be a digit or $; it can be a
// letter or an underscore. Identifiers shall be case sensitive."
//
// The clause's six examples (shiftreg_a, busa_index, error_condition,
// merge_ab, _bus3, n$657) are each declared and given the values 1..6; the
// sum is 21. Case sensitive: v, V and v_V are three variables holding 7, 8
// and 9; none overwrote another.
// Printed: "21 7 8 9".
//! inherited IEEE 1364-2005 3.7
module b_3_7_identifier_examples;
  integer shiftreg_a, busa_index, error_condition, merge_ab, _bus3, n$657;
  integer v, V, v_V;
  initial begin
    shiftreg_a = 1; busa_index = 2; error_condition = 3;
    merge_ab = 4; _bus3 = 5; n$657 = 6;
    v = 7; V = 8; v_V = 9;
    $display("%0d %0d %0d %0d",
             shiftreg_a + busa_index + error_condition + merge_ab + _bus3 + n$657,
             v, V, v_V);
    $finish(0);
  end
endmodule
