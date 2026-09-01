/*-------------------------------------------------------------------------
File name   : wb_sequencer.sv
Project     : WB UVC
---------------------------------------------------------------------------*/

class wb_sequencer extends uvm_sequencer #(wb_transaction);
    `uvm_component_utils(wb_sequencer)
    
      // new - constructor
      function new (string name, uvm_component parent);
        super.new(name, parent);
      endfunction : new
    
    endclass