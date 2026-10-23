//! inherited IEEE 1364-2005 19.3.1
//! reject undefined macro: `protect
// `protect is not one of clause 19's directives, so it is a use of an
// undefined macro (pr478).
`protect
module triage_protect_is_undefined_macro_rejected;
endmodule
