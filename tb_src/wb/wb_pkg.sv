/*-------------------------------------------------------------------------
File name   : wb_pkg.sv
Project     : WB UVC
---------------------------------------------------------------------------*/

package wb_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    //////////////////////////////////////////////////
    //        UVM Class Forward Declarations        //
    //////////////////////////////////////////////////
    
    typedef class wb_agent;
    //typedef class apb_driver;
    typedef class wb_env;
    //typedef class wb_monitor;
    //typedef class trans_seq;
    typedef class wb_sequencer;
    //typedef class apb_transaction;
    
    //////////////////////////////////////////////////
    //              Include files                   //
    //////////////////////////////////////////////////
    `include "wb_transaction.sv"
    `include "wb_config.sv"   
    //`include "wb_monitor.sv"
    `include "wb_sequencer.sv"
    `include "wb_driver.sv"
    `include "wb_agent.sv"  
    `include "wb_env.sv"   
    `include "wb_seq_lib.sv"
    
    endpackage
    