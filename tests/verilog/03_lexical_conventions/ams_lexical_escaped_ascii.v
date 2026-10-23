// AMS2.8.1 permits every printable ASCII character33..126 inside an escaped
// name. Below one name contains the complete range once, in increasing order.
// The value is independently set/read; punctuation must remain inside the name.
//! lrm 2.8.1
//! expect stdout ams_lexical_escaped_ascii.expected.txt
//! inherited IEEE 1364-2005 3.7.1
module audit_ams_lexical_escaped_ascii;
integer \!"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~ ;
initial begin
  \!"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~ = 9;
  $display("%0d", \!"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~ );
end
endmodule
