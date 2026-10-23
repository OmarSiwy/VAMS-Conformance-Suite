// IEEE 1364-2005 §17.1.3, Syntax 17-3, p. 286:
//   monitor_tasks ::= monitor_task_name [ ( list_of_arguments ) ] ;
//                   | $monitoron ;
//                   | $monitoroff ;
// $monitoron and $monitoroff are the two alternatives with no argument list:
// "The $monitoron and $monitoroff tasks control a monitor flag that enables
// and disables the monitoring."
//
// $monitoroff(1) gives the flag task an argument list Syntax 17-3 does not
// admit. Syntax 3-2 (A.6.9) admits an argument list on any system task; the
// refusal rests on Syntax 17-3, the clause that defines $monitoroff's forms
// (§3.7.3: the tasks "defined in Clause 17").
// Legal neighbour: monitor.v's bare $monitoroff; and
// monitoron_already_enabled.v's bare $monitoron;.
//! inherited IEEE 1364-2005 17.1.3
//! reject E1100
//! reject $monitoron and $monitoroff take no arguments
//! neighbour monitoron_already_enabled.v
//! neighbour monitor.v
module b_17_1_3_monitoroff_argument_rejected;
  reg a;
  initial begin
    a = 1'b0;
    $monitor("a=%b", a);
    $monitoroff(1);
  end
endmodule
