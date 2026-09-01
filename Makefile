# Makefile for verification - corrected indentation
TEST ?=apb_timer_ch0_32bit_test
TIME_OUT ?= 10000000

build:
	vcs -timescale=1ns/1ps -f ./results/build_spi.f -top testbench -ntb_opts uvm-1.2 -sverilog -cm line+cond+tgl+assert -LDFLAGS -Wl,--no-as-needed -full64 -debug_all +lint=TFIPC-L
	cd ./results && rm -rf $(TEST)_build
	cd ./results && mkdir -p $(TEST)_build
	mv csrc* simv* -t ./results/$(TEST)_build
	cd ./results/$(TEST)_build && ./simv +UVM_TESTNAME=$(TEST) -cm line+cond+tgl+assert +UVM_TIMEOUT=$(TIME_OUT) > log_$(TEST)_build.txt

gui: 
	cd ./results/$(TEST)_build && dve -vpd wave.vpd &

cov:
	vcs -f ./results/build_spi.f -ntb_opts uvm-1.2 -sverilog -cm line+cond+tgl+assert -LDFLAGS -Wl,--no-as-needed -full64 -debug_all
	cd ./results && rm -rf $(TEST)_cov
	cd ./results && mkdir -p $(TEST)_cov
	mv -f csrc* simv* ./results/$(TEST)_cov/
	cd ./results/$(TEST)_cov && ./simv +UVM_TESTNAME=$(TEST) -cm line+cond+tgl+assert +UVM_TIMEOUT=$(TIME_OUT) > log_$(TEST)_cov.txt
