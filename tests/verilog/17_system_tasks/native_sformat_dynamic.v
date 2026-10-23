// IEEE 1364-2005 §17.2.3, p. 290: the format "can be a reg variable whose
// content is interpreted as the format string", and "If not enough
// arguments are supplied for the format specifiers or too many are
// supplied, then the application shall issue a warning and continue
// execution." A native executable reads such a format when the task runs,
// so each argument meets its conversion only then.
//
//   fmt = "%s-%0d:%5.2f %% %c%m"; args "ab", 7, 1.5, 8'h41
//     %s "ab" -> ab; %0d 7 -> 7; %5.2f 1.5 -> " 1.50" (C's %5.2f, width 5);
//     %% -> %; %c 8'h41 -> A; %m (no argument) -> the module's name
//     -> [ab-7: 1.50 % Anative_sformat_dynamic]
//   fmt = "%h+%h"; one argument 4'hc: the second %h has none -> a warning,
//     and the text so far, "c+", is assigned -> [c+]
//   fmt = 0: no characters, so no conversion; the argument 5 is one too
//     many -> a warning and the empty text -> []
// %s prints a reg's characters with its leading zero bytes dropped
// (b_17_2_3_sformat_variable_format prints "[x=c3!]" the same way).
//! inherited IEEE 1364-2005 17.2.3
// native-required
module native_sformat_dynamic;
  reg [8*48:1] s, fmt;
  initial begin
    fmt = "%s-%0d:%5.2f %% %c%m";
    $sformat(s, fmt, "ab", 7, 1.5, 8'h41);
    $display("[%s]", s);
    fmt = "%h+%h";
    $sformat(s, fmt, 4'hc);
    $display("[%s]", s);
    fmt = 0;
    $sformat(s, fmt, 5);
    $display("[%s]", s);
    $finish(0);
  end
endmodule
