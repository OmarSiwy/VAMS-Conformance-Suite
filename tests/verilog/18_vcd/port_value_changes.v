// IEEE 1364-2005 §18.4.3, p. 346, Syntax 18-29:
//   pport_value 0_strength_component 1_strength_component identifier_code
// "p Key character that indicates a port. There is no space between the p
// and the port_value." "0_strength_component One of the eight Verilog
// strengths that indicates the strength0 specification for the port." (and
// likewise 1_strength_component), coded 0 highz, 1 small, 2 medium, 3 weak,
// 4 large, 5 pull, 6 strong, 7 supply.
// §18.4.3.1, pp. 346-347: "INPUT (TESTFIXTURE): D low, U high, N unknown, Z
// three-state ... OUTPUT (DUT): L low, H high, X unknown (do-not care), T
// three-state, l low (two or more drivers active), h high (two or more
// drivers active) ... UNKNOWN DIRECTION: 0 low (both input and output are
// active with 0 value), 1 high (both input and output are active with 1
// value) ... f unknown (input and output three-stated)".
// §18.4.3.2, p. 347: "Drivers are considered only in terms of primitives,
// continuous assignments, and procedural continuous assignments." ... "If
// both input and output are driving the same value with the same range of
// strength, then this is a conflict. The resolved value is 0/1, and the
// strength is the stronger of the two." ... "If the input is driving a weak
// strength (range) and the output is driving a strong strength (range), then
// the resolved value is l/h, and the strength is the strength of the output."
// "Strength supply 7 to 5 (large): strong strength — Strength 4 to 1: weak
// strength".
// §18.4.4 (pp. 347-348) is the worked example; its lines `pD 6 0`, `pU 0 6`,
// `pN 6 6`, `pX 6 6`, `pH 0 6` and `pf 0 0` fix how a strong driver's
// strengths and a released inout read.
//
// u = b_18_4_3_dev: inputs a, b, output y = a | b (a continuous assignment,
// strong), inout io driven by u through `assign io = den ? dval : 1'bz`
// (strong). The test fixture drives a and b from regs through the port
// connections, and io through two continuous assignments, one strong and one
// (weak0, weak1). Codes: <0 a, <1 b, <2 y, <3 io (port order). One initial
// block makes every change, so none races another.
//
// The reader prints every token after `$enddefinitions $end`, one value
// change per line, skipping any $comment section; within a time record it
// prints the changes in code order, whatever order the file lists them in,
// since §18.4 does not fix that order.
//
// HAND DERIVATION (one line per value change; times in 1ns):
//   #0 $dumpports: a = 0 strong -> pD 6 0 <0; b = 1 -> pU 0 6 <1;
//      y = 0 | 1 = 1 from u -> pH 0 6 <2; io: the fixture (strong 1) and u
//      (strong 1) both drive 1 in the strong range -> p1 0 6 <3; $end.
//   #1 a = x -> pN 6 6 <0 (y = x | 1 = 1, unchanged).
//   #2 b = 0 -> pD 6 0 <1; y = x | 0 = x -> pX 6 6 <2.
//   #3 the fixture's io driver turns weak 0, u's strong 0: input weak,
//      output strong -> pl 6 0 <3 (the strength is the output's).
//   #4 u releases io; the fixture's weak 0 alone: an input low of weak
//      strength -> pD 3 0 <3.
//   #5 the fixture releases io too: both three-stated -> pf 0 0 <3.
//   #6 u drives io (pull0, pull1) to 0, the fixture weak 0 again. Pull is
//      5, inside "7 to 5" by number though the parenthesis says "(large)"
//      (specification/Vague_Decisions.md VD-042: the numbers rule): input weak,
//      output strong range -> pl 5 0 <3. Were pull in the weak range, both
//      sides weak would give p0 5 0 <3.
//! inherited IEEE 1364-2005 18.4.3 18.4.3.1 18.4.3.2 18.4.4
// native-required
`timescale 1ns/1ns
module b_18_4_3_dev(a, b, y, io);
  input a, b;
  output y;
  inout io;
  reg den, dval, pen;
  assign y = a | b;
  assign io = den ? dval : 1'bz;
  assign (pull0, pull1) io = pen ? dval : 1'bz;
endmodule

module b_18_4_3_port_value_changes;
  reg a, b, sen, wen, val;
  wire y, io;
  assign io = sen ? val : 1'bz;
  assign (weak0, weak1) io = wen ? val : 1'bz;
  b_18_4_3_dev u(a, b, y, io);
  integer fd, c, len, started, field, skip, k;
  reg [8*64:1] tok, pv, s0, s1;
  // One time record's changes, by code <0 to <3.
  reg [8*64:1] pvs [0:3], s0s [0:3], s1s [0:3];
  reg have [0:3];

  // The changes a record listed, in code order: §18.4 does not fix the
  // order of the value changes within one time.
  task changes;
    begin
      for (k = 0; k < 4; k = k + 1)
        if (have[k]) begin
          $display("%0s %0s %0s <%0d", pvs[k], s0s[k], s1s[k], k);
          have[k] = 0;
        end
    end
  endtask

  task token;
    begin
      if (skip) begin
        if (tok == "$end") skip = 0;
      end else if (started == 1 && tok == "$end") started = 2;
      else if (started == 2) begin
        if (field == 0 && (tok >> 8 * (len - 1)) == "p") begin
          pv = tok;
          field = 1;
        end else if (field == 1) begin s0 = tok; field = 2; end
        else if (field == 2) begin s1 = tok; field = 3; end
        else if (field == 3) begin
          // `<n`, n one digit here.
          k = tok[8:1] - "0";
          pvs[k] = pv;
          s0s[k] = s0;
          s1s[k] = s1;
          have[k] = 1;
          field = 0;
        end else if (tok == "$comment") skip = 1; // §18.3.6: a writer may add one
        else begin
          changes;
          $display("%0s", tok);
        end
      end else if (tok == "$enddefinitions") started = 1;
    end
  endtask

  initial begin
    a = 1'b0;
    b = 1'b1;
    val = 1'b1;
    sen = 1'b1;
    wen = 1'b0;
    u.dval = 1'b1;
    u.den = 1'b1;
    u.pen = 1'b0;
    $dumpports(b_18_4_3_port_value_changes.u, "b_18_4_3_values.evcd");
    #1 a = 1'bx;
    #1 b = 1'b0;
    #1 sen = 1'b0;
       wen = 1'b1;
       val = 1'b0;
       u.dval = 1'b0;
    #1 u.den = 1'b0;
    #1 wen = 1'b0;
    #1 wen = 1'b1;
       u.pen = 1'b1;
    #1 $dumpportsflush("b_18_4_3_values.evcd");
    fd = $fopen("b_18_4_3_values.evcd", "r");
    started = 0;
    field = 0;
    skip = 0;
    for (k = 0; k < 4; k = k + 1) have[k] = 0;
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
    changes;
    $fclose(fd);
  end
endmodule
