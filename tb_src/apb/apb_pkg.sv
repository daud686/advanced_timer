/*-------------------------------------------------------------------------
File name   : apb_pkg.sv
Project     :  advanced timer
---------------------------------------------------------------------------*/

package apb_pkg;
    
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    //////////////////////////////////////////////////
    //        UVM Class Forward Declarations        //
    //////////////////////////////////////////////////
    
    typedef class apb_agent;
    typedef class apb_driver;
    typedef class apb_env;
    typedef class apb_monitor;
    //typedef class apb_seq_lib;
    typedef class apb_sequencer;
    typedef class apb_transaction;
    
    //////////////////////////////////////////////////
    //              Include files                   //
    //////////////////////////////////////////////////
    `include "apb_transaction.sv"
    `include "apb_config.sv"   
    `include "apb_monitor.sv"
    `include "apb_sequencer.sv"
    `include "apb_driver.sv"
    `include "apb_agent.sv"  
    `include "apb_env.sv"   
    `include "apb_seq_lib.sv"
    
endpackage
    