class clk_env extends uvm_env;
  
	`uvm_component_utils(clk_env)


    clk_rst_agent   clk_agnt;
	clk_rst_cfg   	clk_cfg;
    
    // --------------------------------------- 
    //  Calling the constructor
    // ---------------------------------------
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);

endclass : clk_env

// --------------------------------------------------------------
//  build_phase - create the components of scorebaord and agent
// --------------------------------------------------------------
function void clk_env::build_phase(uvm_phase phase);
  	super.build_phase(phase);
	clk_cfg = new();
	uvm_config_db#(clk_rst_cfg)::set(this,"*","clk_cfg",clk_cfg);
   	clk_agnt        = clk_rst_agent::type_id::create("clk_agnt", this);  

endfunction : build_phase


// ------------------------------------------------------------
//  connect_phase - connecting monitor and scoreboard port
// ------------------------------------------------------------
function void clk_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction : connect_phase
