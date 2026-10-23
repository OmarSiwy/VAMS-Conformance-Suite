// IEEE 1364-2005 §18.3.2, pp. 339-340: "When the $dumpportsoff task is
// executed, a checkpoint is made in the file_pathname where each specified
// port is dumped with an X value. Port values are no longer dumped from that
// simulation time forward. If file_pathname is not specified, all dumping to
// files opened by $dumpports calls shall be suspended." "When the
// $dumpportson task is executed, all ports specified by the associated
// $dumpports call shall have their values dumped." ... "If file_pathname is
// not specified, dumping shall resume for all files specified by $dumpports
// calls, if dumping to those files was stopped." "If $dumpportson is executed
// while ports are already being dumped to file_pathname, the system task is
// ignored. If $dumpportsoff is executed while port dumping is already
// suspended for file_pathname, the system task is ignored."
// §18.3.3, p. 340: "The $dumpportsall system task creates a checkpoint in the
// VCD file that shows the value of all selected ports at that time in the
// simulation, regardless of whether the port values have changed since the
// last time step."
// §18.3.5, p. 341: "If the file_pathname is not specified, the VCD buffers
// shall be flushed for all files opened by calls to $dumpports."
// §18.3.6, p. 341: "The general information in the extended VCD file is
// presented as a series of sections surrounded by keywords."; §18.4.1,
// Syntax 18-27 (p. 343): `* simulation_keyword ::= $dumpports |
// $dumpportsoff | $dumpportson | $dumpportsall`.
// §18.3.7, pp. 341-342: "If a file_pathname is specified that does not match
// a file_pathname specified in a $dumpports call, the control task shall be
// ignored." "If no arguments are specified for the tasks that have only
// optional arguments, the system task name can be used with no arguments or
// the name followed by () can be specified, for example, $dumpportsflush or
// $dumpportsflush(). In both of these cases, the default actions for the
// arguments shall be executed."
//
// u has input a and output y = ~a (codes <0, <1, port order). The test
// fixture changes a on even nanoseconds and calls the control tasks on odd
// ones, from one initial block, so no change races a task. The dump is read
// back after $dumpportsflush and every time, keyword and identifier code
// after `$enddefinitions $end` is printed, one per line; values and
// strengths are §18.4.3's (port_value_changes.v) and are skipped,
// and so is any $comment section. Within one time record or section the
// reader prints the codes it saw in code order, <0 then <1, whatever order
// the file lists them in: §18.4 does not fix that order.
//
// HAND DERIVATION:
//   #0  $dumpports: the start section         -> #0 $dumpports <0 <1 $end
//   #2  a = 1                                  -> #2 <0 <1
//   #3  $dumpportsoff(file): X checkpoint      -> #3 $dumpportsoff <0 <1 $end
//   #4  a = 0: suspended, nothing
//   #5  $dumpportsoff(file) again: already suspended, ignored
//   #6  a = 1: nothing
//   #7  $dumpportson(file) twice: the first dumps every port's value, the
//       second finds dumping on and is ignored -> #7 $dumpportson <0 <1 $end
//   #8  a = 0                                  -> #8 <0 <1
//   #9  $dumpportsall(file)                    -> #9 $dumpportsall <0 <1 $end
//   #10 a = 1                                  -> #10 <0 <1
//   #11 $dumpportsoff("b_18_3_2_other.evcd"): no $dumpports named that
//       file, ignored
//   #12 a = 0: still dumped                    -> #12 <0 <1
//   #13 $dumpportsoff with no argument: every $dumpports file suspends
//                                              -> #13 $dumpportsoff <0 <1 $end
//   #14 a = 1: nothing
//   #15 $dumpportson(): every file resumes     -> #15 $dumpportson <0 <1 $end
//   #16 a = 0                                  -> #16 <0 <1
//   #17 $dumpportsflush with no argument; the reader runs.
// When the simulation ends the file closes with §18.3.6.1's `$vcdclose
// #17 $end` (Syntax 18-26, "the final simulation time at the time the
// extended VCD file is closed"). No design can read that section, so this
// transcript does not show it; it is the last section of the file this
// fixture writes.
//! inherited IEEE 1364-2005 18.3.2 18.3.3 18.3.5 18.3.6 18.3.6.1 18.3.7
// native-required
`timescale 1ns/1ns
module b_18_3_2_dev(a, y);
  input a;
  output y;
  assign y = ~a;
endmodule

module b_18_3_2_dumpports_control_tasks;
  reg a;
  wire y;
  b_18_3_2_dev u(a, y);
  integer fd, c, len, started, skip, seen0, seen1;
  reg [8*64:1] tok, first;

  // The codes a record listed, in code order: §18.4 does not fix the order
  // of the value changes within one time.
  task codes;
    begin
      if (seen0) $display("<0");
      if (seen1) $display("<1");
      seen0 = 0;
      seen1 = 0;
    end
  endtask

  task token;
    begin
      first = tok >> 8 * (len - 1);
      if (skip) begin
        if (tok == "$end") skip = 0;
      end else if (started == 1 && tok == "$end") started = 2;
      else if (started == 2) begin
        // A writer may add a $comment section anywhere (§18.3.6).
        if (tok == "$comment") skip = 1;
        else if (tok == "<0") seen0 = 1;
        else if (tok == "<1") seen1 = 1;
        else if (first == "#" || first == "$") begin
          codes;
          $display("%0s", tok);
        end
      end else if (tok == "$enddefinitions") started = 1;
    end
  endtask

  initial begin
    a = 1'b0;
    $dumpports(b_18_3_2_dumpports_control_tasks.u, "b_18_3_2_control.evcd");
    #2 a = 1'b1;
    #1 $dumpportsoff("b_18_3_2_control.evcd");
    #1 a = 1'b0;
    #1 $dumpportsoff("b_18_3_2_control.evcd");
    #1 a = 1'b1;
    #1 $dumpportson("b_18_3_2_control.evcd");
       $dumpportson("b_18_3_2_control.evcd");
    #1 a = 1'b0;
    #1 $dumpportsall("b_18_3_2_control.evcd");
    #1 a = 1'b1;
    #1 $dumpportsoff("b_18_3_2_other.evcd");
    #1 a = 1'b0;
    #1 $dumpportsoff;
    #1 a = 1'b1;
    #1 $dumpportson();
    #1 a = 1'b0;
    #1 $dumpportsflush;
    fd = $fopen("b_18_3_2_control.evcd", "r");
    started = 0;
    skip = 0;
    seen0 = 0;
    seen1 = 0;
    tok = 0;
    len = 0;
    c = $fgetc(fd);
    while (c != -1) begin
      if (c == " " || c == "\n" || c == "\t" || c == 8'd13) begin
        if (len != 0) token;
        tok = 0;
        len = 0;
      end else begin
        tok = {tok, c[7:0]};
        len = len + 1;
      end
      c = $fgetc(fd);
    end
    if (len != 0) token;
    codes;
    $fclose(fd);
  end
endmodule
