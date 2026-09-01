
 class timer_transaction extends uvm_sequence_item;

    // Signals driven by master (testbench → DUT)
    rand logic             dft_cg_enable_i;
    rand logic [31:0]      ext_sig_i;     // 12 bits = ADDR_WIDTH = 12

    // Protocol control signals — driver will set them, not randomized
    logic                  [3:0] ch_o;
    // logic                  [3:0] ch_1_o;
    // logic                  [3:0] ch_2_o;
    // logic                  [3:0] ch_3_o; 
    logic [31:0] timer_counter_o;
    logic              [3:0]  events_o;

    // Constructor
    function new(string name = "timer_transaction");
        super.new(name);
    endfunction
    

    // UVM field macros — same signals, same order feel
    `uvm_object_utils_begin(timer_transaction)
        `uvm_field_int(dft_cg_enable_i,   UVM_ALL_ON | UVM_NOCOMPARE)
        `uvm_field_int(ext_sig_i,   UVM_ALL_ON | UVM_NOCOMPARE)
        `uvm_field_int(ch_o,    UVM_ALL_ON)
        `uvm_field_int(timer_counter_o,    UVM_ALL_ON)
        // `uvm_field_int(ch_o,    UVM_ALL_ON)
        // `uvm_field_int(ch_1_o,    UVM_ALL_ON)
        // `uvm_field_int(ch_2_o,    UVM_ALL_ON)
        // `uvm_field_int(ch_3_o,    UVM_ALL_ON)
        `uvm_field_int(events_o,     UVM_ALL_ON)
    `uvm_object_utils_end
    
endclass
  
