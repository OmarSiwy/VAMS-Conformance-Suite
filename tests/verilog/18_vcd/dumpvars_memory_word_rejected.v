//! inherited IEEE 1364-2005 18.1.2
//! reject $dumpvars names a module instance or a variable
// $dumpvars takes module or variable identifiers; a memory word array[0] is
// neither (1364 VCD dumps no arrays) (array_word_check).
module triage_dumpvars_memory_word_rejected;
  reg [7:0] array [1:0];

  initial begin
    $dumpfile("triage_dumpvars_word.vcd");
    $dumpvars(0, array[0]);
  end
endmodule
