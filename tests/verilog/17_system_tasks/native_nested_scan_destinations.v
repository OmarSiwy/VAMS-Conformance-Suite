// IEEE 1364-2005 §§17.2.4.3, 5.2.2: each formatted conversion stores into
// its variable destination. A destination's array index can call a function;
// the nested $sscanf below reads its own string and cannot replace the outer
// conversion's remaining input or format. Functions may call other functions
// (§10.4.4); this function enables no task and contains no timing control.
//
// Both outer scans read "10 20". The nested scan of "77" determines
// the first destination's index as 1-1=0. Thus both outer results are two
// assignments, values[0]=10 and last=20, with one pick call per outer scan.
//! inherited IEEE 1364-2005 17.2.4.3 5.2.2 10.4.4
// native-required
module native_nested_scan_destinations;
  integer fd, code, values[0:1], last, calls;
  function integer pick;
    input integer unused;
    integer n, scratch;
    begin
      calls = calls + 1;
      n = $sscanf("77", "%d", scratch);
      pick = n - 1;
    end
  endfunction
  initial begin
    calls = 0; values[0] = 0; last = 0;
    code = $sscanf("10 20", "%d %d", values[pick(0)], last);
    $display("string %0d %0d %0d %0d", code, values[0], last, calls);
    fd = $fopen("native_nested_scan_destinations.txt", "w");
    $fwrite(fd, "10 20");
    $fclose(fd);
    fd = $fopen("native_nested_scan_destinations.txt", "r");
    values[0] = 0; last = 0;
    code = $fscanf(fd, "%d %d", values[pick(0)], last);
    $display("file %0d %0d %0d %0d", code, values[0], last, calls);
    $fclose(fd);
    $finish(0);
  end
endmodule
