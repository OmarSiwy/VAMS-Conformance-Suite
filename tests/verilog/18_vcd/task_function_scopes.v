// IEEE 1364-2005 §18.2.3.4, p. 333: "The $scope section defines the scope of
// the variables being dumped." Syntax 18-12:
//   vcd_declaration_scope ::= $scope scope_type scope_identifier $end
//   scope_type ::= begin | fork | function | module | task
// "task Tasks", "function Functions". §18.1.2, p. 327: "$dumpvars (0, top);
// ... the $dumpvars task shall dump all variables in the module top and in
// all module instances below module top in the hierarchy." The §18.2.4
// example (p. 337) dumps a task's variables: `$scope task t1 $end`, `$var reg
// 32 (k accumulator[31:0] $end`, `$var integer 32 {2 index $end`.
//
// u's task t1 declares reg [31:0] accumulator and integer index, and its
// function f declares reg fr: variables of u, in scopes of their own. (A
// named begin or fork block's variables would be the other two scope types;
// VerA does not parse a declaration inside a block, a gap outside §18.)
//
// The dump is read back during the simulation after a $dumpflush (§18.1.6),
// split into white-space separated tokens, as in
// version_names_dumpfile_literal.v. Codes are the writer's and
// are compared, not printed.
//
// HAND DERIVATION:
//   a `$scope task t1 $end` section holds a $var for accumulator -> acc=1
//                                              and one for index -> index=1
//   a `$scope function f $end` section holds a $var for fr      -> fr=1
//   #1 calls t1, which sets accumulator = 5, dumped as the vector
//   change `b101` followed by accumulator's code               -> acc5=1
//! inherited IEEE 1364-2005 18.2.3.4
`timescale 1ns/1ns
module b_18_2_3_4_dut;
  reg [1:0] r;
  task t1;
    reg [31:0] accumulator;
    integer index;
    begin
      accumulator = 5;
      index = 2;
    end
  endtask
  function f;
    input x;
    reg fr;
    begin
      fr = x;
      f = ~x;
    end
  endfunction
  initial begin
    r = 2'b00;
    #1 t1;
    #1 r = {f(1'b1), 1'b1};
  end
endmodule

// Dumps u and reads the dump back; its own variables are not selected.
module b_18_2_3_4_task_function_scopes;
  b_18_2_3_4_dut u();
  integer fd, c, len, header, skip, field, scope_field, code_next, check_code;
  integer acc, index, fr, acc5;
  reg [8*64:1] tok, first, now, stype, sname, cand, acode;

  task token;
    begin
      if (skip) begin
        if (tok == "$end") skip = 0;
      end else if (tok == "$date" || tok == "$version" || tok == "$comment") skip = 1;
      else if (header) begin
        if (tok == "$scope") scope_field = 1;
        else if (scope_field == 1) begin stype = tok; scope_field = 2; end
        else if (scope_field == 2) begin sname = tok; scope_field = 0; end
        else if (tok == "$upscope") begin stype = 0; sname = 0; end
        // `$var var_type size identifier_code reference $end`
        else if (tok == "$var") field = 1;
        else if (field == 1 || field == 2) field = field + 1;
        else if (field == 3) begin cand = tok; field = 4; end
        else if (field == 4) begin
          // §18.2.4's example writes the range attached, `accumulator[31:0]`;
          // §18.2.3.7's syntax writes it apart. Either names accumulator.
          if (stype == "task" && sname == "t1" &&
              (tok == "accumulator" || (len > 12 && tok >> 8 * (len - 12) == "accumulator["))) begin
            acc = 1;
            acode = cand;
          end
          if (stype == "task" && sname == "t1" && tok == "index") index = 1;
          if (stype == "function" && sname == "f" && tok == "fr") fr = 1;
          field = 0;
        end else if (tok == "$enddefinitions") header = 0;
      end else begin
        // After the header: a vector or real value's code is its own token;
        // `#` opens a time record.
        first = tok >> 8 * (len - 1);
        if (code_next) begin
          if (check_code && now == "#1" && acc && tok == acode) acc5 = 1;
          code_next = 0;
          check_code = 0;
        end else if (first == "b" || first == "B" || first == "r" || first == "R") begin
          code_next = 1;
          check_code = tok == "b101";
        end else if (first == "#") now = tok;
      end
    end
  endtask

  initial begin
    $dumpfile("b_18_2_3_4_scopes.vcd");
    $dumpvars(0, u);
    #3 $dumpflush;
    fd = $fopen("b_18_2_3_4_scopes.vcd", "r");
    header = 1; skip = 0; field = 0; scope_field = 0; code_next = 0; check_code = 0;
    acc = 0; index = 0; fr = 0; acc5 = 0;
    tok = 0; len = 0; now = 0; stype = 0; sname = 0; cand = 0; acode = 0;
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
    $display("acc=%0d index=%0d fr=%0d acc5=%0d", acc, index, fr, acc5);
  end
endmodule
