// IEEE 1364-2005 §19.8: "If there is no `timescale specified or it has been
// reset by a `resetall directive, the time unit and precision are
// simulator-specific." VerA's choice (specification/Vague_Decisions.md) is a unit of
// 1 s and a precision of 1 s. This pins that choice; a tool with another
// default conforms too.
//
// No module here has a `timescale, so §19.8's "error if some modules have a
// `timescale specified and others do not" does not arise.
//   $printtimescale (§17.3.1) prints the scope's unit and precision:
//     "Time scale of (b_19_8_no_timescale_is_1s_1s) is 1s / 1s".
//   #1.5 is rounded to the 1 s precision (§19.8), so the delay is 2 and
//     $realtime reads 2 at the $display: "t=2.0". A finer default precision
//     would read 1.5.
//! inherited IEEE 1364-2005 19.8
module b_19_8_no_timescale_is_1s_1s;
  initial begin
    $printtimescale;
    #1.5 $display("t=%0.1f", $realtime);
  end
endmodule
