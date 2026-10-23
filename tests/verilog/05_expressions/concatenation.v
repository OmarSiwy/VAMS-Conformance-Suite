// IEEE1364-2005 §§5.1.14,5.5: explicit expected bits, no generated oracle.
//! inherited IEEE 1364-2005 5.1.14 5.5
module concatenation;
  reg [7:0] a;
  reg [128:0] wide;
  initial begin
    a=$unsigned(-4); $display("unsigned-integer %b",a);
    a=$unsigned(-4'sd4); $display("unsigned-narrow %b",a);
    a=$signed(4'b1100); $display("signed-extension %b",a);
    a=$signed(4'hf+4'h1); $display("cast-self-width %b",a);
    a=$signed(4'hf)+8'd0; $display("cast-unsigned-parent %b",a);
    a=$unsigned(4'shf)+8'sd0; $display("unsigned-cast-parent %b",a);
    a={$signed(4'b1000),4'b0011}; $display("concat-unsigned %b",a);
    a={4'b1111+4'b0001,4'h2}; $display("operand-self-width %b",a);
    a={4'b10xz,4'bz01x}; $display("concat-four-state %b",a);
    a={2{2'b10,2'bxz}}; $display("replicate-four-state %b",a);
    a={1'b1,{3{1'b0,1'b1}}}; $display("nested-replication %b",a);
    a={{0{$signed(4'b1111)}},4'b1010}; $display("zero-member %b",a);
    a={(1+2){2'bxz}}; $display("constant-expression-count %b",a);
    a={129'd2{4'b1010}}; $display("wide-constant-count %b",a);
    a={{2'b10}{4'h5}}; $display("concatenated-count %b",a);
    a={{1{{0{1'b1}},1'b0}},1'b1}; $display("nested-zero-member %b",a);
    a={(1==1),(|1),(1&&0)}; $display("self-determined-boundaries %b",a);
    a={4'b1<<1}; $display("self-determined-count %b",a);
    a={$unsigned(1)}; $display("cast-boundary %b",a);
    wide={64'hfedcba9876543210,65'b1x0z}; $display("wide-concat %b",wide);
    wide={43{3'b1xz}}; $display("wide-replication %b",wide);
    wide=$signed(65'bz); $display("wide-signed-z %b",wide);
    $finish(0);
  end
endmodule
