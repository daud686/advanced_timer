package top_env_pkg;
    `include "uvm_macros.svh"
    //-----------------Importing uvm package-------------------
    import uvm_pkg::*;
    
    //---------------------Import agents' pkgs---------------------
    //import timer_pkg::*;
    import apb_pkg::*;
	
    //---------------------Files Inclusion---------------------
    `include "top_config.sv"
	//`include "scoreboard.sv"
    `include "top_env.sv"
endpackage:top_env_pkg
