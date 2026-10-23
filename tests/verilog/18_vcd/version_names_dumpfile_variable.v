// IEEE 1364-2005 §18.2.3.8, p. 335: "The $version section indicates which
// version of the VCD writer was used to produce the VCD file and the $dumpfile
// system task used to create the file. If a variable or an expression was
// used to specify the filename within $dumpfile, the unevaluated variable or
// expression literal shall appear in the $version string." Syntax 18-16:
//   vcd_declaration_version ::= $version version_text system_task $end
//
// The file name is the variable fname, so the $version section must carry
// `$dumpfile(fname)`, the variable's name, not the name it holds. The dump
// is read back during the simulation as in
// version_names_dumpfile_literal.v (its legal twin, which names
// the file with a literal and passes): tokens split at white space, date and
// version text tested for a property, codes by the d09_11 CONVENTION.
//
// HAND DERIVATION:
//   the $version section, white space removed, contains the 16 characters
//   $dumpfile(fname)                          -> version=1
//   date=1 and timescale=1 and the value tokens as in the literal twin:
//     $enddefinitions $end #0 $dumpvars 0! $end #1 1!
//! inherited IEEE 1364-2005 18.2.3.8
`timescale 1ns/1ns
module b_18_2_3_8_var_dut;
  reg a;
  initial begin
    a = 1'b0;
    #1 a = 1'b1;
    #2 a = 1'b0;
  end
endmodule

// Dumps u and reads the dump back; its own variables are not selected.
module b_18_2_3_8_version_names_dumpfile_variable;
  b_18_2_3_8_var_dut u();
  integer fd, c;
  integer section; // 0 none, 1 $date, 2 $version, 3 $timescale, 4 $comment
  integer header, date_words, date_ok, version_ok, timescale_ok;
  reg [8*64:1] tok;
  reg [8*16:1] win;
  reg [8*20:1] fname;

  task token;
    begin
      if (section != 0) begin
        if (tok == "$end") section = 0;
        else if (section == 1) date_words = date_words + 1;
      end else if (tok == "$comment") section = 4;
      else if (header) begin
        if (tok == "$date") section = 1;
        else if (tok == "$version") section = 2;
        else if (tok == "$timescale") begin
          section = 3;
          timescale_ok = 1;
        end else if (tok == "$enddefinitions") begin
          header = 0;
          $display("%0s", tok);
        end
      end else $display("%0s", tok);
      if (section == 0 && date_words != 0) date_ok = 1;
    end
  endtask

  initial begin
    fname = "b_18_2_3_8_var.vcd";
    $dumpfile(fname);
    $dumpvars(1, u);
    #2 $dumpflush;
    fd = $fopen("b_18_2_3_8_var.vcd", "r");
    section = 0;
    header = 1;
    date_words = 0;
    date_ok = 0;
    version_ok = 0;
    timescale_ok = 0;
    tok = 0;
    win = 0;
    c = $fgetc(fd);
    while (c != -1) begin
      if (c == " " || c == "\n" || c == "\t" || c == 8'd13) begin
        if (tok != 0) token;
        tok = 0;
      end else begin
        tok = {tok, c[7:0]};
        if (section == 2) begin
          win = {win, c[7:0]};
          if (win == "$dumpfile(fname)") version_ok = 1;
        end
      end
      c = $fgetc(fd);
    end
    if (tok != 0) token;
    $fclose(fd);
    $display("date=%0d version=%0d timescale=%0d", date_ok, version_ok, timescale_ok);
  end
endmodule
