// AMS §2.6.2's digital delay restriction also applies to a UDP instance's
// delay2. Legal neighbour: digital_delay_primitive_notation.v runs a UDP
// with decimal rise/fall delays and observes the update on its stated tick.
//! lrm 2.6.2
//! lrm 2.6.2:3
//! reject E0247
//! neighbour digital_delay_primitive_notation.v
primitive scaled_delay_udp(q, a);
  output q;
  input a;
  table
    0 : 0;
    1 : 1;
  endtable
endprimitive
module scaled_delay_udp_rejected;
  wire q;
  scaled_delay_udp #(1, 2u) g(q, 1'b0);
endmodule
