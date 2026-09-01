/*-------------------------------------------------------------------------
File name   : timer_agent.sv
Project     :  UVC
---------------------------------------------------------------------------*/

class timer_agent extends uvm_agent;

    uvm_active_passive_enum is_active = UVM_ACTIVE;
    int agent_id;

	timer_config cfg;
    timer_driver drv;
    timer_sequencer sqr;
    timer_monitor mon;
  
    // Provide implementations of virtual methods such as get_type_name and create
    `uvm_component_utils_begin(timer_agent)
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
	extern virtual function void update_config(timer_config cfg);
  
endclass:timer_agent

// build
function void timer_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);
	// Configure
	if (cfg == null) begin
		if (!uvm_config_db#(timer_config)::get(this, "", "cfg", cfg)) begin
		`uvm_warning("NOCONFIG", $sformatf("Config not set for spi agent %0d , using default is_active field",agent_id))
		cfg = timer_config::type_id::create("cfg");
		end
	end
    if(cfg != null) begin
	is_active = cfg.is_active;
	end
	mon = timer_monitor::type_id::create("mon", this);
    mon.cfg = cfg;

	// Create Driver and Sequencer only in ACTIVE mode
        if (is_active == UVM_ACTIVE) begin
            sqr = timer_sequencer::type_id::create("sqr", this);
            drv = timer_driver::type_id::create("drv", this);
            drv.cfg = cfg;
            `uvm_info(get_full_name(), "Timer Agent configured as ACTIVE", UVM_LOW)
        end
        else begin
            `uvm_info(get_full_name(), "Timer Agent configured as PASSIVE", UVM_LOW)
        end	
endfunction

// connect
function void timer_agent::connect_phase(uvm_phase phase);
	if(is_active == UVM_ACTIVE) begin
		drv.seq_item_port.connect(sqr.seq_item_export);
	end
endfunction

// Assign the config to the agent's children
function void timer_agent::update_config(timer_config cfg);
	mon.cfg = cfg;
	if (is_active == UVM_ACTIVE) begin
	drv.cfg = cfg;
	end
endfunction : update_config

  
