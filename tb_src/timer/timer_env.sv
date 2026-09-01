/*-------------------------------------------------------------------------
File name   : wb_env.sv
Project     : WB UVC
---------------------------------------------------------------------------*/

class timer_env extends uvm_env;
    //`uvm_component_utils(apb_env)

	uvm_analysis_imp#(timer_config, timer_env) timer_cfg_port_in;

	timer_config cfg;
  
	// Virtual Interface variable
	protected virtual timer_interface tim_vif;
  
	// Control properties
	protected int unsigned num_agents = 1;
  
	// The following two bits are used to control whether checks and coverage are
	// done both in the bus monitor class and the interface.
	bit intf_checks_enable = 1;
	bit intf_coverage_enable = 1;
  
	// Components of the environment
	timer_agent agents[];
  
	// Provide implementations of virtual methods such as get_type_name and create
	`uvm_component_utils_begin(timer_env)
	  `uvm_field_int(num_agents, UVM_ALL_ON)
	  `uvm_field_int(intf_checks_enable, UVM_ALL_ON)
	  `uvm_field_int(intf_coverage_enable, UVM_ALL_ON)
	`uvm_component_utils_end
  
	// new - constructor
	function new(string name, uvm_component parent);
	  super.new(name, parent);
	  timer_cfg_port_in = new ("timer_cfg_port_in", this);
	endfunction : new

  // Additional class methods
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void write(input timer_config cfg );
  extern virtual protected task update_vif_enables();
  extern virtual task run_phase(uvm_phase phase);

endclass:timer_env

	function void timer_env::build_phase(uvm_phase phase);
	string inst_name;
	agents = new[num_agents];
	  super.build_phase(phase);
	  // get config object
	if(!uvm_config_db#(timer_config)::get(this, "", "cfg", cfg)) begin
		// if not in config_db create one with default values
		`uvm_warning(get_type_name(),"Default timer CONFIG OBJ is created")
		cfg = timer_config::type_id::create("cfg", this);
	end
	  // get virtual interface
	  if (!uvm_config_db#(virtual timer_interface)::get(this, "", "tim_vif", tim_vif))
            `uvm_warning(get_type_name(), "timer_interface not found in config_db")

    agents = new[num_agents];
	  for(int i = 0; i < num_agents; i++) begin
		$sformat(inst_name, "agents[%0d]", i);
		agents[i] = timer_agent::type_id::create(inst_name, this);
		agents[i].agent_id = i;
		// set the virtual intf for all components in this env
		uvm_config_db#(virtual timer_interface)::set(this, $sformatf("%s*",inst_name), "tim_vif", tim_vif);
	  end
	  `uvm_info(get_type_name(), $sformatf("Created %0d timer agent(s)", num_agents), UVM_LOW)
	endfunction
  
  function void timer_env::write(input timer_config cfg);
	for(int i = 0; i < num_agents; i++) begin
	  agents[i].update_config(cfg);
	end
  endfunction

	// update_vif_enables
	task timer_env::update_vif_enables();
	  forever begin
		//@(intf_checks_enable || intf_coverage_enable);
		//vif.has_checks <= intf_checks_enable;
		//vif.has_coverage <= intf_coverage_enable;
	  end
	endtask : update_vif_enables
  
	// implement run task
    task timer_env::run_phase(uvm_phase phase);
	  fork
		//update_vif_enables();
	  join
	endtask
  
  
