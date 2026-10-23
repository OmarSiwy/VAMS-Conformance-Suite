// IEEE 1364-2005 §19.4, pp. 352-354: "The `ifdef compiler directive checks
// for the definition of a text_macro_name. If the text_macro_name is defined,
// then the lines following the `ifdef directive are included. If the
// text_macro_name is not defined and an `else directive exists, then this
// source is compiled." ... "The `elsif directive is equivalent to the compiler
// directive sequence `else `ifdef ... `endif." ... "These directives may
// appear anywhere in the source description." ... "Although the names of
// compiler directives are contained in the same name space as text macro
// names, the names of compiler directives are considered not to be defined
// by `ifdef, `ifndef, and `elseif. Nesting of `ifdef, `ifndef, `else, `elsif,
// and `endif compiler directives shall be permitted."
//
// Example 2 (p. 355) with all four macros defined: wow, nest_one and nest_two
// are defined, so the three "is defined" lines and nothing else. Its
// `initial $display` items are made statements of one initial block, so the
// three lines come out in source order (§11.4.1 a) instead of racing.
// Example 3 (p. 355), its displays likewise in one block, under six macro
// sets, each set by `define/`undef just before its copy:
//   A first_block, second_nest   -> "first_block and second_nest defined"
//   B first_block                -> "first_block is defined"
//   C second_block               -> "second_block defined, first_block is not"
//   D none                       -> "first_block, second_block," then
//                                   " last_result not defined." (two string
//                                   arguments, printed back to back)
//   E last_result, real_last     -> "first_block, second_block not defined,",
//                                   " last_result and real_last defined."
//   F last_result                -> "Only last_result defined!"
// The example writes these two-part messages as "a," " b" with no comma;
// A.6.9's system_task_enable separates arguments with commas, so the
// copies here have one.
// `ifdef define: `define is a directive name, "not to be defined", so the
// `else arm: "define is not defined".
// "anywhere": an `ifdef inside an expression selects its operand: with
// `plus3 defined, 1 + 3 = 4.
//! inherited IEEE 1364-2005 19.4
`define wow
`define nest_one
`define second_nest
`define nest_two
`define plus3
module b_19_4_conditional_compilation;
  integer v;
  initial begin
    `ifdef wow
      $display("wow is defined");
      `ifdef nest_one
        $display("nest_one is defined");
        `ifdef nest_two
          $display("nest_two is defined");
        `else
          $display("nest_two is not defined");
        `endif
      `else
        $display("nest_one is not defined");
      `endif
    `else
      $display("wow is not defined");
      `ifdef second_nest
        $display("second_nest is defined");
      `else
        $display("second_nest is not defined");
      `endif
    `endif
`define first_block
    `ifdef first_block
      `ifndef second_nest
        $display("first_block is defined");
      `else
        $display("first_block and second_nest defined");
      `endif
    `elsif second_block
      $display("second_block defined, first_block is not");
    `else
      `ifndef last_result
        $display("first_block, second_block,",
                 " last_result not defined.");
      `elsif real_last
        $display("first_block, second_block not defined,",
                 " last_result and real_last defined.");
      `else
        $display("Only last_result defined!");
      `endif
    `endif
`undef second_nest
    `ifdef first_block
      `ifndef second_nest
        $display("first_block is defined");
      `else
        $display("first_block and second_nest defined");
      `endif
    `elsif second_block
      $display("second_block defined, first_block is not");
    `else
      `ifndef last_result
        $display("first_block, second_block,",
                 " last_result not defined.");
      `elsif real_last
        $display("first_block, second_block not defined,",
                 " last_result and real_last defined.");
      `else
        $display("Only last_result defined!");
      `endif
    `endif
`undef first_block
`define second_block
    `ifdef first_block
      `ifndef second_nest
        $display("first_block is defined");
      `else
        $display("first_block and second_nest defined");
      `endif
    `elsif second_block
      $display("second_block defined, first_block is not");
    `else
      `ifndef last_result
        $display("first_block, second_block,",
                 " last_result not defined.");
      `elsif real_last
        $display("first_block, second_block not defined,",
                 " last_result and real_last defined.");
      `else
        $display("Only last_result defined!");
      `endif
    `endif
`undef second_block
    `ifdef first_block
      `ifndef second_nest
        $display("first_block is defined");
      `else
        $display("first_block and second_nest defined");
      `endif
    `elsif second_block
      $display("second_block defined, first_block is not");
    `else
      `ifndef last_result
        $display("first_block, second_block,",
                 " last_result not defined.");
      `elsif real_last
        $display("first_block, second_block not defined,",
                 " last_result and real_last defined.");
      `else
        $display("Only last_result defined!");
      `endif
    `endif
`define last_result
`define real_last
    `ifdef first_block
      `ifndef second_nest
        $display("first_block is defined");
      `else
        $display("first_block and second_nest defined");
      `endif
    `elsif second_block
      $display("second_block defined, first_block is not");
    `else
      `ifndef last_result
        $display("first_block, second_block,",
                 " last_result not defined.");
      `elsif real_last
        $display("first_block, second_block not defined,",
                 " last_result and real_last defined.");
      `else
        $display("Only last_result defined!");
      `endif
    `endif
`undef real_last
    `ifdef first_block
      `ifndef second_nest
        $display("first_block is defined");
      `else
        $display("first_block and second_nest defined");
      `endif
    `elsif second_block
      $display("second_block defined, first_block is not");
    `else
      `ifndef last_result
        $display("first_block, second_block,",
                 " last_result not defined.");
      `elsif real_last
        $display("first_block, second_block not defined,",
                 " last_result and real_last defined.");
      `else
        $display("Only last_result defined!");
      `endif
    `endif
    `ifdef define
      $display("define is defined");
    `else
      $display("define is not defined");
    `endif
    v = 1 +
    `ifdef plus3
      3
    `else
      5
    `endif
      ;
    $display("%0d", v);
    $finish(0);
  end
endmodule
