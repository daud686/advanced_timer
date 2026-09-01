class timer_driver extends uvm_driver #(timer_transaction);

    // Virtual interface
    protected virtual timer_interface tim_vif;

    // Configuration (recommended to have is_active from agent config)
    timer_config cfg;
    protected int agent_id;

    uvm_analysis_port #(timer_transaction) item_derived_port;

    `uvm_component_utils_begin(timer_driver)
        `uvm_field_int(agent_id, UVM_ALL_ON)
    `uvm_component_utils_end

    // Constructor
    function new(string name = "timer_driver", uvm_component parent = null);
        super.new(name, parent);
        item_derived_port = new("item_derived_port", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual timer_interface)::get(this, "", "tim_vif", tim_vif))
            `uvm_fatal(get_full_name(), "Virtual interface tim_vif not found!")

        if (!uvm_config_db#(timer_config)::get(this, "", "cfg", cfg))
            `uvm_warning(get_full_name(), "timer_config not found")
    endfunction

    // Run phase
    virtual task run_phase(uvm_phase phase);
       `uvm_info(get_type_name(), "Timer Driver (ACTIVE mode) started", UVM_LOW)

        // Active mode only
        reset_signals();
        get_and_drive();
    endtask

    virtual protected task reset_signals();
        @(tim_vif.cb);                     // Use clocking block
        tim_vif.cb.dft_cg_enable_i <= 1'b0;
        tim_vif.cb.ext_sig_i       <= 32'h0000_0000;
        // low_speed_clk_i is usually generated in TB (free running)
    endtask

    // Main driving loop (only executed in ACTIVE mode)
    virtual protected task get_and_drive();
        timer_transaction trans;

        `uvm_info(get_type_name(), "Timer Driver (ACTIVE) is running...", UVM_LOW)

        forever begin
            seq_item_port.get_next_item(req);

            if (!$cast(trans, req))
                `uvm_fatal(get_type_name(), "Failed to cast to timer_transaction")

            `uvm_info(get_type_name(), $sformatf("Driving transaction:\n%s", trans.sprint()), UVM_MEDIUM)

            drive_transfer(trans);

            seq_item_port.item_done();
        end
    endtask

    // Drive the inputs (only executed when agent is ACTIVE)
    virtual protected task drive_transfer(timer_transaction trans);

    @(tim_vif.cb);
        
        tim_vif.dft_cg_enable_i <= trans.dft_cg_enable_i;
        //tim_vif.low_speed_clk_i  <= trans.low_speed_clk_i;

        `uvm_info(get_type_name(), 
            $sformatf("DRIVEN → dft_cg_enable_i=%b | ext_sig_i=0x%8h", 
                      trans.dft_cg_enable_i, trans.ext_sig_i), 
            UVM_MEDIUM)

        // Forward the driven transaction for monitoring / coverage
        item_derived_port.write(trans);
    endtask

endclass : timer_driver





















// class timer_driver extends uvm_driver #(timer_transaction);

//     // The virtual interface used to drive and view HDL signals.
//     protected virtual timer_interface tim_vif;
  
//     timer_config cfg; 
//     // Agent Id
// 	protected int agent_id;
// 	uvm_analysis_port #(timer_transaction) item_derived_port;
// 	uvm_event ev;
	
//     // Provide implmentations of virtual methods such as get_type_name and create
//     `uvm_component_utils_begin(timer_driver)
//       `uvm_field_int(agent_id, UVM_ALL_ON)
//     `uvm_component_utils_end
  
//     // new - constructor
//     function new (string name, uvm_component parent);
// 	  super.new(name, parent);
// 	  item_derived_port = new("item_derived_port", this);
//     endfunction : new


//       // Additional class methods
// 	extern virtual function void build_phase(uvm_phase phase);
//     extern virtual task run_phase(uvm_phase phase);
//     extern virtual protected task get_and_drive();
//     extern virtual protected task reset_signals();
//     extern virtual protected task drive_transfer (timer_transaction trans);
  
// endclass : timer_driver

// // build
// function void timerdriver::build_phase(uvm_phase phase);
//     super.build_phase(phase);
//     // get virtual interface
//     if(!uvm_config_db#(virtual timer_interface)::get(this, "", "tim_vif", tim_vif))
//         `uvm_fatal(get_name(),"No tim_vif is set for this instance")
// endfunction

// // run phase
// task timer_driver::run_phase(uvm_phase phase);

//         if (get_is_active() == UVM_PASSIVE) begin
//             `uvm_info(get_type_name(), "Agent is PASSIVE → Driver is inactive (monitoring only)", UVM_LOW)
//             return;   // Driver does nothing in passive mode
//         end
// 	fork
// 	get_and_drive();
// 	reset_signals();
// 	join
// endtask
  
// // get_and_drive
// task timer_driver::get_and_drive();
// 	timer_transaction this_trans;
// 	ev = uvm_event_pool::get_global("ev_ab");
// 	`uvm_info(get_type_name(), "Timer driver waiting for first transaction...", UVM_LOW)
// 	forever begin
//         seq_item_port.get_next_item(req);

//         // Safe cast
//         if (!$cast(this_trans, req))
//             `uvm_fatal(get_type_name(), "Failed to cast req to timer_transaction")

//         `uvm_info(get_type_name(), 
//                   $sformatf("Starting to drive transaction:\n%s", this_trans.sprint()), 
//                   UVM_MEDIUM)

//         drive_transfer(this_trans);

//         seq_item_port.item_done();
//     end
// endtask : get_and_drive
  
// // reset_signals
// task timer_driver::reset_signals();

// `uvm_info(get_type_name(), "Reset_signals: Driving default values on timer inputs", UVM_LOW)

// 	tim_vif.dft_cg_enable_i <= 1'b0;
//     tim_vif.low_speed_clk_i  <= 1'b0;
//     tim_vif.ext_sig_i        <= 32'h0000_0000;
	
// endtask : reset_signals
  
// // drive_transfer
// task timer_driver::drive_transfer (tim_transaction trans);


// tim_vif.dft_cg_enable_i <= trans.dft_cg_enable_i;
//     tim_vif.low_speed_clk_i  <= trans.low_speed_clk_i;
//     tim_vif.ext_sig_i        <= trans.ext_sig_i;


// 	`uvm_info(get_type_name(), 
//         $sformatf("DRIVEN → dft_cg_enable_i=%b | low_speed_clk_i=%b | ext_sig_i=0x%8h",
//                   trans.dft_cg_enable_i, trans.low_speed_clk_i, trans.ext_sig_i),
//         UVM_LOW)


// 		item_derived_port.write(trans);

// 		`uvm_info(get_type_name(), "Before triggering event 'ev_ab'", UVM_LOW)
//     ev.trigger();
//     `uvm_info(get_type_name(), "After triggering event 'ev_ab'", UVM_LOW)

// endtask : drive_transfer








//  // Optional: wait for PREADY to go low again (some slaves require it)
//         // wait (vif.PREADY === 1'b0);
//           // Generate 40 clean rising edge pulses on ext_sig_i[0]
//     repeat(40) begin
//       vif.ext_sig_i[0] <= 1'b0;
//       repeat(5) @(posedge vif.HCLK);
//       vif.ext_sig_i[0] <= 1'b1;      // Rising edge
//       repeat(5) @(posedge vif.HCLK);
//       vif.ext_sig_i[0] <= 1'b0;
//       repeat(10) @(posedge vif.HCLK);
//     end
