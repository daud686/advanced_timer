
class apb_monitor extends uvm_monitor;

    // This property is the virtual interfaced needed for this component to
    // view HDL signals.
    protected virtual apb_interface vif;

    apb_config cfg;
  
    // Agent Id
    protected int agent_id;
  
    // Property indicating the number of transactions occuring on the wb.
	  protected int unsigned num_transactions = 0;

    // The following bit is used to control whether coverage is
    // done both in the monitor class and the interface.
    bit coverage_enable = 1;
    uvm_analysis_port #(apb_transaction) item_collected_port;
  
    // The following property holds the transaction information currently
    // begin captured (by the collect_receive_data and collect_transmit_data methods).
    apb_transaction trans_collected;
  
    // Provide implementations of virtual methods such as get_type_name and create
    `uvm_component_utils_begin(apb_monitor)
      `uvm_field_int(agent_id, UVM_ALL_ON)
      `uvm_field_int(coverage_enable, UVM_ALL_ON)
    `uvm_component_utils_end
  
    // new - constructor
    function new (string name = "apb_monitor", uvm_component parent = null);
      super.new(name, parent);
      item_collected_port = new("item_collected_port", this);
    endfunction : new

    // Additional class methods
	extern virtual function void build_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);
    extern virtual protected task collect_transactions();

endclass : apb_monitor

// build
function void apb_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);
	// get virtual interface
	if(!uvm_config_db#(virtual apb_interface)::get(this, "", "vif", vif))
		`uvm_fatal(get_name(),"No wb VIF is set for this instance")

endfunction

// run phase
task apb_monitor::run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Run phase apb_monitor", UVM_LOW)
    trans_collected = apb_transaction::type_id::create("trans_collected",this);
	wait(vif.HRESETn === 1'b1);
    @(posedge vif.HCLK);
	`uvm_info(get_type_name(), "Detected Reset Done", UVM_LOW)
  
  collect_transactions();
  //`uvm_info("wb_driver_TR", $sformatf("WB Finished Driving Transfer \n%s",trans_collected.sprint()), UVM_NONE)
endtask
  
// collect_transactions
task apb_monitor::collect_transactions();
forever begin
            // Wait for start of a valid APB transfer (PSEL active)
            @(posedge vif.HCLK);
            wait(vif.PSEL === 1'b1);

            // Sample Setup Phase
            trans_collected.PADDR  = vif.PADDR;
            trans_collected.PWRITE = vif.PWRITE;
            trans_collected.PWDATA = vif.PWDATA;
            trans_collected.dft_cg_enable_i = vif.PWDATA;
            trans_collected.ext_sig_i = vif.PWDATA;

            // Wait for Access Phase (PENABLE becomes high)
            @(posedge vif.HCLK);
            wait(vif.PENABLE === 1'b1);

            // Wait for slave to respond
            wait(vif.PREADY === 1'b1);

            // Sample response
            if (trans_collected.PWRITE == 1'b0) begin
                // Read transaction
                trans_collected.PRDATA = vif.PRDATA;
            end
            // For write, PWDATA was already sampled in Setup phase

            // Optional: Sample error response
            trans_collected.PSLVERR = vif.PSLVERR;

            // Record transaction timing (optional but useful)
            void'(this.begin_tr(trans_collected));

            // Send collected transaction to scoreboard / coverage
            item_collected_port.write(trans_collected);

            num_transactions++;

            `uvm_info(get_type_name(), 
                $sformatf("Collected APB Transaction #%0d (ADDR=0x%0h, WRITE=%b):\n%s", 
                          num_transactions, trans_collected.PADDR, 
                          trans_collected.PWRITE, trans_collected.sprint()), 
                UVM_MEDIUM)

            this.end_tr(trans_collected);

            // Wait for transfer to completely finish (PSEL goes low)
            wait(vif.PSEL === 1'b0);
        end    
endtask : collect_transactions
