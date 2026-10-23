// IEEE1364-2005 §4.6.5: more than one driver on any uwire bit is an error,
// even when the two drivers always agree. This must not be ordinary resolution.
//! inherited IEEE 1364-2005 4.6.5
//! reject a uwire net accepts a single driver
module audit_type_uwire_multiple_drivers_rejected;
  uwire one;
  assign one=1'b1;
  assign one=1'b1;
endmodule
