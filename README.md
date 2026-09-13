# Word-4 AXI-Stream Pipeline

10-word AXI4-Stream collector. MATLAB `buf(4)` is the payload.
Enabled-subsystem accelerator (passthrough). Separate pass counter.
Final beat: TDATA[15:0] = word4, TDATA[31:16] = count.
Latency budget: 100 µs (clock 10 ns / 100 MHz — not the sample time).

## MATLAB

```matlab
testbench_data_collector



# Word-4 AXI-Stream Pipeline

MATLAB / HDL Coder design that collects a **10-word AXI4-Stream packet**, takes **word 4** (`buf(4)`, MATLAB 1-based), sends it through an **enabled passthrough accelerator**, counts how many packets passed, and emits one output beat:

| Field | Bits |
| --- | --- |
| word 4 | `TDATA[15:0]` |
| pass count | `TDATA[31:16]` |

Latency budget: **100 µs** at 100 MHz (`Ts = 10 ns`). That budget is wall-clock time, not the Simulink sample time.

Input is an AXI4-Stream **master** (testbench / upstream). The DUT input port is mapped as AXI4-Stream **Slave**. The DUT output port is mapped as AXI4-Stream **Master**, consumed by a downstream **slave**.

## Block path


## Files

| File | Role |
| --- | --- |
| `data_collector.m` | Buffer 10 beats. On the 10th valid beat emit `buf(4)` and `vec_valid`. |
| `accelerator_passthrough.m` | Models the Enabled Subsystem. Data updates only on enable. Valid is a **one-cycle pulse**. |
| `pass_counter.m` | Separate block. Increments when a vector is allowed through. |
| `final_counter.m` | Packs `{count[15:0], word4[15:0]}` onto `data_out` / `valid_out`. |
| `Testbench_data_collec.m` | MATLAB scoreboard. |
| `tb_word_pipeline.sv` | SystemVerilog AXI-Stream BFM + backpressure stall. |

## Run the MATLAB testbench

Put every `.m` file on the MATLAB path, then:

```matlab
Testbench_data_collec

``` visit - https://baker-sage-pixel-raven.grok.me/ to simulate the model ```
