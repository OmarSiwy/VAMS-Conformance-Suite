// VAMS §9.22, third paragraph: "The driver access functions described here
// only access drivers found in ordinary modules and not to those found in
// connect modules. Driver access functions can only be called from connect
// modules."
//
// `driver_count_connectmodule_rejected.va` pins the fence for an analog
// block. This is the DIGITAL context, a plain `.v` module calling
// `$driver_count` from an `initial` block: still not a connect module, so
// the call has no result to print and the design is refused.
//! lrm 9.22
//! lrm 9.22:1000
//! reject E0818
//! reject can only be called from connect modules
module driver_count_in_an_ordinary_module_rejected;
  wire w;
  assign w = 1'b1;
  initial $display("n=%0d", $driver_count(w));
endmodule
