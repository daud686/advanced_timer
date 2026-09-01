 interface timer_interface;

    logic                      dft_cg_enable_i;
    logic                      low_speed_clk_i;
    logic     [31:0]           ext_sig_i;

    logic                [3:0] ch_o; 
    //logic                [3:0] ch_1_o; 
    //logic                [3:0] ch_2_o; 
    //logic                [3:0] ch_3_o;
    logic              [3:0]  events_o;
    logic [31:0] timer_counter_o;

    logic HCLK;
    logic HRESETn; 

    clocking cb @(posedge HCLK);
      output dft_cg_enable_i;
      output ext_sig_i;
      input  ch_o, timer_counter_o, events_o;
    endclocking

    modport tb (
        output dft_cg_enable_i, low_speed_clk_i, ext_sig_i, 
        input  ch_o, events_o, timer_counter_o,
        input HCLK, HRESETn 
    );

 endinterface