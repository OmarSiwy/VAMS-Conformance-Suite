// IEEE 1364-2005 §18.2.1, p. 330: "Value changes for real variables are
// specified by real numbers." ... "A real number is dumped using a %.16g
// printf() format. This preserves the precision of that number by outputting
// all 53 bits in the mantissa of a 64-bit IEEE 754 double-precision number."
// Syntax 18-8: `vector_value_change ::= ... | r real_number identifier_code`.
//
// The dump is read back during the simulation after a $dumpflush (§18.1.6),
// split into white-space separated tokens, as in
// version_names_dumpfile_literal.v; each `r` value token is
// printed with the time record it is in (codes are the writer's and are not
// printed).
//
// HAND DERIVATION of C's %.16g (ISO C 7.19.6.1: style e when the exponent X
// is < -4 or >= the precision 16, else style f with 16 - 1 - X decimals;
// trailing zeros and a trailing point then removed):
//   #0 1.5            X = 0   -> 1.5
//   #1 -2.25e10       X = 10  -> -22500000000
//   #2 0.25           X = -1  -> 0.25
//   #3 6.02e23        X = 23  -> 6.02e+23 (the nearest double,
//                     601999999999999995805696, rounds back to 6.02 at
//                     16 significant digits)
//   #4 1e16           X = 16  -> 1e+16
//   #5 0.0            X = 0   -> 0
//   #6 1.0/3.0        X = -1  -> 0.3333333333333333 (16 digits)
//! inherited IEEE 1364-2005 18.2.1
`timescale 1ns/1ns
module b_18_2_1_real_dut;
  real r;
  initial begin
    r = 1.5;
    #1 r = -2.25e10;
    #1 r = 0.25;
    #1 r = 6.02e23;
    #1 r = 1e16;
    #1 r = 0.0;
    #1 r = 1.0 / 3.0;
  end
endmodule

// Dumps u and reads the dump back; its own variables are not selected.
module b_18_2_1_real_value_format;
  b_18_2_1_real_dut u();
  integer fd, c, len, header, skip, code_next;
  reg [8*64:1] tok, now, first;

  task token;
    begin
      if (skip) begin
        if (tok == "$end") skip = 0;
      end else if (tok == "$date" || tok == "$version" || tok == "$comment") skip = 1;
      else if (header) begin
        if (tok == "$enddefinitions") header = 0;
      end else begin
        // After the header: a vector or real value's code is its own token,
        // so it is stepped over; `#` opens a time record.
        first = tok >> 8 * (len - 1);
        if (code_next) code_next = 0;
        else if (first == "b" || first == "B" || first == "r" || first == "R") begin
          code_next = 1;
          // Syntax 18-8 allows r or R; the transcript prints r for either.
          if (first == "r" || first == "R")
            $display("%0s r%0s", now, tok & ((512'd1 << 8 * (len - 1)) - 1));
        end else if (first == "#") now = tok;
      end
    end
  endtask

  initial begin
    $dumpfile("b_18_2_1_real.vcd");
    $dumpvars(1, u);
    #7 $dumpflush;
    fd = $fopen("b_18_2_1_real.vcd", "r");
    header = 1; skip = 0; code_next = 0;
    tok = 0; len = 0; now = 0;
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
  end
endmodule
