/*-------------------------------------------------------------------------
File name   : apb_agent.sv
Project     : WB UVC
---------------------------------------------------------------------------*/

class apb_agent extends uvm_agent;

    uvm_active_passive_enum is_active = UVM_ACTIVE;
    int agent_id;

	apb_config cfg;
    apb_driver drv;
    apb_sequencer sqr;
    apb_monitor mon;
  
    // Provide implementations of virtual methods such as get_type_name and create
    `uvm_component_utils_begin(apb_agent)
      `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
      `uvm_field_int(agent_id, UVM_ALL_ON)
    `uvm_component_utils_end
  
    // new - constructor
    function new (string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new

  // Additional class methods
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
	extern virtual function void update_config(apb_config cfg);
  
endclass:apb_agent

// build
function void apb_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);
	// Configure
	if (cfg == null) begin
		`uvm_warning("NOCONFIG", $sformatf("Config not set for spi agent %0d , using default is_active field",agent_id))
		cfg = apb_config::type_id::create("cfg");
		cfg.is_active = is_active;
	end
	else is_active = cfg.is_active;
	mon = apb_monitor::type_id::create("mon", this);
	mon.cfg=cfg;
	if(is_active == UVM_ACTIVE) begin
		sqr = apb_sequencer::type_id::create("sqr", this);
		drv = apb_driver::type_id::create("drv", this);
		drv.cfg=cfg;
	end
endfunction

// connect
function void apb_agent::connect_phase(uvm_phase phase);
	if(is_active == UVM_ACTIVE) begin
		drv.seq_item_port.connect(sqr.seq_item_export);
	end
endfunction

// Assign the config to the agent's children
function void apb_agent::update_config(apb_config cfg);
	mon.cfg = cfg;
	if (is_active == UVM_ACTIVE) begin
	drv.cfg = cfg;
	end
endfunction : update_config

  
