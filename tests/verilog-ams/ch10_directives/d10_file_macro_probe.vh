// Included by file_macro_is_the_opened_path.va INSIDE its analog block,
// so the `__FILE__ below expands while this file is the current input file.
`include "disciplines.vams"
    file_is_short_name = (`__FILE__ == "d10_file_macro_probe.vh");
    included_path = `__FILE__;
