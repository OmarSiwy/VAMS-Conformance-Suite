//! inherited IEEE 1364-2005 4.6.5
// A uwire forbids more than one driver on any bit, not more than one driver on
// the whole net: these two part-select drivers are legal (uwire2).
module triage_uwire_per_bit_drivers;
  uwire [31:0] foo;

  assign foo[15:0] = 'haaaa;
  assign foo[31:16] = 'h5555;

  initial #1 if (foo === 32'h5555aaaa) $display("PASSED"); else $display("FAILED %h", foo);
endmodule
