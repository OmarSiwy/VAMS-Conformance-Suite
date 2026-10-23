//! inherited IEEE 1364-2005 17.2.9
//! reject the memory file name is a string literal
// Syntax 17-7 gives $readmem's file name as a quoted string and has no
// variable form; a string parameter is an integral expression, not a literal
// (pr690).
module triage_readmem_parameter_file_name_rejected;
  parameter MemFile = "triage_readmem.dat";
  reg [7:0] mem [0:1];

  initial $readmemb(MemFile, mem, 0);
endmodule
