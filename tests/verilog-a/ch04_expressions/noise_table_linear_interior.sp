* LRM 4.6.4.3 noise_table: piecewise-linear PSD at tabulated and interior points
* Expected results: noise_table_linear_interior.expected.json
.hdl "noise_table_resistor_device.va"
.hdl "noise_table_linear_device.va"
Vin in 0 DC 0 AC 1
Ns in out a06_noiseless_res
Nt out 0 a06_ntab_lin
.noise v(out) Vin lin 9 1000 9000
.end
