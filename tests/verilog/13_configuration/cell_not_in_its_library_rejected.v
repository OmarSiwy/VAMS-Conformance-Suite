// IEEE 1364-2005 §13.2.3, p. 202: "For each cell definition encountered
// during parsing/compiling, the name of the source file being parsed is
// compared to the file path specifications of the library declarations in
// all of the library map files being used. The cell is mapped into the library
// whose file path specification matches the source file name."
//
// The §13.5 libraries (ex13_5/). top is defined only in top.v, which maps to
// rtlLib, so gateLib holds no cell top and cfg's `design gateLib.top` binds
// nothing. Legal neighbour: cfg2_gate_first.v, `design rtlLib.top`.
//@ libmap ex13_5/lib.map
//@ files ex13_5/top.v ex13_5/adder.v ex13_5/adder.vg
//! inherited IEEE 1364-2005 13.2.3
//! reject E1100
//! reject library `gateLib` holds no cell `top`
//! neighbour cfg2_gate_first.v
config cfg;
  design gateLib.top;
endconfig
