/*-------------------------------------------------------------------------
File name   : spi_monitor.sv
Project     : SPI UVC
---------------------------------------------------------------------------*/

// Modified by WHDL to make UVM 1.2 compliant

class timer_monitor extends uvm_monitor;

    // This property is the virtual interfaced needed for this component to
    // view HDL signals.
    protected virtual timer_interface tim_vif;

    timer_config cfg;
  
    // Agent Id
    protected int agent_id;
  
    // Property indicating the number of transactions occuring on the pt.
	  protected int unsigned num_transactions = 0;

    // The following bit is used to control whether coverage is
    // done both in the monitor class and the interface.
    bit coverage_enable = 1;
  
    uvm_analysis_port #(timer_transaction) item_collected_port;
  
    // The following property holds the transaction information currently
    // begin captured (by the collect_receive_data and collect_transmit_data methods).
    protected timer_transaction trans_collected;
  
    // Provide implementations of virtual methods such as get_type_name and create
    `uvm_component_utils_begin(timer_monitor)
      `uvm_field_int(agent_id, UVM_ALL_ON)
      `uvm_field_int(coverage_enable, UVM_ALL_ON)
    `uvm_component_utils_end
  
    // new - constructor
    function new (string name = "timer_monitor", uvm_component parent = null);
      super.new(name, parent);
      item_collected_port = new("item_collected_port", this);
    endfunction : new

    // Additional class methods
	  extern virtual function void build_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);
    extern virtual protected task collect_transactions();
    extern virtual protected task reset_signals();

endclass : timer_monitor

// build
function void timer_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);
	// get virtual interface
	if(!uvm_config_db#(virtual timer_interface)::get(this, "", "tim_vif", tim_vif))
		`uvm_fatal(get_name(),"No tim_vif is set for this instance")
endfunction

// run phase
task timer_monitor::run_phase(uvm_phase phase);
  trans_collected = timer_transaction::type_id::create("trans_collected",this);
    reset_signals();
    collect_transactions(); 
endtask
  
// reset_signals
task timer_monitor::reset_signals();
	@(posedge tim_vif.HCLK);
  wait(tim_vif.HRESETn === 1'b1);
	`uvm_info(get_type_name(), "Reset Observed, monitoring started", UVM_LOW)
endtask : reset_signals

task timer_monitor::collect_transactions();

forever begin
            @(tim_vif.cb);        // Wait for clocking block edge (posedge HCLK)

            // Sample inputs (driven by driver / testbench)
            trans_collected.dft_cg_enable_i = tim_vif.dft_cg_enable_i;
            trans_collected.ext_sig_i       = tim_vif.ext_sig_i;

            // Sample outputs from DUT
            trans_collected.ch_o   = tim_vif.cb.ch_o;
            //trans_collected.ch_1_o   = tim_vif.cb.ch_1_o;
            //trans_collected.ch_2_o   = tim_vif.cb.ch_2_o;
            //trans_collected.ch_3_o   = tim_vif.cb.ch_3_o;
            trans_collected.events_o = tim_vif.cb.events_o;
            trans_collected.timer_counter_o = tim_vif.timer_counter_o; 
            // Write collected transaction to analysis port (for scoreboard & coverage)
            item_collected_port.write(trans_collected);

            num_transactions++;

            `uvm_info(get_type_name(), 
                $sformatf("Collected Transaction #%0d: %s", 
                          num_transactions, trans_collected.convert2string()), 
                UVM_HIGH)
        end
endtask : collect_transactions

  // int rdata;
  // int apb_data;
  // int length;
  // uvm_event ev2;
  
  // @(negedge tim_vif.wb_rst_i);
  // `uvm_info(get_type_name(), "Reset DONE", UVM_LOW)

  // ev2 = uvm_event_pool::get_global("ev2_seq2mon");

  // forever begin
  //   `uvm_info(get_type_name(),$sformatf(" waiting for the event trigger"),UVM_LOW)        
  //   ev2.wait_trigger;           
  //   `uvm_info(get_type_name(),$sformatf(" event got triggerd"),UVM_LOW)
  //   if(!uvm_config_db#(int)::get(this, "", "apb_data", apb_data))
	// 	  `uvm_fatal(get_name(),"No wb_data is set for this instance")
  //   else 
  //     `uvm_info(get_name(), $sformatf("apb_data = %01h", apb_data), UVM_LOW)

  //   if(apb_data[6:0]==0)
  //     length = 128;
  //   else
  //     length = apb_data[6:0];
  //   for (int i = 0; i<length; i++) begin
  //     if((apb_data[9] == 1) && (apb_data[10] == 0))
	// 	    @(negedge tim_vif.sclk_pad_o);
	//     else
	// 	    @(posedge tim_vif.sclk_pad_o);
  //     if(apb_data[11] == 1'b0)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
  //       trans_collected.rec_data 			<= {trans_collected.rec_data[126:0], apb_vif.mosi_pad_o};
  //     else
  //       trans_collected.rec_data[i] 	<= spi_vif.mosi_pad_o; 
  //     #1
  //     `uvm_info (get_type_name (), $sformatf ("\n \nTransfer data at timer mon = %h \nmosi = %b\n",trans_collected.rec_data, spi_vif.mosi_pad_o ), UVM_NONE)
  //   end 
	//   item_collected_port.write(trans_collected);
  //   // num_transactions++;
  // end

