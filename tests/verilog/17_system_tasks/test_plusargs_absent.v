// IEEE 1364-2005 §17.10.1, printed 320 / physical PDF page 350:
// an unmatched query returns integer zero. This run supplies no plusargs.
// Use a literal query; the packed nonreal-variable query form remains separate.
// This does not test a present match, prefix matching or invocation ordering.
//! lrm 9.12
//! inherited IEEE 1364-2005 17.10.1
module audit_test_plusargs_absent;
    integer literal_result;
    initial begin
        literal_result = $test$plusargs("feature");
        $display("literal=%0d", literal_result);
        $finish(0); // §17.4.1: a bare $finish prints its time and location
    end
endmodule
