
package timer_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    //////////////////////////////////////////////////
    //        UVM Class Forward Declarations        //
    //////////////////////////////////////////////////
    
    typedef class timer_agent;
    typedef class timer_driver;
    typedef class timer_env;
    typedef class timer_monitor;
    typedef class timer_sequencer;
    typedef class timer_transaction;
    
    //////////////////////////////////////////////////
    //              Include files                   //
    //////////////////////////////////////////////////
    `include "timer_transaction.sv"
    `include "timer_config.sv"
    
    `include "timer_monitor.sv"
    `include "timer_sequencer.sv"
    `include "timer_driver.sv"
    `include "timer_agent.sv"
    
    `include "timer_env.sv"
    
    `include "timer_seq_lib.sv"
    
    endpackage
    