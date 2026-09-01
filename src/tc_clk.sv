//==============================================================================
// Technology Cell Clock Primitives
//==============================================================================
// Design:      Technology-agnostic Clock Cell Primitives
// Engineers:   Mam Javaria, RMD
// Source:      PULP Platform - tech_cells_generic
// Date:        
//
// Description:
//   Behavioral models of basic clock manipulation primitives.
//   These cells are intended to be technology-mapped during synthesis.
//
// Primitives:
//   - tc_clk_and2:      Clock AND gate
//   - tc_clk_buffer:    Clock buffer
//   - tc_clk_gating:    Integrated Clock Gating (ICG) cell
//   - tc_clk_inverter:  Clock inverter
//   - tc_clk_mux2:      2-to-1 clock multiplexer
//   - tc_clk_xor2:      Clock XOR gate
//   - tc_clk_or2:       Clock OR gate
//   - tc_clk_delay:     Clock delay element (simulation only)
//
//==============================================================================

//------------------------------------------------------------------------------
// tc_clk_and2 - Clock AND Gate
//------------------------------------------------------------------------------
// Description: Logical AND of two clock signals
//------------------------------------------------------------------------------
module tc_clk_and2 (
  input  logic clk0_i,   // First clock input
  input  logic clk1_i,   // Second clock input
  output logic clk_o     // ANDed clock output
);
  assign clk_o = clk0_i & clk1_i;
endmodule

//------------------------------------------------------------------------------
// tc_clk_buffer - Clock Buffer
//------------------------------------------------------------------------------
// Description: Clock buffer for driving high fanout nets
//------------------------------------------------------------------------------
module tc_clk_buffer (
  input  logic clk_i,    // Clock input
  output logic clk_o     // Buffered clock output
);
  assign clk_o = clk_i;
endmodule

//------------------------------------------------------------------------------
// tc_clk_gating - Integrated Clock Gating Cell (ICG)
//------------------------------------------------------------------------------
// Description: Behavioral model of an integrated clock-gating cell
//
// Operation:
//   - Enable is latched on negative clock edge (glitch-free)
//   - Clock is gated when enable is low
//   - Test enable bypasses gating for DFT
//
// Parameters:
//   IS_FUNCTIONAL: If 0, can be replaced with feedthrough during synthesis
//------------------------------------------------------------------------------
module tc_clk_gating #(
  parameter bit IS_FUNCTIONAL = 1'b1   // Required for functionality?
)(
   input  logic clk_i,       // Input clock
   input  logic en_i,        // Clock enable
   input  logic test_en_i,   // Test enable (DFT bypass)
   output logic clk_o        // Gated clock output
);

  logic clk_en;   // Latched enable signal

  //============================================================================
  // Enable Latch
  //============================================================================
  // Latches enable on negative clock edge to prevent glitches
  //============================================================================
  /* verilator lint_off COMBDLY */
  always_latch begin
    if (clk_i == 1'b0) 
      clk_en <= en_i | test_en_i;   // OR with test enable
  end
  /* verilator lint_on COMBDLY */

  //============================================================================
  // Gated Clock Output
  //============================================================================
  assign clk_o = clk_i & clk_en;

endmodule

//------------------------------------------------------------------------------
// tc_clk_inverter - Clock Inverter
//------------------------------------------------------------------------------
// Description: Clock inverter for phase shifting
//------------------------------------------------------------------------------
module tc_clk_inverter (
  input  logic clk_i,    // Clock input
  output logic clk_o     // Inverted clock output
);
  assign clk_o = ~clk_i;
endmodule

//------------------------------------------------------------------------------
// tc_clk_mux2 - 2-to-1 Clock Multiplexer
//------------------------------------------------------------------------------
// ⚠️ WARNING: NOT GLITCH-FREE!
//
// This is a standard multiplexer, not a glitch-free clock mux.
// Glitches can occur when:
//   - Switching between active clocks
//   - Select signal has glitches
//
// Usage:
//   - Quasi-static clock switching only
//   - Ensure one clock is inactive during switch
//   - Keep downstream logic in reset during transition
//
// For glitch-free switching, use clk_mux_glitch_free from common_cells
//------------------------------------------------------------------------------
module tc_clk_mux2 (
  input  logic clk0_i,      // Clock 0 input
  input  logic clk1_i,      // Clock 1 input
  input  logic clk_sel_i,   // Clock select (0=clk0, 1=clk1)
  output logic clk_o        // Selected clock output
);
  assign clk_o = (clk_sel_i) ? clk1_i : clk0_i;
endmodule

//------------------------------------------------------------------------------
// tc_clk_xor2 - Clock XOR Gate
//------------------------------------------------------------------------------
// Description: Logical XOR of two clock signals
//------------------------------------------------------------------------------
module tc_clk_xor2 (
  input  logic clk0_i,   // First clock input
  input  logic clk1_i,   // Second clock input
  output logic clk_o     // XORed clock output
);
  assign clk_o = clk0_i ^ clk1_i;
endmodule

//------------------------------------------------------------------------------
// tc_clk_or2 - Clock OR Gate
//------------------------------------------------------------------------------
// Description: Logical OR of two clock signals
//------------------------------------------------------------------------------
module tc_clk_or2 (
  input logic clk0_i,    // First clock input
  input logic clk1_i,    // Second clock input
  output logic clk_o     // ORed clock output
);
  assign clk_o = clk0_i | clk1_i;
endmodule

//------------------------------------------------------------------------------
// tc_clk_delay - Clock Delay Element (Simulation Only)
//------------------------------------------------------------------------------
// Description: Adds programmable delay to signal (simulation only)
//
// ⚠️ NOTE: Not synthesizable - used for simulation modeling only
//------------------------------------------------------------------------------
`ifndef SYNTHESIS
module tc_clk_delay #(
  parameter int unsigned Delay = 300ps   // Delay amount
) (
  input  logic in_i,     // Input signal
  output logic out_o     // Delayed output signal
);

// pragma translate_off
`ifndef VERILATOR
  assign #(Delay) out_o = in_i;
`endif
// pragma translate_on

endmodule
`endif

//==============================================================================
// End of File
//==============================================================================
