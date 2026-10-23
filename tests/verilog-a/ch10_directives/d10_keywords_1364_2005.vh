// A header whose ONLY content is an OPENING `begin_keywords, for 02 and 03.
//
// §10.6: "The `begin_keywords directive affects all source code that follows
// the directive, EVEN ACROSS SOURCE CODE FILE BOUNDARIES, until the matching
// `end_keywords directive is encountered."
//
// The region is deliberately left OPEN here. A header that opened and closed
// its own region would test nothing — the boundary crossing is the point, and
// the matching `end_keywords lives in the file that included this one.
//
// Not a fixture: the harness walks `.va` only.
`begin_keywords "1364-2005"
