# Advanced APB Timer IP Documentation

Based on [pulp-platform/apb_adv_timer](https://github.com/pulp-platform/apb_adv_timer), with the modifications described below.

---

## Table of Contents

1. [Overview](#overview)
2. [Changes from Original PULP IP](#changes-from-original-pulp-ip)
3. [Top-Level Interface](#top-level-interface)
4. [Parameters](#parameters)
5. [Register Map](#register-map)
6. [Features and Usage](#features-and-usage)
7. [Programming Guide](#programming-guide)
8. [SoC Integration Notes](#soc-integration-notes)

---

## Overview

The Advanced APB Timer is a configurable timer peripheral that provides:

- **One** 32-bit timer engine (default `TIMER_NBITS = 32`)
- 4 PWM/compare output channels (`ch_o[3:0]`)
- External signal input support (up to 32 signals, parameterized via `EXTSIG_NUM`)
- Multiple input-stage modes (level, edge, armed edge)
- Up/down and sawtooth counting modes
- Configurable prescaler
- 4 top-level event outputs (`events_o[3:0]`) with channel edge detection
- Direct counter output on the top module (`timer_counter_o`)
- Clock gating for power management

**Source Files:**
- Top-level module: `rtl/apb_adv_timer.sv`
- APB interface: `rtl/adv_timer_apb_if.sv`
- Timer core: `rtl/timer_module.sv`
- Clock gating: `rtl/pulp_clk_cells.sv`, `rtl/tc_clk.sv`

---

## Changes from Original PULP IP

| Item | Original PULP IP | This RTL |
|------|------------------|----------|
| Timers | 4 independent timers | 1 timer |
| Counter width | 16-bit | 32-bit default (`TIMER_NBITS` parameter) |
| Channel outputs | `ch_0_o` … `ch_3_o` (4×4 bits) | `ch_o[3:0]` (single timer, 4 channels) |
| Counter visibility | APB read only | APB read + `timer_counter_o` port |
| Input signal bus | `EXTSIG_NUM + 16` sources | `EXTSIG_NUM + 4` sources |
| Clock enable | 4 bits in `REG_CH_EN` | 1 bit (`REG_CH_EN[0]`) |
| 32-bit thresholds | Single 16-bit register pair | Low/high register pairs + `*_TH_HI` extension regs |
| Event source bus | 16 channel bits from 4 timers | 4 channel bits from `ch_o` |

---

## Top-Level Interface

### Module Declaration

**File:** `rtl/apb_adv_timer.sv`

```systemverilog
module apb_adv_timer #(
  parameter APB_ADDR_WIDTH = 12,
  parameter EXTSIG_NUM     = 32,
  parameter TIMER_NBITS    = 32
) (
  // APB Interface
  input  logic                      HCLK,
  input  logic                      HRESETn,
  input  logic [APB_ADDR_WIDTH-1:0] PADDR,
  input  logic               [31:0] PWDATA,
  input  logic                      PWRITE,
  input  logic                      PSEL,
  input  logic                      PENABLE,
  output logic               [31:0] PRDATA,
  output logic                      PREADY,
  output logic                      PSLVERR,

  // Additional Inputs
  input  logic                      dft_cg_enable_i,
  input  logic                      low_speed_clk_i,
  input  logic     [EXTSIG_NUM-1:0] ext_sig_i,

  // Outputs
  output logic                [3:0] events_o,
  output logic                [3:0] ch_o,
  output logic [TIMER_NBITS-1:0]    timer_counter_o
);
```

### Signal Descriptions

#### APB Interface Signals

| Signal | Direction | Width | Description |
|--------|-----------|-------|-------------|
| `HCLK` | Input | 1 | APB bus clock |
| `HRESETn` | Input | 1 | Active-low asynchronous reset |
| `PADDR` | Input | `APB_ADDR_WIDTH` | APB address; bits `[9:2]` used for register decode |
| `PWDATA` | Input | 32 | APB write data |
| `PWRITE` | Input | 1 | 1 = write, 0 = read |
| `PSEL` | Input | 1 | APB peripheral select |
| `PENABLE` | Input | 1 | APB enable (second phase) |
| `PRDATA` | Output | 32 | APB read data |
| `PREADY` | Output | 1 | Always `1` (no wait states) |
| `PSLVERR` | Output | 1 | Always `0` (no slave errors) |

#### Additional Input Signals

| Signal | Direction | Width | Description |
|--------|-----------|-------|-------------|
| `dft_cg_enable_i` | Input | 1 | DFT scan enable; forces clock gate open during scan |
| `low_speed_clk_i` | Input | 1 | Slow clock for input-stage synchronization when `in_clk=1` |
| `ext_sig_i` | Input | `EXTSIG_NUM` | External input signal bus (default 32 bits) |

#### Output Signals

| Signal | Direction | Width | Description |
|--------|-----------|-------|-------------|
| `events_o` | Output | 4 | Rising-edge-detected events from selected `ch_o` bits |
| `ch_o` | Output | 4 | PWM/compare channel outputs (channels 0–3) |
| `timer_counter_o` | Output | `TIMER_NBITS` | Live counter value (same as internal counter) |

### Signal Routing

**Input signal bus** (`rtl/apb_adv_timer.sv`):

```systemverilog
localparam N_TIMEREXTSIG = EXTSIG_NUM + 4;
assign s_timer0_signal = {ch_o, ext_sig_i};
```

| `in_sel` value | Source |
|----------------|--------|
| `0` … `EXTSIG_NUM-1` | `ext_sig_i[in_sel]` |
| `EXTSIG_NUM` … `EXTSIG_NUM+3` | `ch_o[in_sel - EXTSIG_NUM]` (self-feedback) |

Example with `EXTSIG_NUM = 32`:
- `in_sel = 0..31` → external pins
- `in_sel = 32..35` → `ch_o[0..3]`

### Event vs Input-Stage Signal (Verification Note)

Two different "event" concepts exist in this design:

| Signal | Location | Meaning |
|--------|----------|---------|
| Input-stage event | `input_stage.event_o` (internal) | Result of `in_mode` on selected input (`s_int_sig`) |
| Top-level `events_o` | `apb_adv_timer` port | Rising-edge detect on selected `ch_o` bit |

`in_mode` in `REG_TIM0_CFG[10:8]` controls the **input-stage** event only.  
Do **not** use `events_o` to verify `in_mode` behavior.

---

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `APB_ADDR_WIDTH` | 12 | APB address bus width (4 KB space) |
| `EXTSIG_NUM` | 32 | Number of external input signals |
| `TIMER_NBITS` | 32 | Counter and threshold width. When set to 16, `*_TH_HI` registers are ignored |

---

## Register Map

### Address Decoding

**File:** `rtl/adv_timer_apb_if.sv`

```systemverilog
assign s_apb_addr = PADDR[9:2];
```

Address bits `[1:0]` are ignored (word-aligned APB access).

### Address Layout

| Region | Address Range | Description |
|--------|---------------|-------------|
| Timer registers | `0x000` – `0x02F` | Command, config, thresholds, channels, counter |
| Global registers | `0x100` – `0x104` | Event config, clock enable |
| 32-bit extension | `0x200` – `0x210` | Upper 16 bits of thresholds (used when `TIMER_NBITS > 16`) |

### Timer Registers

| Register | Offset | Access | Description |
|----------|--------|--------|-------------|
| `REG_TIM0_CMD` | `0x000` | W | Command register (self-clearing) |
| `REG_TIM0_CFG` | `0x004` | R/W | Input selection, mode, prescaler, sawtooth |
| `REG_TIM0_TH` | `0x008` | R/W | Period start/end, bits `[15:0]` of each |
| `REG_TIM0_CH0_TH` | `0x00C` | R/W | Channel 0 compare value (low 16b) and mode |
| `REG_TIM0_CH1_TH` | `0x010` | R/W | Channel 1 compare value (low 16b) and mode |
| `REG_TIM0_CH2_TH` | `0x014` | R/W | Channel 2 compare value (low 16b) and mode |
| `REG_TIM0_CH3_TH` | `0x018` | R/W | Channel 3 compare value (low 16b) and mode |
| `REG_TIM0_CH0_LUT` | `0x01C` | R/W | Channel 0 LUT and filter (LUT not wired) |
| `REG_TIM0_CH1_LUT` | `0x020` | R/W | Channel 1 LUT and filter |
| `REG_TIM0_CH2_LUT` | `0x024` | R/W | Channel 2 LUT and filter |
| `REG_TIM0_CH3_LUT` | `0x028` | R/W | Channel 3 LUT and filter |
| `REG_TIM0_COUNTER` | `0x02C` | R | Current counter value (read-only) |

### Global Registers

| Register | Offset | Access | Description |
|----------|--------|--------|-------------|
| `REG_EVENT_CFG` | `0x100` | R/W | Event source selection and enable |
| `REG_CH_EN` | `0x104` | R/W | Timer clock enable (`[0]` only) |

### 32-Bit Extension Registers

Required when `TIMER_NBITS = 32`. When `TIMER_NBITS = 16`, these may be written but are ignored.

| Register | Offset | Description |
|----------|--------|-------------|
| `REG_TIM0_TH_HI` | `0x200` | `[15:0]` = start `[31:16]`, `[31:16]` = end `[31:16]` |
| `REG_TIM0_CH0_TH_HI` | `0x204` | Channel 0 compare `[31:16]` |
| `REG_TIM0_CH1_TH_HI` | `0x208` | Channel 1 compare `[31:16]` |
| `REG_TIM0_CH2_TH_HI` | `0x20C` | Channel 2 compare `[31:16]` |
| `REG_TIM0_CH3_TH_HI` | `0x210` | Channel 3 compare `[31:16]` |

### Register Bit Fields

#### REG_TIM0_CMD (Command Register)

| Bits | Field | Access | Description |
|------|-------|--------|-------------|
| [0] | `start` | W | Start timer (auto-clears) |
| [1] | `stop` | W | Stop timer (auto-clears) |
| [2] | `update` | W | Apply pending config (auto-clears) |
| [3] | `rst` | W | Reset timer (auto-clears) |
| [4] | `arm` | W | Arm timer for armed input modes (auto-clears) |
| [31:5] | Reserved | — | Write 0 |

#### REG_TIM0_CFG (Configuration Register)

| Bits | Field | Access | Description |
|------|-------|--------|-------------|
| [7:0] | `in_sel` | R/W | Input signal selection (see Signal Routing) |
| [10:8] | `in_mode` | R/W | Input-stage mode (see Input Modes) |
| [11] | `in_clk` | R/W | When set, input events gated by `low_speed_clk_i` |
| [12] | `saw` | R/W | 0 = up/down, 1 = sawtooth |
| [15:13] | Reserved | — | — |
| [23:16] | `presc` | R/W | Prescaler (0 = no prescaling) |
| [31:24] | Reserved | — | — |

#### REG_TIM0_TH / REG_TIM0_TH_HI (Period Thresholds)

For a 32-bit counter, write both registers:

| Register | Bits | Field |
|----------|------|-------|
| `REG_TIM0_TH` | [15:0] | `period_start[15:0]` |
| `REG_TIM0_TH` | [31:16] | `period_end[15:0]` |
| `REG_TIM0_TH_HI` | [15:0] | `period_start[31:16]` |
| `REG_TIM0_TH_HI` | [31:16] | `period_end[31:16]` |

Full values: `period_start = {TH_HI[15:0], TH[15:0]}`, `period_end = {TH_HI[31:16], TH[31:16]}`.

#### REG_TIM0_CHx_TH / REG_TIM0_CHx_TH_HI (Channel Thresholds)

| Register | Bits | Field |
|----------|------|-------|
| `REG_TIM0_CHx_TH` | [15:0] | Compare value `[15:0]` |
| `REG_TIM0_CHx_TH` | [18:16] | Comparator mode |
| `REG_TIM0_CHx_TH_HI` | [15:0] | Compare value `[31:16]` |

#### REG_TIM0_COUNTER

| Bits | Field | Access | Description |
|------|-------|--------|-------------|
| [TIMER_NBITS-1:0] | `counter` | R | Current counter value |
| [31:TIMER_NBITS] | — | R | Reads as 0 |

Counter can also be read from the `timer_counter_o` port without an APB transaction.

#### REG_EVENT_CFG

| Bits | Field | Access | Description |
|------|-------|--------|-------------|
| [3:0] | `event_sel_0` | R/W | Source for `events_o[0]` (selects `ch_o[3:0]`) |
| [7:4] | `event_sel_1` | R/W | Source for `events_o[1]` |
| [11:8] | `event_sel_2` | R/W | Source for `events_o[2]` |
| [15:12] | `event_sel_3` | R/W | Source for `events_o[3]` |
| [19:16] | `event_en` | R/W | Enable bits for events 0–3 |
| [31:20] | Reserved | — | — |

**Event signal mapping** (`rtl/apb_adv_timer.sv`):

```systemverilog
assign s_event_signals = ch_o;
```

Valid `event_sel_N` values: `0`–`3` (lower 2 bits used).

#### REG_CH_EN

| Bits | Field | Access | Description |
|------|-------|--------|-------------|
| [0] | `timer0_clk_en` | R/W | Enable timer clock gating |
| [31:1] | Reserved | — | Write 0 |

---

## Features and Usage

### 1. Timer Control

**File:** `rtl/timer_cntrl.sv`

| Command | Description |
|---------|-------------|
| `start` | Activate timer and begin counting |
| `stop` | Deactivate timer |
| `update` | Apply configuration changes |
| `rst` | Reset counter and control state |
| `arm` | Arm for armed input modes (modes 6 and 7) |

All command bits are one-cycle strobes (self-clearing).

### 2. Input Stage and External Signals

**File:** `rtl/input_stage.sv`

#### Input Modes (`REG_TIM0_CFG[10:8]`)

| Mode | Value | Input-stage event behavior |
|------|-------|---------------------------|
| Always | `3'b000` | Always `1` |
| Inverted | `3'b001` | `~s_int_sig` |
| Direct | `3'b010` | `s_int_sig` |
| Rising Edge | `3'b011` | Pulse on rising edge |
| Falling Edge | `3'b100` | Pulse on falling edge |
| Both Edges | `3'b101` | Pulse on any edge |
| Armed Rising | `3'b110` | Armed; latch on rising edge |
| Armed Falling | `3'b111` | Armed; latch on falling edge |

When `in_clk = 1`, events are additionally gated by rising edges of `low_speed_clk_i`.

### 3. Prescaler

**File:** `rtl/prescaler.sv`

- `presc = 0`: input-stage events pass through every cycle
- `presc > 0`: output one event every `(presc + 1)` input events

### 4. Counter Modes

**File:** `rtl/up_down_counter.sv`

| `saw` | Mode | Behavior |
|-------|------|----------|
| 1 | Sawtooth | Count `start` → `end`, wrap to `start` |
| 0 | Up/Down | Count up to `end`, then down to `start`, repeat |

### 5. Comparator Operations

**File:** `rtl/comparator.sv`

| Mode | Value | Description |
|------|-------|-------------|
| SET | `3'b000` | Set output on match |
| TOGRST | `3'b001` | Toggle on 1st match, reset on 2nd |
| SETRST | `3'b010` | Set on 1st match, reset on 2nd |
| TOG | `3'b011` | Toggle on each match |
| RST | `3'b100` | Reset on match |
| TOGSET | `3'b101` | Toggle on 1st match, set on 2nd |
| RSTSET | `3'b110` | Reset on 1st match, set on 2nd |

### 6. Output Filter and LUT

**Files:** `rtl/out_filter.sv`, `rtl/lut_4x4.sv`

Both modules exist but are **not instantiated**. LUT and filter register values are stored but not used in the signal path.

### 7. Top-Level Event Generation

**File:** `rtl/apb_adv_timer.sv`

```systemverilog
assign events_o[0] = s_event_en[0] & r_event_sync_0[1] & ~r_event_sync_0[0];
```

`events_o[N]` asserts for one `HCLK` cycle on the rising edge of the selected `ch_o` bit when event `N` is enabled.

---

## Programming Guide

### Basic Setup Sequence

1. Write `REG_TIM0_CFG` — input selection, mode, prescaler, sawtooth
2. Write `REG_TIM0_TH` (+ `REG_TIM0_TH_HI` if 32-bit)
3. Write `REG_TIM0_CHx_TH` (+ `REG_TIM0_CHx_TH_HI` if 32-bit)
4. Write `REG_CH_EN = 0x1` — enable timer clock
5. Write `REG_TIM0_CMD = 0x1` — start

### Example: 50% PWM on Channel 0 (32-bit)

```
Write REG_TIM0_CFG    = 0x00001000   // in_mode=0, saw=1, presc=0
Write REG_TIM0_TH     = 0xFFFF0000   // end[15:0]=0xFFFF, start[15:0]=0x0000
Write REG_TIM0_TH_HI  = 0x00000000   // upper halves = 0
Write REG_TIM0_CH0_TH = 0x00008000   // ch_th[15:0]=0x8000, ch_mode=SET
Write REG_TIM0_CH0_TH_HI = 0x00000000
Write REG_CH_EN       = 0x00000001
Write REG_TIM0_CMD    = 0x00000001   // start
```

Result: `ch_o[0]` is high when counter < `0x8000`, low otherwise.

### Example: External Signal Triggered Counting

Count on rising edge of `ext_sig_i[5]`:

```
Write REG_TIM0_CFG = 0x00000503   // in_sel=5, in_mode=3 (rising), saw=1
Write REG_TIM0_TH  = 0xFFFF0000
Write REG_CH_EN    = 0x00000001
Write REG_TIM0_CMD = 0x00000001
```

### Example: Top-Level Event on Channel 0

```
Write REG_EVENT_CFG = 0x00010000   // event_sel_0=0, event_en[0]=1
```

Monitor `events_o[0]` for rising edges on `ch_o[0]`.

### Reading the Counter

Two options:

```
Read REG_TIM0_COUNTER          // APB access
Monitor timer_counter_o        // direct port (no bus transaction)
```

### Stop / Reset / Update

```
Write REG_TIM0_CMD = 0x00000002   // stop
Write REG_TIM0_CMD = 0x00000008   // reset
Write REG_TIM0_CMD = 0x00000004   // update config
```

---

## SoC Integration Notes

### Clock Domains

| Domain | Signals | Notes |
|--------|---------|-------|
| HCLK | APB, `events_o`, register logic | Main bus clock |
| Gated timer clock | `s_clk_timer0` | Derived from HCLK via `pulp_clock_gating` |
| Low-speed | `low_speed_clk_i` | Only active when `in_clk = 1` |

### Clock Gating

Controlled by `REG_CH_EN[0]`. When cleared, timer logic receives no clock (power saving).  
`dft_cg_enable_i` forces the gate open during scan test.

### Reset

All registers reset asynchronously on `HRESETn` deassertion. Default: timer stopped, registers zero.

### APB Requirements

- Address space used: `0x000` – `0x210` (minimum); standard 4 KB with `APB_ADDR_WIDTH = 12`
- `PREADY = 1`, `PSLVERR = 0` always
- Word-aligned access required

### Interrupts

No dedicated interrupt output. Monitor `events_o[3:0]` and connect to an external interrupt controller.

### Dependencies

**File:** `Bender.yml`

- `tech_cells_generic` (provides `pulp_clock_gating` via `pulp_clk_cells.sv`)
- Local support files: `rtl/tc_clk.sv`, `rtl/pulp_clk_cells.sv`

### Verification Considerations

1. **`in_mode` verification** — probe `input_stage.event_o` (internal) or use hierarchical access / bind. Do not compare against `events_o`.
2. **`events_o` verification** — configure `REG_EVENT_CFG`, drive counter/channel activity, check rising-edge pulses on `events_o`.
3. **32-bit thresholds** — write both low (`REG_TIM0_TH`) and high (`REG_TIM0_TH_HI`) register pairs.
4. **Command bits** — all auto-clear after one cycle; do not expect them to remain set.
5. **Counter** — readable via APB or `timer_counter_o` port.

**Testbench:** `tb/tb_input_stage_mode001.sv` — focused check of mode `001` inversion in `input_stage`.

---

## Appendix: Module Index

| Module | File |
|--------|------|
| Top-level | `rtl/apb_adv_timer.sv` |
| APB interface | `rtl/adv_timer_apb_if.sv` |
| Timer engine | `rtl/timer_module.sv` |
| Timer controller | `rtl/timer_cntrl.sv` |
| Input stage | `rtl/input_stage.sv` |
| Prescaler | `rtl/prescaler.sv` |
| Counter | `rtl/up_down_counter.sv` |
| Comparator | `rtl/comparator.sv` |
| Clock gating | `rtl/pulp_clk_cells.sv`, `rtl/tc_clk.sv` |

---

**End of Documentation**
