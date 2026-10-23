// IEEE 1364-2005 §13.4.4, p. 206: "In the case where the config includes a
// design statement, then the specified cell shall be the top-level module".
// The clause speaks of "the config"; with several, §13.3.2 reaches a second
// config only through a `use ... :config` clause. VerA takes the config no
// other config's use clause names, as §12.1.1 takes an uninstantiated module
// as a top, and refuses rather than pick by file order when there are two
// such (Vague_Decisions VD-083).
//
// cfg_a and cfg_b both name a design and neither names the other, so neither
// is the design's. Legal neighbour: hierarchical_config.v, where cfg
// names sub and only cfg is unreferenced.
//! inherited IEEE 1364-2005 13.4.4
//! reject E0243
//! reject are both unreferenced
//! neighbour hierarchical_config.v
config cfg_a;
  design work.top;
endconfig
config cfg_b;
  design work.top;
endconfig
module top;
  initial $display("top");
endmodule
