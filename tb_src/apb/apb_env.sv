/*-------------------------------------------------------------------------
File name   : wb_env.sv
Project     : WB UVC
---------------------------------------------------------------------------*/

class apb_env extends uvm_env;
    //`uvm_component_utils(apb_env)

	uvm_analysis_imp#(apb_config, apb_env) apb_cfg_port_in;

	apb_config cfg;
  
	// Virtual Interface variable
	protected virtual apb_interface vif;
  
	// Control properties
	protected int unsigned num_agents = 1;
  
	// The following two bits are used to control whether checks and coverage are
	// done both in the bus monitor class and the interface.
	bit intf_checks_enable = 1;
	bit intf_coverage_enable = 1;
  
	// Components of the environment
	apb_agent agents[];
  
	// Provide implementations of virtual methods such as get_type_name and create
	`uvm_component_utils_begin(apb_env)
	  `uvm_field_int(num_agents, UVM_ALL_ON)
	  `uvm_field_int(intf_checks_enable, UVM_ALL_ON)
	  `uvm_field_int(intf_coverage_enable, UVM_ALL_ON)
	`uvm_component_utils_end
  
	// new - constructor
	function new(string name, uvm_component parent);
	  super.new(name, parent);
	  apb_cfg_port_in = new ("apb_cfg_port_in", this);
	endfunction : new

  // Additional class methods
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void write(input apb_config cfg );
  extern virtual protected task update_vif_enables();
  extern virtual task run_phase(uvm_phase phase);

endclass:apb_env

	function void apb_env::build_phase(uvm_phase phase);
	string inst_name;
	agents = new[num_agents];
	  super.build_phase(phase);
	  // get config object
	if(!uvm_config_db#(apb_config)::get(this, "", "cfg", cfg)) begin
		// if not in config_db create one with default values
		`uvm_warning(get_type_name(),"Default apb CONFIG OBJ is created")
		cfg = apb_config::type_id::create("cfg", this);
	end
	  // get virtual interface
	  if(!uvm_config_db#(virtual apb_interface)::get(this, "", "vif", vif))
		`uvm_fatal(get_type_name(),"No wb VIF is set for this instance")

	  for(int i = 0; i < num_agents; i++) begin
		$sformat(inst_name, "agents[%0d]", i);
		agents[i] = apb_agent::type_id::create(inst_name, this);
		agents[i].agent_id = i;
		// set the virtual intf for all components in this env
		uvm_config_db#(virtual apb_interface)::set(this, $sformatf("%s*",inst_name), "vif", vif);
	  end
	endfunction
  
  function void apb_env::write(input apb_config cfg);
	for(int i = 0; i < num_agents; i++) begin
	  agents[i].update_config(cfg);
	end
  endfunction

	// update_vif_enables
	task apb_env::update_vif_enables();
	  forever begin
		//@(intf_checks_enable || intf_coverage_enable);
		//vif.has_checks <= intf_checks_enable;
		//vif.has_coverage <= intf_coverage_enable;
	  end
	endtask : update_vif_enables
  
	// implement run task
    task apb_env::run_phase(uvm_phase phase);
	  fork
		//update_vif_enables();
	  join
	endtask
  
  
