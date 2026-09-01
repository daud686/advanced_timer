
 class apb_transaction extends uvm_sequence_item;

    // Signals driven by master (testbench → DUT)
    rand logic             PWRITE;
    rand logic [31:0]      PWDATA;
    rand logic [11:0]      PADDR;     // 12 bits = ADDR_WIDTH = 12
    rand logic             dft_cg_enable_i;
    rand logic [31:0]      ext_sig_i;     // 12 bits = ADDR_WIDTH = 12
    rand logic                  PSEL;
    
    logic                  [3:0] ch_o;
    logic [31:0] timer_counter_o;
    logic              [3:0]  events_o;

    // Protocol control signals — driver will set them, not randomized
    logic                  PENABLE;

    // Signals coming back from slave (DUT → testbench)
    logic [31:0]           PRDATA;
    logic                  PREADY;
    logic                  PSLVERR;

    rand int unsigned delay;


    // Constructor
    function new(string name = "apb_transaction");
        super.new(name);
    endfunction
    
    constraint soft_delay_c {
        soft delay == 0;           // Soft constraint
        soft dft_cg_enable_i == 0;
        soft ext_sig_i == 0;
        soft PSEL == 1;
    }

    // UVM field macros — same signals, same order feel
    `uvm_object_utils_begin(apb_transaction)
        `uvm_field_int(PWRITE,   UVM_ALL_ON)
        `uvm_field_int(PWDATA,   UVM_ALL_ON)
        `uvm_field_int(PADDR,    UVM_ALL_ON)
        `uvm_field_int(PSEL,     UVM_ALL_ON)
        `uvm_field_int(PENABLE,  UVM_ALL_ON)
        `uvm_field_int(PRDATA,   UVM_ALL_ON)
        `uvm_field_int(PREADY,   UVM_ALL_ON)
        `uvm_field_int(PSLVERR,  UVM_ALL_ON)
        `uvm_field_int(delay,    UVM_ALL_ON | UVM_NOCOMPARE)
        `uvm_field_int(dft_cg_enable_i,   UVM_ALL_ON | UVM_NOCOMPARE)
        `uvm_field_int(ext_sig_i,   UVM_ALL_ON | UVM_NOCOMPARE)
        `uvm_field_int(ch_o,    UVM_ALL_ON)
        `uvm_field_int(timer_counter_o,    UVM_ALL_ON)
        `uvm_field_int(events_o,     UVM_ALL_ON)
    `uvm_object_utils_end

endclass
  
