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
//  [1] TIMER_NBITS parameter added (default 32).
//      Counter and threshold wires widened to [TIMER_NBITS-1:0].
//      The underlying timer_module and up_down_counter use NUM_BITS which is
//      set from this parameter, so the full 0..2^TIMER_NBITS-1 range works.
//
//  [2] Reduced from 4 timers to 1 timer.
//      Removed all timer1/timer2/timer3 signals, instantiations and the
//      three associated pulp_clock_gating instances.
//      Removed ch_0_o..ch_3_o ports.  Replaced with ch_o[3:0] — the four
//      compare-channel bits of the single remaining timer.
//
//  [3] pulp_clock_gating reinstated.
//      Gates the timer clock off when software clears REG_CH_EN[0].
//      Requires tc_clk.sv + pulp_clk_cells.sv to be compiled alongside.
//      dft_cg_enable_i is the DFT scan-enable input: when asserted during
//      manufacturing scan test it forces the clock gate open so every
//      flip-flop inside the timer is reachable by the scan chain.
//
//  [4] low_speed_clk_i and dft_cg_enable_i ports reinstated.
//      low_speed_clk_i is passed to input_stage.ls_clk_i.
//      When CLKSEL bit (REG_TIM0_CFG[11]) = 1, input events are gated to
//      rising edges of ls_clk_i, limiting the count rate to the slow clock.
//      When CLKSEL = 0 (reset default) ls_clk_i has no effect on counting.
//
//  [5] Added timer_counter_o[TIMER_NBITS-1:0] output.
//      The 32-bit counter value is now visible directly on the module
//      boundary, so SoC logic can sample it without an APB read.
//
//  [6] N_TIMEREXTSIG now equals EXTSIG_NUM+4 (was EXTSIG_NUM+16).
//      The input_stage signal bus fed all four timers' output channels back
//      as trigger sources; with one timer only four bits come back.
//      INSEL 0..EXTSIG_NUM-1  → ext_sig_i bits  (external pin counting)
//      INSEL EXTSIG_NUM..EXTSIG_NUM+3 → ch_o[0..3] (self-feedback)
//
//  [7] events_o[3:0] kept at 4 bits — one per compare channel of the
//      single timer.  The event selector indexes ch_o directly.
//

