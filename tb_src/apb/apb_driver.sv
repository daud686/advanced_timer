//===================================================================
// File: apb_driver.sv
// Description: APB driver - drives APB transactions to the interface
//===================================================================

class apb_driver extends uvm_driver #(apb_transaction);
    
    `uvm_component_utils(apb_driver)

    // Virtual interface handle
    virtual apb_interface vif;

    // Configuration object (uncomment and use if you actually need it)
    apb_config cfg;

    // Constructor
    function new(string name = "apb_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    //================================================================
    // Build phase
    //================================================================
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Get configuration (optional - only if you really use cfg)
        if (!uvm_config_db#(apb_config)::get(this, "", "cfg", cfg)) begin
            `uvm_warning(get_type_name(), "No apb_config found - using defaults")
            // You can create default config here if needed
            // cfg = apb_config::type_id::create("cfg");
        end

        // Get virtual interface - mandatory
        if (!uvm_config_db#(virtual apb_interface)::get(this, "", "vif", vif)) begin
            `uvm_fatal(get_type_name(), "Virtual interface 'vif' not set in config_db")
        end
    endfunction : build_phase

    //================================================================
    // Connect phase (optional - usually not needed in driver)
    //================================================================
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        // Most drivers don't need anything here
    endfunction : connect_phase

    //================================================================
    // Run phase - main driver loop
    //================================================================
    virtual task run_phase(uvm_phase phase);
        apb_transaction req;

        // Wait for reset de-assertion before starting activity
	`uvm_info(get_type_name(), "before Reset", UVM_LOW)
        wait (vif.HRESETn === 1'b1);
        @(posedge vif.HCLK);  // synchronize to first clock after reset
	`uvm_info(get_type_name(), "after Reset", UVM_LOW)


        forever begin
            // Drive idle values at the beginning of each potential transfer
            `uvm_info(get_type_name(), "in the APB ", UVM_LOW)
            vif.PSEL    <= 1'b0;
            vif.PENABLE <= 1'b0;
            vif.PWRITE  <= 1'b0;
            vif.PADDR   <= '0;
            vif.PWDATA  <= '0;
            vif.dft_cg_enable_i <= 1'b0;
            vif.ext_sig_i       <= 32'h0000_0000;

            // Get next item from sequencer
            seq_item_port.get_next_item(req);

            // Drive the transaction
            drive(req);
            `uvm_info(get_type_name(), $sformatf("transaction delay %0d ", req.delay), UVM_LOW)
            `uvm_info(get_type_name(), $sformatf("Full transaction fields %0p ", req), UVM_LOW)
            repeat(req.delay) @(posedge vif.HCLK);
            
            `uvm_info(get_type_name(),
                      $sformatf("Finished driving transaction:\n%s", req.sprint()),
                      UVM_HIGH)

            // Signal completion to sequencer
            seq_item_port.item_done();
            `uvm_info(get_type_name(), "transaction done  ", UVM_LOW)
    
        end

        
    endtask : run_phase

    //================================================================
    // Drive one transaction (APB protocol implementation)
    //================================================================
    virtual task drive(apb_transaction req);
        `uvm_info(get_type_name(), "in the drive task  ", UVM_LOW)
        // Setup phase (address + control)
        @(posedge vif.HCLK);
        if(req.PSEL == 1) begin
            vif.PADDR   <= req.PADDR;
            vif.PWDATA  <= req.PWDATA;
            vif.PWRITE  <= req.PWRITE;
            vif.PSEL    <= 1'b1;
            vif.PENABLE <= 1'b0;
        end
        vif.dft_cg_enable_i <= req.dft_cg_enable_i;
        vif.ext_sig_i       <= req.ext_sig_i; 

        // Access phase
        if(req.PSEL == 1) begin
            @(posedge vif.HCLK);
            vif.PENABLE <= 1'b1;
            wait (vif.PREADY === 1'b1);
            req.PRDATA = vif.PRDATA;
            @(posedge vif.HCLK);
            // Deassert control signals
            vif.PSEL    <= 1'b0;
            vif.PENABLE <= 1'b0;
        end

        // Wait for slave to accept the transfer
       

        // Hold signals until end of transfer (one cycle after PREADY)
        

    endtask : drive

endclass : apb_driver



































/*class apb_driver extends uvm_driver #(apb_transaction);
	`uvm_component_utils(apb_driver)

	virtual apb_interface vif;
  	//uart_config 				cfg; // Handle to  a cfg class
	apb_config 					apb_cfg; 

	function new (string name = "apb_driver", uvm_component parent = null);
		super.new(name, parent);
	endfunction : new

	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);
	extern virtual task drive(apb_transaction req);  

endclass

  	// --------------------------------------- 
  	// build phase
  	// ---------------------------------------
  	function void apb_driver::build_phase(uvm_phase phase);
  		super.build_phase(phase);  
		//if(!uvm_config_db#(uart_config)::get(this, "", "cfg", cfg))
		//	`uvm_fatal("No cfg",{"Configuration must be set for: ",get_full_name(),".cfg"});
		//if(!uvm_config_db#(apb_config)::get(this, "", "apb_cfg", apb_cfg))
		//	`uvm_fatal("No apb_cfg",{"Configuration must be set for: ",get_full_name()});
  	endfunction: build_phase

	// --------------------------------------- 
  	// Conenct phase
  	// ---------------------------------------
	function void apb_driver::connect_phase(uvm_phase phase);
        super.connect_phase(phase);
	   	if (!uvm_config_db#(virtual apb_interface)::get(this, "", "vif", vif))
            `uvm_fatal("NO_VIF", {"Virtual interface must be set for ", get_full_name(), ".vif"}); 
    endfunction : connect_phase  

  	// ---------------------------------------  
  	//  run phase
  	// ---------------------------------------  
  	// task apb_driver::run_phase(uvm_phase phase);
  	// 	apb_transaction req;
  	//   	forever 
  	//   	begin
	// 		@(posedge vif.PCLK iff (vif.PRESETn))
	// 		vif.PSEL		<= 0;
	// 		vif.PENABLE		<= 0;  
	// 		vif.PWRITE		<= 0;
  	//   		vif.PWDATA		<= 0;
  	//   		vif.PADDR		<= 0;  
  	//     	seq_item_port.get_next_item(req);
  	//     	drive(req);
 	// 		`uvm_info("APB_DRIVER_TR", $sformatf("APB Finished Driving Transfer \n%s",req.sprint()), UVM_HIGH)
  	//     	seq_item_port.item_done();
  	//   	end
  	// endtask : run_phase

	task apb_driver::run_phase(uvm_phase phase);
    apb_transaction req;

    // Wait until reset is de-asserted before starting any activity
    wait (vif.HRESETn === 1'b1);

    forever begin
        // Wait for clock edge + make sure we're still out of reset
        @(posedge vif.HCLK iff vif.HRESETn);

        // Drive bus to idle state at the beginning of each potential transfer
        vif.PSEL    <= 1'b0;
        vif.PENABLE <= 1'b0;
        vif.PWRITE  <= 1'b0;
        vif.PWDATA  <= 32'h0000_0000;
        vif.PADDR   <= 12'h000;

        // Get next transaction from sequencer
        seq_item_port.get_next_item(req);

        // Drive the actual transaction
        drive(req);

        // Report completion (same style as you had)
        `uvm_info("APB_DRIVER_TR", 
                  $sformatf("APB Finished Driving Transfer \n%s", req.sprint()), 
                  UVM_HIGH)

        // Tell sequencer we're done with this item
        seq_item_port.item_done();
    end
endtask : run_phase
	
  	//---------------------------------------------------------
  	// drive - transaction level to signal level
  	// drives the value's from seq_item to interface signals
  	//--------------------------------------------------------
    
task apb_driver::drive(apb_transaction req);
    vif.PSEL    <= 1'b1;
    vif.PENABLE <= 1'b0;
    vif.PWRITE  <= req.PWRITE;
    vif.PADDR   <= req.PADDR;
    vif.PWDATA  <= req.PWDATA;

    @(posedge vif.HCLK);
    vif.PENABLE <= 1'b1;

    wait(vif.PREADY);           // wait for slave ready

    vif.PSEL    <= 1'b0;
    vif.PENABLE <= 1'b0;

    wait(!vif.PREADY);          // wait for ready to drop (optional)
endtask

*/