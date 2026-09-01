//==============================================================================
// PULP Clock Cell Wrappers
//==============================================================================
// Design:      PULP Platform Clock Cell Wrappers
// Engineers:   Mam Javaria, RMD
// Source:      PULP Platform - tech_cells_generic
// Date:        
//
// Description:
//   Wrapper modules that instantiate technology cell clock primitives.
//   Provides a consistent interface layer between design and technology cells.
//
// Modules:
//   - pulp_clock_and2:     Wraps tc_clk_and2
//   - pulp_clock_buffer:   Wraps tc_clk_buffer
//   - pulp_clock_gating:   Wraps tc_clk_gating (ICG)
//   - pulp_clock_inverter: Wraps tc_clk_inverter
//   - pulp_clock_mux2:     Wraps tc_clk_mux2
//   - pulp_clock_xor2:     Wraps tc_clk_xor2
//   - pulp_clock_delay:    Clock delay for simulation
//
//==============================================================================

//------------------------------------------------------------------------------
// pulp_clock_and2 - Clock AND Gate Wrapper
//------------------------------------------------------------------------------
module pulp_clock_and2 (
  input  logic clk0_i,   // First clock input
  input  logic clk1_i,   // Second clock input
  output logic clk_o     // ANDed clock output
);

  tc_clk_and2 i_tc_clk_and2 (
    .clk0_i,
    .clk1_i,
    .clk_o
  );

endmodule

//------------------------------------------------------------------------------
// pulp_clock_buffer - Clock Buffer Wrapper
//------------------------------------------------------------------------------
module pulp_clock_buffer (
  input  logic clk_i,    // Clock input
  output logic clk_o     // Buffered clock output
);

  tc_clk_buffer i_tc_clk_buffer (
    .clk_i,
    .clk_o
  );

endmodule

//------------------------------------------------------------------------------
// pulp_clock_gating - Integrated Clock Gating Cell Wrapper
//------------------------------------------------------------------------------
// Description: Wraps behavioral ICG model for power-efficient clock control
//
// Usage:
//   This is the primary clock gating cell used throughout the timer design.
//   Enable is latched on negative clock edge for glitch-free operation.
//------------------------------------------------------------------------------
module pulp_clock_gating (
   input  logic clk_i,       // Input clock
   input  logic en_i,        // Clock enable
   input  logic test_en_i,   // Test enable (DFT)
   output logic clk_o        // Gated clock output
);

  tc_clk_gating i_tc_clk_gating (
     .clk_i,
     .en_i,
     .test_en_i,
     .clk_o
  );

endmodule

//------------------------------------------------------------------------------
// pulp_clock_inverter - Clock Inverter Wrapper
//------------------------------------------------------------------------------
module pulp_clock_inverter (
  input  logic clk_i,    // Clock input
  output logic clk_o     // Inverted clock output
);

  tc_clk_inverter i_tc_clk_inverter (
    .clk_i,
    .clk_o
  );

endmodule

//------------------------------------------------------------------------------
// pulp_clock_mux2 - Clock Multiplexer Wrapper
//------------------------------------------------------------------------------
// ⚠️ WARNING: Not glitch-free! See tc_clk_mux2 for usage guidelines.
//------------------------------------------------------------------------------
module pulp_clock_mux2 (
  input  logic clk0_i,      // Clock 0 input
  input  logic clk1_i,      // Clock 1 input
  input  logic clk_sel_i,   // Clock select
  output logic clk_o        // Selected clock output
);

  tc_clk_mux2 i_tc_clk_mux2 (
    .clk0_i,
    .clk1_i,
    .clk_sel_i,
    .clk_o
  );

endmodule

//------------------------------------------------------------------------------
// pulp_clock_xor2 - Clock XOR Gate Wrapper
//------------------------------------------------------------------------------
module pulp_clock_xor2 (
  input  logic clk0_i,   // First clock input
  input  logic clk1_i,   // Second clock input
  output logic clk_o     // XORed clock output
);

  tc_clk_xor2 i_tc_clk_xor2 (
    .clk0_i,
    .clk1_i,
    .clk_o
  );

endmodule

//------------------------------------------------------------------------------
// pulp_clock_delay - Clock Delay for Simulation
//------------------------------------------------------------------------------
// Description: Simulation-only clock delay element (300ps)
//------------------------------------------------------------------------------
`ifndef SYNTHESIS
module pulp_clock_delay(
  input  logic in_i,     // Input signal
  output logic out_o     // Delayed output signal
);
  /* verilator lint_off ASSIGNDLY */
  assign #(300ps) out_o = in_i;
  /* verilator lint_on ASSIGNDLY */
endmodule
`endif

//==============================================================================
// End of File
//==============================================================================
