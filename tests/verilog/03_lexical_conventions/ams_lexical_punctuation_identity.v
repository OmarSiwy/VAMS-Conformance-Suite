// AMS2.8/2.8.1: punctuation remains part of escaped identifier identity.
// All names are distinct, even where deleting punctuation maps them to ab.
// Prefix/suffix ! . ~, leading digit/$/backslash, and comment-looking sequences
// remain name contents. Independent values catch consistently renamed aliases.
//! lrm 2.8.1
//! expect stdout ams_lexical_punctuation_identity.expected.txt
//! inherited IEEE 1364-2005 3.7.1
module audit_ams_lexical_punctuation_identity;
integer ab, \a.b , \a/b , \a+b , \.ab , \ab. , \!ab , \ab! , \~ab , \ab~ , \1ab , \$ab , \\ab , \a/*b , \a//b , \a*/b ;
initial begin
  ab = 1;
  \a.b = 2;
  \a/b = 3;
  \a+b = 4;
  \.ab = 5;
  \ab. = 6;
  \!ab = 7;
  \ab! = 8;
  \~ab = 9;
  \ab~ = 10;
  \1ab = 11;
  \$ab = 12;
  \\ab = 13;
  \a/*b = 14;
  \a//b = 15;
  \a*/b = 16;
  $display("%0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d", ab, \a.b , \a/b , \a+b , \.ab , \ab. , \!ab , \ab! , \~ab , \ab~ , \1ab , \$ab , \\ab , \a/*b , \a//b , \a*/b );
end
endmodule
