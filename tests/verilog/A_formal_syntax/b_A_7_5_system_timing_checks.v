// IEEE 1364-2005 A.7.5.1, p. 502:
//   system_timing_check ::= $setup_timing_check | $hold_timing_check
//     | $setuphold_timing_check | $recovery_timing_check | $removal_timing_check
//     | $recrem_timing_check | $skew_timing_check | $timeskew_timing_check
//     | $fullskew_timing_check | $period_timing_check | $width_timing_check
//     | $nochange_timing_check
//   $setup_timing_check ::= $setup ( data_event , reference_event , timing_check_limit [ , [ notifier ] ] ) ;
//   $hold_timing_check ::= $hold ( reference_event , data_event , timing_check_limit [ , [ notifier ] ] ) ;
//   $setuphold_timing_check ::= $setuphold ( reference_event , data_event , timing_check_limit , timing_check_limit
//     [ , [ notifier ] [ , [ stamptime_condition ] [ , [ checktime_condition ]
//     [ , [ delayed_reference ] [ , [ delayed_data ] ] ] ] ] ] ) ;
//   $recovery_timing_check ::= $recovery ( reference_event , data_event , timing_check_limit [ , [ notifier ] ] ) ;
//   $removal_timing_check ::= $removal ( reference_event , data_event , timing_check_limit [ , [ notifier ] ] ) ;
//   $recrem_timing_check ::= $recrem ( reference_event , data_event , timing_check_limit , timing_check_limit
//     [ , [ notifier ] [ , [ stamptime_condition ] [ , [ checktime_condition ]
//     [ , [ delayed_reference ] [ , [ delayed_data ] ] ] ] ] ] ) ;
//   $skew_timing_check ::= $skew ( reference_event , data_event , timing_check_limit [ , [ notifier ] ] ) ;
//   $timeskew_timing_check ::= $timeskew ( reference_event , data_event , timing_check_limit
//     [ , [ notifier ] [ , [ event_based_flag ] [ , [ remain_active_flag ] ] ] ] ) ;
//   $fullskew_timing_check ::= $fullskew ( reference_event , data_event , timing_check_limit , timing_check_limit
//     [ , [ notifier ] [ , [ event_based_flag ] [ , [ remain_active_flag ] ] ] ] ) ;
//   $period_timing_check ::= $period ( controlled_reference_event , timing_check_limit [ , [ notifier ] ] ) ;
//   $width_timing_check ::= $width ( controlled_reference_event , timing_check_limit [ , threshold [ , notifier ] ] ) ;
//   $nochange_timing_check ::= $nochange ( reference_event , data_event , start_edge_offset ,
//     end_edge_offset [ , [ notifier ] ] ) ;
// A.7.5.2, p. 503:
//   checktime_condition ::= mintypmax_expression
//   controlled_reference_event ::= controlled_timing_check_event
//   data_event ::= timing_check_event
//   delayed_data ::= terminal_identifier | terminal_identifier [ constant_mintypmax_expression ]
//   delayed_reference ::= terminal_identifier | terminal_identifier [ constant_mintypmax_expression ]
//   end_edge_offset ::= mintypmax_expression
//   event_based_flag ::= constant_expression
//   notifier ::= variable_identifier
//   reference_event ::= timing_check_event
//   remain_active_flag ::= constant_expression
//   stamptime_condition ::= mintypmax_expression
//   start_edge_offset ::= mintypmax_expression
//   threshold ::= constant_expression
//   timing_check_limit ::= expression
// A.7.5.3, p. 503-504:
//   timing_check_event ::= [timing_check_event_control] specify_terminal_descriptor
//     [ &&& timing_check_condition ]
//   controlled_timing_check_event ::= timing_check_event_control specify_terminal_descriptor
//     [ &&& timing_check_condition ]
//   timing_check_event_control ::= posedge | negedge | edge_control_specifier
//   specify_terminal_descriptor ::= specify_input_terminal_descriptor | specify_output_terminal_descriptor
//   edge_control_specifier ::= edge [ edge_descriptor { , edge_descriptor } ]
//   edge_descriptor ::= 01 | 10 | z_or_x zero_or_one | zero_or_one z_or_x
//   zero_or_one ::= 0 | 1
//   z_or_x ::= x | X | z | Z
//   timing_check_condition ::= scalar_timing_check_condition | ( scalar_timing_check_condition )
//   scalar_timing_check_condition ::= expression | ~ expression | expression == scalar_constant
//     | expression === scalar_constant | expression != scalar_constant | expression !== scalar_constant
//   scalar_constant ::= 1'b0 | 1'b1 | 1'B0 | 1'B1 | 'b0 | 'b1 | 'B0 | 'B1 | 1 | 0
//
// The eight checks VerA's digital engine evaluates, with every optional
// argument it evaluates somewhere: notifiers, a null notifier (`, )`), a
// $width threshold, edge descriptors of all four shapes (01, 10, x1, 0z), a
// constant bit-select terminal (bus[0]), and &&& conditions of every scalar
// form: a bare expression, `~`, `==`, `===`, `!=` and `!==`, against
// 1'b1, 'b1, 0 and 1'B0. The productions only the other four commands and
// the negative-limit arguments use (event_based_flag, remain_active_flag,
// the $nochange offsets, stamptime and checktime conditions, delayed
// reference and data) are parsed by a digital run too, which then refuses
// the design by name (E1149, ieee1364/15_timing_checks/b_15_*_refused.v), so
// they have no run here; an analog compile accepts them all
// (annex_a_syntax/timing_checks_design_runs.va).
//
// The stimulus sets en, d and clk at 0, raises clk at 10 and bus at 20, so no
// reference event shares its time with a data event, and every check stays
// quiet:
//   t=0   en = 1, d = 1 (a data event of every check on d), clk x -> 0 (x0: a
//         derived data event of the edge[x1, 0z] $width, with no pulse open;
//         no other check takes it).
//   t=10  clk 0 -> 1: the reference event of $setup, $hold, $setuphold (en
//         is 1), $recovery, $removal and the conditioned $setup and $hold;
//         d last moved at 0, 10 away, beyond every limit (1, 2). $period's
//         edge[01, 10] takes its first edge, nothing to measure. The
//         edge[x1, 0z] $width does not take 01.
//   t=20  bus x -> 2'b01: bus[0] x -> 1, $recrem's reference event; d last
//         moved at 0, beyond its limits of 1.
// No violation, so the notifier keeps the 0 it took at 0, and q = d = 1.
// Output: "q=1 ntfr=0".
//! inherited IEEE 1364-2005 A.7.5.1,A.7.5.2,A.7.5.3
`timescale 1ns/1ns
module b_A_7_5_cell (clk, d, en, bus, q);
  input clk, d, en;
  input [1:0] bus;
  output q;
  reg ntfr;
  assign q = d;
  initial ntfr = 0;
  specify
    $setup(d, posedge clk, 1, ntfr);
    $hold(posedge clk, d, 1);
    $setuphold(posedge clk &&& en, negedge d, 1, 1, ntfr);
    $recovery(posedge clk, d &&& ~en, 2);
    $removal(posedge clk, d &&& (en == 1'b1), 2, );
    $recrem(posedge bus[0], d &&& en === 'b1, 1, 1, ntfr);
    $hold(posedge clk, d &&& en != 0, 1);
    $setup(d &&& en !== 1'B0, posedge clk, 1, ntfr);
    $period(edge [01, 10] clk, 10);
    $width(edge [x1, 0z] clk, 4, 1, ntfr);
  endspecify
endmodule
module b_A_7_5_system_timing_checks;
  reg clk, d, en;
  reg [1:0] bus;
  wire q;
  b_A_7_5_cell c (clk, d, en, bus, q);
  initial begin
    en = 1; d = 1; clk = 0;
    #10 clk = 1;
    #10 bus = 2'b01;
    #10 $display("q=%b ntfr=%0d", q, c.ntfr);
    $finish(0);
  end
endmodule
