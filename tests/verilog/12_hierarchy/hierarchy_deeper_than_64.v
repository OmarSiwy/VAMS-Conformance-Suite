// IEEE 1364-2005 §12.1.1 builds a finite hierarchy and bounds nothing about
// its depth. VerA refused one deeper than 64 levels (E1100) until 2026-10
// (#29); it now elaborates as deep as the stack reserved for it allows.
//
// HAND DERIVATION. m0 instantiates m1 and so on to m66: 66 levels below the
// top, past the old 64. Only m66 has a process, and it prints its own
// hierarchical name (§17.1.1.6 %m): m0 then 66 instance names u.
//! inherited IEEE 1364-2005 12.1.1
//! expect stdout hierarchy_deeper_than_64.expected.txt
module m0; m1 u(); endmodule
module m1; m2 u(); endmodule
module m2; m3 u(); endmodule
module m3; m4 u(); endmodule
module m4; m5 u(); endmodule
module m5; m6 u(); endmodule
module m6; m7 u(); endmodule
module m7; m8 u(); endmodule
module m8; m9 u(); endmodule
module m9; m10 u(); endmodule
module m10; m11 u(); endmodule
module m11; m12 u(); endmodule
module m12; m13 u(); endmodule
module m13; m14 u(); endmodule
module m14; m15 u(); endmodule
module m15; m16 u(); endmodule
module m16; m17 u(); endmodule
module m17; m18 u(); endmodule
module m18; m19 u(); endmodule
module m19; m20 u(); endmodule
module m20; m21 u(); endmodule
module m21; m22 u(); endmodule
module m22; m23 u(); endmodule
module m23; m24 u(); endmodule
module m24; m25 u(); endmodule
module m25; m26 u(); endmodule
module m26; m27 u(); endmodule
module m27; m28 u(); endmodule
module m28; m29 u(); endmodule
module m29; m30 u(); endmodule
module m30; m31 u(); endmodule
module m31; m32 u(); endmodule
module m32; m33 u(); endmodule
module m33; m34 u(); endmodule
module m34; m35 u(); endmodule
module m35; m36 u(); endmodule
module m36; m37 u(); endmodule
module m37; m38 u(); endmodule
module m38; m39 u(); endmodule
module m39; m40 u(); endmodule
module m40; m41 u(); endmodule
module m41; m42 u(); endmodule
module m42; m43 u(); endmodule
module m43; m44 u(); endmodule
module m44; m45 u(); endmodule
module m45; m46 u(); endmodule
module m46; m47 u(); endmodule
module m47; m48 u(); endmodule
module m48; m49 u(); endmodule
module m49; m50 u(); endmodule
module m50; m51 u(); endmodule
module m51; m52 u(); endmodule
module m52; m53 u(); endmodule
module m53; m54 u(); endmodule
module m54; m55 u(); endmodule
module m55; m56 u(); endmodule
module m56; m57 u(); endmodule
module m57; m58 u(); endmodule
module m58; m59 u(); endmodule
module m59; m60 u(); endmodule
module m60; m61 u(); endmodule
module m61; m62 u(); endmodule
module m62; m63 u(); endmodule
module m63; m64 u(); endmodule
module m64; m65 u(); endmodule
module m65; m66 u(); endmodule
module m66; initial $display("%m"); endmodule
