// IEEE 1364-2005 §8.1, p. 105: "They can appear anywhere in the source text,
// either before or after they are instantiated inside a module. They shall
// not appear between the keywords module and endmodule."
//
// The primitive inv is defined between module and endmodule. Legal
// neighbour: definition_placement.v defines the same table outside
// every module, before and after its use.
//! inherited IEEE 1364-2005 8.1
//! reject E0205
//! reject found primitive
//! neighbour definition_placement.v
module b_8_1_definition_inside_module_rejected;
  primitive inv(q, a);
    output q;
    input a;
    table
      0 : 1;
      1 : 0;
    endtable
  endprimitive
  initial $finish(0);
endmodule
