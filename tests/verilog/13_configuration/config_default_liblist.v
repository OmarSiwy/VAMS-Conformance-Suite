// IEEE1364-2005 §13.3.1.2: a `default` clause pairs with `liblist`. The legal
// twin of config_default_use_rejected.v, whose `default` pairs with `use`.
// Declaration acceptance only: the configuration binds the one module there is.
//! inherited IEEE 1364-2005 13.3.1.2
config config_legal;
  design config_host;
  default liblist work;
endconfig
module config_host;
  initial begin $display("accepted"); $finish(0); end
endmodule
