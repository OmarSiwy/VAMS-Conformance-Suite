// IEEE 1364-2005 §18.2.2, p. 331: "Events are dumped in the same format as
// scalars; for example, 1*%. For events, however, the value (1 in this
// example) is irrelevant. Only the identifier code (*% in this example) is
// significant. It appears in the VCD file as a marker to indicate the event
// was triggered during the time step." §18.2.3.7, p. 334, Syntax 18-15:
// `var_type ::= event | integer | ...`. §18.1.2, pp. 326-327: "When invoked with
// no arguments, $dumpvars dumps all the variables in the model"; with
// arguments, `(1, u)` "dumps all variables within the module" u.
//
// The dump is read back during the simulation after a $dumpflush (§18.1.6),
// split into white-space separated tokens, as in
// version_names_dumpfile_literal.v. The writer's choice of codes
// and of the value digit is not printed; what is:
//
// HAND DERIVATION:
//   u declares reg a and event e. The header has a `$var event <size> <code>
//   e $end` section                                        -> declared=1
//   e is triggered at #1 and #3, a changes at #2 only. A marker is one token,
//   a value digit then e's code, inside the time record:
//     #1: a marker                                         -> at1=1
//     #2: none (a changed, e did not)                      -> at2=0
//     #3: a marker                                         -> at3=1
//! inherited IEEE 1364-2005 18.2.2 18.2.3.7
`timescale 1ns/1ns
module b_18_2_2_event_dut;
  reg a;
  event e;
  initial begin
    a = 1'b0;
    #1 -> e;
    #1 a = 1'b1;
    #1 -> e;
  end
endmodule

// Dumps u and reads the dump back; its own variables are not selected.
module b_18_2_2_event_marker;
  b_18_2_2_event_dut u();
  integer fd, c, len, clen, header, skip, field, declared, elen, code_next, at1, at2, at3;
  reg [8*64:1] tok, vtype, cand, ecode, now, mask, first;

  task token;
    begin
      if (skip) begin
        if (tok == "$end") skip = 0;
      end else if (tok == "$date" || tok == "$version" || tok == "$comment") skip = 1;
      else if (header) begin
        // `$var var_type size identifier_code reference $end`
        if (tok == "$var") field = 1;
        else if (field == 1) begin vtype = tok; field = 2; end
        else if (field == 2) field = 3;
        else if (field == 3) begin cand = tok; clen = len; field = 4; end
        else if (field == 4) begin
          if (vtype == "event" && tok == "e") begin
            declared = 1;
            ecode = cand;
            elen = clen;
            mask = {512{1'b1}} >> (512 - 8 * clen);
          end
          field = 0;
        end else if (tok == "$enddefinitions") header = 0;
      end else begin
        // After the header: a vector or real value's code is its own token,
        // so it is stepped over; `#` opens a time record; `$` a keyword; any
        // other token is a scalar change, a value digit then a code.
        first = tok >> 8 * (len - 1);
        if (code_next) code_next = 0;
        else if (first == "b" || first == "B" || first == "r" || first == "R") code_next = 1;
        else if (first == "#") now = tok;
        else if (first != "$" && declared && len == elen + 1 && (tok & mask) == ecode) begin
          if (now == "#1") at1 = 1;
          if (now == "#2") at2 = 1;
          if (now == "#3") at3 = 1;
        end
      end
    end
  endtask

  initial begin
    $dumpfile("b_18_2_2_event.vcd");
    $dumpvars(1, u);
    #4 $dumpflush;
    fd = $fopen("b_18_2_2_event.vcd", "r");
    header = 1; skip = 0; field = 0; declared = 0; elen = 0; code_next = 0;
    at1 = 0; at2 = 0; at3 = 0;
    tok = 0; len = 0; now = 0; mask = 0; ecode = 0;
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
    $fclose(fd);
    $display("declared=%0d at1=%0d at2=%0d at3=%0d", declared, at1, at2, at3);
  end
endmodule
