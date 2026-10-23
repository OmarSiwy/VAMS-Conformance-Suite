// IEEE 1364-2005 §17.2.4.4 loads a packed reg or a memory; §4.9.3 defines
// a memory as a one-dimensional array of reg elements.
// This target has two unpacked dimensions. The descending one-dimensional
// memory in native_binary_file_targets.v is the legal running neighbor.
//! inherited IEEE 1364-2005 17.2.4.4
//! reject E1100
//! reject $fread loads a one-dimensional memory
//! neighbour native_binary_file_targets.v
module b_17_2_4_4_fread_multidim_rejected;
  integer fd, code;
  reg [7:0] mem [0:1][0:1];
  initial code = $fread(mem, fd);
endmodule
