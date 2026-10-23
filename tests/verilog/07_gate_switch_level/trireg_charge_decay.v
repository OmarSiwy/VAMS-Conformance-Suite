// Verilog-AMS LRM 2.4 annex A.2.1.3 `net_declaration`, the trireg alternative:
//   "| trireg [ discipline_identifier ] [ charge_strength ] [ signed ]
//        [ delay3 ] list_of_net_identifiers ;"
// annex A.2.2.2:
//   "charge_strength ::= ( small ) | ( medium ) | ( large )"
// annex A.2.2.3:
//   "delay3 ::= # delay_value
//             | # ( mintypmax_expression [ , mintypmax_expression
//                 [ , mintypmax_expression ] ] )"
// §1.1 makes the meaning IEEE Std 1364 Verilog's: a trireg holds the value it
// was last driven to when all of its drivers go to z (the capacitive state),
// and the THIRD delay of its `delay3` is the charge decay time — the interval
// after which the stored charge is gone and the net becomes x.
//
// This fixture separates retention from decay by SAMPLING AROUND the decay
// instant. Current execution results are recorded in the primitive audit;
// the source-derived expectation does not depend on an implementation snapshot.
//
//! lrm annex A.2.1.3
//! lrm annex A.2.2.2
//! lrm annex A.2.2.3
//! lrm 1.1
//! timescale 1ns/1ns
//! inherited IEEE 1364-2005 4.6.3 7.14.2 7.14.2.1 7.14.2.2
//
// HAND DERIVATION — `trireg (medium) #(0, 0, 50) c;` with a single driver.
// Rise and fall delays are 0 so no net delay (that is D06) shifts any sample.
//   t=0    d=1     -> c driven to 1
//   t=10   display                                              -> "driven 1"
//          d=z     -> capacitive state begins at t=10;
//                     the charge decay is due at 10 + 50 = 60
//   t=49   11 ns before the decay                               -> 1
//   t=59   1 ns before the decay                                -> 1
//   t=61   1 ns after  the decay                                -> x
//          d=0     -> driven again; the stored value is replaced and the
//                     decay countdown is discarded
//   t=62   display                                              -> "redriven 0"
//          d=z     -> capacitive state begins again at t=62, due at 112
//   t=72   40 ns before the new decay                           -> 0
//   t=117  5 ns after it                                        -> x
//
// t=59/t=61 bracket the specified t=60 decay; they do not prove its exact
// instant or assert ordering WITHIN t=60. The second half checks the countdown
// restarts, rather than being armed once per net.
//
// With the strengths and delay accepted but no decay, every line after
// "driven 1" would instead read the stored
// value: 1, 1, 1, 0, 0, 0.

`timescale 1ns/1ns
module d03_trireg_charge_decay;
  reg d;
  trireg (medium) #(0, 0, 50) c;

  assign c = d;

  initial begin
    d = 1'b1;
    #10 $display("driven %b", c);
    d = 1'bz;
    #39 $display("t49 %b", c);
    #10 $display("t59 %b", c);
    #2 $display("t61 %b", c);
    d = 1'b0;
    #1 $display("redriven %b", c);
    d = 1'bz;
    #10 $display("t72 %b", c);
    #45 $display("t117 %b", c);
    $finish(0);
  end
endmodule
