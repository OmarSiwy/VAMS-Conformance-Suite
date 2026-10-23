* LRM 9.17.2 $bound_step: the clause's own vsine example, forcing 20 points
* per cycle. A 1 kHz sine into a purely resistive 1k load, so nothing except
* $bound_step(0.05/freq) = 5e-5 s keeps the accepted grid fine enough to
* resolve the waveform. Sampled at the two quarter-cycle extremes.
* Expected results: bound_step.expected.json
.hdl "spice_sine_source.va"
Nsrc src 0 a10_vsine
Rload src 0 1k
.tran 1e-3 1e-2
.end
