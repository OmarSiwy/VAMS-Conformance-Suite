// IEEE 1364-2005 §3.8, p. 16: "An attribute_instance can appear in the
// Verilog description as a prefix attached to a declaration, a module item,
// a statement, or a port connection." A.6.7 `case_item ::= expression
// { , expression } : statement_or_null | default [ : ] statement_or_null`,
// and A.6.4 `statement ::= { attribute_instance } ...`: an instance may
// prefix the statement of every case, casez and casex item.
//
// Legal neighbour of case_attribute_before_endcase_rejected.v: the
// same (* k *) now prefixes each item's statement. §3.8 standardizes no
// attribute, so each statement runs as if it were absent. With s = 2'b10:
//   case: 2'b01 differs, 2'b10 equals s (§9.5)             -> a = 2
//   casez: 2'b?1 needs bit 0 = 1 and s has 0; 2'b1? has bit 1 = 1 and a
//          don't-care bit 0 (§9.5.1)                       -> b = 20
//   casex: 2'bx0 needs bit 0 = 0, which s has (§9.5.1)     -> c = 100
// Printed: "a 2 b 20 c 100".
//! inherited IEEE 1364-2005 3.8.2
module b_3_8_2_case_item_statement_attribute;
  reg [1:0] s;
  integer a, b, c;
  initial begin
    s = 2'b10;
    case (s)
      2'b01: (* k *) a = 1;
      2'b10: (* k *) a = 2;
      default: (* k *) a = 3;
    endcase
    casez (s)
      2'b?1: (* k *) b = 10;
      2'b1?: (* k *) b = 20;
      default: (* k *) b = 30;
    endcase
    casex (s)
      2'bx0: (* k *) c = 100;
      default: (* k *) c = 300;
    endcase
    $display("a %0d b %0d c %0d", a, b, c);
  end
endmodule
