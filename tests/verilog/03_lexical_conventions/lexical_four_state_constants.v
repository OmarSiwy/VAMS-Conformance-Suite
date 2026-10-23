// LRM 2.6.1: x/z digits fill 4 bits in hex, 3 in octal, 1 in binary;
// short values pad with their leading x/z or with zero; excess bits truncate
// from the left. ? is an alternate z, case-insensitively. Unsized x/z extends
// to the expression width, including above the mandatory 32-bit minimum.
//
// The transcript is derived as bit groups, not captured from VerA:
// 5'bx -> xxxxx; 6'oz -> zzzzzz; 8'hx1 -> xxxx0001;
// 8'h?2 -> zzzz0010; 5'b10xZ? -> 10xzz; 4'b10xz01 -> xz01.
// Unsized context fill is isolated in lexical_unsized_context_fill.v so its
// missing implementation cannot prevent these sized-literal checks from running.
// A signed four-bit 1111 is -1, extending to fff; unsigned 1111 extends to 00f.
//
// AMS digital behavior. Annex C.3 excludes these four-state semantics from
// the analog-only profile; a Verilog-A rejection is not AMS implementation.
//! lrm 2.6.1
//! lrm 2.6.1:11
//! lrm 2.6.1:14
//! lrm 2.6.1:15
//! lrm 2.6.1:17
//! lrm 2.6.1:18
//! inherited IEEE 1364-2005 3.5.1 5.5.3
module lexical_four_state_constants;
    reg [11:0] extended;
    initial begin
        $display("binary-x %b", 5'bx);
        $display("octal-z %b", 6'oz);
        $display("hex-x %b", 8'hx1);
        $display("hex-question %b", 8'h?2);
        $display("mixed-case %b", 5'b10xZ?);
        $display("truncate-left %b", 4'b10xz01);
        extended = 4'shf;
        $display("signed-extend %h", extended);
        extended = 4'hf;
        $display("unsigned-extend %h", extended);
        $finish(0);
    end
endmodule
