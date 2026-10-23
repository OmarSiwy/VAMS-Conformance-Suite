// IEEE 1364-2005 §§17.7.1–17.7.2, printed309–310/physical339–340.
// $time returns64bits in module units; $stime is unsigned32bits and retains
// the low32bits when time is larger. The scheduler must jump between events;
// this test does not require billions of iterations or an impractical run.
//
// Independent boundary derivation, unit=precision=1ns:
// 2^31=2147483648: stime remains positive, not signed-negative.
// 2^32-1=4294967295: both values retain all low32bits.
// 2^32=4294967296: time retains bit32, stime wraps to0.
// 2^32+3: time retains bit32 and lowbits3, stime is3.
// $time>>32=1 after the wrap distinguishes a32bit-return implementation;
// storing a small result in a64bit destination alone cannot prove this.
//! lrm 9.10
//! inherited IEEE 1364-2005 17.7.1,17.7.2
//! expect stdout time_stime_wrap.expected.txt
`timescale 1ns/1ns
module audit_time_stime_wrap;
  initial begin
    #(64'd2147483648);
    $display("half t=%0d s=%0d positive=%0d", $time, $stime, $stime > 0);
    #(64'd2147483647);
    $display("before t=%0d s=%0d", $time, $stime);
    #1;
    $display("wrap t=%0d s=%0d high=%0d", $time, $stime, $time >> 32);
    #3;
    $display("after t=%0d s=%0d high=%0d", $time, $stime, $time >> 32);
    $finish(0);
  end
endmodule
