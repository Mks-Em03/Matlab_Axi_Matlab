# Word-4 AXI-Stream Pipeline

10-word AXI4-Stream collector. MATLAB `buf(4)` is the payload.
Enabled-subsystem accelerator (passthrough). Separate pass counter.
Final beat: TDATA[15:0] = word4, TDATA[31:16] = count.
Latency budget: 100 µs (clock 10 ns / 100 MHz — not the sample time).

## MATLAB

```matlab
testbench_data_collector