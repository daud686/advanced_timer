// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

//
// CHANGES vs original rtl_legacy:
//
//  [1] Removed timer1/2/3 — only timer0 remains.
//      All timer1_*, timer2_*, timer3_* ports and registers deleted.
//
//  [2] Added TIMER_NBITS parameter (default 32).
//      All threshold and compare outputs widened to [TIMER_NBITS-1:0].
//      Counter input widened to [TIMER_NBITS-1:0].
//
//  [3] Added REG_TIM0_TH_HI and REG_TIM0_CHx_TH_HI registers (0x200–0x210).
//      These hold the upper 16 bits of each 32-bit threshold/compare value.
//      When TIMER_NBITS=16 these registers are written but ignored (merge_word16
//      returns only the low 16 bits), so the design stays backward-compatible.
//
//  [4] Removed timer1_clk_en_o / timer2_clk_en_o / timer3_clk_en_o ports.
//      Only timer0_clk_en_o remains.
//
//  [5] Counter read (REG_TIM0_COUNTER) now returns full TIMER_NBITS value
//      zero-extended to 32 bits.  For 32-bit timer this fills the whole word.
//

//  Register map (byte address = APB word index << 2):
//
//  0x000  REG_TIM0_CMD     [4]=arm [3]=rst [2]=update [1]=stop [0]=start  (W only)
//  0x004  REG_TIM0_CFG     [23:16]=prescaler [12]=sawtooth [11]=in_clk
//                          [10:8]=mode [7:0]=in_sel
//  0x008  REG_TIM0_TH      [31:16]=period_end[15:0]  [15:0]=period_start[15:0]
//  0x00C  REG_TIM0_CH0_TH  [18:16]=comp_op [15:0]=compare_val[15:0]
//  0x010  REG_TIM0_CH1_TH
//  0x014  REG_TIM0_CH2_TH
//  0x018  REG_TIM0_CH3_TH
//  0x01C  REG_TIM0_CH0_LUT [17:16]=filter_mode [15:0]=LUT (LUT not wired to HW)
//  0x020  REG_TIM0_CH1_LUT
//  0x024  REG_TIM0_CH2_LUT
//  0x028  REG_TIM0_CH3_LUT
//  0x02C  REG_TIM0_COUNTER (R only) — current counter value
//  0x100  REG_EVENT_CFG    [19:16]=event_en [15:12]=sel3 [11:8]=sel2 [7:4]=sel1 [3:0]=sel0
//  0x104  REG_CH_EN        [0]=timer0_clk_en
//
//  --- 32-bit extension registers (new) ---
//  0x200  REG_TIM0_TH_HI      [31:16]=period_end[31:16] [15:0]=period_start[31:16]
//  0x204  REG_TIM0_CH0_TH_HI  [15:0]=compare_val[31:16]
//  0x208  REG_TIM0_CH1_TH_HI
//  0x20C  REG_TIM0_CH2_TH_HI
//  0x210  REG_TIM0_CH3_TH_HI

