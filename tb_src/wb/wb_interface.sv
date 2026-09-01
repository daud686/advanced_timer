/*-------------------------------------------------------------------------
File name   : wb_interface.sv
Project     : WB UVC
---------------------------------------------------------------------------*/
/*
interface wb_interface(input logic wb_clk_i, wb_rst_i);

    // Control flags
    bit                has_checks = 1;
    bit                has_coverage = 1;
  
    // Actual Signals
  
  logic                     [4:0] wb_adr_i;	    
  logic                     [32-1:0] wb_dat_i;      // databus input  
  logic                     [32-1:0] wb_dat_o;      // databus output

  logic                     [3:0] wb_sel_i;         // byte select inputs
  logic                           wb_we_i;          // write enable input
  logic                           wb_stb_i;         // stobe/core select signal
  logic                           wb_cyc_i;         // valid bus cycle input
  logic                           wb_ack_o;         // bus cycle acknowledge output
  logic                           wb_err_o;         // termination w/ error
  logic                           wb_int_o;         // interrupt request signal output


  

  clocking wb_cb_drv@(negedge wb_clk_i);
    output wb_adr_i, wb_dat_i, wb_sel_i, wb_we_i, wb_stb_i, wb_cyc_i;
    input wb_dat_o, wb_ack_o, wb_err_o, wb_int_o;	
  endclocking

  clocking wb_cb_mon@(posedge wb_clk_i);
    input wb_adr_i, wb_dat_i, wb_sel_i, wb_we_i, wb_stb_i, wb_cyc_i,
    wb_dat_o, wb_ack_o, wb_err_o, wb_int_o;	
  endclocking    

  covergroup cg_wb @(posedge wb_clk_i);
     

     coverpoint wb_adr_i{ 
       bins wb_adr_i_tx_0 = {5'h0};
       bins wb_adr_i_tx_1 = {5'h4};
       bins wb_adr_i_tx_2 = {5'h8};
       bins wb_adr_i_tx_3 = {5'hc};
       bins wb_adr_i_cntrl = {5'h10};
       bins wb_adr_i_divider = {5'h14};
       bins wb_adr_i_ss = {5'h18};
    }
    cp_rx_reg_0: coverpoint wb_dat_o iff (wb_adr_i == 5'h00){
      option.auto_bin_max = 8;
    }
    cp_rx_reg_1: coverpoint wb_dat_o iff (wb_adr_i == 5'h04){
      option.auto_bin_max = 8;
    }
    cp_rx_reg_2: coverpoint wb_dat_o iff (wb_adr_i == 5'h08){
      option.auto_bin_max = 8;
    }
    cp_rx_reg_3: coverpoint wb_dat_o iff (wb_adr_i == 5'h0c){
      option.auto_bin_max = 8;
    }
    cp_tx_reg_0: coverpoint wb_dat_i iff (wb_adr_i == 5'h00){
      option.auto_bin_max = 8; 
    }
    cp_tx_reg_1: coverpoint wb_dat_i iff (wb_adr_i == 5'h04){
      option.auto_bin_max = 8;
    }
    cp_tx_reg_2: coverpoint wb_dat_i iff (wb_adr_i == 5'h08){
      option.auto_bin_max = 8;
    }
    cp_tx_reg_3: coverpoint wb_dat_i iff (wb_adr_i == 5'h0c){
      option.auto_bin_max = 8;
    }
    cp_cntrl_reg_go_zero: coverpoint wb_dat_i iff ((wb_adr_i == 5'h10) &&(wb_dat_i[8]==0)){
      bins wb_dat_i_go_zero = {[32'h0:32'hffffff]};
    }
    cp_cntrl_reg_go_one: coverpoint wb_dat_i iff ((wb_adr_i == 5'h10) &&(wb_dat_i[8]==1)){
      // bins wb_dat_i_go_one = {[32'h0:32'hffffff]};
      option.auto_bin_max = 2; 
    }
    cp_cntrl_reg_lsb: coverpoint wb_dat_i iff ((wb_adr_i == 5'h10) &&(wb_dat_i[11]==1)){
      option.auto_bin_max = 2;
    }
    cp_cntrl_reg_msb: coverpoint wb_dat_i iff ((wb_adr_i == 5'h10) &&(wb_dat_i[11]==0)){
      option.auto_bin_max = 2;
    }
    cp_cntrl_reg_rising_edge: coverpoint wb_dat_i iff ((wb_adr_i == 5'h10) &&(wb_dat_i[10:9]==2'b01)){
      bins wb_dat_i_3 = {[32'h0:32'hffffff]};
    }
    cp_cntrl_reg_falling_edge: coverpoint wb_dat_i iff ((wb_adr_i == 5'h10) &&(wb_dat_i[10:9]==2'b10)){

      bins wb_dat_i_4 = {[32'h0:32'hffffff]};
    }
    cp_cntrl_reg_char_length: coverpoint wb_dat_i[6:0] iff ((wb_adr_i == 5'h10) ){
      option.auto_bin_max = 4 ; 
    }
    cp_cntrl_reg_ie: coverpoint wb_dat_i iff ((wb_adr_i == 5'h10) &&(wb_dat_i[12]==1)){
      bins wb_dat_i_5 = {[32'h0:32'hffffff]};
    }
    cp_cntrl_reg_ass: coverpoint wb_dat_i iff ((wb_adr_i == 5'h10) &&(wb_dat_i[13]==1)){
      bins wb_dat_i_6 = {[32'h0:32'hffffff]};
    }
    cp_divider_reg: coverpoint wb_dat_i[2:0] iff (wb_adr_i == 5'h14){
      option.auto_bin_max = 3 ; 
    }
    cp_ss_reg: coverpoint wb_dat_i [7:0]  iff (wb_adr_i == 5'h18){
       bins wb_dat_i_ss_8 = {8'd128};
       bins wb_dat_i_ss_7 = {8'd64};
       bins wb_dat_i_ss_6 = {8'd32};
       bins wb_dat_i_ss_5 = {8'd16};
       bins wb_dat_i_ss_4 = {8'd8};
       bins wb_dat_i_ss_3 = {8'd4};
       bins wb_dat_i_ss_2 = {8'd2};
       bins wb_dat_i_ss_1 = {8'd1};
    }

    coverpoint wb_sel_i {
      bins wb_sel_i_0 = {4'hf};
    }
    coverpoint wb_we_i;
    coverpoint wb_stb_i;
    coverpoint wb_cyc_i;
    coverpoint wb_ack_o;
    coverpoint wb_int_o;
    //cross_1: cross wb_we_i, cp_tx_reg_0;

endgroup
    cg_wb cg_wb_ = new();
  
  endinterface : wb_interface
  
  */

 






    // // Common modports (sirf do — basic use ke liye kaafi)
    // modport master (
    //     output PSEL,
    //     output PENABLE,
    //     output PWRITE,
    //     output PADDR,
    //     output PWDATA,
    //     input  PRDATA,
    //     input  PREADY,
    //     input  PSLVERR
    // );

    // modport slave (
    //     input  PSEL,
    //     input  PENABLE,
    //     input  PWRITE,
    //     input  PADDR,
    //     input  PWDATA,
    //     output PRDATA,
    //     output PREADY,
    //     output PSLVERR
    // );



