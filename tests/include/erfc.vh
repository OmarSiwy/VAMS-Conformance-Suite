// erfc(x) as a portable Verilog-A analog function. `include it INSIDE a module
// body (an analog function is a module item, §4.7.1).
//
// Why a function and not a builtin: the LRM's mathematical functions are
// Table 4-14 (standard) and Table 4-15 (trigonometric and hyperbolic), and
// neither lists erf or erfc; §4.3 names no other source of built-ins. A model
// that needs erfc therefore defines it, and this one needs nothing but §4.3's
// exp() and Annex D.2's `M_2_SQRTPI.
//
// |x| < 1.5: erfc = 1 - erf, erf(a) = 2/sqrt(pi) exp(-a^2) sum 2^n a^(2n+1) /
//            (1*3*...*(2n+1)) — every term positive, so the sum cancels nothing.
// |x| >= 1.5: the continued fraction erfc(a) = exp(-a^2)/sqrt(pi) /
//            (a + (1/2)/(a + 1/(a + (3/2)/(a + ...)))), evaluated backwards
//            from 60 terms.
// x < 0:     erfc(x) = 2 - erfc(-x).
//
// Measured against libm erfc on x = -6..6 in steps of 1e-3: relative error at
// most 1.9e-13 (at the 1.5 split). Beyond |x| ~ 6 the rounding of a*a inside
// exp() dominates, as it does for any erfc not built on a split-exponent exp.
// Not bit-matching libm: portable Verilog-A has no way to be.
analog function real erfc;
  input x;
  real x;
  real a, s, term, f;
  integer n;
  begin
    a = (x < 0.0) ? -x : x;
    if (a < 1.5) begin
      term = a;
      s = a;
      for (n = 1; n < 60; n = n + 1) begin
        term = term * 2.0 * a * a / (2 * n + 1);
        s = s + term;
      end
      erfc = 1.0 - `M_2_SQRTPI * exp(-a * a) * s;
    end else begin
      f = a;
      for (n = 60; n > 0; n = n - 1)
        f = a + (n / 2.0) / f;
      erfc = 0.5 * `M_2_SQRTPI * exp(-a * a) / f;
    end
    if (x < 0.0)
      erfc = 2.0 - erfc;
  end
endfunction
