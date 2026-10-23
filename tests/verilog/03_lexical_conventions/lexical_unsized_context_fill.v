// LRM 2.6.1: "Unsized unsigned constants where the high order bit is unknown
// (X or x) or three-state (Z or z) shall be extended to the size of the
// expression containing the constant."
// For 40-bit destinations, 'hx/'hz fill ten hex groups, 'h3x zero-pads
// to 000000003x, and 'hz3 z-pads to zzzzzzzzz3. A 32-bit-only or always-zero
// extension is distinguishable in the upper two hex digits.
//
// Known gap observed 2026-09-23: --run reports E1100, "unsized four-state
// literal context fill is not implemented". This is legal AMS source. Keep
// the behavioral oracle; changing this into a rejection would hide the gap.
// test-devices does not implement //! xfail; it must report this case as FAIL.
//! lrm 2.6.1
//! lrm 2.6.1:20
//! inherited IEEE 1364-2005 3.5.1
module lexical_unsized_context_fill;
    reg [39:0] wide;
    initial begin
        wide = 'hx;
        $display("unsized-x %h", wide);
        wide = 'hz;
        $display("unsized-z %h", wide);
        wide = 'h3x;
        $display("unsized-zero-pad %h", wide);
        wide = 'hz3;
        $display("unsized-z-pad %h", wide);
        $finish(0);
    end
endmodule
