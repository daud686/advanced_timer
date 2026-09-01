/*-------------------------------------------------------------------------
File name   : wb_monitor.sv
Project     : WB UVC
---------------------------------------------------------------------------*/

class wb_monitor extends uvm_monitor;

    // This property is the virtual interfaced needed for this component to
    // view HDL signals.
    protected virtual apb_interface vif;

    wb_config cfg;
  
    // Agent Id
    protected int agent_id;
  
    // Property indicating the number of transactions occuring on the wb.
	  protected int unsigned num_transactions = 0;

    // The following bit is used to control whether coverage is
    // done both in the monitor class and the interface.
    bit coverage_enable = 1;
    uvm_analysis_port #(wb_transaction) item_collected_port;
  
    // The following property holds the transaction information currently
    // begin captured (by the collect_receive_data and collect_transmit_data methods).
    apb_transaction trans_collected;
  
    // Provide implementations of virtual methods such as get_type_name and create
    `uvm_component_utils_begin(wb_monitor)
      `uvm_field_int(agent_id, UVM_ALL_ON)
      `uvm_field_int(coverage_enable, UVM_ALL_ON)
    `uvm_component_utils_end
  
    // new - constructor
    function new (string name = "", uvm_component parent = null);
      super.new(name, parent);
      item_collected_port = new("item_collected_port", this);
    endfunction : new

    // Additional class methods
	extern virtual function void build_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);
    extern virtual protected task collect_transactions();

endclass : wb_monitor

// build
function void wb_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);
	// get virtual interface
	if(!uvm_config_db#(virtual wb_interface)::get(this, "", "vif", vif))
		`uvm_fatal(get_name(),"No wb VIF is set for this instance")
endfunction

// run phase
task wb_monitor::run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Run phase wb_monitor", UVM_LOW)
    trans_collected = wb_transaction::type_id::create("trans_collected",this);
	@(negedge vif.wb_rst_i);
	`uvm_info(get_type_name(), "Detected Reset Done", UVM_LOW)
  
  collect_transactions();
  //`uvm_info("wb_driver_TR", $sformatf("WB Finished Driving Transfer \n%s",trans_collected.sprint()), UVM_NONE)
endtask
  
// collect_transactions
task wb_monitor::collect_transactions();

  forever begin
  wait(vif.wb_stb_i == 1 && vif.wb_cyc_i == 1);
  `uvm_info(get_type_name(),"getting 1 for wb_stb_in and wb_cyc_i",UVM_NONE)
  wait(vif.wb_ack_o);
  `uvm_info(get_type_name(),"getting 1 wb_ack_o",UVM_NONE)
  void'(this.begin_tr(trans_collected));
  trans_collected.wb_addr=this.vif.wb_adr_i;
  trans_collected.wb_write = this.vif.wb_we_i;
  if (trans_collected.wb_write == 0) begin
    trans_collected.wb_data=this.vif.wb_dat_o;
    $display("******************* Here *****************************");
    //`uvm_info(get_type_name(),$sformatf("Transfered collected:\n%s",trans_collected.sprint() ), UVM_NONE)
    $display("/n********* data out sampled: %0h, wb_dat_i: %0h , 0: %0b ****************",
    this.vif.wb_dat_o, this.vif.wb_dat_i, 0);
    // trans_collected.wb_data=trans_collected.wb_write?this.vif.wb_cb_mon.wb_dat_i:this.vif.wb_cb_mon.wb_dat_o;
    trans_collected.wb_select=this.vif.wb_sel_i;
    this.end_tr(trans_collected);
    item_collected_port.write(trans_collected) ; 
  end
  else
    trans_collected.wb_data=this.vif.wb_dat_i;
  
  `uvm_info(get_type_name(),$sformatf("Transfered collected:\n%s",trans_collected.sprint() ), UVM_NONE)
  repeat(2) @(vif.wb_cb_mon);
  end 
    
endtask : collect_transactions
