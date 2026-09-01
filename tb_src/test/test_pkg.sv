/*-------------------------------------------------------------------------
File name   : test_pkg.sv
Project     : SPI VIP
---------------------------------------------------------------------------*/

package test_pkg;
    `include "uvm_macros.svh"
    //-----------------Importing uvm package-------------------
    import uvm_pkg::*;
    
    //---------------------Import agents' pkgs---------------------
    import top_env_pkg::*;

    //---------------------Files Inclusion---------------------
    //
    //`include "transfer_test_8_msb.sv"
    `include "apb_basic_write_test.sv"
    `include "apb_advtimer_timer0_reset_test.sv"
    `include "apb_timer0_clockgate_test.sv"
	`include "apb_saw_mode_test.sv"
    `include "apb_triangle_mode_count_test.sv"
    `include "basic_timer_setup_pwm_generation_timer0_ch0_test.sv" 
    `include "clock_selection_hclk_test.sv" 
    `include "apb_timer0_random_prescaler_test.sv" 
    `include "apb_prescaler_test.sv"
    `include "clock_selection_low_speed_test.sv" 
    `include "apb_timer0_full_register_access_test.sv"
    `include "apb_timer0_ext_trigger_test.sv"  
	`include "update_sig_timer0_test.sv"
    `include "timer0_full_flow_test.sv"
    `include "input_stage_full_coverage_test.sv"

    // timer0 comaparator channels 32 bits 
    `include "apb_timer_ch0_32bit_test.sv"
    `include "apb_timer_ch1_32bit_test.sv"
    `include "apb_timer_ch2_32bit_test.sv"
    `include "apb_timer_ch3_32bit_test.sv"


    // toggle coverage timer0 comaparator channels
    `include "comp_ch0_toggle_coverage_timer0_test.sv"
    `include "comp_ch1_toggle_coverage_timer0_test.sv"
    `include "comp_ch2_toggle_coverage_timer0_test.sv"
    `include "comp_ch3_toggle_coverage_timer0_test.sv"

    // toggle covergae cases for counter
    `include "updown_counter_full_toggle_coverage_timer0_test.sv"
    
    //timer0 compare operation tests
    `include "pwm_comp_op_000_set_sawtooth_on_timer0_ch0_test.sv" 
    `include "pwm_comp_op_000_set_sawtooth_off_timer0_ch0_test.sv" 
    `include "pwm_comp_op_001_togrst_sawtooth_on_timer0_ch0_test.sv"
    `include "pwm_comp_op_001_togrst_sawtooth_off_timer0_ch0_test.sv" 
    `include "pwm_comp_op_010_setrst_sawtooth_on_timer0_ch0_test.sv" 
    `include "pwm_comp_op_010_setrst_sawtooth_off_timer0_ch0_test.sv"
    `include "pwm_comp_op_011_tog_any_sawtooth_timer0_ch0_test.sv"    
    `include "pwm_comp_op_100_rst_on_match_timer0_ch0_test.sv"
    `include "pwm_comp_op_101_togset_sawtooth_on_timer0_ch0_test.sv"
    `include "pwm_comp_op_101_togset_sawtooth_off_timer0_ch0_test.sv"
    `include "pwm_comp_op_110_rstset_sawtooth_on_timer0_ch0_test.sv"
    `include "pwm_comp_op_110_rstset_sawtooth_off_timer0_ch0_test.sv"
    `include "pwm_comp_default_hold_no_match_timer0_ch0_test.sv" 
    `include "pwm_comp_reset_behavior_all_op_timer0_ch0_test.sv" 
    `include "pwm_comp_update_gating_all_op_timer0_ch0_test.sv"
    `include "pwm_comp_op_default_illegal_timer0_ch0_test.sv"

       /////////imput stage timer_0 
    `include "input_stage_mode_0_always_timer0_test.sv"
    `include "input_stage_mode_1_invert_timer0_test.sv"
    `include "input_stage_mode_2_passthrough_timer0_test.sv"
    `include "input_stage_mode_3_rising_edge_timer0_test.sv"
    `include "input_stage_mode_4_falling_edge_timer0_test.sv"
    `include "input_stage_mode_5_both_edges_timer0_test.sv"
    `include "input_stage_mode_6_rising_armed_timer0_test.sv"
    `include "input_stage_mode_7_falling_armed_timer0_test.sv"

    `include "event_generation_timer0_ch0_test.sv"
    
    // `include "fully_random_test.sv"
endpackage:test_pkg
