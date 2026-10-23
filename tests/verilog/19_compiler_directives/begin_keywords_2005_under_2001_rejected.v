//@ std 1364-2001
//! inherited IEEE 1364-2005 19.11
//! reject unsupported keyword set: `1364-2005`
// §19.11 is new in 1364-2005; a 1364-2001 tool has no 2005 keyword set, so
// selecting begin_keywords "1364-2005" is refused (pr1077 is listed -g2).
`begin_keywords "1364-2005"
module triage_begin_keywords_2005_under_2001_rejected;
endmodule
`end_keywords
