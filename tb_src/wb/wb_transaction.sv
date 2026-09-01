/*-------------------------------------------------------------------------
File name   : wb_transaction.sv
Project     : WB UVC
---------------------------------------------------------------------------*/
/*
`define WB_DATA_WIDTH 32
`define WB_ADDRESS_WIDTH 32
`define GRANULARITY 4

class wb_transaction extends uvm_sequence_item;

    // rand variables
  typedef enum {READ,WRITE} PWRITE;
  rand logic [31 : 0]               wb_addr;
  rand logic [`WB_DATA_WIDTH-1:0]   wb_data;
  rand logic [`GRANULARITY-1 : 0]   wb_select;
  rand PWRITE wb_write;
  //rand logic wb_write;
    // constraints
  constraint c_direction { wb_write inside {READ,WRITE }; }
  constraint c_address { wb_addr inside {'h0,'h4,'h8,'hc,'h10,'h14,'h18}; }
  constraint c_control_1 { if(wb_addr==32'h10)  {wb_data[10:9]!= 2'b00};} 
  constraint c_control_2 { if(wb_addr==32'h10) {   wb_data[10:9]!= 2'b11};} 
  constraint c_ss_1 { if(wb_addr==32'h18) {   wb_data[7:0]!= 8'h00};} 
  constraint c_ss_2 { if(wb_addr==32'h18) {   wb_data[31:8] == 24'h0};} 
  constraint c_ss_one_hot { if(wb_addr==32'h18) { $countones(wb_data[7:0]) == 1};} 

  //constraint c_control { if (wb_addr==10) {wb_data[6:0] != 7'h00; } }


    // These declarations implement the create() and get_type_name() as well as enable automation of the
    // transfer fields
    `uvm_object_utils_begin(wb_transaction)
      `uvm_field_int(wb_addr,UVM_DEFAULT)
      `uvm_field_int(wb_data,UVM_DEFAULT)
      `uvm_field_enum(PWRITE,wb_write,UVM_ALL_ON)
      //`uvm_field_(wb_write,UVM_ALL_ON)
      `uvm_field_int(wb_select,UVM_ALL_ON)
    `uvm_object_utils_end
  
    function new(string name = "wb_transaction");
        super.new(name);
    endfunction
  
  endclass
  */
 