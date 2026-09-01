
  
`ifndef CLK_PKG_SV
`define CLK_PKG_SV

package clk_pkg;

// Import the UVM class library  and UVM automation macros
import uvm_pkg::*;
`include "uvm_macros.svh"


`include "clk_config.sv"
`include "clk_sequencer.sv"
`include "clk_sequence.sv"

`include "clk_transaction.sv"
`include "clk_driver.sv"
`include "clk_monitor.sv"
`include "clk_agent.sv"
`include "clk_environment.sv"



endpackage : clk_pkg
`endif  // CLK_PKG_SV


