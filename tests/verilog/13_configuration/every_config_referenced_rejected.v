// IEEE 1364-2005 §13.4.4, p. 206: "In the case where the config includes a
// design statement, then the specified cell shall be the top-level module".
// VerA takes the config no other config's `use` clause names (§13.3.2
// reaches a second config only through one), and refuses when there is none
// (Vague_Decisions VD-083).
//
// cfg_a binds top.u to cfg_b and cfg_b binds top.u to cfg_a: each is named by
// the other's use clause, so no config is unreferenced. Legal neighbour:
// hierarchical_config.v, the same shape with one root config.
//! inherited IEEE 1364-2005 13.4.4
//! reject E0243
//! reject every configuration is named by another's `use` clause
//! neighbour hierarchical_config.v
config cfg_a;
  design work.top;
  instance top.u use work.cfg_b:config;
endconfig
config cfg_b;
  design work.top;
  instance top.u use work.cfg_a:config;
endconfig
module leaf;
endmodule
module top;
  leaf u();
endmodule
