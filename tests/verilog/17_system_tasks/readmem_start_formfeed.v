// IEEE 1364-2005 17.2.9, printed296: start-only loading proceeds upward
// to the highest address regardless of declared direction; @ does not reverse
// that direction. Formfeed (byte0c) is a whitespace separator, not data.
// Each memory starts aa; indices2,3 receive11,22. The addressed binary file
// writes index3 first, then @2 restarts upward and replaces both indices2,3.
//! inherited IEEE 1364-2005 17.2.9
module audit_readmem_start_formfeed;
  reg [7:0] descending[3:0];
  reg [7:0] ascending[0:3];
  integer i;
  initial begin
    for(i=0;i<4;i=i+1) begin descending[i]=8'haa; ascending[i]=8'haa; end
    $readmemh("audit_readmem_formfeed.hex",descending,2);
    $readmemb("audit_readmem_formfeed.bin",ascending,2);
    $display("descending=%h,%h,%h,%h",descending[0],descending[1],descending[2],descending[3]);
    $display("ascending=%h,%h,%h,%h",ascending[0],ascending[1],ascending[2],ascending[3]);
    $readmemb("audit_readmem_formfeed_address.bin",ascending,2);
    $display("relocated=%h,%h,%h,%h",ascending[0],ascending[1],ascending[2],ascending[3]);
  end
endmodule
