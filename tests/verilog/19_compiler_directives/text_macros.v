// IEEE 1364-2005 §19.3.1, p. 350: "The compiler shall substitute the text of
// the macro for the string `text_macro_name and any actual arguments that
// follow it." ... "If more than one line is necessary to specify the text,
// the newline shall be preceded by a backslash (\)." p. 351: "If a one-line
// comment (that is, a comment specified with the characters //) is included
// in the text, then the comment shall not become part of the substituted
// text. The macro text can be blank, in which case the text macro is defined
// to be empty and no text is substituted when the macro is used." ... "White
// space shall be allowed between the text macro name and the left
// parenthesis." p. 352: "Redefinition of text macros is allowed; the latest
// definition of a particular text macro read by the compiler prevails when
// the macro name is encountered in the source text. The macro text can
// contain usages of other text macros. Such usages shall be substituted after
// the original macro is substituted, not when it is defined."
// §19, p. 349: "The scope of a compiler directive extends from the point
// where it is processed, across all files processed, to the point where
// another compiler directive supersedes it".
//
// The clause's examples:
//   reg [1:`wordsize] data with `wordsize 8: data = 9'h1A5 keeps the low 8
//     bits, 1010_0101.
//   `var_nand(2) g121 (q21, n10, n11) is `nand #2 g121 (...)`: n10 = n11 = 1
//     at time 0, so q21 = ~(1 & 1) = 0 from time 2; read at time 3 -> 0.
//     n10 = 0 at time 3 makes the nand 1, which the #2 delay puts on q21 at
//     time 5: still 0 at time 4, 1 at time 6. (No read falls before time 2,
//     where the gate has not yet driven q21.)
//   n = `max(p+q, r+s) with p = 1, q = 2, r = 5, s = -1: (3) > (4) is false,
//     so n = (r+s) = 4.
// `two_lines(k) is two statements across a backslash-newline: k = 3 -> 4 -> 8.
// `with_comment is 7 without its // comment, so `with_comment + 1 = 8 (if the
//   comment were kept, "+ 1" would be commented out and the $display would
//   not parse).
// `empty 5 is 5.
// `paren is defined with a space before its "(", so it has no formal
//   arguments (p. 351: "The left parenthesis shall follow the text macro name
//   immediately") and its text is "(2)": `paren * 3 = 6.
// `max (4, 9): white space before the actual list; (4) > (9) false -> 9.
// `outer is "(`inner + 1)", defined while `inner is 10. `inner is then
//   redefined to 20, and `outer is used afterwards: the nested usage is
//   substituted at use, so 21 (not 11). Redefined with no `undef between:
//   the latest definition prevails. The redefinition sits inside the initial
//   block, textually before the use: macros follow source text, not
//   execution, and §19.3.1 lets a `define appear inside a module.
//! inherited IEEE 1364-2005 19 19.3.1
`timescale 1ns/1ns
`define wordsize 8
`define var_nand(dly) nand #dly
`define max(a,b)((a) > (b) ? (a) : (b))
`define two_lines(x) x = x + 1; \
                     x = x * 2;
`define with_comment 7 // not part of the text
`define empty
`define paren (2)
`define inner 10
`define outer (`inner + 1)
module b_19_3_1_text_macros;
  reg [1:`wordsize] data;
  reg n10, n11;
  wire q21;
  integer n, p, q, r, s, k;
  `var_nand(2) g121 (q21, n10, n11);
  initial begin
    n10 = 1'b1;
    n11 = 1'b1;
    data = 9'h1A5;
    p = 1; q = 2; r = 5; s = -1;
    n = `max(p+q, r+s);
    k = 3;
    `two_lines(k)
    $display("%b %0d %0d %0d", data, n, k, `with_comment + 1);
    $display("%0d %0d %0d", `empty 5, `paren * 3, `max (4, 9));
    #3 $display("q21=%b", q21);
    n10 = 1'b0;
    #1 $display("q21=%b", q21);
    #2 $display("q21=%b", q21);
`define inner 20
    $display("%0d", `outer);
    $finish(0);
  end
endmodule