func_cov:
	urg -report ./results/func_coverage_report -dir ./results/*_build/*.vdb
code_cov:
	dve -full64 -cov -covdir ./results/*_build/*.vdb &
	urg -report ./results/code_coverage_report -dir ./results/*_build/*.vdb
# 	@echo "=== Opening DVE Coverage GUI ==="
# 	dve -full64 \
# 	    -cov \
# 	    -covdir ./results/*_cov/*.vdb &
# 	@echo "=== Generating URG Code Coverage Report ==="
# 	urg -dir ./results/*_cov/*.vdb \
# 	    -report ./results/code_coverage_report \
# 	    -format both \
# 	    -log ./results/urg_code.log
# 	@echo "✅ Report → ./results/code_coverage_report/dashboard.html"



# ====================== MERGE ALL COVERAGE ======================
merge_cov:
	@echo "=== Merging code coverage from ALL tests ==="
	urg -dir ./results/*_cov/*.vdb \
	    -report ./results/combined_coverage_report \
	    -format both \          # ← This is the correct option
	    -showcfg
	@echo "✅ Combined coverage report generated successfully!"
	@echo "Open HTML report using:"
	@echo "    firefox ./results/combined_coverage_report/index.html"
	@echo "    or"
	@echo "    google-chrome ./results/combined_coverage_report/index.html"

merge_cov_clean:
	rm -rf ./results/combined_coverage_report
# ============================================================
allclean:
	clear
	rm -rf csrc *.daidir urgReport tr_db.log ucli.key vc_hdrs.h *.vdb DVEfiles urgReport *_test *.txt

clean: 
	rm -rf csrc DVEfiles inter.vpd simv simv.daidir simv.vdb tr_db.log ucli.key vc_hdrs.h novas.conf novas_dump.log *.txt *.vdb *.daidir test *.cst *.log 

asrt:
	vcs -f ./results/build_spi.f -ntb_opts uvm-1.2 -sverilog -assert enable_diag +define+ASSERT_ON +define+check1+check2+check3+check4+check5+check6+check7 -LDFLAGS -Wl,--no-as-needed -full64 -debug_all +lint=TFIPC-L -cm assert
	cd ./results && rm -rf $(TEST)_asrt
	cd ./results && mkdir -p $(TEST)_asrt
	mv csrc* simv* -t ./results/$(TEST)_asrt
	cd ./results/$(TEST)_asrt && ./simv +UVM_TESTNAME=$(TEST) +UVM_TIMEOUT=$(TIME_OUT) > log_$(TEST)_asrt.txt

# ────────────────────────────────────────────────
# Run multiple tests
# ────────────────────────────────────────────────

all_build:
	make build TEST=apb_basic_write_test   
	make build TEST=apb_advtimer_timer0_reset_test  
	make build TEST=apb_timer0_clockgate_test  
	make build TEST=apb_saw_mode_test       
	make build TEST=apb_triangle_mode_count_test    
	make build TEST=basic_timer_setup_pwm_generation_timer0_ch0_test  
	make build TEST=clock_selection_hclk_test   
	make build TEST=apb_timer0_full_register_access_test  
	make build TEST=update_sig_timer0_test 
	make build TEST=timer0_full_flow_test 
	make build TEST=input_stage_full_coverage_test

# 	toggle coverage for counter timer 0, 1,2, 3 
	make build TEST=updown_counter_full_toggle_coverage_timer0_test

# 	timer0 comparators channels 32 bits  
	make build TEST=apb_timer_ch0_32bit_test
	make build TEST=apb_timer_ch1_32bit_test
	make build TEST=apb_timer_ch2_32bit_test
	make build TEST=apb_timer_ch3_32bit_test

# 	timer0 comparators channels toggle coverage 
	make build TEST=comp_ch0_toggle_coverage_timer0_test 
	make build TEST=comp_ch1_toggle_coverage_timer0_test  		 
	make build TEST=comp_ch2_toggle_coverage_timer0_test  
	make build TEST=comp_ch3_toggle_coverage_timer0_test  
	
# 	prescaler test cases for timer 0,1,2,3
	make build TEST=apb_timer0_random_prescaler_test 
	make build TEST=apb_prescaler_test 

	make build TEST=clock_selection_low_speed_test   
	make build TEST=apb_timer0_ext_trigger_test

# 	timer0 compare operation tests
	make build TEST=pwm_comp_op_000_set_sawtooth_on_timer0_ch0_test 
	make build TEST=pwm_comp_op_000_set_sawtooth_off_timer0_ch0_test 
	make build TEST=pwm_comp_op_001_togrst_sawtooth_on_timer0_ch0_test 
	make build TEST=pwm_comp_op_001_togrst_sawtooth_off_timer0_ch0_test  
	make build TEST=pwm_comp_op_010_setrst_sawtooth_on_timer0_ch0_test   
	make build TEST=pwm_comp_op_010_setrst_sawtooth_off_timer0_ch0_test 
	make build TEST=pwm_comp_op_011_tog_any_sawtooth_timer0_ch0_test 
	make build TEST=pwm_comp_op_100_rst_on_match_timer0_ch0_test 
	make build TEST=pwm_comp_op_101_togset_sawtooth_on_timer0_ch0_test  
	make build TEST=pwm_comp_op_101_togset_sawtooth_off_timer0_ch0_test  
	make build TEST=pwm_comp_op_110_rstset_sawtooth_on_timer0_ch0_test 
	make build TEST=pwm_comp_op_110_rstset_sawtooth_off_timer0_ch0_test 
	make build TEST=pwm_comp_default_hold_no_match_timer0_ch0_test  
	make build TEST=pwm_comp_reset_behavior_all_op_timer0_ch0_test 
	make build TEST=pwm_comp_update_gating_all_op_timer0_ch0_test 
	make build TEST=pwm_comp_op_default_illegal_timer0_ch0_test  
	

#   input stage test cases for timer_0
	make build TEST=input_stage_mode_0_always_timer0_test      
	make build TEST=input_stage_mode_1_invert_timer0_test    
	make build TEST=input_stage_mode_2_passthrough_timer0_test   
	make build TEST=input_stage_mode_3_rising_edge_timer0_test    
	make build TEST=input_stage_mode_4_falling_edge_timer0_test   
	make build TEST=input_stage_mode_5_both_edges_timer0_test   
	make build TEST=input_stage_mode_6_rising_armed_timer0_test   
	make build TEST=input_stage_mode_7_falling_armed_timer0_test   
 	
# 	event generation test cases
	make build TEST=event_generation_timer0_ch0_test 

all_cov:
	make cov TEST=apb_basic_write_test
	make cov TEST=apb_advtimer_timer0_reset_test
	make cov TEST=apb_timer0_clockgate_test
	make cov TEST=apb_timer0_full_register_access_test
	make cov TEST=apb_saw_mode_test
	make cov TEST=apb_triangle_mode_count_test
	make cov TEST=basic_timer_setup_pwm_generation_timer0_ch0_test
	make cov TEST=clock_selection_hclk_test
	make cov TEST=apb_timer0_random_prescaler_test
	make cov TEST=apb_prescaler_test
	make cov TEST=clock_selection_low_speed_test
	make cov TEST=apb_timer0_ext_trigger_test
	make cov TEST=update_sig_timer0_test
	make cov TEST=timer0_full_flow_test
	make cov TEST=input_stage_full_coverage_test


# 	timer0 comparators channels 32 bits  
	make cov TEST=apb_timer_ch0_32bit_test
	make cov TEST=apb_timer_ch1_32bit_test
	make cov TEST=apb_timer_ch2_32bit_test
	make cov TEST=apb_timer_ch3_32bit_test
	    
# 	toggle coverage for counter timer 0, 1,2, 3 
	make cov TEST=updown_counter_full_toggle_coverage_timer0_test

# 	timer0 channels toggle coverage 
	make cov TEST=comp_ch0_toggle_coverage_timer0_test
	make cov TEST=comp_ch1_toggle_coverage_timer0_test
	make cov TEST=comp_ch2_toggle_coverage_timer0_test
	make cov TEST=comp_ch3_toggle_coverage_timer0_test

# 	timer0 compare operation tests	
	make cov TEST=pwm_comp_op_000_set_sawtooth_on_timer0_ch0_test
	make cov TEST=pwm_comp_op_000_set_sawtooth_off_timer0_ch0_test
	make cov TEST=pwm_comp_op_001_togrst_sawtooth_on_timer0_ch0_test
	make cov TEST=pwm_comp_op_001_togrst_sawtooth_off_timer0_ch0_test
	make cov TEST=pwm_comp_op_010_setrst_sawtooth_on_timer0_ch0_test
	make cov TEST=pwm_comp_op_010_setrst_sawtooth_off_timer0_ch0_test
	make cov TEST=pwm_comp_op_011_tog_any_sawtooth_timer0_ch0_test
	make cov TEST=pwm_comp_op_100_rst_on_match_timer0_ch0_test
	make cov TEST=pwm_comp_op_101_togset_sawtooth_on_timer0_ch0_test
	make cov TEST=pwm_comp_op_101_togset_sawtooth_off_timer0_ch0_test
	make cov TEST=pwm_comp_op_110_rstset_sawtooth_on_timer0_ch0_test
	make cov TEST=pwm_comp_op_110_rstset_sawtooth_off_timer0_ch0_test
	make cov TEST=pwm_comp_default_hold_no_match_timer0_ch0_test
	make cov TEST=pwm_comp_reset_behavior_all_op_timer0_ch0_test
	make cov TEST=pwm_comp_update_gating_all_op_timer0_ch0_test
	make cov TEST=pwm_comp_op_default_illegal_timer0_ch0_test

	make cov TEST=input_stage_mode_0_always_timer0_test
	make cov TEST=input_stage_mode_1_invert_timer0_test
	make cov TEST=input_stage_mode_2_passthrough_timer0_test
	make cov TEST=input_stage_mode_3_rising_edge_timer0_test
	make cov TEST=input_stage_mode_4_falling_edge_timer0_test
	make cov TEST=input_stage_mode_5_both_edges_timer0_test
	make cov TEST=input_stage_mode_6_rising_armed_timer0_test
	make cov TEST=input_stage_mode_7_falling_armed_timer0_test

	make cov TEST=event_generation_timer0_ch0_test




















































# Makefile for verification - corrected indentation
# TEST ?= apb_timer_ch0_32bit_test 
# TIME_OUT ?= 10000000

# build:
# 	vcs -timescale=1ns/1ps -f ./results/build_spi.f -top testbench -ntb_opts uvm-1.2 -sverilog -cm line+cond+tgl+assert -LDFLAGS -Wl,--no-as-needed -full64 -debug_all +lint=TFIPC-L
# 	cd ./results && rm -rf $(TEST)_build
# 	cd ./results && mkdir -p $(TEST)_build
# 	mv csrc* simv* -t ./results/$(TEST)_build
# 	cd ./results/$(TEST)_build && ./simv +UVM_TESTNAME=$(TEST) -cm line+cond+tgl+assert +UVM_TIMEOUT=$(TIME_OUT) > log_$(TEST)_build.txt

# gui: 
# 	cd ./results/$(TEST)_build && dve -vpd wave.vpd &

# cov:
# 	vcs -f ./results/build_spi.f -ntb_opts uvm-1.2 -sverilog -cm line+cond+tgl+assert -LDFLAGS -Wl,--no-as-needed -full64 -debug_all
# 	cd ./results && rm -rf $(TEST)_cov
# 	cd ./results && mkdir -p $(TEST)_cov
# 	mv -f csrc* simv* ./results/$(TEST)_cov/
# 	cd ./results/$(TEST)_cov && ./simv +UVM_TESTNAME=$(TEST) -cm line+cond+tgl+assert +UVM_TIMEOUT=$(TIME_OUT) > log_$(TEST)_cov.txt
# func_cov:
# 	urg -report ./results/func_coverage_report -dir ./results/*_build/*.vdb
# code_cov:
# 	dve -full64 -cov -covdir ./results/*_build/*.vdb &
# 	urg -report ./results/code_coverage_report -dir ./results/*_build/*.vdb
# # 	@echo "=== Opening DVE Coverage GUI ==="
# # 	dve -full64 \
# # 	    -cov \
# # 	    -covdir ./results/*_cov/*.vdb &
# # 	@echo "=== Generating URG Code Coverage Report ==="
# # 	urg -dir ./results/*_cov/*.vdb \
# # 	    -report ./results/code_coverage_report \
# # 	    -format both \
# # 	    -log ./results/urg_code.log
# # 	@echo "✅ Report → ./results/code_coverage_report/dashboard.html"


# # ====================== MERGE ALL COVERAGE ======================
# merge_cov:
# 	@echo "=== Merging code coverage from ALL tests ==="
# 	urg -dir ./results/*_cov/*.vdb \
# 	    -report ./results/combined_coverage_report \
# 	    -format both \          # ← This is the correct option
# 	    -showcfg
# 	@echo "✅ Combined coverage report generated successfully!"
# 	@echo "Open HTML report using:"
# 	@echo "    firefox ./results/combined_coverage_report/index.html"
# 	@echo "    or"
# 	@echo "    google-chrome ./results/combined_coverage_report/index.html"

# merge_cov_clean:
# 	rm -rf ./results/combined_coverage_report
# # ============================================================
# allclean:
# 	clear
# 	rm -rf csrc *.daidir urgReport tr_db.log ucli.key vc_hdrs.h *.vdb DVEfiles urgReport *_test *.txt

# clean: 
# 	rm -rf csrc DVEfiles inter.vpd simv simv.daidir simv.vdb tr_db.log ucli.key vc_hdrs.h novas.conf novas_dump.log *.txt *.vdb *.daidir test *.cst *.log 

# asrt:
# 	vcs -f ./results/build_spi.f -ntb_opts uvm-1.2 -sverilog -assert enable_diag +define+ASSERT_ON +define+check1+check2+check3+check4+check5+check6+check7 -LDFLAGS -Wl,--no-as-needed -full64 -debug_all +lint=TFIPC-L -cm assert
# 	cd ./results && rm -rf $(TEST)_asrt
# 	cd ./results && mkdir -p $(TEST)_asrt
# 	mv csrc* simv* -t ./results/$(TEST)_asrt
# 	cd ./results/$(TEST)_asrt && ./simv +UVM_TESTNAME=$(TEST) +UVM_TIMEOUT=$(TIME_OUT) > log_$(TEST)_asrt.txt

# # ────────────────────────────────────────────────
# # Run multiple tests
# # ────────────────────────────────────────────────

# all_build:
# 	make build TEST=apb_basic_write_test   
# 	make build TEST=apb_advtimer_timer0_reset_test  
# 	make build TEST=apb_timer0_clockgate_test  
# 	make build TEST=apb_saw_mode_test       
# 	make build TEST=apb_triangle_mode_count_test    
# 	make build TEST=basic_timer_setup_pwm_generation_timer0_ch0_test  
# 	make build TEST=clock_selection_hclk_test   
# 	make build TEST=apb_timer0_full_register_access_test  
# 	make build TEST=update_sig_timer0_test 
# 	make build TEST=timer0_full_flow_test 
# 	make build TEST=input_stage_full_coverage_test

# # 	toggle coverage for counter timer 0, 1,2, 3 
# 	make build TEST=updown_counter_full_toggle_coverage_timer0_test

# # 	timer0 comparators channels 32 bits  
# 	make build TEST=apb_timer_ch0_32bit_test
# 	make build TEST=apb_timer_ch1_32bit_test
# 	make build TEST=apb_timer_ch2_32bit_test
# 	make build TEST=apb_timer_ch3_32bit_test

# # 	timer0 comparators channels toggle coverage 
# 	make build TEST=comp_ch0_toggle_coverage_timer0_test 
# 	make build TEST=comp_ch1_toggle_coverage_timer0_test  		 
# 	make build TEST=comp_ch2_toggle_coverage_timer0_test  
# 	make build TEST=comp_ch3_toggle_coverage_timer0_test  
	
# # 	prescaler test cases for timer 0,1,2,3
# 	make build TEST=apb_timer0_random_prescaler_test 
# 	make build TEST=apb_prescaler_test 

# 	make build TEST=clock_selection_low_speed_test   
# 	make build TEST=apb_timer0_ext_trigger_test

# # 	timer0 compare operation tests
# 	make build TEST=pwm_comp_op_000_set_sawtooth_on_timer0_ch0_test 
# 	make build TEST=pwm_comp_op_000_set_sawtooth_off_timer0_ch0_test 
# 	make build TEST=pwm_comp_op_001_togrst_sawtooth_on_timer0_ch0_test 
# 	make build TEST=pwm_comp_op_001_togrst_sawtooth_off_timer0_ch0_test  
# 	make build TEST=pwm_comp_op_010_setrst_sawtooth_on_timer0_ch0_test   
# 	make build TEST=pwm_comp_op_010_setrst_sawtooth_off_timer0_ch0_test 
# 	make build TEST=pwm_comp_op_011_tog_any_sawtooth_timer0_ch0_test 
# 	make build TEST=pwm_comp_op_100_rst_on_match_timer0_ch0_test 
# 	make build TEST=pwm_comp_op_101_togset_sawtooth_on_timer0_ch0_test  
# 	make build TEST=pwm_comp_op_101_togset_sawtooth_off_timer0_ch0_test  
# 	make build TEST=pwm_comp_op_110_rstset_sawtooth_on_timer0_ch0_test 
# 	make build TEST=pwm_comp_op_110_rstset_sawtooth_off_timer0_ch0_test 
# 	make build TEST=pwm_comp_default_hold_no_match_timer0_ch0_test  
# 	make build TEST=pwm_comp_reset_behavior_all_op_timer0_ch0_test 
# 	make build TEST=pwm_comp_update_gating_all_op_timer0_ch0_test 
# 	make build TEST=pwm_comp_op_default_illegal_timer0_ch0_test  
	

# #   input stage test cases for timer_0
# 	make build TEST=input_stage_mode_0_always_timer0_test      
# 	make build TEST=input_stage_mode_1_invert_timer0_test    
# 	make build TEST=input_stage_mode_2_passthrough_timer0_test   
# 	make build TEST=input_stage_mode_3_rising_edge_timer0_test    
# 	make build TEST=input_stage_mode_4_falling_edge_timer0_test   
# 	make build TEST=input_stage_mode_5_both_edges_timer0_test   
# 	make build TEST=input_stage_mode_6_rising_armed_timer0_test   
# 	make build TEST=input_stage_mode_7_falling_armed_timer0_test   
 	
# # 	event generation test cases
# 	make build TEST=event_generation_timer0_ch0_test 

# all_cov:
# 	make cov TEST=apb_basic_write_test
# 	make cov TEST=apb_advtimer_timer0_reset_test
# 	make cov TEST=apb_timer0_clockgate_test
# 	make cov TEST=apb_timer0_full_register_access_test
# 	make cov TEST=apb_saw_mode_test
# 	make cov TEST=apb_triangle_mode_count_test
# 	make cov TEST=basic_timer_setup_pwm_generation_timer0_ch0_test
# 	make cov TEST=clock_selection_hclk_test
# 	make cov TEST=apb_timer0_random_prescaler_test
# 	make cov TEST=apb_prescaler_test
# 	make cov TEST=clock_selection_low_speed_test
# 	make cov TEST=apb_timer0_ext_trigger_test
# 	make cov TEST=update_sig_timer0_test
# 	make cov TEST=timer0_full_flow_test
# 	make cov TEST=input_stage_full_coverage_test


# # 	timer0 comparators channels 32 bits  
# 	make cov TEST=apb_timer_ch0_32bit_test
# 	make cov TEST=apb_timer_ch1_32bit_test
# 	make cov TEST=apb_timer_ch2_32bit_test
# 	make cov TEST=apb_timer_ch3_32bit_test
	    
# # 	toggle coverage for counter timer 0, 1,2, 3 
# 	make cov TEST=updown_counter_full_toggle_coverage_timer0_test

# # 	timer0 channels toggle coverage 
# 	make cov TEST=comp_ch0_toggle_coverage_timer0_test
# 	make cov TEST=comp_ch1_toggle_coverage_timer0_test
# 	make cov TEST=comp_ch2_toggle_coverage_timer0_test
# 	make cov TEST=comp_ch3_toggle_coverage_timer0_test

# # 	timer0 compare operation tests	
# 	make cov TEST=pwm_comp_op_000_set_sawtooth_on_timer0_ch0_test
# 	make cov TEST=pwm_comp_op_000_set_sawtooth_off_timer0_ch0_test
# 	make cov TEST=pwm_comp_op_001_togrst_sawtooth_on_timer0_ch0_test
# 	make cov TEST=pwm_comp_op_001_togrst_sawtooth_off_timer0_ch0_test
# 	make cov TEST=pwm_comp_op_010_setrst_sawtooth_on_timer0_ch0_test
# 	make cov TEST=pwm_comp_op_010_setrst_sawtooth_off_timer0_ch0_test
# 	make cov TEST=pwm_comp_op_011_tog_any_sawtooth_timer0_ch0_test
# 	make cov TEST=pwm_comp_op_100_rst_on_match_timer0_ch0_test
# 	make cov TEST=pwm_comp_op_101_togset_sawtooth_on_timer0_ch0_test
# 	make cov TEST=pwm_comp_op_101_togset_sawtooth_off_timer0_ch0_test
# 	make cov TEST=pwm_comp_op_110_rstset_sawtooth_on_timer0_ch0_test
# 	make cov TEST=pwm_comp_op_110_rstset_sawtooth_off_timer0_ch0_test
# 	make cov TEST=pwm_comp_default_hold_no_match_timer0_ch0_test
# 	make cov TEST=pwm_comp_reset_behavior_all_op_timer0_ch0_test
# 	make cov TEST=pwm_comp_update_gating_all_op_timer0_ch0_test
# 	make cov TEST=pwm_comp_op_default_illegal_timer0_ch0_test

# 	make cov TEST=input_stage_mode_0_always_timer0_test
# 	make cov TEST=input_stage_mode_1_invert_timer0_test
# 	make cov TEST=input_stage_mode_2_passthrough_timer0_test
# 	make cov TEST=input_stage_mode_3_rising_edge_timer0_test
# 	make cov TEST=input_stage_mode_4_falling_edge_timer0_test
# 	make cov TEST=input_stage_mode_5_both_edges_timer0_test
# 	make cov TEST=input_stage_mode_6_rising_armed_timer0_test
# 	make cov TEST=input_stage_mode_7_falling_armed_timer0_test

# 	make cov TEST=event_generation_timer0_ch0_test






























