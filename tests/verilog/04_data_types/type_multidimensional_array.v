// IEEE1364-2005 §4.9: every unpacked dimension has an explicit index;
// bounds may be negative/ascending/descending. Each element remains4bits,
// irrespective of dimension lengths. Variable index selects independent words.
//! inherited IEEE 1364-2005 4.9 4.9.2
module audit_type_multidimensional_array;
  reg [3:0] memory [-1:0][2:1];
  integer row, column;
  initial begin
    memory[-1][2]=3; memory[-1][1]=5;
    memory[0][2]=9; memory[0][1]=14;
    row=-1; column=1;
    $display("dynamic=%b other=%b", memory[row][column], memory[0][2]);
    memory[row][column]=17;
    $display("truncated=%b untouched=%b", memory[-1][1], memory[0][1]);
    $finish(0);
  end
endmodule
