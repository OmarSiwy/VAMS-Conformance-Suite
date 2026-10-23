* LRM 5.10.3.3 timer(): the simulator PLACES a time point at the event
* Two single-shot timers at 2.5e-4 s and 6.25e-4 s, neither on the .tran
* printstep grid (0, 1e-4, 2e-4, ...). Each must appear as an accepted time
* point carrying the post-event staircase level.
* Expected results: timer_breakpoints.expected.json
.hdl "spice_timer_steps_device.va"
Nstep out 0 a10_timer_steps
Rload out 0 1k
.tran 1e-4 1e-3
.end
