* LRM 4.6.4.4 noise_table_log: log-log interpolation, not linear, between knots
* Expected results: noise_table_log_interior.expected.json
.hdl "noise_table_resistor_device.va"
.hdl "noise_table_log_device.va"
Vin in 0 DC 0 AC 1
Ns in out a06_noiseless_res
Nt out 0 a06_ntab_log
.noise v(out) Vin lin 3 1000 3000
.end
