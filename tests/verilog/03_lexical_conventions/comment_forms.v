// IEEE 1364-2005 §3.3, p. 8: "The Verilog HDL has two forms to introduce
// comments. A one-line comment shall start with the two characters // and end
// with a newline. A block comment shall start with /* and end with */. Block
// comments shall not be nested. The one-line comment token // shall not have
// any special meaning in a block comment."
//
// a = 1, then:
//   a one-line comment holding /* opens no block; it ends at the newline, so
//     the next line's a = a + 2 runs -> 3
//   a block comment holding // hides nothing after its */ on the same line:
//     a = a + /* ... // ... */ 4 -> 7
//   a block comment across lines, then a = a + 8 after its */ -> 15
//   not nested: in /* outer /* inner */ the first */ ends the comment, so
//     the a = a + 16 after it runs -> 31
//   a commented-out statement on its own line does not run (a = 0 skipped)
// Printed: "31".
//! inherited IEEE 1364-2005 3.3
module b_3_3_comment_forms;
  reg [7:0] a;
  initial begin
    a = 1; // one-line comment with /* inside
    a = a + 2;
    a = a + /* block with // inside */ 4;
    /* a block comment
       spanning lines */ a = a + 8;
    /* outer /* inner */ a = a + 16;
    // a = 0;
    $display("%0d", a);
    $finish(0);
  end
endmodule
