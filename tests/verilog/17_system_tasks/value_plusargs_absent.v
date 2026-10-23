// IEEE 1364-2005 §17.10.2, printed 321 / physical PDF page 351:
// an unmatched query returns zero without changing the destination and without
// generating a warning. No plusargs are supplied. Sentinels 37 and a5 must
// survive, distinguishing no-match from a fabricated zero writeback.
// Literal format strings are legal. Packed nonreal query forms, present matches,
// first-match ordering and conversions require explicit invocation arguments.
//! lrm 9.12
//! inherited IEEE 1364-2005 17.10.2
module audit_value_plusargs_absent;
    reg [7:0] packed_value;
    integer value, literal_result, packed_result;
    initial begin
        value = 37;
        packed_value = 8'ha5;
        literal_result = $value$plusargs("gain=%d", value);
        packed_result = $value$plusargs("word=%h", packed_value);
        $display("literal=%0d value=%0d packed=%0d word=%h",
                 literal_result, value, packed_result, packed_value);
        $finish(0); // §17.4.1: a bare $finish prints its time and location
    end
endmodule
