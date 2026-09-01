
import uvm_pkg::*;
module testbench;
    
    
  apb_interface #(
        .ADDR_WIDTH(12),
        .DATA_WIDTH(32)
    ) adv_if (.*);

    //timer_interface tim_if();

    initial begin
        adv_if.HCLK = 0;
        forever #5 adv_if.HCLK = ~adv_if.HCLK;
    end


//    initial begin
//         tim_if.HCLK = 0;
//         forever #5 tim_if.HCLK = ~tim_if.HCLK;
//     end

    initial begin
        adv_if.low_speed_clk_i = 0;
        forever #15258.789 adv_if.low_speed_clk_i = ~adv_if.low_speed_clk_i;
    end

    initial begin
        adv_if.HRESETn = 0;
        #100;
        adv_if.HRESETn = 1;
        `uvm_info("TESTBENCH", "Reset de-asserted", UVM_LOW)
    end

    initial begin
        $vcdplusfile("wave.vpd");
        $vcdpluson;
    end

  //spi_interface p_if(clk , rst);
  
  apb_adv_timer #(
        .APB_ADDR_WIDTH (12),
        .EXTSIG_NUM     (32),
        .TIMER_NBITS    (32)
    ) dut (
        .HCLK             (adv_if.HCLK),
        .HRESETn          (adv_if.HRESETn),
        .PADDR            (adv_if.PADDR),
        .PWDATA           (adv_if.PWDATA),
        .PWRITE           (adv_if.PWRITE),
        .PSEL             (adv_if.PSEL),
        .PENABLE          (adv_if.PENABLE),
        .PRDATA           (adv_if.PRDATA),
        .PREADY           (adv_if.PREADY),
        .PSLVERR          (adv_if.PSLVERR),

        // Timer-specific inputs – tied off for basic simulation
        .dft_cg_enable_i  (adv_if.dft_cg_enable_i),
        .low_speed_clk_i  (adv_if.low_speed_clk_i),
        .ext_sig_i        (adv_if.ext_sig_i),

        // Outputs – can be observed in waveform
        .events_o         (adv_if.events_o),
        .ch_o           (adv_if.ch_o),
        .timer_counter_o()
        //.ch_1_o           (tim_if.ch_1_o),
        //.ch_2_o           (tim_if.ch_2_o),
        //.ch_3_o           (tim_if.ch_3_o)
    );

  initial begin
        // Pass the virtual interface to UVM components
        uvm_config_db#(virtual apb_interface)::set(
            null, "*", "vif", adv_if
        );
       // uvm_config_db#(virtual apb_interface)::set(null, "*", "apb_vif", apb_if);   // alternative name
        //uvm_config_db#(virtual timer_interface)::set(null, "*", "tim_vif", tim_if);
        // Launch UVM environment
        // Test name comes from +UVM_TESTNAME (or default uvm_test if not set)
        `uvm_info("TESTBENCH", "Starting UVM Test", UVM_LOW)
        $display("Debug ilder vs new");
        run_test();
    end
endmodule

