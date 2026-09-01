 interface apb_interface #(parameter ADDR_WIDTH = 12,
                           parameter DATA_WIDTH = 32);
    logic HCLK;
    logic HRESETn;

    // APB Master to Slave
    logic                      PSEL;
    logic                      PENABLE;
    logic                      PWRITE;
    logic [ADDR_WIDTH-1:0]     PADDR;
    logic [DATA_WIDTH-1:0]     PWDATA;
    logic                      dft_cg_enable_i;
    logic                      low_speed_clk_i;
    logic     [DATA_WIDTH-1:0] ext_sig_i;

    logic                [3:0] ch_o; 
    logic              [3:0]  events_o;
    logic [DATA_WIDTH-1:0] timer_counter_o;

    // APB Slave to Master
    logic [DATA_WIDTH-1:0]     PRDATA;
    logic                      PREADY;
    logic                      PSLVERR;

    modport tb (
        input  HCLK, HRESETn,
        input  PRDATA, PREADY, PSLVERR, ch_o, events_o, timer_counter_o,
        output PSEL, PENABLE, PWRITE, PADDR, PWDATA, dft_cg_enable_i, low_speed_clk_i, ext_sig_i
    );

 endinterface