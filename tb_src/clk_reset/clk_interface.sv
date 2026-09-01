
interface clk_rst_interface (
    output logic wb_rst_i,
    output logic wb_clk_i
  );
  //import clk_rst_pkg::*;
  logic reset_n_drv = 'z;
  logic clk_drv = 'z;
    
  // TBD do we need the 2 modports at all?
  modport driver (
    output wb_rst_i     ,
    output wb_clk_i         ,
    output reset_n_drv ,
    output clk_drv
  );

  modport monitor (
    input  wb_rst_i     ,
    input  wb_clk_i
  );
  // Drivable signals (not net type). Defaults to 'z so it works when the agent is passive

  // Continous assignments to drive the modport wires
  assign wb_rst_i = reset_n_drv;
  assign wb_clk_i     = clk_drv;

  bit first_reset_started = 0;

  initial begin
    wait ($isunknown({wb_rst_i, wb_clk_i}) == 1'b0);
    fork
      forever @({wb_rst_i, wb_clk_i}) begin
          assert ($isunknown({wb_rst_i, wb_clk_i}) == 1'b0); // From the moment both reset_n and clk become valid, they can never again be unknown.
        end
      begin
        wait (wb_rst_i == 1'b0); // TBD is this needed?
        first_reset_started = 1;
      end
    join
  end

endinterface





