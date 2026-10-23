* LRM 5.10.3.1 cross(): the simulator controls the timestep to resolve the
* crossing to time_tol. A 1 V/ms ramp crosses the 0.5 V threshold at exactly
* t = 5e-4 s, which is not on this deck's grid; with time_tol = 1 us the
* latched output must still be low at 4.99e-4 and high by 5.02e-4.
* Expected results: cross_timestep.expected.json
.hdl "spice_cross_latch_device.va"
Vin in 0 PWL(0 0 1m 1)
Nlatch in out a10_cross_latch
Rload out 0 1k
.tran 1e-4 1e-3
.end