`define REG_TIM0_CMD       8'b00000000  // BASEADDR+0x000
`define REG_TIM0_CFG       8'b00000001  // BASEADDR+0x004
`define REG_TIM0_TH        8'b00000010  // BASEADDR+0x008
`define REG_TIM0_CH0_TH    8'b00000011  // BASEADDR+0x00C
`define REG_TIM0_CH1_TH    8'b00000100  // BASEADDR+0x010
`define REG_TIM0_CH2_TH    8'b00000101  // BASEADDR+0x014
`define REG_TIM0_CH3_TH    8'b00000110  // BASEADDR+0x018
`define REG_TIM0_CH0_LUT   8'b00000111  // BASEADDR+0x01C
`define REG_TIM0_CH1_LUT   8'b00001000  // BASEADDR+0x020
`define REG_TIM0_CH2_LUT   8'b00001001  // BASEADDR+0x024
`define REG_TIM0_CH3_LUT   8'b00001010  // BASEADDR+0x028
`define REG_TIM0_COUNTER   8'b00001011  // BASEADDR+0x02C  (read-only)
`define REG_EVENT_CFG      8'b01000000  // BASEADDR+0x100
`define REG_CH_EN          8'b01000001  // BASEADDR+0x104
// 32-bit extension registers
`define REG_TIM0_TH_HI     8'b10000000  // BASEADDR+0x200
`define REG_TIM0_CH0_TH_HI 8'b10000001  // BASEADDR+0x204
`define REG_TIM0_CH1_TH_HI 8'b10000010  // BASEADDR+0x208
`define REG_TIM0_CH2_TH_HI 8'b10000011  // BASEADDR+0x20C
`define REG_TIM0_CH3_TH_HI 8'b10000100  // BASEADDR+0x210

module adv_timer_apb_if #(
  parameter APB_ADDR_WIDTH = 12,
  parameter TIMER_NBITS    = 32  // [2] parameterized; was implicitly 16
) (
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

  output logic               [3:0]  events_en_o,
  output logic               [3:0]  events_sel_0_o,
  output logic               [3:0]  events_sel_1_o,
  output logic               [3:0]  events_sel_2_o,
  output logic               [3:0]  events_sel_3_o,

  // [1] removed timer1_counter_i / timer2_counter_i / timer3_counter_i
  // [2] widened to TIMER_NBITS
  input  logic [TIMER_NBITS-1:0]    timer0_counter_i,

  output logic                      timer0_start_o,
  output logic                      timer0_stop_o,
  output logic                      timer0_update_o,
  output logic                      timer0_arm_o,
  output logic                      timer0_rst_o,
  output logic                      timer0_saw_o,
  output logic                [2:0] timer0_in_mode_o,
  output logic                [7:0] timer0_in_sel_o,
  output logic                      timer0_in_clk_o,
  output logic                [7:0] timer0_presc_o,
  // [2] thresholds widened to TIMER_NBITS
  output logic [TIMER_NBITS-1:0]    timer0_th_hi_o,
  output logic [TIMER_NBITS-1:0]    timer0_th_low_o,
  output logic                [2:0] timer0_ch0_mode_o,
  output logic                [1:0] timer0_ch0_flt_o,
  output logic [TIMER_NBITS-1:0]    timer0_ch0_th_o,
  output logic               [15:0] timer0_ch0_lut_o,
  output logic                [2:0] timer0_ch1_mode_o,
  output logic                [1:0] timer0_ch1_flt_o,
  output logic [TIMER_NBITS-1:0]    timer0_ch1_th_o,
  output logic               [15:0] timer0_ch1_lut_o,
  output logic                [2:0] timer0_ch2_mode_o,
  output logic                [1:0] timer0_ch2_flt_o,
  output logic [TIMER_NBITS-1:0]    timer0_ch2_th_o,
  output logic               [15:0] timer0_ch2_lut_o,
  output logic                [2:0] timer0_ch3_mode_o,
  output logic                [1:0] timer0_ch3_flt_o,
  output logic [TIMER_NBITS-1:0]    timer0_ch3_th_o,
  output logic               [15:0] timer0_ch3_lut_o,

  // [1][4] removed timer1_clk_en_o / timer2_clk_en_o / timer3_clk_en_o
  output logic                      timer0_clk_en_o
);

  // ------------------------------------------------------------------
  // Internal registers
  // ------------------------------------------------------------------

  // [3] r_timer0_th holds [31:16]=period_end[15:0], [15:0]=period_start[15:0]
  //     r_timer0_th_hi holds upper halves for 32-bit counters
  logic [31:0] r_timer0_th;
  logic [31:0] r_timer0_th_hi;      // [3] new: upper 16b of start (in [15:0]) and end (in [31:16])

  logic  [7:0] r_timer0_presc;
  logic  [7:0] r_timer0_in_sel;
  logic        r_timer0_in_clk;
  logic  [2:0] r_timer0_in_mode;
  logic        r_timer0_start;
  logic        r_timer0_stop;
  logic        r_timer0_update;
  logic        r_timer0_arm;
  logic        r_timer0_rst;
  logic        r_timer0_saw;

  logic [15:0] r_timer0_ch0_th;
  logic [15:0] r_timer0_ch0_th_hi;  // [3] new
  logic  [2:0] r_timer0_ch0_mode;
  logic [15:0] r_timer0_ch0_lut;
  logic  [1:0] r_timer0_ch0_flt;

  logic [15:0] r_timer0_ch1_th;
  logic [15:0] r_timer0_ch1_th_hi;  // [3] new
  logic  [2:0] r_timer0_ch1_mode;
  logic [15:0] r_timer0_ch1_lut;
  logic  [1:0] r_timer0_ch1_flt;

  logic [15:0] r_timer0_ch2_th;
  logic [15:0] r_timer0_ch2_th_hi;  // [3] new
  logic  [2:0] r_timer0_ch2_mode;
  logic [15:0] r_timer0_ch2_lut;
  logic  [1:0] r_timer0_ch2_flt;

  logic [15:0] r_timer0_ch3_th;
  logic [15:0] r_timer0_ch3_th_hi;  // [3] new
  logic  [2:0] r_timer0_ch3_mode;
  logic [15:0] r_timer0_ch3_lut;
  logic  [1:0] r_timer0_ch3_flt;

  logic  [3:0] r_event_sel_0;
  logic  [3:0] r_event_sel_1;
  logic  [3:0] r_event_sel_2;
  logic  [3:0] r_event_sel_3;
  logic  [3:0] r_event_en;

  logic        r_clk_en;             // [1] was [3:0] for 4 timers, now 1 bit

  logic  [7:0] s_apb_addr;

  // ------------------------------------------------------------------
  // [3] merge_word16: assembles a TIMER_NBITS-wide value from two 16-bit
  // halves.  When TIMER_NBITS==16 the 'hi' half is simply ignored and we
  // return 'lo' unchanged, preserving 16-bit behaviour with no extra regs.
  // When TIMER_NBITS==32 the result is {hi[15:0], lo[15:0]}.
  // ------------------------------------------------------------------
  function automatic [TIMER_NBITS-1:0] merge_word16(
    input logic [15:0] hi,
    input logic [15:0] lo
  );
    if (TIMER_NBITS > 16)
      merge_word16 = {hi, lo};
    else
      merge_word16 = lo;
  endfunction

  // ------------------------------------------------------------------
  // Output assigns
  // ------------------------------------------------------------------

  assign events_en_o    = r_event_en;
  assign events_sel_0_o = r_event_sel_0;
  assign events_sel_1_o = r_event_sel_1;
  assign events_sel_2_o = r_event_sel_2;
  assign events_sel_3_o = r_event_sel_3;

  assign timer0_start_o    = r_timer0_start;
  assign timer0_stop_o     = r_timer0_stop;
  assign timer0_update_o   = r_timer0_update;
  assign timer0_rst_o      = r_timer0_rst;
  assign timer0_arm_o      = r_timer0_arm;
  assign timer0_saw_o      = r_timer0_saw;
  assign timer0_in_mode_o  = r_timer0_in_mode;
  assign timer0_in_sel_o   = r_timer0_in_sel;
  assign timer0_in_clk_o   = r_timer0_in_clk;
  assign timer0_presc_o    = r_timer0_presc;

  // [3] 32-bit threshold: {end_upper,end_lower} and {start_upper,start_lower}
  assign timer0_th_hi_o    = merge_word16(r_timer0_th_hi[31:16], r_timer0_th[31:16]);
  assign timer0_th_low_o   = merge_word16(r_timer0_th_hi[15:0],  r_timer0_th[15:0]);

  assign timer0_ch0_mode_o = r_timer0_ch0_mode;
  assign timer0_ch0_flt_o  = r_timer0_ch0_flt;
  assign timer0_ch0_th_o   = merge_word16(r_timer0_ch0_th_hi, r_timer0_ch0_th);
  assign timer0_ch0_lut_o  = r_timer0_ch0_lut;

  assign timer0_ch1_mode_o = r_timer0_ch1_mode;
  assign timer0_ch1_flt_o  = r_timer0_ch1_flt;
  assign timer0_ch1_th_o   = merge_word16(r_timer0_ch1_th_hi, r_timer0_ch1_th);
  assign timer0_ch1_lut_o  = r_timer0_ch1_lut;

  assign timer0_ch2_mode_o = r_timer0_ch2_mode;
  assign timer0_ch2_flt_o  = r_timer0_ch2_flt;
  assign timer0_ch2_th_o   = merge_word16(r_timer0_ch2_th_hi, r_timer0_ch2_th);
  assign timer0_ch2_lut_o  = r_timer0_ch2_lut;

  assign timer0_ch3_mode_o = r_timer0_ch3_mode;
  assign timer0_ch3_flt_o  = r_timer0_ch3_flt;
  assign timer0_ch3_th_o   = merge_word16(r_timer0_ch3_th_hi, r_timer0_ch3_th);
  assign timer0_ch3_lut_o  = r_timer0_ch3_lut;

  assign timer0_clk_en_o   = r_clk_en;

  assign s_apb_addr = PADDR[9:2];

  // ------------------------------------------------------------------
  // APB write
  // ------------------------------------------------------------------
  always_ff @(posedge HCLK or negedge HRESETn) begin
    if (~HRESETn) begin
      r_timer0_th       <= '0;
      r_timer0_th_hi    <= '0;
      r_timer0_presc    <= '0;
      r_timer0_in_sel   <= '0;
      r_timer0_in_clk   <= '0;
      r_timer0_in_mode  <= '0;
      r_timer0_saw      <= '0;
      r_timer0_ch0_th    <= '0;
      r_timer0_ch0_th_hi <= '0;
      r_timer0_ch0_mode  <= '0;
      r_timer0_ch0_lut   <= '0;
      r_timer0_ch0_flt   <= '0;
      r_timer0_ch1_th    <= '0;
      r_timer0_ch1_th_hi <= '0;
      r_timer0_ch1_mode  <= '0;
      r_timer0_ch1_lut   <= '0;
      r_timer0_ch1_flt   <= '0;
      r_timer0_ch2_th    <= '0;
      r_timer0_ch2_th_hi <= '0;
      r_timer0_ch2_mode  <= '0;
      r_timer0_ch2_lut   <= '0;
      r_timer0_ch2_flt   <= '0;
      r_timer0_ch3_th    <= '0;
      r_timer0_ch3_th_hi <= '0;
      r_timer0_ch3_mode  <= '0;
      r_timer0_ch3_lut   <= '0;
      r_timer0_ch3_flt   <= '0;
      r_event_sel_0     <= '0;
      r_event_sel_1     <= '0;
      r_event_sel_2     <= '0;
      r_event_sel_3     <= '0;
      r_event_en        <= '0;
      r_clk_en          <= '0;
    end else begin
      // Pulse outputs: self-clear each cycle so the timer engine sees a
      // one-cycle strobe rather than a held level.
      r_timer0_start  <= '0;
      r_timer0_stop   <= '0;
      r_timer0_update <= '0;
      r_timer0_rst    <= '0;
      r_timer0_arm    <= '0;

      if (PSEL && PENABLE && PWRITE) begin
        case (s_apb_addr)
          // ---- timer0 command (write-only, self-clearing) ----
          `REG_TIM0_CMD: begin
            r_timer0_start  <= PWDATA[0];
            r_timer0_stop   <= PWDATA[1];
            r_timer0_update <= PWDATA[2];
            r_timer0_rst    <= PWDATA[3];
            r_timer0_arm    <= PWDATA[4];
          end
          // ---- timer0 config ----
          `REG_TIM0_CFG: begin
            r_timer0_in_sel  <= PWDATA[7:0];
            r_timer0_in_mode <= PWDATA[10:8];
            r_timer0_in_clk  <= PWDATA[11];
            r_timer0_saw     <= PWDATA[12];
            r_timer0_presc   <= PWDATA[23:16];
          end
          // ---- period thresholds (low 16b) ----
          `REG_TIM0_TH:
            r_timer0_th <= PWDATA;
          // [3] period thresholds (high 16b, 32-bit extension)
          `REG_TIM0_TH_HI:
            r_timer0_th_hi <= PWDATA;
          // ---- channel 0 compare ----
          `REG_TIM0_CH0_TH: begin
            r_timer0_ch0_th   <= PWDATA[15:0];
            r_timer0_ch0_mode <= PWDATA[18:16];
          end
          `REG_TIM0_CH0_TH_HI:
            r_timer0_ch0_th_hi <= PWDATA[15:0];
          `REG_TIM0_CH0_LUT: begin
            r_timer0_ch0_lut <= PWDATA[15:0];
            r_timer0_ch0_flt <= PWDATA[17:16];
          end
          // ---- channel 1 compare ----
          `REG_TIM0_CH1_TH: begin
            r_timer0_ch1_th   <= PWDATA[15:0];
            r_timer0_ch1_mode <= PWDATA[18:16];
          end
          `REG_TIM0_CH1_TH_HI:
            r_timer0_ch1_th_hi <= PWDATA[15:0];
          `REG_TIM0_CH1_LUT: begin
            r_timer0_ch1_lut <= PWDATA[15:0];
            r_timer0_ch1_flt <= PWDATA[17:16];
          end
          // ---- channel 2 compare ----
          `REG_TIM0_CH2_TH: begin
            r_timer0_ch2_th   <= PWDATA[15:0];
            r_timer0_ch2_mode <= PWDATA[18:16];
          end
          `REG_TIM0_CH2_TH_HI:
            r_timer0_ch2_th_hi <= PWDATA[15:0];
          `REG_TIM0_CH2_LUT: begin
            r_timer0_ch2_lut <= PWDATA[15:0];
            r_timer0_ch2_flt <= PWDATA[17:16];
          end
          // ---- channel 3 compare ----
          `REG_TIM0_CH3_TH: begin
            r_timer0_ch3_th   <= PWDATA[15:0];
            r_timer0_ch3_mode <= PWDATA[18:16];
          end
          `REG_TIM0_CH3_TH_HI:
            r_timer0_ch3_th_hi <= PWDATA[15:0];
          `REG_TIM0_CH3_LUT: begin
            r_timer0_ch3_lut <= PWDATA[15:0];
            r_timer0_ch3_flt <= PWDATA[17:16];
          end
          // ---- event and clock-enable config ----
          `REG_EVENT_CFG: begin
            r_event_sel_0 <= PWDATA[3:0];
            r_event_sel_1 <= PWDATA[7:4];
            r_event_sel_2 <= PWDATA[11:8];
            r_event_sel_3 <= PWDATA[15:12];
            r_event_en    <= PWDATA[19:16];
          end
          `REG_CH_EN:
            r_clk_en <= PWDATA[0];  // [4] single bit for one timer
          default: ;
        endcase
      end
    end
  end

  // ------------------------------------------------------------------
  // APB read
  // ------------------------------------------------------------------
  always_comb begin
    PRDATA = '0;
    if (PSEL && PENABLE && !PWRITE) begin
      case (s_apb_addr)
        `REG_TIM0_TH:        PRDATA = r_timer0_th;
        `REG_TIM0_TH_HI:     PRDATA = r_timer0_th_hi;
        // [FIX] Use 3'h0 padding (not 4'h0) to match PULP bit map and PWDATA write decode
        `REG_TIM0_CFG:       PRDATA = {8'h0, r_timer0_presc, 3'h0, r_timer0_saw,
                                        r_timer0_in_clk, r_timer0_in_mode, r_timer0_in_sel};
        `REG_TIM0_CH0_TH:    PRDATA = {13'h0, r_timer0_ch0_mode, r_timer0_ch0_th};
        `REG_TIM0_CH0_TH_HI: PRDATA = {16'h0, r_timer0_ch0_th_hi};
        `REG_TIM0_CH0_LUT:   PRDATA = {14'h0, r_timer0_ch0_flt, r_timer0_ch0_lut};
        `REG_TIM0_CH1_TH:    PRDATA = {13'h0, r_timer0_ch1_mode, r_timer0_ch1_th};
        `REG_TIM0_CH1_TH_HI: PRDATA = {16'h0, r_timer0_ch1_th_hi};
        `REG_TIM0_CH1_LUT:   PRDATA = {14'h0, r_timer0_ch1_flt, r_timer0_ch1_lut};
        `REG_TIM0_CH2_TH:    PRDATA = {13'h0, r_timer0_ch2_mode, r_timer0_ch2_th};
        `REG_TIM0_CH2_TH_HI: PRDATA = {16'h0, r_timer0_ch2_th_hi};
        `REG_TIM0_CH2_LUT:   PRDATA = {14'h0, r_timer0_ch2_flt, r_timer0_ch2_lut};
        `REG_TIM0_CH3_TH:    PRDATA = {13'h0, r_timer0_ch3_mode, r_timer0_ch3_th};
        `REG_TIM0_CH3_TH_HI: PRDATA = {16'h0, r_timer0_ch3_th_hi};
        `REG_TIM0_CH3_LUT:   PRDATA = {14'h0, r_timer0_ch3_flt, r_timer0_ch3_lut};
        // [5] counter read: zero-extend to 32 bits regardless of TIMER_NBITS
        `REG_TIM0_COUNTER:   PRDATA = {{(32-TIMER_NBITS){1'b0}}, timer0_counter_i};
        `REG_EVENT_CFG:      PRDATA = {12'h0, r_event_en, r_event_sel_3,
                                        r_event_sel_2, r_event_sel_1, r_event_sel_0};
        `REG_CH_EN:          PRDATA = {31'h0, r_clk_en};
        default:             PRDATA = '0;
      endcase
    end
  end

  assign PREADY  = 1'b1;
  assign PSLVERR = 1'b0;

endmodule // adv_timer_apb_if
