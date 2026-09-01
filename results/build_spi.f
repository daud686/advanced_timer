
// Include directories

//+incdir+./tb_src/wb
+incdir+./tb_src/apb
//+incdir+./tb_src/timer
+incdir+./tb_src/test
+incdir+./tb_src/top_env
//+incdir+./wb_spi_vip/src

// SV Interfaces

//./tb_src/wb/wb_interface.sv
./tb_src/apb/apb_interface.sv
//./tb_src/timer/timer_interface.sv

// Other Verilog Packages

./tb_src/apb/apb_pkg.sv
//./tb_src/timer/timer_pkg.sv
./tb_src/top_env/top_env_pkg.sv
./tb_src/test/test_pkg.sv

// Test Bench Top Level

//./tb_src/test/wb_spi_property.sv
./tb_src/test/testbench.sv

// DUT Parts

./src/pulp_clk_cells.sv
./src/adv_timer_apb_if.sv
./src/apb_adv_timer.sv
./src/comparator.sv
./src/input_stage.sv
./src/lut_4x4.sv
./src/out_filter.sv
./src/prescaler.sv
./src/timer_cntrl.sv
./src/timer_module.sv
./src/up_down_counter.sv
./src/tc_clk.sv