module apb_adv_timer #(
  parameter APB_ADDR_WIDTH = 12,
  parameter EXTSIG_NUM     = 32,
  parameter TIMER_NBITS    = 32   // [1] was 16
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

  input  logic                      dft_cg_enable_i,   // [3] DFT scan-enable for clock gate
  input  logic                      low_speed_clk_i,   // [4] slow clock for input_stage CLKSEL mode
  input  logic     [EXTSIG_NUM-1:0] ext_sig_i,

  // [7] four event outputs, one per compare channel
  output logic                [3:0] events_o,

  // [2] one timer, four compare-channel outputs
  output logic                [3:0] ch_o,

  // [5] direct counter output
  output logic [TIMER_NBITS-1:0]    timer_counter_o
);

  // [6] signal bus: ext_sig_i bits + 4 compare-channel feedback bits
  localparam N_TIMEREXTSIG = EXTSIG_NUM + 4;

  // ------------------------------------------------------------------
  // Internal wires from APB decoder to timer engine
  // ------------------------------------------------------------------
  logic                      s_timer0_apb_start;
  logic                      s_timer0_apb_stop;
  logic                      s_timer0_apb_arm;
  logic                      s_timer0_apb_update;
  logic                      s_timer0_apb_rst;
  logic                      s_timer0_apb_saw;
  logic                [7:0] s_timer0_apb_in_sel;
  logic                [2:0] s_timer0_apb_in_mode;
  logic                [7:0] s_timer0_apb_presc;
  logic [TIMER_NBITS-1:0]    s_timer0_apb_th_hi;   // [1] was [15:0]
  logic [TIMER_NBITS-1:0]    s_timer0_apb_th_low;  // [1] was [15:0]
  logic                [2:0] s_timer0_apb_ch0_mode;
  logic                [1:0] s_timer0_apb_ch0_flt;
  logic [TIMER_NBITS-1:0]    s_timer0_apb_ch0_th;  // [1] was [15:0]
  logic               [15:0] s_timer0_apb_ch0_lut;
  logic                [2:0] s_timer0_apb_ch1_mode;
  logic                [1:0] s_timer0_apb_ch1_flt;
  logic [TIMER_NBITS-1:0]    s_timer0_apb_ch1_th;
  logic               [15:0] s_timer0_apb_ch1_lut;
  logic                [2:0] s_timer0_apb_ch2_mode;
  logic                [1:0] s_timer0_apb_ch2_flt;
  logic [TIMER_NBITS-1:0]    s_timer0_apb_ch2_th;
  logic               [15:0] s_timer0_apb_ch2_lut;
  logic                [2:0] s_timer0_apb_ch3_mode;
  logic                [1:0] s_timer0_apb_ch3_flt;
  logic [TIMER_NBITS-1:0]    s_timer0_apb_ch3_th;
  logic               [15:0] s_timer0_apb_ch3_lut;
  logic                      s_timer0_apb_in_clk;

  logic                [3:0] s_event_en;
  logic                [3:0] s_event_sel_0;
  logic                [3:0] s_event_sel_1;
  logic                [3:0] s_event_sel_2;
  logic                [3:0] s_event_sel_3;

  logic [TIMER_NBITS-1:0]    s_timer0_counter;     // [1] was [15:0]
  logic                      s_timer0_clk_en;
  logic                      s_clk_timer0;         // [3] gated clock to timer engine

  // [5] expose counter on port
  assign timer_counter_o = s_timer0_counter;

  // ------------------------------------------------------------------
  // APB register decoder (single timer)
  // ------------------------------------------------------------------
  adv_timer_apb_if #(
    .APB_ADDR_WIDTH ( APB_ADDR_WIDTH ),
    .TIMER_NBITS    ( TIMER_NBITS   )   // [1] pass parameter through
  ) u_apb_if (
    .HCLK                    ( HCLK                  ),
    .HRESETn                 ( HRESETn               ),
    .PADDR                   ( PADDR                 ),
    .PWDATA                  ( PWDATA                ),
    .PWRITE                  ( PWRITE                ),
    .PSEL                    ( PSEL                  ),
    .PENABLE                 ( PENABLE               ),
    .PRDATA                  ( PRDATA                ),
    .PREADY                  ( PREADY                ),
    .PSLVERR                 ( PSLVERR               ),

    .events_en_o             ( s_event_en            ),
    .events_sel_0_o          ( s_event_sel_0         ),
    .events_sel_1_o          ( s_event_sel_1         ),
    .events_sel_2_o          ( s_event_sel_2         ),
    .events_sel_3_o          ( s_event_sel_3         ),

    // [1] counter input widened
    .timer0_counter_i        ( s_timer0_counter      ),

    .timer0_start_o          ( s_timer0_apb_start    ),
    .timer0_stop_o           ( s_timer0_apb_stop     ),
    .timer0_arm_o            ( s_timer0_apb_arm      ),
    .timer0_update_o         ( s_timer0_apb_update   ),
    .timer0_rst_o            ( s_timer0_apb_rst      ),
    .timer0_saw_o            ( s_timer0_apb_saw      ),
    .timer0_in_sel_o         ( s_timer0_apb_in_sel   ),
    .timer0_in_clk_o         ( s_timer0_apb_in_clk   ),
    .timer0_in_mode_o        ( s_timer0_apb_in_mode  ),
    .timer0_presc_o          ( s_timer0_apb_presc    ),
    .timer0_th_hi_o          ( s_timer0_apb_th_hi    ),
    .timer0_th_low_o         ( s_timer0_apb_th_low   ),
    .timer0_ch0_mode_o       ( s_timer0_apb_ch0_mode ),
    .timer0_ch0_flt_o        ( s_timer0_apb_ch0_flt  ),
    .timer0_ch0_th_o         ( s_timer0_apb_ch0_th   ),
    .timer0_ch0_lut_o        ( s_timer0_apb_ch0_lut  ),
    .timer0_ch1_mode_o       ( s_timer0_apb_ch1_mode ),
    .timer0_ch1_flt_o        ( s_timer0_apb_ch1_flt  ),
    .timer0_ch1_th_o         ( s_timer0_apb_ch1_th   ),
    .timer0_ch1_lut_o        ( s_timer0_apb_ch1_lut  ),
    .timer0_ch2_mode_o       ( s_timer0_apb_ch2_mode ),
    .timer0_ch2_flt_o        ( s_timer0_apb_ch2_flt  ),
    .timer0_ch2_th_o         ( s_timer0_apb_ch2_th   ),
    .timer0_ch2_lut_o        ( s_timer0_apb_ch2_lut  ),
    .timer0_ch3_mode_o       ( s_timer0_apb_ch3_mode ),
    .timer0_ch3_flt_o        ( s_timer0_apb_ch3_flt  ),
    .timer0_ch3_th_o         ( s_timer0_apb_ch3_th   ),
    .timer0_ch3_lut_o        ( s_timer0_apb_ch3_lut  ),

    .timer0_clk_en_o         ( s_timer0_clk_en       )
  );

  // ------------------------------------------------------------------
  // [6] Signal bus fed to input_stage:
  //   bits [EXTSIG_NUM-1:0]           → ext_sig_i  (external pins)
  //   bits [EXTSIG_NUM+3:EXTSIG_NUM]  → ch_o[3:0]  (self-feedback)
  //
  // To count on an external pin, program INSEL = pin index (0..31 for
  // 32 external signals), then set MODE to the desired edge/level mode.
  // ------------------------------------------------------------------
  logic [N_TIMEREXTSIG-1:0] s_timer0_signal;
  assign s_timer0_signal = {ch_o, ext_sig_i};  // [6] was {ch3,ch2,ch1,ch0,ext_sig_i}

  // [3] Clock gate: HCLK is gated by s_timer0_clk_en (REG_CH_EN[0]).
  //     dft_cg_enable_i forces the gate open during scan so that all
  //     flip-flops inside the timer are reachable by the scan chain.
  //     tc_clk_gating latches the enable on the negative clock edge,
  //     making the gated output glitch-free.
  pulp_clock_gating i_clk_gate_timer0 (
    .clk_i     ( HCLK             ),
    .en_i      ( s_timer0_clk_en  ),
    .test_en_i ( dft_cg_enable_i  ),
    .clk_o     ( s_clk_timer0     )
  );

  logic [7:0] s_timer0_status;

  timer_module #(
    .NUM_BITS ( TIMER_NBITS    ),  // [1] was default 16
    .N_EXTSIG ( N_TIMEREXTSIG )   // [6] updated signal bus width
  ) u_tim0 (
    .clk_i            ( s_clk_timer0             ),  // [3] gated clock
    .rstn_i           ( HRESETn                 ),

    .cfg_start_i      ( s_timer0_apb_start      ),
    .cfg_stop_i       ( s_timer0_apb_stop       ),
    .cfg_rst_i        ( s_timer0_apb_rst        ),
    .cfg_update_i     ( s_timer0_apb_update     ),
    .cfg_arm_i        ( s_timer0_apb_arm        ),

    .cfg_sel_i        ( s_timer0_apb_in_sel     ),
    .cfg_sel_clk_i    ( s_timer0_apb_in_clk     ),
    .cfg_mode_i       ( s_timer0_apb_in_mode    ),

    .cfg_presc_i      ( s_timer0_apb_presc      ),

    .cfg_sawtooth_i   ( s_timer0_apb_saw        ),
    .cfg_cnt_start_i  ( s_timer0_apb_th_low     ),
    .cfg_cnt_end_i    ( s_timer0_apb_th_hi      ),

    .cfg_comp_ch0_i   ( s_timer0_apb_ch0_th     ),
    .cfg_comp_op_ch0_i( s_timer0_apb_ch0_mode   ),
    .cfg_comp_ch1_i   ( s_timer0_apb_ch1_th     ),
    .cfg_comp_op_ch1_i( s_timer0_apb_ch1_mode   ),
    .cfg_comp_ch2_i   ( s_timer0_apb_ch2_th     ),
    .cfg_comp_op_ch2_i( s_timer0_apb_ch2_mode   ),
    .cfg_comp_ch3_i   ( s_timer0_apb_ch3_th     ),
    .cfg_comp_op_ch3_i( s_timer0_apb_ch3_mode   ),

    // [4] low_speed_clk_i: passed to input_stage.  Active only when
    //     CLKSEL (REG_TIM0_CFG[11]) = 1; otherwise has no effect.
    .ls_clk_i         ( low_speed_clk_i          ),

    .signal_i         ( s_timer0_signal         ),  // [6]

    .counter_o        ( s_timer0_counter        ),

    .pwm_o            ( ch_o                    ),  // [2] was ch_0_o
    .status_o         ( s_timer0_status         )
  );

  // ------------------------------------------------------------------
  // [7] Edge-detect events: one per compare channel of the single timer.
  //   s_event_sel_N selects which ch_o bit (0..3) triggers event N.
  //   events_o[N] fires on the rising edge of the selected bit when
  //   that event channel is enabled.
  // ------------------------------------------------------------------
  logic [3:0] s_event_signals;
  logic [1:0] r_event_sync_0;
  logic [1:0] r_event_sync_1;
  logic [1:0] r_event_sync_2;
  logic [1:0] r_event_sync_3;

  assign s_event_signals = ch_o;  // [2] was {ch_3_o,ch_2_o,ch_1_o,ch_0_o}

  assign events_o[0] = s_event_en[0] & r_event_sync_0[1] & ~r_event_sync_0[0];
  assign events_o[1] = s_event_en[1] & r_event_sync_1[1] & ~r_event_sync_1[0];
  assign events_o[2] = s_event_en[2] & r_event_sync_2[1] & ~r_event_sync_2[0];
  assign events_o[3] = s_event_en[3] & r_event_sync_3[1] & ~r_event_sync_3[0];

  always_ff @(posedge HCLK or negedge HRESETn) begin
    if (~HRESETn) begin
      r_event_sync_0 <= '0;
      r_event_sync_1 <= '0;
      r_event_sync_2 <= '0;
      r_event_sync_3 <= '0;
    end else begin
      if (s_event_en[0])
        r_event_sync_0 <= {s_event_signals[s_event_sel_0[1:0]], r_event_sync_0[1]};
      if (s_event_en[1])
        r_event_sync_1 <= {s_event_signals[s_event_sel_1[1:0]], r_event_sync_1[1]};
      if (s_event_en[2])
        r_event_sync_2 <= {s_event_signals[s_event_sel_2[1:0]], r_event_sync_2[1]};
      if (s_event_en[3])
        r_event_sync_3 <= {s_event_signals[s_event_sel_3[1:0]], r_event_sync_3[1]};
    end
  end

endmodule // apb_adv_timer
