/*-------------------------------------------------------------------------
File name   : wb_driver.sv
Project     : WB UVC
---------------------------------------------------------------------------*/

// class wb_driver extends uvm_driver #(wb_transaction);
//     wb_config cfg;
//     // The virtual interface used to drive and view HDL signals.
//     protected virtual wb_interface vif;
//     // Agent Id
//     protected int agent_id;
//     uvm_analysis_port #(wb_transaction) item_derived_port;
//     // Provide implmentations of virtual methods such as get_type_name and create
//     `uvm_component_utils_begin(wb_driver)
//       `uvm_field_int(agent_id, UVM_ALL_ON)
//     `uvm_component_utils_end
  
//     // new - constructor
//     function new (string name, uvm_component parent);
//       super.new(name, parent);
//       item_derived_port = new("item_derived_port", this);
//     endfunction : new


//       // Additional class methods
// 	extern virtual function void build_phase(uvm_phase phase);
//     extern virtual task run_phase(uvm_phase phase);
//     extern virtual protected task get_and_drive();
//     extern virtual protected task reset_signals();
//     extern virtual protected task drive_transfer (wb_transaction trans);
// 	  extern virtual task drive_write(wb_transaction trans);
//     extern virtual task drive_read(wb_transaction trans);
//   	//extern virtual task drive_write_nbyte(wb_transaction trans);
//   	//extern virtual task drive_read_nbyte(wb_transaction trans);
// endclass : wb_driver

// // build
// function void wb_driver::build_phase(uvm_phase phase);
//     super.build_phase(phase);
//     // get virtual interface
//     if(!uvm_config_db#(virtual wb_interface)::get(this, "", "vif", vif))
//         `uvm_fatal(get_name(),"No wb VIF is set for this instance")
// endfunction

// // run phase
// task wb_driver::run_phase(uvm_phase phase);
// 	fork
// 	get_and_drive();
// 	reset_signals();
// 	join
// endtask
  
// // get_and_drive
// task wb_driver::get_and_drive();
// 	wb_transaction this_trans;
// 	@(negedge vif.wb_rst_i);
//   	`uvm_info(get_type_name(), "Reset End now drive", UVM_LOW)
// 	forever begin
// 	seq_item_port.get_next_item(req);
// 	if (!$cast(this_trans, req))
// 		uvm_report_fatal("CASTFL", "Failed to cast req to this_trans in get_and_drive"); 
//   `uvm_info(get_type_name(), $sformatf("WB Start Driving Transfer \n%s",this_trans.sprint()), UVM_NONE)
//   drive_transfer(this_trans);
//   item_derived_port.write(this_trans);
// 	seq_item_port.item_done();
// 	end
// endtask : get_and_drive
  
// // reset_signals
// task wb_driver::reset_signals();
// 	@(posedge vif.wb_rst_i);
// 	`uvm_info(get_type_name(), "Reset Observed", UVM_LOW)
// 	// update 
//   vif.wb_dat_i <=0;
//   vif.wb_adr_i <=0;
//   vif.wb_sel_i <=0;
//   vif.wb_we_i  <=0;
//   vif.wb_cyc_i <=0;
//   vif.wb_stb_i <=0;
//   //vif.wb_ack_o <=0;
//   //vif.wb_data_out <=0;

// endtask : reset_signals
  
// // drive_transfer
// task wb_driver::drive_transfer (wb_transaction trans);
// 	// update yourself
//   `uvm_info(get_type_name(),"drive transfer function",UVM_NONE)
//   //@(posedge vif.wb_clk_i);  
//   if (trans.wb_write== 1)
//     drive_write(trans); 
//   else
//     drive_read(trans);   
// endtask : drive_transfer

// task wb_driver::drive_read(wb_transaction trans);
//   `uvm_info(get_type_name(),"Started READING Transaction=============",UVM_NONE)
//   @(vif.wb_cb_drv);
//   this.vif.wb_cb_drv.wb_cyc_i<=1;
//   this.vif.wb_cb_drv.wb_stb_i<=1;
//   this.vif.wb_cb_drv.wb_we_i <=0;
//   this.vif.wb_cb_drv.wb_adr_i<=trans.wb_addr;
//   this.vif.wb_cb_drv.wb_dat_i<=32'hx;
//   //this.vif.wb_cb_drv.wb_sel_i<=trans.wb_select;
//   this.vif.wb_cb_drv.wb_sel_i<=4'b1111;
//   @(vif.wb_cb_drv.wb_ack_o);
//   @(vif.wb_cb_drv);
//   this.vif.wb_cb_drv.wb_stb_i<=0;
//   this.vif.wb_cb_drv.wb_cyc_i<=0; 
//   //@(vif.wb_cb_drv);
// endtask: drive_read

// task wb_driver::drive_write(wb_transaction trans);
//   `uvm_info(get_type_name(),"Started WRITING Transaction=============",UVM_NONE)
//   @(vif.wb_cb_drv);
//   this.vif.wb_cb_drv.wb_cyc_i<=1;
//   this.vif.wb_cb_drv.wb_stb_i<=1;
//   this.vif.wb_cb_drv.wb_we_i<=1;
//   this.vif.wb_cb_drv.wb_adr_i<=trans.wb_addr;
//   this.vif.wb_cb_drv.wb_dat_i<=trans.wb_data;
//   //this.vif.wb_cb_drv.wb_sel_i<=trans.wb_select;
//   this.vif.wb_cb_drv.wb_sel_i<=4'b1111;
//   @(vif.wb_cb_drv.wb_ack_o);                                                                                
//   `uvm_info(get_type_name(),"getting 1 wb_ack_o",UVM_NONE)
//   @(vif.wb_cb_drv);
//   `uvm_info(get_type_name(),"getting 1 wb_ack_o  after 1 clockedge",UVM_NONE)
//   this.vif.wb_cb_drv.wb_stb_i<=0;
//   this.vif.wb_cb_drv.wb_cyc_i<=0; 
//   this.vif.wb_cb_drv.wb_we_i<=0;

// endtask: drive_write


