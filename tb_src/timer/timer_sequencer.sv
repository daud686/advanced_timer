/*-------------------------------------------------------------------------
File name   : spi_sequencer.sv
Project     : SPI UVC
---------------------------------------------------------------------------*/

class timer_sequencer extends uvm_sequencer #(timer_transaction);
    `uvm_component_utils(timer_sequencer)
      // new - constructor
      function new (string name, uvm_component parent);
        super.new(name, parent);
      endfunction : new
    
endclass