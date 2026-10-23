// IEEE1364-2005 10.4.4, printed155: Function assignments must not be nonblocking; a delayed return is not legal.
// Legal-context control: function_return_variable.v.
// The reject phrase below is an INTENDED rule-specific diagnostic, not an
// observed current diagnostic. Generic unsupported-declaration rejection
// cannot establish this rule; the paired legal control must execute too.
//! lrm 1.1
//! inherited IEEE 1364-2005 10.4.4
//! reject function body cannot contain a nonblocking assignment
//! neighbour function_return_variable.v
module audit_function_nonblocking_rejected;
  function f(input a); begin f<=a; end endfunction
  reg r;
  initial r=f(1'b1);
endmodule
