// IEEE1364-2005 10.2.1/10.2.3 printed147/149: concurrent static
// activations share locals; automatic activations have independent locals.
// The first entries save10 at time0, later entries overwrite/save20 at
// time1. Resume times2 and3 are distinct. Thus static reports20 twice,
// automatic reports10 then20. Output observations are staggered as well.
//! lrm 1.1
//! inherited IEEE 1364-2005 10.2.3
//! expect stdout task_concurrent_storage.expected.txt
`timescale 1ns/1ns
module audit_task_concurrent_storage;
  integer s1,s2,a1,a2;
  task shared_task(input integer id,output integer result);
    integer saved;
    begin saved=id; #2; result=saved; end
  endtask
  task automatic private_task(input integer id,output integer result);
    integer saved;
    begin saved=id; #2; result=saved; end
  endtask
  initial shared_task(10,s1);
  initial begin #1; shared_task(20,s2); end
  initial private_task(10,a1);
  initial begin #1; private_task(20,a2); end
  initial begin
    #4; $display("static=%0d,%0d automatic=%0d,%0d",s1,s2,a1,a2);
    $finish(0);
  end
endmodule
