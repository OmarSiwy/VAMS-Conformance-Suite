// A.2.7 Task declarations:
//
//     task_declaration ::= task [ automatic ] task_identifier ( [ task_port_list ] ) ;
//                              { block_item_declaration } statement_or_null endtask
//     task_port_item ::= tf_input_declaration | tf_output_declaration
//                      | tf_inout_declaration
//
// and A.6.4 `statement ::= ... | task_enable`. VAMS §1.1 makes IEEE Std 1364
// Verilog's Clause 10 task semantics part of this language: arguments are passed
// by VALUE — inputs and inouts are copied IN when the task is entered, outputs
// and inouts are copied OUT when it returns.
//
// One task, all three directions, tests the copied input values and final
// output/inout values. It does not distinguish value passing from reference
// passing or establish when outputs become visible; those obligations are
// TF-EVID-001 in docs/conformance-ieee-task-functions-review.md at 8b1514d4 and the
// independent task_copy_timing.v fixture.
//
// HAND DERIVATION — decimal literals, four bits wide.
//   caller sets   p = 4'd3  = 0011
//                 r = 4'd10 = 1010
//   call bump(p, q, r):
//     copy in     i  = 0011           (from p)
//                 io = 1010           (from r)
//     body        o  = i + 1 = 3 + 1  = 4  -> 0100
//                 io = io + i = 10+3  = 13 -> 1101   (13 < 16, no wrap)
//     copy out    q <- o  = 0100
//                 r <- io = 1101
//   p is an input actual and is never written: it stays 0011.
//   -> "task 0011 0100 1101"
//
// The input formal i is never assigned, so this row cannot detect writes
// through a reference-passed input. Writing o does not write i or actual p.
// A missing copy-out leaves q at xxxx and r at 1010.
// An inout copied in but not out leaves r at 1010 as well, which is why the
// value chosen for r (1010) differs from its result (1101) in more than one bit.
//
// No delays anywhere, so the program needs no `timescale (untimed programs do
// not require one).
//
//! lrm A.2.7
//! lrm A.6.4
//! lrm 1.1
//! lrm A.2.7:1000
//! lrm A.6.9
//! lrm A.6.9:1000
//! inherited IEEE 1364-2005 10.2.2
module d04_task_argument_passing;
  reg [3:0] p, q, r;

  task bump(input [3:0] i, output [3:0] o, inout [3:0] io);
    begin
      o = i + 4'd1;
      io = io + i;
    end
  endtask

  initial begin
    p = 4'd3;
    r = 4'd10;
    bump(p, q, r);
    $display("task %b %b %b", p, q, r);
    $finish(0);
  end
endmodule
