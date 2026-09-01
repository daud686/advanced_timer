import uvm_pkg::*;
`include "uvm_macros.svh"
import apb_pkg::*;

/// Daud New

class apb_base_seq extends uvm_sequence#(apb_transaction);

   `uvm_object_utils(apb_base_seq)
    //static int pre_value=9;
    function new(string name = "apb_base_seq");
        super.new(name);
    endfunction
    task body();        
    endtask

endclass :apb_base_seq

//////////////////////////////

class apb_timer_ch0_32bit_seq extends apb_base_seq;

  `uvm_object_utils(apb_timer_ch0_32bit_seq)

  function new(string name="apb_timer_ch0_32bit_seq");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), "=== 50% PWM on Channel 0 (32-bit) SEQUENCE START ===", UVM_LOW)

    // 1. Reset Timer
    `uvm_do_with(req, {
        req.PADDR  == 12'h000;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0008;   // rst
        req.delay  == 20;
    })

    // 2. Enable Timer Clock
    `uvm_do_with(req, {
        req.PADDR  == 12'h104;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0001;   // REG_CH_EN[0] = 1
        req.delay  == 20;
    })

        // 3. Configure Event 0 -> Channel 0
`uvm_do_with(req, {
    req.PADDR  == 12'h100;           // REG_EVENT_CFG
    req.PWRITE == 1;
    req.PWDATA == 32'h0001_0000;     // event_en[0]=1, event_sel_0=0 (Channel 0)
    req.delay  == 20;
})

// Read REG_EVENT_CFG
`uvm_do_with(req, {
    req.PADDR  == 12'h100;           // REG_EVENT_CFG
    req.PWRITE == 0;
    req.delay  == 20;
})

        // 4. Period Threshold
    `uvm_do_with(req,{
      req.PADDR  == 12'h008;
      req.PWRITE == 1;
      req.PWDATA == 32'h2000_0000;
      req.delay  == 20;
    })

    // Read REG_TIM0_TH
    `uvm_do_with(req,{
      req.PADDR  == 12'h008;
      req.PWRITE == 0;
      req.delay  == 20;
    })

    // 3. Configure Timer CFG (Sawtooth, in_mode=0, presc=0)
    `uvm_do_with(req, {
        req.PADDR  == 12'h004;           // REG_TIM0_CFG
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_1000;     // saw=1, others 0 → 0x00001000
        req.delay  == 20;
    })

    // 5. Period Threshold High (REG_TIM0_TH_HI)
    `uvm_do_with(req, {
        req.PADDR  == 12'h200;           // REG_TIM0_TH_HI
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0000;     // upper bits = 0
        req.delay  == 20;
    })

     `uvm_do_with(req, {
        req.PADDR  == 12'h200;           // REG_TIM0_TH_HI
        req.PWRITE == 0;
        //req.PWDATA == 32'h0000_0000;     // upper bits = 0
        req.delay  == 20;
    })

    // 6. Channel 0 Threshold Low + Mode (SET)
    `uvm_do_with(req, {
        req.PADDR  == 12'h00C;           // REG_TIM0_CH0_TH
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_1000;     // ch_mode=000 (SET), ch_th[15:0]=0x8000
        req.delay  == 20;
    })

    `uvm_do_with(req, {
    req.PADDR  == 12'h00C;   // REG_TIM0_CH0_TH
    req.PWRITE == 0;
    req.delay  == 20;
})

    // 7. Channel 0 Threshold High
    `uvm_do_with(req, {
        req.PADDR  == 12'h204;           // REG_TIM0_CH0_TH_HI
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0000;
        req.delay  == 20;
    })

    `uvm_do_with(req, {
    req.PADDR  == 12'h204;   // REG_TIM0_CH0_TH_HI
    req.PWRITE == 0;
    req.delay  == 20;
})

    // 8. Update Configuration (apply pending values)
    `uvm_do_with(req, {
        req.PADDR  == 12'h000;           // REG_TIM0_CMD
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0004;     // update
        req.delay  == 20;
    })

    // 9. Start Timer
    `uvm_do_with(req, {
        req.PADDR  == 12'h000;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0001;     // start
        req.delay  == 50;
    })

    `uvm_info(get_type_name(), "50% PWM on ch_o[0] started. Counter should toggle at 0x8000.", UVM_MEDIUM)

    // Observe behavior (run for sufficient cycles)
    `uvm_do_with(req, {req.delay == 5000; req.PSEL == 0;}) 

    // Optional: Read counter periodically
    repeat(6) begin
      `uvm_do_with(req, {
        req.PADDR  == 12'h02C;   // REG_TIM0_COUNTER
        req.PWRITE == 0;
        req.delay  == 100;
      })
    end

    // Stop Timer
    `uvm_do_with(req, {
        req.PADDR  == 12'h000;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0002;   // stop
    })

    `uvm_info(get_type_name(), "=== 50% PWM on Channel 0 SEQUENCE COMPLETED ===", UVM_LOW)
  endtask

endclass

///////////////////////////////////////////////////////

class apb_timer_ch1_32bit_seq extends apb_base_seq;

  `uvm_object_utils(apb_timer_ch1_32bit_seq)

  function new(string name="apb_timer_ch1_32bit_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(),
      "=== 50% PWM on Channel 1 (32-bit) SEQUENCE START ===",
      UVM_LOW)

    // 1. Reset Timer
    `uvm_do_with(req,{
      req.PADDR  == 12'h000;
      req.PWRITE == 1;
      req.PWDATA == 32'h0000_0008;
      req.delay  == 20;
    })

    // 2. Enable Timer Clock
    `uvm_do_with(req,{
      req.PADDR  == 12'h104;
      req.PWRITE == 1;
      req.PWDATA == 32'h0000_0001;
      req.delay  == 20;
    })

    `uvm_do_with(req, {
    req.PADDR  == 12'h100;
    req.PWRITE == 1;
    req.PWDATA == 32'h0002_0010;   // event_en[1]=1, event_sel_1=1
    req.delay  == 20;
})

`uvm_do_with(req, {
    req.PADDR  == 12'h100;           // REG_EVENT_CFG
    req.PWRITE == 0;
    req.delay  == 20;
})

        // 4. Period Threshold
    `uvm_do_with(req,{
      req.PADDR  == 12'h008;
      req.PWRITE == 1;
      req.PWDATA == 32'h2000_0000;
      req.delay  == 20;
    })

    // Read REG_TIM0_TH
    `uvm_do_with(req,{
      req.PADDR  == 12'h008;
      req.PWRITE == 0;
      req.delay  == 20;
    })

    // 3. Configure Timer
    `uvm_do_with(req,{
      req.PADDR  == 12'h004;
      req.PWRITE == 1;
      req.PWDATA == 32'h0000_1000;
      req.delay  == 20;
    })

    // 5. Period Threshold High
    `uvm_do_with(req,{
      req.PADDR  == 12'h200;
      req.PWRITE == 1;
      req.PWDATA == 32'h0000_0000;
      req.delay  == 20;
    })

    // 6. Channel 1 Threshold
    `uvm_do_with(req,{
      req.PADDR  == 12'h010;      // REG_TIM0_CH1_TH
      req.PWRITE == 1;
      req.PWDATA == 32'h0000_1000;
      req.delay  == 20;
    })

    // Read REG_TIM0_CH1_TH
    `uvm_do_with(req,{
      req.PADDR  == 12'h010;
      req.PWRITE == 0;
      req.delay  == 20;
    })

    // 7. Channel 1 Threshold High
    `uvm_do_with(req,{
      req.PADDR  == 12'h208;      // REG_TIM0_CH1_TH_HI
      req.PWRITE == 1;
      req.PWDATA == 32'h0000_0000;
      req.delay  == 20;
    })

    // Read REG_TIM0_CH1_TH_HI
    `uvm_do_with(req,{
      req.PADDR  == 12'h208;
      req.PWRITE == 0;
      req.delay  == 20;
    })

    // 8. Update
    `uvm_do_with(req,{
      req.PADDR  == 12'h000;
      req.PWRITE == 1;
      req.PWDATA == 32'h0000_0004;
      req.delay  == 20;
    })

    // 9. Start
    `uvm_do_with(req,{
      req.PADDR  == 12'h000;
      req.PWRITE == 1;
      req.PWDATA == 32'h0000_0001;
      req.delay  == 50;
    })

    `uvm_info(get_type_name(),
      "Channel 1 started.",
      UVM_MEDIUM)

    // Observe
    `uvm_do_with(req,{
      req.delay == 5000;
      req.PSEL  == 0;
    })

    // Read Counter
    repeat(6) begin
      `uvm_do_with(req,{
        req.PADDR  == 12'h02C;
        req.PWRITE == 0;
        req.delay  == 100;
      })
    end

    // Stop
    `uvm_do_with(req,{
      req.PADDR  == 12'h000;
      req.PWRITE == 1;
      req.PWDATA == 32'h0000_0002;
    })

    `uvm_info(get_type_name(),
      "=== Channel 1 SEQUENCE COMPLETED ===",
      UVM_LOW)

  endtask

endclass

/////////////////////////////////////////////

class apb_timer_ch2_32bit_seq extends apb_base_seq;

  `uvm_object_utils(apb_timer_ch2_32bit_seq)

  function new(string name="apb_timer_ch2_32bit_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(),
      "=== 50% PWM on Channel 2 (32-bit) SEQUENCE START ===",
      UVM_LOW)

    // 1. Reset Timer
    `uvm_do_with(req,{
      req.PADDR  == 12'h000;
      req.PWRITE == 1;
      req.PWDATA == 32'h0000_0008;
      req.delay  == 20;
    })

    // 2. Enable Timer Clock
    `uvm_do_with(req,{
      req.PADDR  == 12'h104;
      req.PWRITE == 1;
      req.PWDATA == 32'h0000_0001;
      req.delay  == 20;
    })

        // 4. Period Threshold
    `uvm_do_with(req,{
      req.PADDR  == 12'h008;
      req.PWRITE == 1;
      req.PWDATA == 32'h2000_0000;
      req.delay  == 20;
    })

    // Read REG_TIM0_TH
    `uvm_do_with(req,{
      req.PADDR  == 12'h008;
      req.PWRITE == 0;
      req.delay  == 20;
    })

    // event2 <- ch2
`uvm_do_with(req, {
    req.PADDR  == 12'h100;
    req.PWRITE == 1;
    req.PWDATA == 32'h0004_0200;   // event_en[2]=1, event_sel_2=2
    req.delay  == 20;
})

    `uvm_do_with(req, {
    req.PADDR  == 12'h100;           // REG_EVENT_CFG
    req.PWRITE == 0;
    req.delay  == 20;
})

    // 3. Configure Timer
    `uvm_do_with(req,{
      req.PADDR  == 12'h004;
      req.PWRITE == 1;
      req.PWDATA == 32'h0000_1000;
      req.delay  == 20;
    })

    // 5. Period Threshold High
    `uvm_do_with(req,{
      req.PADDR  == 12'h200;
      req.PWRITE == 1;
      req.PWDATA == 32'h0000_0000;
      req.delay  == 20;
    })

    // 6. Channel 2 Threshold
    `uvm_do_with(req,{
      req.PADDR  == 12'h014;      // REG_TIM0_CH2_TH
      req.PWRITE == 1;
      req.PWDATA == 32'h0000_1000;
      req.delay  == 20;
    })

    // Read REG_TIM0_CH2_TH
    `uvm_do_with(req,{
      req.PADDR  == 12'h014;
      req.PWRITE == 0;
      req.delay  == 20;
    })

    // 7. Channel 2 Threshold High
    `uvm_do_with(req,{
      req.PADDR  == 12'h20C;      // REG_TIM0_CH2_TH_HI
      req.PWRITE == 1;
      req.PWDATA == 32'h0000_0000;
      req.delay  == 20;
    })

    // Read REG_TIM0_CH2_TH_HI
    `uvm_do_with(req,{
      req.PADDR  == 12'h20C;
      req.PWRITE == 0;
      req.delay  == 20;
    })

    // 8. Update
    `uvm_do_with(req,{
      req.PADDR  == 12'h000;
      req.PWRITE == 1;
      req.PWDATA == 32'h0000_0004;
      req.delay  == 20;
    })

    // 9. Start
    `uvm_do_with(req,{
      req.PADDR  == 12'h000;
      req.PWRITE == 1;
      req.PWDATA == 32'h0000_0001;
      req.delay  == 50;
    })

    `uvm_info(get_type_name(),
      "Channel 2 started.",
      UVM_MEDIUM)

    // Observe
    `uvm_do_with(req,{
      req.delay == 5000;
      req.PSEL  == 0;
    })

    // Read Counter
    repeat(6) begin
      `uvm_do_with(req,{
        req.PADDR  == 12'h02C;
        req.PWRITE == 0;
        req.delay  == 100;
      })
    end

    // Stop
    `uvm_do_with(req,{
      req.PADDR  == 12'h000;
      req.PWRITE == 1;
      req.PWDATA == 32'h0000_0002;
    })

    `uvm_info(get_type_name(),
      "=== Channel 2 SEQUENCE COMPLETED ===",
      UVM_LOW)

  endtask

endclass

//////////////////////////////

class apb_timer_ch3_32bit_seq extends apb_base_seq;

  `uvm_object_utils(apb_timer_ch3_32bit_seq)

  function new(string name="apb_timer_ch3_32bit_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(),
      "=== 50% PWM on Channel 3 (32-bit) SEQUENCE START ===",
      UVM_LOW)

    // 1. Reset Timer
    `uvm_do_with(req,{
      req.PADDR  == 12'h000;
      req.PWRITE == 1;
      req.PWDATA == 32'h0000_0008;
      req.delay  == 20;
    })

    // 2. Enable Timer Clock
    `uvm_do_with(req,{
      req.PADDR  == 12'h104;
      req.PWRITE == 1;
      req.PWDATA == 32'h0000_0001;
      req.delay  == 20;
    })

        // 4. Period Threshold
    `uvm_do_with(req,{
      req.PADDR  == 12'h008;
      req.PWRITE == 1;
      req.PWDATA == 32'h2000_0000;
      req.delay  == 20;
    })

    // Read REG_TIM0_TH
    `uvm_do_with(req,{
      req.PADDR  == 12'h008;
      req.PWRITE == 0;
      req.delay  == 20;
    })

    // event3 <- ch3
`uvm_do_with(req, {
    req.PADDR  == 12'h100;
    req.PWRITE == 1;
    req.PWDATA == 32'h0008_3000;   // event_en[3]=1, event_sel_3=3
    req.delay  == 20;
})

    `uvm_do_with(req, {
    req.PADDR  == 12'h100;           // REG_EVENT_CFG
    req.PWRITE == 0;
    req.delay  == 20;
})

    // 3. Configure Timer
    `uvm_do_with(req,{
      req.PADDR  == 12'h004;
      req.PWRITE == 1;
      req.PWDATA == 32'h0000_1000;
      req.delay  == 20;
    })

    // 5. Period Threshold High
    `uvm_do_with(req,{
      req.PADDR  == 12'h200;
      req.PWRITE == 1;
      req.PWDATA == 32'h0000_0000;
      req.delay  == 20;
    })

    // 6. Channel 3 Threshold
    `uvm_do_with(req,{
      req.PADDR  == 12'h018;      // REG_TIM0_CH3_TH
      req.PWRITE == 1;
      req.PWDATA == 32'h0000_1000;
      req.delay  == 20;
    })

    // Read REG_TIM0_CH3_TH
    `uvm_do_with(req,{
      req.PADDR  == 12'h018;
      req.PWRITE == 0;
      req.delay  == 20;
    })

    // 7. Channel 3 Threshold High
    `uvm_do_with(req,{
      req.PADDR  == 12'h210;      // REG_TIM0_CH3_TH_HI
      req.PWRITE == 1;
      req.PWDATA == 32'h0000_0000;
      req.delay  == 20;
    })

    // Read REG_TIM0_CH3_TH_HI
    `uvm_do_with(req,{
      req.PADDR  == 12'h210;
      req.PWRITE == 0;
      req.delay  == 20;
    })

    // 8. Update
    `uvm_do_with(req,{
      req.PADDR  == 12'h000;
      req.PWRITE == 1;
      req.PWDATA == 32'h0000_0004;
      req.delay  == 20;
    })

    // 9. Start
    `uvm_do_with(req,{
      req.PADDR  == 12'h000;
      req.PWRITE == 1;
      req.PWDATA == 32'h0000_0001;
      req.delay  == 50;
    })

    `uvm_info(get_type_name(),
      "Channel 3 started.",
      UVM_MEDIUM)

    // Observe
    `uvm_do_with(req,{
      req.delay == 5000;
      req.PSEL  == 0;
    })

    // Read Counter
    repeat(6) begin
      `uvm_do_with(req,{
        req.PADDR  == 12'h02C;
        req.PWRITE == 0;
        req.delay  == 100;
      })
    end

    // Stop
    `uvm_do_with(req,{
      req.PADDR  == 12'h000;
      req.PWRITE == 1;
      req.PWDATA == 32'h0000_0002;
    })

    `uvm_info(get_type_name(),
      "=== Channel 3 SEQUENCE COMPLETED ===",
      UVM_LOW)

  endtask

endclass

///////////////////////////////


class apb_basic_write_seq extends apb_base_seq;
    `uvm_object_utils(apb_basic_write_seq)

    function new(string name = "apb_basic_write_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_do_with(req,{ req.PADDR == 12'h004; req.PWRITE == 1'b1; req.PWDATA == 32'h0000_0100;})
        `uvm_do_with(req,{ req.PADDR == 12'h004; req.PWRITE == 1'b0;})
    endtask

endclass

/*------------------------------------------------------------
  Per Timer Reset Sequence - Timer0
------------------------------------------------------------*/

class apb_advtimer_timer0_reset_seq extends apb_base_seq;

  `uvm_object_utils(apb_advtimer_timer0_reset_seq)


  function new(string name="apb_advtimer_timer0_reset_seq");
    super.new(name);
  endfunction
task body();

    `uvm_info(get_type_name(), "=== TIMER0 RESET + START + STOP SEQUENCE START ===", UVM_LOW)

    // 1. Reset
    `uvm_do_with(req,{req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay == 30;})

    // 2. Enable Clock for Timer0
    `uvm_do_with(req,{req.PADDR==12'h104; req.PWRITE==1; req.PWDATA==32'h0000_0001; req.delay == 30;})

    // 3. Start Timer
    `uvm_do_with(req,{req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0005; req.delay == 30;}) // UPDATE + START

    `uvm_info(get_type_name(), "Timer Started - Counter should be running", UVM_LOW)

    // 4. Stop Timer (with UPDATE)
    `uvm_do_with(req,{req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0006; req.delay == 30;}) // UPDATE + STOP

    `uvm_info(get_type_name(), "Stop command issued with UPDATE", UVM_LOW)

    // 5. Read back CMD register
    `uvm_do_with(req,{req.PADDR==12'h000; req.PWRITE==0;})
    `uvm_info(get_type_name(), $sformatf("CMD Readback after STOP = 0x%08h", req.PRDATA), UVM_LOW)

    `uvm_info(get_type_name(), "=== TIMER0 RESET SEQUENCE COMPLETED ===", UVM_LOW)

  endtask

endclass 

//////////////////////

class apb_saw_mode_seq extends apb_base_seq;

  `uvm_object_utils(apb_saw_mode_seq)

  function new(string name="apb_saw_mode_seq");
    super.new(name);
  endfunction

task body();

  `uvm_info(get_type_name(), "=== SAWTOOTH MODE TEST START ===", UVM_LOW)

  `uvm_do_with(req, {
        req.PADDR  == 12'h000;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0008;   // RESET
        req.delay == 20;
    })

  // 1. Enable Timer0 clock
  `uvm_do_with(req, {
      req.PADDR  == 12'h104;
      req.PWRITE == 1'b1;
      req.PWDATA == 32'h0000_0001;
      //req.delay == 20;
  })

  // repeat(10) @(posedge vif.HCLK);

  // 2. Configure Timer0 in Sawtooth mode
  `uvm_do_with(req, {
      req.PADDR  == 12'h004;           // REG_TIM0_CFG
      req.PWRITE == 1'b1;
      req.PWDATA == 32'h0000_1000;     // SAWTOOTH = 1 (bit 12)
  })

  // 3. Set proper thresholds for easy observation
  `uvm_do_with(req, {
      req.PADDR  == 12'h008;           // REG_TIM0_TH
      req.PWRITE == 1'b1;
      req.PWDATA == 32'h0100_0000;     // COUNT_END=0x0100, COUNT_START=0x0000
  })

  `uvm_do_with(req, {
        req.PADDR  == 12'h00C;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0040;     // COMP_OP=000 (SET), Threshold=0x0040
    })

   // ============== UPDATE CONFIGURATION ==============
    `uvm_do_with(req, {
      req.PADDR  == 12'h000;
      req.PWRITE == 1;
      req.PWDATA == 32'h0000_0004;     // UPDATE only
      req.delay  == 10;
    })

    `uvm_do_with(req, {
      req.PADDR  == 12'h000;           // REG_TIM0_CMD
      req.PWRITE == 1'b1;
      req.PWDATA == 32'h0000_0001;     // START=1
      req.delay  == 50;
    })

    `uvm_do_with(req,{req.delay == 200; req.PSEL == 0;}) 

    `uvm_do_with(req, {
        req.PADDR  == 12'h02C;
        req.PWRITE == 0;               // READ
        req.delay  == 5;
      })

    `uvm_do_with(req, {
        req.PADDR  == 12'h000;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0002;     // STOP
    })

    `uvm_info(get_type_name(), "=== SAWTOOTH MODE TEST END ===", UVM_LOW)

endtask

endclass

///////////////////////////////////////////////

class updown_counter_full_toggle_coverage_timer0_seq extends apb_base_seq;

  `uvm_object_utils(updown_counter_full_toggle_coverage_timer0_seq)

  function new(string name = "updown_counter_full_toggle_coverage_timer0_seq");
    super.new(name);
  endfunction

  task reconfigure_and_run(
    bit        sawtooth,
    bit [31:0] count_start,
    bit [31:0] count_end,
    int        obs_cycles
  );
    `uvm_info(get_type_name(), 
      $sformatf("SAW=%0b START=0x%08h END=0x%08h obs=%0d", 
                sawtooth, count_start, count_end, obs_cycles), UVM_LOW)

    // Stop Timer
    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0002; req.delay==5;})

    // CFG Register
    `uvm_do_with(req, {
      req.PADDR  == 12'h004;
      req.PWRITE == 1;
      req.PWDATA == {8'h00, 8'h00, 3'h0, sawtooth, 12'h000};
      req.delay  == 5;
    })

    // Threshold Low
    `uvm_do_with(req, {
      req.PADDR  == 12'h008;
      req.PWRITE == 1;
      req.PWDATA == {count_end[15:0], count_start[15:0]};
      req.delay  == 5;
    })

    // Threshold High (Critical for 32-bit toggle)
    `uvm_do_with(req, {
      req.PADDR  == 12'h200;
      req.PWRITE == 1;
      req.PWDATA == {count_end[31:16], count_start[31:16]};
      req.delay  == 5;
    })

    // UPDATE + START
    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0004; req.delay==5;})
    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001; req.delay==obs_cycles;})

    // Read counter
    `uvm_do_with(req,{req.PADDR==12'h02C; req.PWRITE==0; req.delay==5;})
  endtask

  task body();
    `uvm_info(get_type_name(), "=== UPDOWN COUNTER FULL TOGGLE + CONDITION COVERAGE START ===", UVM_LOW)

    // Initial Reset
    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay==60;})

    // Clock enable
    `uvm_do_with(req, {req.PADDR==12'h104; req.PWRITE==1; req.PWDATA==32'h0000_0001;})

    // Channel configs - FIXED loop
    begin
      int i;
      for (i = 0; i < 4; i++) begin
        `uvm_do_with(req, {
          req.PADDR  == 12'h00C + (i*4);
          req.PWRITE == 1;
          req.PWDATA == 32'h0003_0010;
        })
      end
    end

    // Basic Sawtooth
    reconfigure_and_run(1'b1, 32'h0000_0000, 32'h0000_0001, 100);
    reconfigure_and_run(1'b1, 32'h0000_0000, 32'h0000_0000, 50);

    // UP/DOWN - Key for condition coverage
    reconfigure_and_run(1'b0, 32'h0000_0000, 32'h0000_0010, 500);
    reconfigure_and_run(1'b0, 32'h0000_0005, 32'h0000_0015, 800);

    // Heavy toggle phases (including upper 16 bits)
    reconfigure_and_run(1'b1, 32'h0000_0001, 32'h0000_FFFF, 20000);
    reconfigure_and_run(1'b1, 32'hFFFF_0000, 32'hFFFF_FFFF, 20000);
    reconfigure_and_run(1'b1, 32'h5555_5555, 32'hAAAA_AAAA, 30000);
    reconfigure_and_run(1'b0, 32'h0001_0000, 32'h0002_0000, 20000);
    reconfigure_and_run(1'b0, 32'h7FFF_FFFF, 32'h8000_0000, 25000);

    // Update + Reset while running
    `uvm_do_with(req,{req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0004; req.delay==10;})
    `uvm_do_with(req,{req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001; req.delay==300;})

    `uvm_do_with(req,{req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay==20;})
    `uvm_do_with(req,{req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001; req.delay==200;})

    // Final full range
    reconfigure_and_run(1'b0, 32'h0000_0000, 32'hFFFF_FFFF, 100000);

    `uvm_info(get_type_name(), "=== UPDOWN COUNTER FULL TOGGLE + CONDITION COVERAGE COMPLETED ===", UVM_LOW)
  endtask
endclass


/////////////////////////////////////////////////////////////

class apb_triangle_mode_count_seq extends apb_base_seq;

  `uvm_object_utils(apb_triangle_mode_count_seq)

  function new(string name="apb_triangle_mode_count_seq");
    super.new(name);
  endfunction

task body();

    `uvm_info(get_type_name(), "=== TRIANGLE MODE (CENTER-ALIGNED) TEST START ===", UVM_LOW)

    // 1. Reset Timer0
    `uvm_do_with(req, {
        req.PADDR  == 12'h000;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0008;   // RESET
        req.delay == 30;
    })
    // repeat(40) @(posedge vif.HCLK);

    // 2. Enable Timer0 Clock
    `uvm_do_with(req, {
        req.PADDR  == 12'h104;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0001;
        req.delay == 30;
    })
    // repeat(20) @(posedge vif.HCLK);

    // 3. Configure Triangle Mode (SAWTOOTH = 0)
    `uvm_do_with(req, {
        req.PADDR  == 12'h004;           
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0000;     // SAWTOOTH = 0 → Triangle / Center-Aligned Mode
    })

    // 4. Set Period (COUNT_END)
    `uvm_do_with(req, {
        req.PADDR  == 12'h008;           
        req.PWRITE == 1;
        req.PWDATA == 32'hFFFF_0000;     // Good period for observation
    })

    // 5. Configure Channel 0 (Simple OP_SET for easy PWM observation)
    `uvm_do_with(req, {
        req.PADDR  == 12'h00C;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0010;     // COMP_OP=000 (SET), Threshold ≈ half period
    })

    `uvm_do_with(req, {
      req.PADDR  == 12'h000;
      req.PWRITE == 1;
      req.PWDATA == 32'h0000_0004;     // UPDATE only
      req.delay  == 10;
    })

    `uvm_do_with(req, {
      req.PADDR  == 12'h000;           // REG_TIM0_CMD
      req.PWRITE == 1'b1;
      req.PWDATA == 32'h0000_0001;     // START=1
      req.delay  == 50;
    })

    `uvm_do_with(req,{req.delay == 5000; req.PSEL == 0;}) 

    repeat(8) begin
      `uvm_do_with(req, {
        req.PADDR  == 12'h02C;
        req.PWRITE == 0;               // READ
        req.delay  == 50;
      })
    end
    // repeat(800) @(posedge vif.HCLK);
    `uvm_info(get_type_name(), "Triangle Mode Running - Counter should go Up and Down", UVM_LOW)
    // Optional: Stop the timer
    `uvm_do_with(req, {
        req.PADDR  == 12'h000;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0002;     // STOP
    })

    `uvm_info(get_type_name(), "=== TRIANGLE MODE TEST COMPLETED ===", UVM_LOW)

  endtask
endclass

////////////////////////////////////////

  class basic_timer_setup_pwm_generation_timer0_ch0_seq extends apb_base_seq;

  `uvm_object_utils(basic_timer_setup_pwm_generation_timer0_ch0_seq)

  function new(string name="basic_timer_setup_pwm_generation_timer0_ch0_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(), "=== BASIC TIMER0 PWM GENERATION TEST START ===", UVM_LOW)

    // 1. Reset Timer0
    `uvm_do_with(req, {
        req.PADDR  == 12'h000;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0008;   // RESET
        req.delay == 40;
    })
    // repeat(50) @(posedge vif.HCLK);

    // 2. Enable Timer0 Clock
    
    // repeat(20) @(posedge vif.HCLK);

    // 3. Configure CFG Register
    `uvm_do_with(req, {
        req.PADDR  == 12'h004;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_1005;   // Default mode, SAW=0
    })

    // 4. Set Period Register
    `uvm_do_with(req, {
        req.PADDR  == 12'h008;
        req.PWRITE == 1;
        req.PWDATA == 32'h0020_0000;   // Reasonable period
    })

    // 5. Configure Channel 0 for PWM (Toggle mode + ~50% duty)
    `uvm_do_with(req,{ req.PADDR==12'h00C; req.PWRITE==1; req.PWDATA==32'h0003_0010; }) 
    `uvm_do_with(req,{ req.PADDR==12'h010; req.PWRITE==1; req.PWDATA==32'h0004_0000; }) 
    `uvm_do_with(req,{ req.PADDR==12'h014; req.PWRITE==1; req.PWDATA==32'h0004_0000; }) 
    `uvm_do_with(req,{ req.PADDR==12'h018; req.PWRITE==1; req.PWDATA==32'h0004_0000; }) 

     `uvm_do_with(req,{
      req.PADDR  == 12'h100;
      req.PWRITE == 1;
      req.PWDATA == 32'h0001_0000;
    })

    `uvm_do_with(req, {
        req.PADDR  == 12'h104;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0001;
        req.delay == 20;
    })

    // 6. UPDATE + START (Very Important)
    `uvm_do_with(req, {
        req.PADDR  == 12'h000;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0001;   // UPDATE + START
        req.delay == 200;
    })

     repeat(10) begin
      `uvm_do_with(req,{req.ext_sig_i == 32'h0000_0000; req.delay==50; req.PSEL == 0;})
      `uvm_do_with(req,{req.ext_sig_i == 32'h0000_0020; req.delay==50; req.PSEL == 0;})
      `uvm_do_with(req,{req.ext_sig_i == 32'h0000_0000; req.delay==50; req.PSEL == 0;})
    end

    // repeat(1200) @(posedge vif.HCLK);

    `uvm_info(get_type_name(), "PWM Generation Running - Check ch_0_o[0] waveform", UVM_LOW)

    // 7. Stop the Timer
    `uvm_do_with(req, {
        req.PADDR  == 12'h000;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0002;   // STOP
    })

    `uvm_info(get_type_name(), "=== BASIC TIMER0 PWM GENERATION TEST COMPLETED ===", UVM_LOW)

  endtask
endclass

//////////////////////////////////////

class clock_selection_hclk_seq extends apb_base_seq;

  `uvm_object_utils(clock_selection_hclk_seq)

  function new(string name="clock_selection_hclk_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(), "=== CLOCK SELECTION HCLK TEST START ===", UVM_LOW)

   `uvm_do_with(req, {
        req.PADDR  == 12'h000;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0008;   // RESET
        req.delay == 30;
    })

    // 2. Configure REG_TIM0_CFG with CLKSEL=0 (use HCLK)
    `uvm_do_with(req,{
        req.PADDR  == 12'h004;
        req.PWRITE == 1;
        req.PWDATA == 32'b0000_0000_0000_0000_0001_1011_0000_0000;
    })

    // 3. Enable Timer0 clock
    `uvm_do_with(req,{
        req.PADDR  == 12'h104;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0001;
    })

    // 4. Start Timer0
    `uvm_do_with(req,{
        req.PADDR  == 12'h000;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0001;
    })

     `uvm_do_with(req,{req.delay == 500; req.PSEL == 0;})

    `uvm_info(get_type_name(), "=== CLOCK SELECTION HCLK TEST COMPLETED ===", UVM_LOW);

  endtask
endclass

/////////////////////////////////////////////

class clock_selection_low_speed_seq extends apb_base_seq;

  `uvm_object_utils(clock_selection_low_speed_seq)

  function new(string name="clock_selection_low_speed_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(), "=== CLOCK SELECTION LOW_SPEED_CLK_i TEST START ===", UVM_LOW)

    `uvm_do_with(req, {
        req.PADDR  == 12'h000;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0008;   // RESET
        req.delay == 30;
    })

    // 3. Configure REG_TIMx_CFG with CLKSEL = 1
    `uvm_do_with(req,{
        req.PADDR  == 12'h004;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0800;   // CLKSEL=1 (bit 11)
    })

    // 4. Enable Timer0 clock
    `uvm_do_with(req,{
        req.PADDR  == 12'h104;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0001;
    })

    // 5. Start Timer0
    `uvm_do_with(req,{
        req.PADDR  == 12'h000;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0001;
    })

    `uvm_do_with(req,{req.delay == 5000; req.PSEL == 0;})

    `uvm_info(get_type_name(), "=== CLOCK SELECTION LOW_SPEED_CLK_i TEST COMPLETED ===", UVM_LOW);

  endtask
endclass

////////////////////////////////////////

class apb_timer0_random_prescaler_seq extends apb_base_seq;

  `uvm_object_utils(apb_timer0_random_prescaler_seq)

  function new(string name = "apb_timer0_random_prescaler_seq");
    super.new(name);
  endfunction

  // Helper task to reconfigure and run with different PRESC values
  task run_phase_with_presc(bit [7:0] presc, int obs_window);
    `uvm_info(get_type_name(), $sformatf("→ Testing PRESC=0x%0h (divide by %0d)", presc, presc+1), UVM_LOW)

    // Stop Timer
    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0002; req.delay==5;}) // STOP

    // Configure new PRESC value (bits [23:16])
    `uvm_do_with(req, {
        req.PADDR  == 12'h004;
        req.PWRITE == 1;
        req.PWDATA == {8'h00, presc, 4'h1, 12'h000};  // PRESC + SAWTOOTH=1
    })

    // Update + Start
    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0004; req.delay==5;}) // UPDATE
    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001; req.delay==obs_window;}) // START
  endtask

  task body();

    `uvm_info(get_type_name(), "=== TIMER0 PRESCALER FULL COVERAGE / RANDOM TEST START ===", UVM_LOW)

    // ==================== Initial Setup ====================
    // Reset Timer0
    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay==60;})

    // Set common configurations (Period + Comparators + Events + Clock Enable)
    `uvm_do_with(req, {req.PADDR==12'h008; req.PWRITE==1; req.PWDATA==32'h0020_0000;}) // COUNT_END=0x20

    `uvm_do_with(req, {req.PADDR==12'h00C; req.PWRITE==1; req.PWDATA==32'h0003_0010;}) // Ch0: TOG
    `uvm_do_with(req, {req.PADDR==12'h010; req.PWRITE==1; req.PWDATA==32'h0003_0010;}) // Ch1: TOG
    `uvm_do_with(req, {req.PADDR==12'h014; req.PWRITE==1; req.PWDATA==32'h0003_0010;}) // Ch2: TOG
    `uvm_do_with(req, {req.PADDR==12'h018; req.PWRITE==1; req.PWDATA==32'h0003_0010;}) // Ch3: TOG

    `uvm_do_with(req, {req.PADDR==12'h100; req.PWRITE==1; req.PWDATA==32'h000F_0000;}) // Event enable
    `uvm_do_with(req, {req.PADDR==12'h104; req.PWRITE==1; req.PWDATA==32'h0000_0001;}) // Clock Enable for Timer0

    // ==================== Different PRESC Values ====================

    `uvm_info(get_type_name(), "Phase 1: PRESC=0x00 (No Prescaling)", UVM_LOW)
    run_phase_with_presc(8'h00, 2048);

    `uvm_info(get_type_name(), "Phase 2: PRESC=0x01 (Divide by 2)", UVM_LOW)
    run_phase_with_presc(8'h01, 2048);

    `uvm_info(get_type_name(), "Phase 3: PRESC=0x03 (Divide by 4)", UVM_LOW)
    run_phase_with_presc(8'h03, 2048);

    `uvm_info(get_type_name(), "Phase 4: PRESC=0x07 (Divide by 8)", UVM_LOW)
    run_phase_with_presc(8'h07, 4096);

    `uvm_info(get_type_name(), "Phase 5: PRESC=0x0F (Divide by 16)", UVM_LOW)
    run_phase_with_presc(8'h0F, 4096);

    `uvm_info(get_type_name(), "Phase 6: PRESC=0x1F (Divide by 32)", UVM_LOW)
    run_phase_with_presc(8'h1F, 8192);

    `uvm_info(get_type_name(), "Phase 7: PRESC=0x3F (Divide by 64)", UVM_LOW)
    run_phase_with_presc(8'h3F, 16384);

    `uvm_info(get_type_name(), "Phase 8: PRESC=0x7F (Divide by 128)", UVM_LOW)
    run_phase_with_presc(8'h7F, 32768);

    `uvm_info(get_type_name(), "Phase 9: PRESC=0xFF (Divide by 256 - Maximum)", UVM_LOW)
    run_phase_with_presc(8'hFF, 65536);

    // Interesting corner patterns
    `uvm_info(get_type_name(), "Phase 10: PRESC=0xAA (Alternating bits)", UVM_LOW)
    run_phase_with_presc(8'hAA, 32768);

    `uvm_info(get_type_name(), "Phase 11: PRESC=0x55 (Inverse alternating bits)", UVM_LOW)
    run_phase_with_presc(8'h55, 32768);

    `uvm_info(get_type_name(), "=== TIMER0 PRESCALER FULL COVERAGE TEST COMPLETED ===", UVM_LOW);

  endtask
endclass

////////////////////////////////////////

class apb_timer0_ext_trigger_seq extends apb_base_seq;

  `uvm_object_utils(apb_timer0_ext_trigger_seq)

  function new(string name = "apb_timer0_ext_trigger_seq");
    super.new(name);
  endfunction

  task body();
    bit [31:0] rand_sig;
    int b, i;

    `uvm_info(get_type_name(),
              "=== EXTERNAL SIGNAL RANDOM TOGGLE COVERAGE SEQ START ===", UVM_LOW)

    // ------------------------------------------------------------------
    // 1. Reset
    // ------------------------------------------------------------------
    `uvm_do_with(req, {
        req.PADDR     == 12'h000;
        req.PWRITE    == 1;
        req.PWDATA    == 32'h0000_0008;   // RESET
        req.delay     == 40;
        req.ext_sig_i == 32'h0;
    })

    // ------------------------------------------------------------------
    // 2. Basic period + CH0 (so timer is alive and ch_o can toggle)
    // ------------------------------------------------------------------
    `uvm_do_with(req, {
        req.PADDR  == 12'h008;
        req.PWRITE == 1;
        req.PWDATA == 32'h1000_0000;      // end = 0x1000
    })

    `uvm_do_with(req, {
        req.PADDR  == 12'h00C;
        req.PWRITE == 1;
        req.PWDATA == 32'h0003_0800;      // TOG, TH=0x800
    })

    // ------------------------------------------------------------------
    // 3. Event + Clock enable
    // ------------------------------------------------------------------
    `uvm_do_with(req, {
        req.PADDR  == 12'h100;
        req.PWRITE == 1;
        req.PWDATA == 32'h000F_0000;
    })

    `uvm_do_with(req, {
        req.PADDR  == 12'h104;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0001;
    })

    // ------------------------------------------------------------------
    // 4. Walk every bit of ext_sig_i  (closes [4:1] and [30:10])
    //    Also write different in_sel values so cfg_sel_i[7:6]/r_sel[7:6]
    //    see both 0 and 1.
    // ------------------------------------------------------------------
    for (b = 0; b < 32; b++) begin

      // STOP
      `uvm_do_with(req, {
          req.PADDR     == 12'h000;
          req.PWRITE    == 1;
          req.PWDATA    == 32'h0000_0002;
          req.delay     == 5;
          req.ext_sig_i == 32'h0;
      })

      // CFG: MODE=rising(011), INSEL = b  (also exercises high bits of sel)
      //      Force some transactions with sel[7:6] set for full toggle
      `uvm_do_with(req, {
          req.PADDR  == 12'h004;
          req.PWRITE == 1;
          req.PWDATA == {8'h00, 8'h00, 3'h0, 1'b0, 1'b0, 3'b011, b[7:0]};
          req.delay  == 3;
      })

      // UPDATE
      `uvm_do_with(req, {
          req.PADDR  == 12'h000;
          req.PWRITE == 1;
          req.PWDATA == 32'h0000_0004;
          req.delay  == 5;
      })

      // START
      `uvm_do_with(req, {
          req.PADDR  == 12'h000;
          req.PWRITE == 1;
          req.PWDATA == 32'h0000_0001;
          req.delay  == 10;
      })

      // ---- Drive the selected bit (and a few random neighbours) ----
      // Low
      `uvm_do_with(req, {
          req.PSEL      == 0;
          req.ext_sig_i == 32'h0;
          req.delay     == 15;
      })

      // Rising edge on bit b
      `uvm_do_with(req, {
          req.PSEL      == 0;
          req.ext_sig_i == (32'h1 << b);
          req.delay     == 20;
      })

      // Falling edge
      `uvm_do_with(req, {
          req.PSEL      == 0;
          req.ext_sig_i == 32'h0;
          req.delay     == 15;
      })

      // Extra random multi-bit pattern (helps remaining holes)
      rand_sig = $urandom();
      `uvm_do_with(req, {
          req.PSEL      == 0;
          req.ext_sig_i == rand_sig;
          req.delay     == 20;
      })
      `uvm_do_with(req, {
          req.PSEL      == 0;
          req.ext_sig_i == ~rand_sig;
          req.delay     == 20;
      })
      `uvm_do_with(req, {
          req.PSEL      == 0;
          req.ext_sig_i == 32'h0;
          req.delay     == 10;
      })
    end

    // ------------------------------------------------------------------
    // 5. Extra pass: force cfg_sel_i[7:6] both directions
    //    (write values with bits 7:6 = 00/01/10/11)
    // ------------------------------------------------------------------
    for (i = 0; i < 4; i++) begin
      `uvm_do_with(req, {
          req.PADDR  == 12'h000;
          req.PWRITE == 1;
          req.PWDATA == 32'h0000_0002;
          req.delay  == 5;
      })

      // in_sel with [7:6] = i, lower bits = 0
      `uvm_do_with(req, {
          req.PADDR  == 12'h004;
          req.PWRITE == 1;
          req.PWDATA == {8'h00, 8'h00, 3'h0, 1'b0, 1'b0, 3'b010, {i[1:0], 6'h00}};
          req.delay  == 3;
      })

      `uvm_do_with(req, {
          req.PADDR  == 12'h000;
          req.PWRITE == 1;
          req.PWDATA == 32'h0000_0004;   // UPDATE
          req.delay  == 5;
      })

      `uvm_do_with(req, {
          req.PADDR  == 12'h000;
          req.PWRITE == 1;
          req.PWDATA == 32'h0000_0001;
          req.delay  == 30;
      })
    end

    // ------------------------------------------------------------------
    // 6. Final random burst on whole bus (extra safety)
    // ------------------------------------------------------------------
    `uvm_do_with(req, {
        req.PADDR  == 12'h000;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0002;
        req.delay  == 5;
    })

    `uvm_do_with(req, {
        req.PADDR  == 12'h004;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_1300;     // rising, sel=0
        req.delay  == 3;
    })

    `uvm_do_with(req, {
        req.PADDR  == 12'h000;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0004;
        req.delay  == 5;
    })

    `uvm_do_with(req, {
        req.PADDR  == 12'h000;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0001;
        req.delay  == 10;
    })

    repeat (40) begin
      rand_sig = $urandom();
      `uvm_do_with(req, {
          req.PSEL      == 0;
          req.ext_sig_i == rand_sig;
          req.delay     == 12;
      })
    end

    // Idle observation window
    `uvm_do_with(req, {
        req.PSEL  == 0;
        req.delay == 300;
    })

    `uvm_info(get_type_name(),
              "=== EXTERNAL SIGNAL RANDOM TOGGLE COVERAGE SEQ COMPLETED ===", UVM_LOW)

  endtask

endclass



// class apb_timer0_ext_trigger_seq extends apb_base_seq;

//   `uvm_object_utils(apb_timer0_ext_trigger_seq)

//   function new(string name = "apb_timer0_ext_trigger_seq");
//     super.new(name);
//   endfunction

//   task body();

//     `uvm_info(get_type_name(), "=== SIMPLE EXTERNAL SIGNAL TRIGGER TEST (Timer0) START ===", UVM_LOW)

//     // 1. Reset Timer0
//     `uvm_do_with(req, {
//         req.PADDR   == 12'h000;
//         req.PWRITE  == 1;
//         req.PWDATA  == 32'h0000_0008;
//         req.delay   == 50;
//         req.ext_sig_i == 32'h0;
//     })

//     // 2. Configure CFG Register
//     //    INSEL=0 (ext_sig_i[0]), MODE=3 (Rising Edge), SAWTOOTH=1, CLKSEL=0, PRESC=0
//     `uvm_do_with(req, {
//         req.PADDR   == 12'h004;
//         req.PWRITE  == 1;
//         req.PWDATA  == 32'h0000_1300;     // MODE=3 (Rising), INSEL=0
//     })

//     // 3. Set reasonable Period
//     `uvm_do_with(req, {
//         req.PADDR   == 12'h008;
//         req.PWRITE  == 1;
//         req.PWDATA  == 32'h1000_0000;     // COUNT_END = 0x1000
//     })

//     // 4. Configure CH0 with Toggle mode (easy to observe in waveform)
//     `uvm_do_with(req, {
//         req.PADDR   == 12'h00C;
//         req.PWRITE  == 1;
//         req.PWDATA  == 32'h0003_0800;     // COMP_OP=011 (TOG), TH=0x0800
//     })

//     // 5. Event Configuration
//     `uvm_do_with(req, {
//         req.PADDR   == 12'h100;
//         req.PWRITE  == 1;
//         req.PWDATA  == 32'h000F_0000;
//     })

//     // 6. Enable Clock for Timer0
//     `uvm_do_with(req, {
//         req.PADDR   == 12'h104;
//         req.PWRITE  == 1;
//         req.PWDATA  == 32'h0000_0001;
//     })

//     // 7. Start Timer
//     `uvm_do_with(req, {
//         req.PADDR   == 12'h000;
//         req.PWRITE  == 1;
//         req.PWDATA  == 32'h0000_0001;
//         req.delay   == 100;
//     })

//     `uvm_info(get_type_name(), "Timer configured for Rising Edge on ext_sig_i[0]", UVM_LOW);
//     `uvm_info(get_type_name(), "Driving external signal pulses now...", UVM_LOW);

//     // ====================== Drive External Signal ======================
//     repeat(20) begin
//         // Low
//         `uvm_do_with(req, {req.ext_sig_i == 32'h0000_0000; req.delay == 30; req.PSEL == 0;})
//         // Rising Edge
//         `uvm_do_with(req, {req.ext_sig_i == 32'h0000_0001; req.delay == 40; req.PSEL == 0;})
//     end

//     // Keep running for observation
//     `uvm_do_with(req, {req.delay == 800; req.PSEL == 0;})

//     `uvm_info(get_type_name(), "=== SIMPLE EXTERNAL SIGNAL TRIGGER TEST COMPLETED ===", UVM_LOW);

//   endtask
// endclass

//////////////////////////////////////////////////////////////////////////////timer_0 comparator sequences

class pwm_comp_op_000_set_sawtooth_on_timer0_ch0_seq extends apb_base_seq;

  `uvm_object_utils(pwm_comp_op_000_set_sawtooth_on_timer0_ch0_seq)

  function new(string name = "pwm_comp_op_000_set_sawtooth_on_timer0_ch0_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(), "=== PWM COMP_OP=000 (OP_SET) + SAWTOOTH TEST START ===", UVM_LOW)

     // 1. Reset Timer1
        `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay == 30;})
        // repeat(60) @(posedge vif.HCLK);

`uvm_do_with(req,{ req.PADDR==12'h004; req.PWRITE==1; req.PWDATA==32'h0000_1000;}) // SAW=0 first
    // repeat(100) @(posedge vif.HCLK);
    // 2. REG_TIM0_CFG → SAWTOOTH=1, PRESC=0, MODE=0, CLKSEL=0
    `uvm_do_with(req,{
        req.PADDR  == 12'h004;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_1000;   
        req.delay == 30;// SAW=1, others default
    })
    // repeat(100) @(posedge vif.HCLK);


    // 3. REG_TIM0_TH → COUNT_START=0x0000, COUNT_END=0x0020
    `uvm_do_with(req,{
        req.PADDR  == 12'h008;
        req.PWRITE == 1;
        req.PWDATA == 32'h0030_0000;
    })

    `uvm_do_with(req,{
        req.PADDR  == 12'h008;
        req.PWRITE == 0;
        req.delay == 20;
    })

// 4. Configure All 4 Channels with COMP_OP=000 (OP_SET), TH=0x0010
        `uvm_do_with(req, {req.PADDR==12'h00C; req.PWRITE==1; req.PWDATA==32'h0000_0010; req.delay==20;}) // Ch0
        `uvm_do_with(req, {req.PADDR==12'h010; req.PWRITE==1; req.PWDATA==32'h0000_0018; req.delay==20;}) // Ch1
        `uvm_do_with(req, {req.PADDR==12'h014; req.PWRITE==1; req.PWDATA==32'h0000_0020; req.delay==20;}) // Ch2
        `uvm_do_with(req, {req.PADDR==12'h018; req.PWRITE==1; req.PWDATA==32'h0000_0022; req.delay==20;}) // Ch3

         `uvm_do_with(req,{
        req.PADDR  == 12'h100;           
        req.PWRITE == 1;
        req.PWDATA == 32'h000F_3210;     // event_en[0] = 1, select ch_o[0] as source
        req.delay  == 20;
    })

    // repeat(100) @(posedge vif.HCLK);

        `uvm_info(get_type_name(), "All 4 channels configured with COMP_OP=000 (OP_SET)", UVM_LOW)
 `uvm_do_with(req,{
        req.PADDR  == 12'h100;           
        req.PWRITE == 1;
        req.PWDATA == 32'h000F_3210;     // event_en[0] = 1, select ch_o[0] as source
    })
        // 5. Enable Timer0 clock gate
        `uvm_do_with(req, {req.PADDR==12'h104; req.PWRITE==1; req.PWDATA==32'h0000_0001;})

        `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0005; req.delay == 50;})
        `uvm_do_with(req,{req.delay == 600; req.PSEL == 0;})
        // 6. Start Timer0
       `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0002; req.delay == 30;})

        // repeat(400) @(posedge vif.HCLK);   // Enough time to cross threshold multiple times


        `uvm_info(get_type_name(), "=== PWM COMP_OP=000 + SAWTOOTH TEST COMPLETED ===", UVM_LOW)

        // #3000;   // Keep waveform open

    endtask
endclass

////////////////////////////////////////////

class pwm_comp_op_000_set_sawtooth_off_timer0_ch0_seq extends apb_base_seq;

  `uvm_object_utils(pwm_comp_op_000_set_sawtooth_off_timer0_ch0_seq)

  function new(string name = "pwm_comp_op_000_set_sawtooth_off_timer0_ch0_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(), "=== PWM COMP_OP=000 (OP_SET) + TRIANGLE MODE (SAWTOOTH=0) TEST START ===", UVM_LOW)

    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay == 30;})
        // repeat(60) @(posedge vif.HCLK);

    // 2. REG_TIM0_CFG → SAWTOOTH=0 (Triangle / Up-Down mode), PRESC=0, MODE=0
    `uvm_do_with(req,{
        req.PADDR  == 12'h004;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0000;   // SAWTOOTH=0
    })

    // 3. REG_TIM0_TH → COUNT_START=0x0000, COUNT_END=0x0020
    `uvm_do_with(req,{
        req.PADDR  == 12'h008;
        req.PWRITE == 1;
        req.PWDATA == 32'h0020_0000;
        req.delay == 10;
    })

    
    `uvm_do_with(req,{
        req.PADDR  == 12'h008;
        req.PWRITE == 0;
        req.delay == 20;
    })

     `uvm_do_with(req, {req.PADDR==12'h00C; req.PWRITE==1; req.PWDATA==32'h0000_0010; req.delay == 10;}) // Ch0
     `uvm_do_with(req, {req.PADDR==12'h010; req.PWRITE==1; req.PWDATA==32'h0000_0010; req.delay == 10;}) // Ch1
     `uvm_do_with(req, {req.PADDR==12'h014; req.PWRITE==1; req.PWDATA==32'h0000_0010; req.delay == 10;}) // Ch2
     `uvm_do_with(req, {req.PADDR==12'h018; req.PWRITE==1; req.PWDATA==32'h0000_0010; req.delay == 10;}) // Ch3

    `uvm_info(get_type_name(), "All 4 channels configured with COMP_OP=000 (OP_SET)", UVM_LOW)
 `uvm_do_with(req,{
        req.PADDR  == 12'h100;           
        req.PWRITE == 1;
        req.PWDATA == 32'h000F_3210;     // event_en[0] = 1, select ch_o[0] as source
        req.delay == 10;
    })

    // 5. Enable Timer0 clock
    `uvm_do_with(req,{
        req.PADDR  == 12'h104;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0001;
    })

    // 6. Start Timer0
    `uvm_do_with(req,{
        req.PADDR  == 12'h000;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0001;
    })

    `uvm_do_with(req,{req.delay == 600; req.PSEL == 0;})   // Enough time to cross threshold multiple times

        // 7. Final Verification for all 4 PWM outputs
        `uvm_info(get_type_name(), "=== Checking PWM Outputs (Should be HIGH and holding) ===", UVM_LOW)

    endtask
endclass

///////////////////////////////////

class pwm_comp_op_001_togrst_sawtooth_on_timer0_ch0_seq extends apb_base_seq;

  `uvm_object_utils(pwm_comp_op_001_togrst_sawtooth_on_timer0_ch0_seq)

  function new(string name = "pwm_comp_op_001_togrst_sawtooth_on_timer0_ch0_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(), "=== PWM COMP_OP=001 (OP_TOGRST) + SAWTOOTH TEST START ===", UVM_LOW)

    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay == 30;})
        // repeat(60) @(posedge vif.HCLK);

    // 2. REG_TIM0_CFG → SAWTOOTH=1, PRESC=0, MODE=0, CLKSEL=0
    `uvm_do_with(req,{
        req.PADDR  == 12'h004;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_1000;   // SAW=1
    })

    // 3. REG_TIM0_TH → COUNT_START=0x0000, COUNT_END=0x0020
    `uvm_do_with(req,{
        req.PADDR  == 12'h008;
        req.PWRITE == 1;
        req.PWDATA == 32'h0020_0000;
    })

    
    `uvm_do_with(req,{
        req.PADDR  == 12'h008;
        req.PWRITE == 0;
        req.delay == 20;
    })

     `uvm_do_with(req, {req.PADDR==12'h00C; req.PWRITE==1; req.PWDATA==32'h0001_0010;}) // Ch0
     `uvm_do_with(req, {req.PADDR==12'h010; req.PWRITE==1; req.PWDATA==32'h0001_0010;}) // Ch1
     `uvm_do_with(req, {req.PADDR==12'h014; req.PWRITE==1; req.PWDATA==32'h0001_0010;}) // Ch2
     `uvm_do_with(req, {req.PADDR==12'h018; req.PWRITE==1; req.PWDATA==32'h0001_0010;}) // Ch3

    `uvm_info(get_type_name(), "All 4 channels configured with COMP_OP=001 (togrst)", UVM_LOW)

    `uvm_do_with(req,{
        req.PADDR  == 12'h100;           
        req.PWRITE == 1;
        req.PWDATA == 32'h000F_3210;     // event_en[0] = 1, select ch_o[0] as source
    })

    // 5. Enable Timer0 clock
    `uvm_do_with(req,{
        req.PADDR  == 12'h104;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0001;
    })

    // 6. Start Timer0
    `uvm_do_with(req,{
        req.PADDR  == 12'h000;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0001;
    })

    `uvm_do_with(req,{req.delay == 300; req.PSEL == 0;})   // ≥300 cycles for full sawtooth behavior

  endtask
endclass

//////////////////////////////////////

class pwm_comp_op_001_togrst_sawtooth_off_timer0_ch0_seq extends apb_base_seq;

  `uvm_object_utils(pwm_comp_op_001_togrst_sawtooth_off_timer0_ch0_seq)

  function new(string name = "pwm_comp_op_001_togrst_sawtooth_off_timer0_ch0_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(), "=== PWM COMP_OP=001 (OP_TOGRST) + TRIANGLE MODE (SAWTOOTH=0) TEST START ===", UVM_LOW)

      `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay == 30;})
        // repeat(60) @(posedge vif.HCLK);

    // 2. REG_TIM0_CFG → SAWTOOTH=0 (triangle/up-down), PRESC=0, MODE=0
    `uvm_do_with(req,{
        req.PADDR  == 12'h004;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0000;   // SAWTOOTH=0
    })

    // 3. REG_TIM0_TH → COUNT_START=0x0000, COUNT_END=0x0020
    `uvm_do_with(req,{
        req.PADDR  == 12'h008;
        req.PWRITE == 1;
        req.PWDATA == 32'h0020_0000;
    })

    
    `uvm_do_with(req,{
        req.PADDR  == 12'h008;
        req.PWRITE == 0;
        req.delay == 20;
    })

    `uvm_do_with(req, {req.PADDR==12'h00C; req.PWRITE==1; req.PWDATA==32'h0001_0010;}) // Ch0
     `uvm_do_with(req, {req.PADDR==12'h010; req.PWRITE==1; req.PWDATA==32'h0001_0010;}) // Ch1
     `uvm_do_with(req, {req.PADDR==12'h014; req.PWRITE==1; req.PWDATA==32'h0001_0010;}) // Ch2
     `uvm_do_with(req, {req.PADDR==12'h018; req.PWRITE==1; req.PWDATA==32'h0001_0010;}) // Ch3

    `uvm_info(get_type_name(), "All 4 channels configured with COMP_OP=001 (togrst)", UVM_LOW)

    `uvm_do_with(req,{
        req.PADDR  == 12'h100;           
        req.PWRITE == 1;
        req.PWDATA == 32'h000F_3210;     // event_en[0] = 1, select ch_o[0] as source
    })

    // 5. Enable Timer0 clock
    `uvm_do_with(req,{
        req.PADDR  == 12'h104;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0001;
    })

    // 6. Start Timer0
    `uvm_do_with(req,{
        req.PADDR  == 12'h000;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0001;
    })

    `uvm_do_with(req,{req.delay == 300; req.PSEL == 0;})   // ≥400 cycles for full up-down behavior


  endtask
endclass

//////////////////////////////////////////////////////////////

class pwm_comp_op_010_setrst_sawtooth_on_timer0_ch0_seq extends apb_base_seq;

  `uvm_object_utils(pwm_comp_op_010_setrst_sawtooth_on_timer0_ch0_seq)

  function new(string name = "pwm_comp_op_010_setrst_sawtooth_on_timer0_ch0_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(), "=== PWM COMP_OP=010 (OP_SETRST) + SAWTOOTH TEST START ===", UVM_LOW)

    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay == 30;})
        // repeat(60) @(posedge vif.HCLK);

    // 2. REG_TIM0_CFG → SAWTOOTH=1, PRESC=0, MODE=0
    `uvm_do_with(req,{
        req.PADDR  == 12'h004;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_1000;   // SAW=1
    })

    // 3. REG_TIM0_TH → COUNT_START=0x0000, COUNT_END=0x0020
    `uvm_do_with(req,{
        req.PADDR  == 12'h008;
        req.PWRITE == 1;
        req.PWDATA == 32'h0020_0000;
    })

    
    `uvm_do_with(req,{
        req.PADDR  == 12'h008;
        req.PWRITE == 0;
        req.delay == 20;
    })

     `uvm_do_with(req, {req.PADDR==12'h00C; req.PWRITE==1; req.PWDATA==32'h0002_0010;}) // Ch0
     `uvm_do_with(req, {req.PADDR==12'h010; req.PWRITE==1; req.PWDATA==32'h0002_0010;}) // Ch1
     `uvm_do_with(req, {req.PADDR==12'h014; req.PWRITE==1; req.PWDATA==32'h0002_0010;}) // Ch2
     `uvm_do_with(req, {req.PADDR==12'h018; req.PWRITE==1; req.PWDATA==32'h0002_0010;}) // Ch3

    `uvm_info(get_type_name(), "All 4 channels configured with COMP_OP=001 (togrst)", UVM_LOW)

    `uvm_do_with(req,{
        req.PADDR  == 12'h100;           
        req.PWRITE == 1;
        req.PWDATA == 32'h000F_3210;     // event_en[0] = 1, select ch_o[0] as source
    })

    // 5. Enable Timer0 clock
    `uvm_do_with(req,{
        req.PADDR  == 12'h104;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0001;
    })

    // 6. Start Timer0
    `uvm_do_with(req,{
        req.PADDR  == 12'h000;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0001;
    })

     `uvm_do_with(req,{req.delay == 300; req.PSEL == 0;})   // ≥300 cycles for clear sawtooth pattern

  endtask
endclass

////////////////////////////////////////////

class pwm_comp_op_010_setrst_sawtooth_off_timer0_ch0_seq extends apb_base_seq;

  `uvm_object_utils(pwm_comp_op_010_setrst_sawtooth_off_timer0_ch0_seq)

  function new(string name = "pwm_comp_op_010_setrst_sawtooth_off_timer0_ch0_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(), "=== PWM COMP_OP=010 (OP_SETRST) + TRIANGLE MODE (SAWTOOTH=0) TEST START ===", UVM_LOW)

    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay == 50;})
        // repeat(60) @(posedge vif.HCLK);

    // 2. REG_TIM0_CFG → SAWTOOTH=0 (triangle/up-down mode)
    `uvm_do_with(req,{
        req.PADDR  == 12'h004;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0000;   // SAWTOOTH=0
    })

    // 3. REG_TIM0_TH → COUNT_START=0x0000, COUNT_END=0x0020
    `uvm_do_with(req,{
        req.PADDR  == 12'h008;
        req.PWRITE == 1;
        req.PWDATA == 32'h0020_0000;
    })
    
    `uvm_do_with(req,{
        req.PADDR  == 12'h008;
        req.PWRITE == 0;
        req.delay == 20;
    })

    // 4. REG_TIM0_CH0_TH → COMP_OP=010 (OP_SETRST), THRESHOLD=0x0010
    
     `uvm_do_with(req, {req.PADDR==12'h00C; req.PWRITE==1; req.PWDATA==32'h0002_0010;}) // Ch0
     `uvm_do_with(req, {req.PADDR==12'h010; req.PWRITE==1; req.PWDATA==32'h0002_0010;}) // Ch1
     `uvm_do_with(req, {req.PADDR==12'h014; req.PWRITE==1; req.PWDATA==32'h0002_0010;}) // Ch2
     `uvm_do_with(req, {req.PADDR==12'h018; req.PWRITE==1; req.PWDATA==32'h0002_0010;}) // Ch3

    `uvm_info(get_type_name(), "All 4 channels configured with COMP_OP=001 (togrst)", UVM_LOW)

    `uvm_do_with(req,{
        req.PADDR  == 12'h100;           
        req.PWRITE == 1;
        req.PWDATA == 32'h000F_3210;     // event_en[0] = 1, select ch_o[0] as source
    })

    // 5. Enable Timer0 clock
    `uvm_do_with(req,{
        req.PADDR  == 12'h104;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0001;
    })

    // 6. Start Timer0
    `uvm_do_with(req,{
        req.PADDR  == 12'h000;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0001;
    })

    `uvm_do_with(req,{req.delay == 300; req.PSEL == 0;})   // ≥400 cycles to see full up-down + repeat

  endtask
endclass

///////////////////////////////////////////////////////

class pwm_comp_op_011_tog_any_sawtooth_timer0_ch0_seq extends apb_base_seq;

  `uvm_object_utils(pwm_comp_op_011_tog_any_sawtooth_timer0_ch0_seq)

  function new(string name = "pwm_comp_op_011_tog_any_sawtooth_timer0_ch0_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(), "=== COMP_OP=011 (OP_TOG) - Pure Toggle Test START ===", UVM_LOW)

   `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay == 30;})

    // ==================== PHASE 1: SAWTOOTH = 1 ====================
    `uvm_do_with(req,{req.PADDR==12'h004; req.PWRITE==1; req.PWDATA==32'h0000_1000;}) // SAW=1
    `uvm_do_with(req,{req.PADDR==12'h008; req.PWRITE==1; req.PWDATA==32'h0020_0000;})

     
    `uvm_do_with(req,{
        req.PADDR  == 12'h008;
        req.PWRITE == 0;
        req.delay == 20;
    })

    `uvm_do_with(req, {req.PADDR==12'h00C; req.PWRITE==1; req.PWDATA==32'h0003_0010;}) // Ch0
     `uvm_do_with(req, {req.PADDR==12'h010; req.PWRITE==1; req.PWDATA==32'h0003_0010;}) // Ch1
     `uvm_do_with(req, {req.PADDR==12'h014; req.PWRITE==1; req.PWDATA==32'h0003_0010;}) // Ch2
     `uvm_do_with(req, {req.PADDR==12'h018; req.PWRITE==1; req.PWDATA==32'h0003_0010;}) // Ch3

    `uvm_info(get_type_name(), "All 4 channels configured with COMP_OP=001 (togrst)", UVM_LOW)

    `uvm_do_with(req,{
        req.PADDR  == 12'h100;           
        req.PWRITE == 1;
        req.PWDATA == 32'h000F_3210;     // event_en[0] = 1, select ch_o[0] as source
    })

    `uvm_do_with(req,{req.PADDR==12'h104; req.PWRITE==1; req.PWDATA==32'h0000_0001;})
    `uvm_do_with(req,{req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001;})

    `uvm_do_with(req,{req.delay == 300; req.PSEL == 0;})

    // ==================== PHASE 2: SAWTOOTH = 0 ====================
    `uvm_do_with(req,{req.PADDR==12'h004; req.PWRITE==1; req.PWDATA==32'h0000_0000;}) // SAW=0
    `uvm_do_with(req,{req.PADDR==12'h008; req.PWRITE==1; req.PWDATA==32'h0020_0000;})

     
    `uvm_do_with(req,{
        req.PADDR  == 12'h008;
        req.PWRITE == 0;
        req.delay == 20;
    })

    `uvm_do_with(req, {req.PADDR==12'h00C; req.PWRITE==1; req.PWDATA==32'h0003_0012;}) // Ch0
     `uvm_do_with(req, {req.PADDR==12'h010; req.PWRITE==1; req.PWDATA==32'h0003_0012;}) // Ch1
     `uvm_do_with(req, {req.PADDR==12'h014; req.PWRITE==1; req.PWDATA==32'h0003_0012;}) // Ch2
     `uvm_do_with(req, {req.PADDR==12'h018; req.PWRITE==1; req.PWDATA==32'h0003_0012;}) // Ch3
    `uvm_do_with(req,{req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001;}) // re-start

    `uvm_do_with(req,{req.delay == 300; req.PSEL == 0;})
    // repeat(250) @(posedge vif.HCLK);

  endtask
endclass


class pwm_comp_op_100_rst_on_match_timer0_ch0_seq extends apb_base_seq;

  `uvm_object_utils(pwm_comp_op_100_rst_on_match_timer0_ch0_seq)

  function new(string name = "pwm_comp_op_100_rst_on_match_timer0_ch0_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(), "=== COMP_OP=100 (OP_RST) - Force Low on Match ===", UVM_LOW)

   `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay == 30;})
        // repeat(60) @(posedge vif.HCLK);

    // 2. Configure Timer0
    `uvm_do_with(req,{ req.PADDR==12'h004; req.PWRITE==1; req.PWDATA==32'h0000_1000; }) // SAWTOOTH=1
    `uvm_do_with(req,{ req.PADDR==12'h008; req.PWRITE==1; req.PWDATA==32'h0020_0000; })

     
    `uvm_do_with(req,{
        req.PADDR  == 12'h008;
        req.PWRITE == 0;
        req.delay == 20;
    })

     `uvm_do_with(req, {req.PADDR==12'h00C; req.PWRITE==1; req.PWDATA==32'h0004_0010;}) // Ch0
     `uvm_do_with(req, {req.PADDR==12'h010; req.PWRITE==1; req.PWDATA==32'h0004_0010;}) // Ch1
     `uvm_do_with(req, {req.PADDR==12'h014; req.PWRITE==1; req.PWDATA==32'h0004_0010;}) // Ch2
     `uvm_do_with(req, {req.PADDR==12'h018; req.PWRITE==1; req.PWDATA==32'h0004_0010;}) // Ch3

    `uvm_info(get_type_name(), "All 4 channels configured with COMP_OP=001 (togrst)", UVM_LOW)

    `uvm_do_with(req,{
        req.PADDR  == 12'h100;           
        req.PWRITE == 1;
        req.PWDATA == 32'h000F_3210;     // event_en[0] = 1, select ch_o[0] as source
    })
        
    `uvm_do_with(req,{ req.PADDR==12'h104; req.PWRITE==1; req.PWDATA==32'h0000_0001; })
    `uvm_do_with(req,{ req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001; })

    `uvm_do_with(req,{req.delay == 500; req.PSEL == 0;})

    `uvm_info(get_type_name(), "=== COMP_OP=100 (OP_RST) Test COMPLETED ===", UVM_LOW);

  endtask
endclass

/////////////////////////////////////////////////////////

class pwm_comp_op_101_togset_sawtooth_on_timer0_ch0_seq extends apb_base_seq;
  
  `uvm_object_utils(pwm_comp_op_101_togset_sawtooth_on_timer0_ch0_seq)

  function new(string name = "pwm_comp_op_101_togset_sawtooth_on_timer0_ch0_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(), "=== COMP_OP=101 (OP_TOGSET) + SAWTOOTH=1 TEST START ===", UVM_LOW)

   `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay == 30;})
        // repeat(60) @(posedge vif.HCLK);

    // 2. Configure for SAWTOOTH=1 + COMP_OP=101 (OP_TOGSET)
    `uvm_do_with(req,{ req.PADDR==12'h004; req.PWRITE==1; req.PWDATA==32'h0000_1000; }) // SAW=1
    `uvm_do_with(req,{ req.PADDR==12'h008; req.PWRITE==1; req.PWDATA==32'h0020_0000; })

    
    `uvm_do_with(req,{
        req.PADDR  == 12'h008;
        req.PWRITE == 0;
        req.delay == 20;
    })

     `uvm_do_with(req, {req.PADDR==12'h00C; req.PWRITE==1; req.PWDATA==32'h0005_0010;}) // Ch0
     `uvm_do_with(req, {req.PADDR==12'h010; req.PWRITE==1; req.PWDATA==32'h0005_0010;}) // Ch1
     `uvm_do_with(req, {req.PADDR==12'h014; req.PWRITE==1; req.PWDATA==32'h0005_0010;}) // Ch2
     `uvm_do_with(req, {req.PADDR==12'h018; req.PWRITE==1; req.PWDATA==32'h0005_0010;}) // Ch3

    `uvm_info(get_type_name(), "All 4 channels configured with COMP_OP=001 (togrst)", UVM_LOW)

    `uvm_do_with(req,{
        req.PADDR  == 12'h100;           
        req.PWRITE == 1;
        req.PWDATA == 32'h000F_3210;     // event_en[0] = 1, select ch_o[0] as source
    })


    `uvm_do_with(req,{ req.PADDR==12'h104; req.PWRITE==1; req.PWDATA==32'h0000_0001; })
    `uvm_do_with(req,{ req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001; })

     `uvm_do_with(req,{req.delay == 500; req.PSEL == 0;}) // Enough cycles to see the repeating pattern

    `uvm_info(get_type_name(), "=== COMP_OP=101 (OP_TOGSET) + SAWTOOTH=1 TEST COMPLETED ===", UVM_LOW);

  endtask
endclass

////////////////////////////////////////////

class pwm_comp_op_101_togset_sawtooth_off_timer0_ch0_seq extends apb_base_seq;

  `uvm_object_utils(pwm_comp_op_101_togset_sawtooth_off_timer0_ch0_seq)

  function new(string name = "pwm_comp_op_101_togset_sawtooth_off_timer0_ch0_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(), "=== COMP_OP=101 (OP_TOGSET) + SAWTOOTH=0 (Triangle) TEST START ===", UVM_LOW)

   `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay == 30;})

    // 2. Configure for SAWTOOTH=0 + COMP_OP=101 (OP_TOGSET)
    `uvm_do_with(req,{ req.PADDR==12'h004; req.PWRITE==1; req.PWDATA==32'h0000_0000; }) // SAW=0
    `uvm_do_with(req,{ req.PADDR==12'h008; req.PWRITE==1; req.PWDATA==32'h0020_0000; })
    
     
    `uvm_do_with(req,{
        req.PADDR  == 12'h008;
        req.PWRITE == 0;
        req.delay == 20;
    })
     
     `uvm_do_with(req, {req.PADDR==12'h00C; req.PWRITE==1; req.PWDATA==32'h0005_0010;}) // Ch0
     `uvm_do_with(req, {req.PADDR==12'h010; req.PWRITE==1; req.PWDATA==32'h0005_0010;}) // Ch1
     `uvm_do_with(req, {req.PADDR==12'h014; req.PWRITE==1; req.PWDATA==32'h0005_0010;}) // Ch2
     `uvm_do_with(req, {req.PADDR==12'h018; req.PWRITE==1; req.PWDATA==32'h0005_0010;}) // Ch3

    `uvm_info(get_type_name(), "All 4 channels configured with COMP_OP=001 (togrst)", UVM_LOW)

    `uvm_do_with(req,{
        req.PADDR  == 12'h100;           
        req.PWRITE == 1;
        req.PWDATA == 32'h000F_3210;     // event_en[0] = 1, select ch_o[0] as source
    })

    `uvm_do_with(req,{ req.PADDR==12'h104; req.PWRITE==1; req.PWDATA==32'h0000_0001; })
    `uvm_do_with(req,{ req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001; })

    `uvm_do_with(req,{req.delay == 500; req.PSEL == 0;})
    
    `uvm_info(get_type_name(), "=== COMP_OP=101 (OP_TOGSET) + SAWTOOTH=0 TEST COMPLETED ===", UVM_LOW);

  endtask
endclass

//////////////////////////////////////////////////////////

class pwm_comp_op_110_rstset_sawtooth_on_timer0_ch0_seq extends apb_base_seq;

  `uvm_object_utils(pwm_comp_op_110_rstset_sawtooth_on_timer0_ch0_seq)

  function new(string name = "pwm_comp_op_110_rstset_sawtooth_on_timer0_ch0_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(), "=== COMP_OP=110 (OP_RSTSET) + SAWTOOTH=1 TEST START ===", UVM_LOW)

    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay == 30;})

    // 2. Configure Timer0
    `uvm_do_with(req,{ req.PADDR==12'h004; req.PWRITE==1; req.PWDATA==32'h0000_1000; }) // SAWTOOTH=1
    `uvm_do_with(req,{ req.PADDR==12'h008; req.PWRITE==1; req.PWDATA==32'h0020_0000; })
    
    
    `uvm_do_with(req,{
        req.PADDR  == 12'h008;
        req.PWRITE == 0;
        req.delay == 20;
    })

     `uvm_do_with(req, {req.PADDR==12'h00C; req.PWRITE==1; req.PWDATA==32'h0006_0010;}) // Ch0
     `uvm_do_with(req, {req.PADDR==12'h010; req.PWRITE==1; req.PWDATA==32'h0006_0010;}) // Ch1
     `uvm_do_with(req, {req.PADDR==12'h014; req.PWRITE==1; req.PWDATA==32'h0006_0010;}) // Ch2
     `uvm_do_with(req, {req.PADDR==12'h018; req.PWRITE==1; req.PWDATA==32'h0006_0010;}) // Ch3

    `uvm_info(get_type_name(), "All 4 channels configured with COMP_OP=001 (togrst)", UVM_LOW)

    `uvm_do_with(req,{
        req.PADDR  == 12'h100;           
        req.PWRITE == 1;
        req.PWDATA == 32'h000F_3210;     // event_en[0] = 1, select ch_o[0] as source
    })

    `uvm_do_with(req,{ req.PADDR==12'h104; req.PWRITE==1; req.PWDATA==32'h0000_0001; })
    `uvm_do_with(req,{ req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001; })

    `uvm_do_with(req,{req.delay == 500; req.PSEL == 0;})

    `uvm_info(get_type_name(), "=== COMP_OP=110 (OP_RSTSET) + SAWTOOTH=1 TEST COMPLETED ===", UVM_LOW);

  endtask
endclass

////////////////////////////////////////////////////////////////////

class pwm_comp_op_110_rstset_sawtooth_off_timer0_ch0_seq extends apb_base_seq;

  `uvm_object_utils(pwm_comp_op_110_rstset_sawtooth_off_timer0_ch0_seq)

  function new(string name = "pwm_comp_op_110_rstset_sawtooth_off_timer0_ch0_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(), "=== COMP_OP=110 (OP_RSTSET) + SAWTOOTH=0 (Triangle) TEST START ===", UVM_LOW)

    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay == 30;})

    // 2. Configure for SAWTOOTH=0 + COMP_OP=110 (OP_RSTSET)
    `uvm_do_with(req,{ req.PADDR==12'h004; req.PWRITE==1; req.PWDATA==32'h0000_0000; }) // SAWTOOTH=0
    `uvm_do_with(req,{ req.PADDR==12'h008; req.PWRITE==1; req.PWDATA==32'h0020_0000; })

    
    `uvm_do_with(req,{
        req.PADDR  == 12'h008;
        req.PWRITE == 0;
        req.delay == 20;
    })

     `uvm_do_with(req, {req.PADDR==12'h00C; req.PWRITE==1; req.PWDATA==32'h0006_0010;}) // Ch0
     `uvm_do_with(req, {req.PADDR==12'h010; req.PWRITE==1; req.PWDATA==32'h0006_0010;}) // Ch1
     `uvm_do_with(req, {req.PADDR==12'h014; req.PWRITE==1; req.PWDATA==32'h0006_0010;}) // Ch2
     `uvm_do_with(req, {req.PADDR==12'h018; req.PWRITE==1; req.PWDATA==32'h0006_0010;}) // Ch3

    `uvm_info(get_type_name(), "All 4 channels configured with COMP_OP=001 (togrst)", UVM_LOW)

    `uvm_do_with(req,{
        req.PADDR  == 12'h100;           
        req.PWRITE == 1;
        req.PWDATA == 32'h000F_3210;     // event_en[0] = 1, select ch_o[0] as source
    })
    
    `uvm_do_with(req,{ req.PADDR==12'h104; req.PWRITE==1; req.PWDATA==32'h0000_0001; })
    `uvm_do_with(req,{ req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001; })

     `uvm_do_with(req,{req.delay == 500; req.PSEL == 0;})
    
    `uvm_info(get_type_name(), "=== COMP_OP=110 (OP_RSTSET) + SAWTOOTH=0 TEST COMPLETED ===", UVM_LOW);

  endtask
endclass

//////////////////////////////////////////////////////////////////////

class pwm_comp_default_hold_no_match_timer0_ch0_seq extends apb_base_seq;

  `uvm_object_utils(pwm_comp_default_hold_no_match_timer0_ch0_seq)

  function new(string name = "pwm_comp_default_hold_no_match_timer0_ch0_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(), "=== DEFAULT HOLD: No Match / No Event_2 Test START ===", UVM_LOW)

    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay == 30;})


    // 2. Configure so that match never happens
    `uvm_do_with(req,{ req.PADDR==12'h004; req.PWRITE==1; req.PWDATA==32'h0000_1000; }) // SAWTOOTH=1 (you can change to 0 if needed)
    `uvm_do_with(req,{ req.PADDR==12'h008; req.PWRITE==1; req.PWDATA==32'h0020_0000; }) // small COUNT_END
    
    `uvm_do_with(req,{
        req.PADDR  == 12'h008;
        req.PWRITE == 0;
        req.delay == 20;
    })

    `uvm_do_with(req,{ req.PADDR==12'h00C; req.PWRITE==1; req.PWDATA==32'h0000_FFFF; }) // COMP_THRESHOLD = 0xFFFF (never reached)

    `uvm_info(get_type_name(), "All 4 channels configured with COMP_OP=001 (togrst)", UVM_LOW)

    `uvm_do_with(req,{
        req.PADDR  == 12'h100;           
        req.PWRITE == 1;
        req.PWDATA == 32'h000F_3210;     // event_en[0] = 1, select ch_o[0] as source
    })

    `uvm_do_with(req,{ req.PADDR==12'h104; req.PWRITE==1; req.PWDATA==32'h0000_0001; })
    `uvm_do_with(req,{ req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001; })

    `uvm_do_with(req,{req.delay == 500; req.PSEL == 0;})

    `uvm_info(get_type_name(), "=== DEFAULT HOLD: No Match Test COMPLETED ===", UVM_LOW);

  endtask
endclass

/////////////////////////////////////////////////////////////////////

class pwm_comp_reset_behavior_all_op_timer0_ch0_seq extends apb_base_seq;

  `uvm_object_utils(pwm_comp_reset_behavior_all_op_timer0_ch0_seq)

  function new(string name = "pwm_comp_reset_behavior_all_op_timer0_ch0_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(), "=== PWM RESET BEHAVIOR (All COMP_OP) TEST START ===", UVM_LOW)

    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay == 30;})

    // 2. Configure active PWM (OP_SET example - PWM should go high)
    `uvm_do_with(req,{ req.PADDR==12'h004; req.PWRITE==1; req.PWDATA==32'h0000_1000; }) // SAW=1
    `uvm_do_with(req,{ req.PADDR==12'h008; req.PWRITE==1; req.PWDATA==32'h0020_0000; })

     
    `uvm_do_with(req,{
        req.PADDR  == 12'h008;
        req.PWRITE == 0;
        req.delay == 20;
    })

    `uvm_do_with(req, {req.PADDR==12'h00C; req.PWRITE==1; req.PWDATA==32'h0000_0010;}) // Ch0
     `uvm_do_with(req, {req.PADDR==12'h010; req.PWRITE==1; req.PWDATA==32'h0000_0010;}) // Ch1
     `uvm_do_with(req, {req.PADDR==12'h014; req.PWRITE==1; req.PWDATA==32'h0000_0010;}) // Ch2
     `uvm_do_with(req, {req.PADDR==12'h018; req.PWRITE==1; req.PWDATA==32'h0000_0010;}) // Ch3

    `uvm_info(get_type_name(), "All 4 channels configured with COMP_OP=001 (togrst)", UVM_LOW)

    `uvm_do_with(req,{
        req.PADDR  == 12'h100;           
        req.PWRITE == 1;
        req.PWDATA == 32'h000F_3210;     // event_en[0] = 1, select ch_o[0] as source
    })

    `uvm_do_with(req,{ req.PADDR==12'h104; req.PWRITE==1; req.PWDATA==32'h0000_0001; })
    `uvm_do_with(req,{ req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001; })

     `uvm_do_with(req,{req.delay == 100; req.PSEL == 0;})

    // ====================== HARD RESET (HRESETn) ======================
    `uvm_info(get_type_name(), "→ Applying Hard Reset (HRESETn low)", UVM_LOW)
  `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008;})

    `uvm_info(get_type_name(), "✅ PWM forced to 0 after hard reset", UVM_LOW);

    // ====================== SOFT RESET (CMD RESET bit) ======================
    // Re-configure PWM to high again
    `uvm_do_with(req,{ req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001; req.delay == 100; })

    `uvm_info(get_type_name(), "→ Applying Soft Reset (CMD RESET=1)", UVM_LOW)
    `uvm_do_with(req,{ req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay == 30; }) // RESET bit

    `uvm_info(get_type_name(), "=== PWM RESET BEHAVIOR TEST COMPLETED ===", UVM_LOW);

  endtask
endclass

/////////////////////////////////////////////////////

class pwm_comp_update_gating_all_op_timer0_ch0_seq extends apb_base_seq;

  `uvm_object_utils(pwm_comp_update_gating_all_op_timer0_ch0_seq)

  function new(string name = "pwm_comp_update_gating_all_op_timer0_ch0_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(), "=== PWM UPDATE GATING TEST (COMP_OP/TH ignored until UPDATE=1) START ===", UVM_LOW)

    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay == 30;})

    // 2. Configure active PWM (OP_SET so PWM goes high)
    `uvm_do_with(req,{ req.PADDR==12'h004; req.PWRITE==1; req.PWDATA==32'h0000_1000; }) // SAW=1
    `uvm_do_with(req,{ req.PADDR==12'h008; req.PWRITE==1; req.PWDATA==32'h0020_0000; })

    
    `uvm_do_with(req,{
        req.PADDR  == 12'h008;
        req.PWRITE == 0;
        req.delay == 20;
    })

     `uvm_do_with(req, {req.PADDR==12'h00C; req.PWRITE==1; req.PWDATA==32'h0000_0010;}) // Ch0
     `uvm_do_with(req, {req.PADDR==12'h010; req.PWRITE==1; req.PWDATA==32'h0000_0010;}) // Ch1
     `uvm_do_with(req, {req.PADDR==12'h014; req.PWRITE==1; req.PWDATA==32'h0000_0010;}) // Ch2
     `uvm_do_with(req, {req.PADDR==12'h018; req.PWRITE==1; req.PWDATA==32'h0000_0010;}) // Ch3

    `uvm_info(get_type_name(), "All 4 channels configured with COMP_OP=001 (togrst)", UVM_LOW)

    `uvm_do_with(req,{
        req.PADDR  == 12'h100;           
        req.PWRITE == 1;
        req.PWDATA == 32'h000F_3210;     // event_en[0] = 1, select ch_o[0] as source
    })

    `uvm_do_with(req,{ req.PADDR==12'h104; req.PWRITE==1; req.PWDATA==32'h0000_0001; })
    `uvm_do_with(req,{ req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001; })

     `uvm_do_with(req,{req.delay == 100; req.PSEL == 0;})

    // 3. Change to new COMP_OP and new TH (without UPDATE)
    `uvm_do_with(req,{ req.PADDR==12'h00C; req.PWRITE==1; req.PWDATA==32'h0003_0008; }) // New: COMP_OP=011 (OP_TOG), TH=0x0008
    `uvm_do_with(req, {req.PADDR==12'h010; req.PWRITE==1; req.PWDATA==32'h0000_0010;}) // Ch1
    `uvm_do_with(req, {req.PADDR==12'h014; req.PWRITE==1; req.PWDATA==32'h0000_0010;}) // Ch2
    `uvm_do_with(req, {req.PADDR==12'h018; req.PWRITE==1; req.PWDATA==32'h0000_0010;}) // Ch3

    `uvm_do_with(req,{req.delay == 100; req.PSEL == 0;})

    // 4. Set UPDATE=1 to apply new values
    `uvm_do_with(req,{ req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0010; }) // UPDATE bit (bit 4)

    `uvm_do_with(req,{req.delay == 100; req.PSEL == 0;})

    `uvm_info(get_type_name(), "=== PWM UPDATE GATING TEST COMPLETED ===", UVM_LOW);

  endtask
endclass

// class comp_ch0_toggle_coverage_timer0_seq extends apb_base_seq;

//   `uvm_object_utils(comp_ch0_toggle_coverage_timer0_seq)

//   function new(string name = "comp_ch0_toggle_coverage_timer0_seq");
//     super.new(name);
//   endfunction

//   // Helper: Stop → Reconfigure CH0 (32-bit) → Update + Start
//   task reconfigure_ch0_32bit(bit [31:0] threshold, bit [2:0] comp_op, int run_cycles);
//     `uvm_info(get_type_name(), 
//         $sformatf("CH0 32b: TH=0x%08h, COMP_OP=0b%03b, cycles=%0d", threshold, comp_op, run_cycles), 
//         UVM_LOW)

//     // Stop timer
//     `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0002; req.delay==5;})

//     // Low 16-bit + comp_op
//     `uvm_do_with(req, {
//         req.PADDR  == 12'h00C;
//         req.PWRITE == 1;
//         req.PWDATA == {13'h0, comp_op, threshold[15:0]};
//     })

//     // High 16-bit threshold (this hits cfg_comp_i[31:16] and r_comp[31:16])
//     `uvm_do_with(req, {
//         req.PADDR  == 12'h204;           // REG_TIM0_CH0_TH_HI
//         req.PWRITE == 1;
//         req.PWDATA == {16'h0, threshold[31:16]};
//     })

//     // Update + Start
//     `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0004; req.delay==5;})
//     `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001; req.delay==run_cycles;})
//   endtask

//   task body();
//     `uvm_info(get_type_name(), "=== CH0 COMPARATOR FULL TOGGLE COVERAGE (32-bit) START ===", UVM_LOW)

//     // ==================== Global Setup ====================
//     `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay==60;}) // Reset

//     // Timer CFG: Sawtooth, no prescaler, in_mode=0
//     `uvm_do_with(req, {req.PADDR==12'h004; req.PWRITE==1; req.PWDATA==32'h0000_1000;})

//     // Large period to reach upper 16 bits of counter
//     `uvm_do_with(req, {req.PADDR==12'h008; req.PWRITE==1; req.PWDATA==32'hFFFF_0000;}) // low
//     `uvm_do_with(req, {req.PADDR==12'h200; req.PWRITE==1; req.PWDATA==32'h0000_0000;}) // TH_HI → period = 32'h0000_FFFF

//     `uvm_do_with(req, {req.PADDR==12'h008; req.PWRITE==0; req.delay==20;}) // read back

//     // Enable other channels (minimal config)
//     `uvm_do_with(req, {req.PADDR==12'h010; req.PWRITE==1; req.PWDATA==32'h0000_0010;})
//     `uvm_do_with(req, {req.PADDR==12'h014; req.PWRITE==1; req.PWDATA==32'h0000_0010;})
//     `uvm_do_with(req, {req.PADDR==12'h018; req.PWRITE==1; req.PWDATA==32'h0000_0010;})

//     // Event + Clock Enable
//     `uvm_do_with(req, {req.PADDR==12'h100; req.PWRITE==1; req.PWDATA==32'h000F_0000;})
//     `uvm_do_with(req, {req.PADDR==12'h104; req.PWRITE==1; req.PWDATA==32'h0000_0001;})

//     `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0004; req.delay==5;}) // Update

//     // ==================== Main Toggle Phases ====================

//     `uvm_info(get_type_name(), "Phase 1: 32-bit Thresholds + Upper Counter Bits", UVM_LOW)
//     reconfigure_ch0_32bit(32'h0001_0000, 3'b011, 10000);  // Hits upper bits of counter + comp
//     reconfigure_ch0_32bit(32'h8000_1234, 3'b011, 40000);  // High threshold + upper count
//     reconfigure_ch0_32bit(32'hFFFF_FFFF, 3'b011, 2000);   // Max threshold
//     reconfigure_ch0_32bit(32'h0000_0000, 3'b011, 500);    // Zero threshold

//     `uvm_info(get_type_name(), "Phase 2: All Comparator Modes (including op[2]=1)", UVM_LOW)
//     reconfigure_ch0_32bit(32'h0001_0000, 3'b000, 200);   // SET
//     reconfigure_ch0_32bit(32'h0001_0000, 3'b001, 300);   // TOGRST     → 2nd event
//     reconfigure_ch0_32bit(32'h0001_0000, 3'b010, 300);   // SETRST     → 2nd event
//     reconfigure_ch0_32bit(32'h0001_0000, 3'b011, 200);   // TOG
//     reconfigure_ch0_32bit(32'h0001_0000, 3'b100, 200);   // RST        → op[2]=1
//     reconfigure_ch0_32bit(32'h0001_0000, 3'b101, 300);   // TOGSET     → op[2]=1
//     reconfigure_ch0_32bit(32'h0001_0000, 3'b110, 300);   // RSTSET     → op[2]=1

//     `uvm_info(get_type_name(), "Phase 3: Reset & Active Signal Toggle", UVM_LOW)
//     `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001; req.delay==150;})
//     `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay==30;}) // RST command
//     `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001; req.delay==300;})

//     `uvm_info(get_type_name(), "=== CH0 COMPARATOR FULL TOGGLE COVERAGE COMPLETED ===", UVM_LOW);
//   endtask

// endclass

class comp_ch0_toggle_coverage_timer0_seq extends apb_base_seq;

  `uvm_object_utils(comp_ch0_toggle_coverage_timer0_seq)

  function new(string name = "comp_ch0_toggle_coverage_timer0_seq");
    super.new(name);
  endfunction

  task reconfigure_ch0_32bit(bit [31:0] threshold, bit [2:0] comp_op, int run_cycles);
    `uvm_info(get_type_name(), 
        $sformatf("CH0: TH=0x%08h, OP=0b%03b, cycles=%0d", threshold, comp_op, run_cycles), 
        UVM_LOW)

    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0002;}) // Stop

    // Low register
    `uvm_do_with(req, {
        req.PADDR  == 12'h00C;
        req.PWRITE == 1;
        req.PWDATA == {13'h0, comp_op, threshold[15:0]};
    });

    // High register (required for 32-bit)
    `uvm_do_with(req, {
        req.PADDR  == 12'h204;
        req.PWRITE == 1;
        req.PWDATA == threshold[31:16];
    });

    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0004; req.delay==8;}) // Update
    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001; req.delay==run_cycles;}) // Start
  endtask

  task body();
    `uvm_info(get_type_name(), "=== CH0 COMPARATOR FULL TOGGLE COVERAGE - FINAL ===", UVM_LOW)

    // Global Reset
    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay==50;})

    // Timer Configuration
    `uvm_do_with(req, {req.PADDR==12'h004; req.PWRITE==1; req.PWDATA==32'h0000_1000;}) // saw=1, presc=0

    // === VERY LARGE PERIOD (essential for upper 16-bit counter toggle) ===
    `uvm_do_with(req, {req.PADDR==12'h008; req.PWRITE==1; req.PWDATA==32'hFFFF_0000;})
    `uvm_do_with(req, {req.PADDR==12'h200; req.PWRITE==1; req.PWDATA==32'h0000_FFFF;}) // period = 32'hFFFF_FFFF

    // Other channels minimal
    `uvm_do_with(req, {req.PADDR==12'h010; req.PWRITE==1; req.PWDATA==32'h0000_0010;})
    `uvm_do_with(req, {req.PADDR==12'h014; req.PWRITE==1; req.PWDATA==32'h0000_0010;})
    `uvm_do_with(req, {req.PADDR==12'h018; req.PWRITE==1; req.PWDATA==32'h0000_0010;})

    `uvm_do_with(req, {req.PADDR==12'h100; req.PWRITE==1; req.PWDATA==32'h000F_0000;})
    `uvm_do_with(req, {req.PADDR==12'h104; req.PWRITE==1; req.PWDATA==32'h0000_0001;}) // Clock enable

    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0004; req.delay==10;}) // Update

    // ==================== Coverage Phases ====================

    `uvm_info(get_type_name(), "Phase 1: Upper Counter Bits + 32-bit Thresholds", UVM_LOW)
    reconfigure_ch0_32bit(32'h0001_0000, 3'b011, 20000);
    reconfigure_ch0_32bit(32'h8000_0000, 3'b011, 80000);  // Force upper bits
    reconfigure_ch0_32bit(32'hFFFF_FFFF, 3'b011, 5000);

    `uvm_info(get_type_name(), "Phase 2: All Ops with Direction Change on op[2]", UVM_LOW)
    reconfigure_ch0_32bit(32'h0001_0000, 3'b000, 300);   // 000
    reconfigure_ch0_32bit(32'h0001_0000, 3'b100, 400);   // 100 → toggle op[2] 0→1
    reconfigure_ch0_32bit(32'h0001_0000, 3'b011, 400);   // 011 → toggle op[2] 1→0
    reconfigure_ch0_32bit(32'h0001_0000, 3'b101, 400);   // 101
    reconfigure_ch0_32bit(32'h0001_0000, 3'b110, 400);   // 110
    reconfigure_ch0_32bit(32'h0001_0000, 3'b001, 500);   // 001 (TOGRST)
    reconfigure_ch0_32bit(32'h0001_0000, 3'b010, 500);   // 010 (SETRST)

    `uvm_info(get_type_name(), "Phase 3: Force r_active High + Reset Paths", UVM_LOW)
    // Long run with active timer
    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001; req.delay==1000;})

    // Reset command while running
    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay==50;})
    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001; req.delay==500;})

    `uvm_info(get_type_name(), "=== CH0 COMPARATOR TOGGLE COVERAGE FINISHED ===", UVM_LOW);
  endtask

endclass

class comp_ch1_toggle_coverage_timer0_seq extends apb_base_seq;

  `uvm_object_utils(comp_ch1_toggle_coverage_timer0_seq)

  function new(string name = "comp_ch1_toggle_coverage_timer0_seq");
    super.new(name);
  endfunction

  // Helper task for CH1 (32-bit)
  task reconfigure_ch1_32bit(bit [31:0] threshold, bit [2:0] comp_op, int run_cycles);
    `uvm_info(get_type_name(), 
        $sformatf("CH1: TH=0x%08h, OP=0b%03b, cycles=%0d", threshold, comp_op, run_cycles), 
        UVM_LOW)

    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0002;}) // Stop

    // Low register - CH1
    `uvm_do_with(req, {
        req.PADDR  == 12'h010;           // REG_TIM0_CH1_TH
        req.PWRITE == 1;
        req.PWDATA == {13'h0, comp_op, threshold[15:0]};
    });

    // High register - CH1
    `uvm_do_with(req, {
        req.PADDR  == 12'h208;           // REG_TIM0_CH1_TH_HI
        req.PWRITE == 1;
        req.PWDATA == threshold[31:16];
    });

    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0004; req.delay==8;}) // Update
    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001; req.delay==run_cycles;}) // Start
  endtask

  task body();
    `uvm_info(get_type_name(), "=== CH1 COMPARATOR FULL TOGGLE COVERAGE - FINAL ===", UVM_LOW)

    // Global Reset
    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay==50;})

    // Timer Configuration (Sawtooth mode)
    `uvm_do_with(req, {req.PADDR==12'h004; req.PWRITE==1; req.PWDATA==32'h0000_1000;}) // saw=1, presc=0

    // === VERY LARGE PERIOD (required for timer_count_i[31:16]) ===
    `uvm_do_with(req, {req.PADDR==12'h008; req.PWRITE==1; req.PWDATA==32'hFFFF_0000;})
    `uvm_do_with(req, {req.PADDR==12'h200; req.PWRITE==1; req.PWDATA==32'h0000_FFFF;}) // period = 32'hFFFF_FFFF

    // Configure other channels with minimal settings
    `uvm_do_with(req, {req.PADDR==12'h00C; req.PWRITE==1; req.PWDATA==32'h0000_0010;}) // CH0
    `uvm_do_with(req, {req.PADDR==12'h014; req.PWRITE==1; req.PWDATA==32'h0000_0010;}) // CH2
    `uvm_do_with(req, {req.PADDR==12'h018; req.PWRITE==1; req.PWDATA==32'h0000_0010;}) // CH3

    // Event Config + Clock Enable
    `uvm_do_with(req, {req.PADDR==12'h100; req.PWRITE==1; req.PWDATA==32'h000F_0000;})
    `uvm_do_with(req, {req.PADDR==12'h104; req.PWRITE==1; req.PWDATA==32'h0000_0001;})

    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0004; req.delay==10;}) // Update

    // ==================== Coverage Phases ====================

    `uvm_info(get_type_name(), "Phase 1: Upper Counter Bits + 32-bit Thresholds (CH1)", UVM_LOW)
    reconfigure_ch1_32bit(32'h0001_0000, 3'b011, 20000);
    reconfigure_ch1_32bit(32'h8000_0000, 3'b011, 80000);   // Force upper 16-bit counter toggle
    reconfigure_ch1_32bit(32'hFFFF_FFFF, 3'b011, 5000);

    `uvm_info(get_type_name(), "Phase 2: All Ops with Direction Change on op[2] (CH1)", UVM_LOW)
    reconfigure_ch1_32bit(32'h0001_0000, 3'b000, 300);   // 000
    reconfigure_ch1_32bit(32'h0001_0000, 3'b100, 400);   // 100 → op[2] 0→1
    reconfigure_ch1_32bit(32'h0001_0000, 3'b011, 400);   // 011 → op[2] 1→0
    reconfigure_ch1_32bit(32'h0001_0000, 3'b101, 400);   // 101
    reconfigure_ch1_32bit(32'h0001_0000, 3'b110, 400);   // 110
    reconfigure_ch1_32bit(32'h0001_0000, 3'b001, 500);   // TOGRST
    reconfigure_ch1_32bit(32'h0001_0000, 3'b010, 500);   // SETRST

    `uvm_info(get_type_name(), "Phase 3: Force r_active High + Reset Paths (CH1)", UVM_LOW)
    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001; req.delay==1000;})

    // Reset command while running
    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay==50;})
    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001; req.delay==500;})

    `uvm_info(get_type_name(), "=== CH1 COMPARATOR FULL TOGGLE COVERAGE FINISHED ===", UVM_LOW);
  endtask

endclass

///////////////// channel 2 comparator toggle coverage

class comp_ch2_toggle_coverage_timer0_seq extends apb_base_seq;

  `uvm_object_utils(comp_ch2_toggle_coverage_timer0_seq)

  function new(string name = "comp_ch2_toggle_coverage_timer0_seq");
    super.new(name);
  endfunction

  // Helper task for CH2 (32-bit)
  task reconfigure_ch2_32bit(bit [31:0] threshold, bit [2:0] comp_op, int run_cycles);
    `uvm_info(get_type_name(), 
        $sformatf("CH2: TH=0x%08h, OP=0b%03b, cycles=%0d", threshold, comp_op, run_cycles), 
        UVM_LOW)

    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0002;}) // Stop

    // Low register - CH2
    `uvm_do_with(req, {
        req.PADDR  == 12'h014;           // REG_TIM0_CH2_TH
        req.PWRITE == 1;
        req.PWDATA == {13'h0, comp_op, threshold[15:0]};
    });

    // High register - CH2
    `uvm_do_with(req, {
        req.PADDR  == 12'h20C;           // REG_TIM0_CH2_TH_HI
        req.PWRITE == 1;
        req.PWDATA == threshold[31:16];
    });

    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0004; req.delay==8;}) // Update
    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001; req.delay==run_cycles;}) // Start
  endtask

  task body();
    `uvm_info(get_type_name(), "=== CH2 COMPARATOR FULL TOGGLE COVERAGE - FINAL ===", UVM_LOW)

    // Global Reset
    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay==50;})

    // Timer Configuration (Sawtooth mode)
    `uvm_do_with(req, {req.PADDR==12'h004; req.PWRITE==1; req.PWDATA==32'h0000_1000;}) // saw=1, presc=0

    // === VERY LARGE PERIOD (required for timer_count_i[31:16]) ===
    `uvm_do_with(req, {req.PADDR==12'h008; req.PWRITE==1; req.PWDATA==32'hFFFF_0000;})
    `uvm_do_with(req, {req.PADDR==12'h200; req.PWRITE==1; req.PWDATA==32'h0000_FFFF;}) // period = 32'hFFFF_FFFF

    // Configure other channels with minimal settings
    `uvm_do_with(req, {req.PADDR==12'h00C; req.PWRITE==1; req.PWDATA==32'h0000_0010;}) // CH0
    `uvm_do_with(req, {req.PADDR==12'h010; req.PWRITE==1; req.PWDATA==32'h0000_0010;}) // CH1
    `uvm_do_with(req, {req.PADDR==12'h018; req.PWRITE==1; req.PWDATA==32'h0000_0010;}) // CH3

    // Event Config + Clock Enable
    `uvm_do_with(req, {req.PADDR==12'h100; req.PWRITE==1; req.PWDATA==32'h000F_0000;})
    `uvm_do_with(req, {req.PADDR==12'h104; req.PWRITE==1; req.PWDATA==32'h0000_0001;})

    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0004; req.delay==10;}) // Update

    // ==================== Coverage Phases ====================

    `uvm_info(get_type_name(), "Phase 1: Upper Counter Bits + 32-bit Thresholds (CH2)", UVM_LOW)
    reconfigure_ch2_32bit(32'h0001_0000, 3'b011, 20000);
    reconfigure_ch2_32bit(32'h8000_0000, 3'b011, 80000);   // Force upper 16-bit counter toggle
    reconfigure_ch2_32bit(32'hFFFF_FFFF, 3'b011, 5000);

    `uvm_info(get_type_name(), "Phase 2: All Ops with Direction Change on op[2] (CH2)", UVM_LOW)
    reconfigure_ch2_32bit(32'h0001_0000, 3'b000, 300);   // 000
    reconfigure_ch2_32bit(32'h0001_0000, 3'b100, 400);   // 100 → op[2] 0→1
    reconfigure_ch2_32bit(32'h0001_0000, 3'b011, 400);   // 011 → op[2] 1→0
    reconfigure_ch2_32bit(32'h0001_0000, 3'b101, 400);   // 101
    reconfigure_ch2_32bit(32'h0001_0000, 3'b110, 400);   // 110
    reconfigure_ch2_32bit(32'h0001_0000, 3'b001, 500);   // TOGRST
    reconfigure_ch2_32bit(32'h0001_0000, 3'b010, 500);   // SETRST

    `uvm_info(get_type_name(), "Phase 3: Force r_active High + Reset Paths (CH2)", UVM_LOW)
    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001; req.delay==1000;})

    // Reset command while running
    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay==50;})
    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001; req.delay==500;})

    `uvm_info(get_type_name(), "=== CH2 COMPARATOR FULL TOGGLE COVERAGE FINISHED ===", UVM_LOW);
  endtask

endclass

class comp_ch3_toggle_coverage_timer0_seq extends apb_base_seq;

  `uvm_object_utils(comp_ch3_toggle_coverage_timer0_seq)

  function new(string name = "comp_ch3_toggle_coverage_timer0_seq");
    super.new(name);
  endfunction

  // Helper task for CH3 (32-bit)
  task reconfigure_ch3_32bit(bit [31:0] threshold, bit [2:0] comp_op, int run_cycles);
    `uvm_info(get_type_name(), 
        $sformatf("CH3: TH=0x%08h, OP=0b%03b, cycles=%0d", threshold, comp_op, run_cycles), 
        UVM_LOW)

    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0002;}) // Stop

    // Low register - CH3
    `uvm_do_with(req, {
        req.PADDR  == 12'h018;           // REG_TIM0_CH3_TH
        req.PWRITE == 1;
        req.PWDATA == {13'h0, comp_op, threshold[15:0]};
    });

    // High register - CH3
    `uvm_do_with(req, {
        req.PADDR  == 12'h210;           // REG_TIM0_CH3_TH_HI
        req.PWRITE == 1;
        req.PWDATA == threshold[31:16];
    });

    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0004; req.delay==8;}) // Update
    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001; req.delay==run_cycles;}) // Start
  endtask

  task body();
    `uvm_info(get_type_name(), "=== CH3 COMPARATOR FULL TOGGLE COVERAGE - FINAL ===", UVM_LOW)

    // Global Reset
    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay==50;})

    // Timer Configuration (Sawtooth mode)
    `uvm_do_with(req, {req.PADDR==12'h004; req.PWRITE==1; req.PWDATA==32'h0000_1000;}) // saw=1, presc=0

    // === VERY LARGE PERIOD (required for timer_count_i[31:16]) ===
    `uvm_do_with(req, {req.PADDR==12'h008; req.PWRITE==1; req.PWDATA==32'hFFFF_0000;})
    `uvm_do_with(req, {req.PADDR==12'h200; req.PWRITE==1; req.PWDATA==32'h0000_FFFF;}) // period = 32'hFFFF_FFFF

    // Configure other channels with minimal settings
    `uvm_do_with(req, {req.PADDR==12'h00C; req.PWRITE==1; req.PWDATA==32'h0000_0010;}) // CH0
    `uvm_do_with(req, {req.PADDR==12'h010; req.PWRITE==1; req.PWDATA==32'h0000_0010;}) // CH1
    `uvm_do_with(req, {req.PADDR==12'h014; req.PWRITE==1; req.PWDATA==32'h0000_0010;}) // CH2

    // Event Config + Clock Enable
    `uvm_do_with(req, {req.PADDR==12'h100; req.PWRITE==1; req.PWDATA==32'h000F_0000;})
    `uvm_do_with(req, {req.PADDR==12'h104; req.PWRITE==1; req.PWDATA==32'h0000_0001;})

    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0004; req.delay==10;}) // Update

    // ==================== Coverage Phases ====================

    `uvm_info(get_type_name(), "Phase 1: Upper Counter Bits + 32-bit Thresholds (CH3)", UVM_LOW)
    reconfigure_ch3_32bit(32'h0001_0000, 3'b011, 20000);
    reconfigure_ch3_32bit(32'h8000_0000, 3'b011, 80000);   // Force upper 16-bit counter toggle
    reconfigure_ch3_32bit(32'hFFFF_FFFF, 3'b011, 5000);

    `uvm_info(get_type_name(), "Phase 2: All Ops with Direction Change on op[2] (CH3)", UVM_LOW)
    reconfigure_ch3_32bit(32'h0001_0000, 3'b000, 300);   // 000
    reconfigure_ch3_32bit(32'h0001_0000, 3'b100, 400);   // 100 → op[2] 0→1
    reconfigure_ch3_32bit(32'h0001_0000, 3'b011, 400);   // 011 → op[2] 1→0
    reconfigure_ch3_32bit(32'h0001_0000, 3'b101, 400);   // 101
    reconfigure_ch3_32bit(32'h0001_0000, 3'b110, 400);   // 110
    reconfigure_ch3_32bit(32'h0001_0000, 3'b001, 500);   // TOGRST
    reconfigure_ch3_32bit(32'h0001_0000, 3'b010, 500);   // SETRST

    `uvm_info(get_type_name(), "Phase 3: Force r_active High + Reset Paths (CH3)", UVM_LOW)
    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001; req.delay==1000;})

    // Reset command while running
    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay==50;})
    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001; req.delay==500;})

    `uvm_info(get_type_name(), "=== CH3 COMPARATOR FULL TOGGLE COVERAGE FINISHED ===", UVM_LOW);
  endtask

endclass


/// channel 3 timer 0 comparator toggle 
// class comp_ch3_toggle_coverage_timer0_seq extends apb_base_seq;

//   `uvm_object_utils(comp_ch3_toggle_coverage_timer0_seq)

//   function new(string name = "comp_ch3_toggle_coverage_timer0_seq");
//     super.new(name);
//   endfunction

//   // Helper task: Reconfigure CH3 comparator and run for given cycles
//   task reconfigure_and_run(bit [15:0] threshold, bit [2:0] comp_op, int cycles);
//     `uvm_info(get_type_name(), 
//         $sformatf("→ CH3: TH=0x%04h, COMP_OP=0b%03b, cycles=%0d", threshold, comp_op, cycles), 
//         UVM_LOW)

//     // Stop Timer
//     `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0002; req.delay==5;})

//     // Reconfigure CH3 Comparator
//     `uvm_do_with(req, {
//         req.PADDR  == 12'h018;
//         req.PWRITE == 1;
//         req.PWDATA == {13'h0, comp_op, threshold};
//     })

//     // Update + Start
//     `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0004; req.delay==5;})
//     `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001; req.delay==cycles;})
//   endtask

//   task body();

//     `uvm_info(get_type_name(), "=== COMP CH3 TOGGLE COVERAGE TEST - Timer0 START ===", UVM_LOW)

//     // ==================== Initial Setup ====================
//     // Reset Timer0
//     `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay==60;})

//     // Configure Timer CFG: SAWTOOTH=1, PRESC=0, CLKSEL=0, MODE=0
//     `uvm_do_with(req, {req.PADDR==12'h004; req.PWRITE==1; req.PWDATA==32'h0000_1000;})

//     // Update
//     `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0004; req.delay==5;})

//     // Set large period so all thresholds are reachable
//     `uvm_do_with(req, {req.PADDR==12'h008; req.PWRITE==1; req.PWDATA==32'hFFFF_0000;})

//     // Configure other channels (fixed)
//     `uvm_do_with(req, {req.PADDR==12'h00C; req.PWRITE==1; req.PWDATA==32'h0003_0010;}) // Ch0
//     `uvm_do_with(req, {req.PADDR==12'h010; req.PWRITE==1; req.PWDATA==32'h0003_0010;}) // Ch1
//     `uvm_do_with(req, {req.PADDR==12'h014; req.PWRITE==1; req.PWDATA==32'h0003_0010;}) // Ch2

//     // Event Generation + Clock Enable
//     `uvm_do_with(req, {req.PADDR==12'h100; req.PWRITE==1; req.PWDATA==32'h000F_0000;})
//     `uvm_do_with(req, {req.PADDR==12'h104; req.PWRITE==1; req.PWDATA==32'h0000_0001;})

//     // ==================== Toggle Coverage Phases ====================

//     `uvm_info(get_type_name(), "Phase 1-14: Individual Bit Toggle Coverage on CH3", UVM_LOW)
//     reconfigure_and_run(16'h0001, 3'b011, 200);   // bit[0]
//     reconfigure_and_run(16'h0002, 3'b011, 200);   // bit[1]
//     reconfigure_and_run(16'h0004, 3'b011, 200);   // bit[2]
//     reconfigure_and_run(16'h0008, 3'b011, 200);   // bit[3]
//     reconfigure_and_run(16'h0010, 3'b011, 200);   // bit[4]
//     reconfigure_and_run(16'h0020, 3'b011, 300);   // bit[5]
//     reconfigure_and_run(16'h0040, 3'b011, 300);   // bit[6]
//     reconfigure_and_run(16'h0080, 3'b011, 500);   // bit[7]
//     reconfigure_and_run(16'h0100, 3'b011, 1000);  // bit[8]
//     reconfigure_and_run(16'h0200, 3'b011, 2000);  // bit[9]
//     reconfigure_and_run(16'h0400, 3'b011, 2000);  // bit[10]
//     reconfigure_and_run(16'h0800, 3'b011, 4000);  // bit[11]
//     reconfigure_and_run(16'h1000, 3'b011, 8000);  // bit[12]
//     reconfigure_and_run(16'h2000, 3'b011, 16000); // bit[13]
//     reconfigure_and_run(16'h4000, 3'b011, 32000); // bit[14]
//     reconfigure_and_run(16'h8000, 3'b011, 65000); // bit[15] MSB

//     `uvm_info(get_type_name(), "Phase 15: Corner Cases", UVM_LOW)
//     reconfigure_and_run(16'hFFFF, 3'b011, 200);   // All bits high
//     reconfigure_and_run(16'h0000, 3'b011, 100);   // Threshold = 0
//     reconfigure_and_run(16'hAAAA, 3'b011, 200);   // Alternating bits
//     reconfigure_and_run(16'h5555, 3'b011, 200);   // Inverse alternating

//     `uvm_info(get_type_name(), "Phase 16: All COMP_OP Modes Coverage on CH3", UVM_LOW)
//     reconfigure_and_run(16'h0010, 3'b000, 200);   // OP_SET
//     reconfigure_and_run(16'h0010, 3'b001, 200);   // OP_TOGRST
//     reconfigure_and_run(16'h0010, 3'b010, 200);   // OP_SETRST
//     reconfigure_and_run(16'h0010, 3'b011, 200);   // OP_TOG
//     reconfigure_and_run(16'h0010, 3'b100, 200);   // OP_RST
//     reconfigure_and_run(16'h0010, 3'b101, 200);   // OP_TOGSET
//     reconfigure_and_run(16'h0010, 3'b110, 200);   // OP_RSTSET

//     `uvm_info(get_type_name(), "Phase 17: Reset Mid-Run Coverage", UVM_LOW)
//     `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001; req.delay==100;})
//     `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay==30;}) // RESET
//     `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001; req.delay==200;})

//     `uvm_info(get_type_name(), "=== COMP CH3 TOGGLE COVERAGE TEST - Timer0 COMPLETED ===", UVM_LOW);

//   endtask
// endclass


//////////////// timer_0 input stage sequences //////////////////////////////////

class input_stage_mode_0_always_timer0_seq extends apb_base_seq;

  `uvm_object_utils(input_stage_mode_0_always_timer0_seq)

  function new(string name = "input_stage_mode_0_always_timer0_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(), "=== MODE=0 (ALWAYS ENABLED) TEST START ===", UVM_LOW)

    //--------------------------------------------
    // 1. Reset Timer0
    //--------------------------------------------
    
    `uvm_do_with(req,{req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay == 20; req.ext_sig_i == 32'h0000_0000;})

    `uvm_do_with(req,{
      req.PADDR  == 12'h004;
      req.PWRITE == 1;
      req.PWDATA == 32'h0000_1020; // SAW=1, CLKSEL=0, INSEL=31, MODE=000
    })

      `uvm_do_with(req,{
        req.PADDR  == 12'h004;
        req.PWRITE == 0;
        req.delay == 20;
    })

    `uvm_do_with(req,{
      req.PADDR  == 12'h008;
      req.PWRITE == 1;
      req.PWDATA == 32'h0030_0000;
    })
      `uvm_do_with(req,{
        req.PADDR  == 12'h008;
        req.PWRITE == 0;
        req.delay == 20;
    })

   `uvm_do_with(req,{ req.PADDR==12'h00C; req.PWRITE==1; req.PWDATA==32'h0004_0000; }) // ch_0_o[0] = 0
      `uvm_do_with(req,{
        req.PADDR  == 12'h00C;
        req.PWRITE == 0;
        req.delay == 20;
    })
   `uvm_do_with(req,{ req.PADDR==12'h010; req.PWRITE==1; req.PWDATA==32'h0003_0020; }) // ch_0_o[1] = Toggle (Active)
      `uvm_do_with(req,{
        req.PADDR  == 12'h010;
        req.PWRITE == 0;
        req.delay == 20;
    })
   `uvm_do_with(req,{ req.PADDR==12'h014; req.PWRITE==1; req.PWDATA==32'h0004_0000; }) // ch_0_o[2] = 0
      `uvm_do_with(req,{
        req.PADDR  == 12'h014;
        req.PWRITE == 0;
        req.delay == 20;
    })

   `uvm_do_with(req,{ req.PADDR==12'h018; req.PWRITE==1; req.PWDATA==32'h0004_0000; }) // ch_0_o[3] = 0
      `uvm_do_with(req,{
        req.PADDR  == 12'h018;
        req.PWRITE == 0;
        req.delay == 20;
    })

    `uvm_do_with(req,{
      req.PADDR  == 12'h100;
      req.PWRITE == 1;
      req.PWDATA == 32'h0002_0010;
    })
      `uvm_do_with(req,{
        req.PADDR  == 12'h100;
        req.PWRITE == 0;
        req.delay == 20;
    })

    `uvm_do_with(req,{req.PADDR==12'h104; req.PWRITE==1; req.PWDATA==32'h0000_0001;})
      `uvm_do_with(req,{
        req.PADDR  == 12'h104;
        req.PWRITE == 0;
        req.delay == 20;
    })

      `uvm_do_with(req,{
    req.PADDR  == 12'h000;
    req.PWRITE == 1;
    req.PWDATA == 32'h0000_0004;   // UPDATE
    req.delay  == 20;
})

  `uvm_do_with(req,{
        req.PADDR  == 12'h000;
        req.PWRITE == 0;
        req.delay == 20;
    })
    

    `uvm_do_with(req,{req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h1;})

      `uvm_do_with(req,{
        req.PADDR  == 12'h000;
        req.PWRITE == 0;
        req.delay == 20;
    })

    repeat(40) begin
      `uvm_do_with(req,{req.ext_sig_i == 32'h0000_0000; req.delay==1; req.PSEL == 0;})
      `uvm_do_with(req,{req.ext_sig_i == 32'h8000_0000; req.delay==1; req.PSEL == 0;})
    end

    `uvm_info(get_type_name(), "=== TEST COMPLETED ===", UVM_LOW)

  endtask
endclass

///////////////////////////////////////////////////////////////

class input_stage_mode_1_invert_timer0_seq extends apb_base_seq;

  `uvm_object_utils(input_stage_mode_1_invert_timer0_seq)

  function new(string name = "input_stage_mode_1_invert_timer0_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(), "=== MODE=1 (INVERTED LEVEL - Count when Input=0) TEST START ===", UVM_LOW)

    //--------------------------------------------
    // 1. Reset Timer0
    //--------------------------------------------
    `uvm_do_with(req,{req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay == 20; req.ext_sig_i == 32'h0000_0000;})
      `uvm_do_with(req,{
        req.PADDR  == 12'h000;
        req.PWRITE == 0;
        req.delay == 20;
    })

    //--------------------------------------------
    // 2. Configure CFG Register for MODE=1
    //--------------------------------------------
    `uvm_do_with(req,{
      req.PADDR  == 12'h004;
      req.PWRITE == 1;
      req.PWDATA == 32'h0000_0105;   // SAW=1, INSEL=4 (example), MODE=001 (Inverted Level)
    })

      `uvm_do_with(req,{
        req.PADDR  == 12'h004;
        req.PWRITE == 0;
        req.delay == 20;
    })

    //--------------------------------------------
    // 3. Set Period Register
    //--------------------------------------------
    `uvm_do_with(req,{
      req.PADDR  == 12'h008;
      req.PWRITE == 1;
      req.PWDATA == 32'h0005_0000;
    })

      `uvm_do_with(req,{
        req.PADDR  == 12'h008;
        req.PWRITE == 0;
        req.delay == 20;
    })

    //--------------------------------------------
    // 4. Configure Channels (basic)
    //--------------------------------------------
    `uvm_do_with(req,{ req.PADDR==12'h00C; req.PWRITE==1; req.PWDATA==32'h0004_0000; }) 
      `uvm_do_with(req,{
        req.PADDR  == 12'h00C;
        req.PWRITE == 0;
        req.delay == 20;
    })
    `uvm_do_with(req,{ req.PADDR==12'h010; req.PWRITE==1; req.PWDATA==32'h0003_0005; }) 
      `uvm_do_with(req,{
        req.PADDR  == 12'h010;
        req.PWRITE == 0;
        req.delay == 20;
    })
    `uvm_do_with(req,{ req.PADDR==12'h014; req.PWRITE==1; req.PWDATA==32'h0004_0000; }) 
      `uvm_do_with(req,{
        req.PADDR  == 12'h014;
        req.PWRITE == 0;
        req.delay == 20;
    })
    `uvm_do_with(req,{ req.PADDR==12'h018; req.PWRITE==1; req.PWDATA==32'h0004_0000; }) 
      `uvm_do_with(req,{
        req.PADDR  == 12'h018;
        req.PWRITE == 0;
        req.delay == 20;
    })

    //--------------------------------------------
    // 5. Event Configuration
    //--------------------------------------------
    `uvm_do_with(req,{
      req.PADDR  == 12'h100;
      req.PWRITE == 1;
      req.PWDATA == 32'h0002_0010;
    })

      `uvm_do_with(req,{
        req.PADDR  == 12'h100;
        req.PWRITE == 0;
        req.delay == 20;
    })

    //--------------------------------------------
    // 6. Enable Clock
    //--------------------------------------------
    `uvm_do_with(req,{req.PADDR==12'h104; req.PWRITE==1; req.PWDATA==32'h0000_0001;})
      `uvm_do_with(req,{
        req.PADDR  == 12'h104;
        req.PWRITE == 0;
        req.delay == 20;
    })

    `uvm_do_with(req,{
    req.PADDR  == 12'h000;
    req.PWRITE == 1;
    req.PWDATA == 32'h0000_0004;   // UPDATE
    req.delay  == 20;
})

  `uvm_do_with(req,{
        req.PADDR  == 12'h000;
        req.PWRITE == 0;
        req.delay == 20;
    })

    //--------------------------------------------
    // 7. Start Timer
    //--------------------------------------------
    `uvm_do_with(req,{req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001; req.delay==10;})

      `uvm_do_with(req,{
        req.PADDR  == 12'h000;
        req.PWRITE == 0;
        req.delay == 20;
    })

    //============================================================
    // 8. Drive Input Signal for MODE=1 Testing
    //============================================================

    `uvm_info(get_type_name(), "Driving Input LOW  → Timer SHOULD COUNT", UVM_LOW)

     repeat(10) begin
      `uvm_do_with(req,{req.ext_sig_i == 32'h0000_0000; req.delay==50; req.PSEL == 0;})
      `uvm_do_with(req,{req.ext_sig_i == 32'h0000_0020; req.delay==50; req.PSEL == 0;})
      `uvm_do_with(req,{req.ext_sig_i == 32'h0000_0000; req.delay==50; req.PSEL == 0;})
    end

    `uvm_info(get_type_name(), "=== MODE=1 (INVERTED LEVEL) TEST COMPLETED ===", UVM_LOW)

  endtask


endclass  

////////////////////////////////////////////////////////////////

class input_stage_mode_2_passthrough_timer0_seq extends apb_base_seq;

  `uvm_object_utils(input_stage_mode_2_passthrough_timer0_seq)

  virtual apb_interface   vif;
  // virtual timer_interface tim_vif;

  function new(string name = "input_stage_mode_2_passthrough_timer0_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(), "=== MODE=2 (DIRECT LEVEL - Count when Input=1) TEST START ===", UVM_LOW)

    //--------------------------------------------
    // 1. Reset Timer0
    //--------------------------------------------
    `uvm_do_with(req,{req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay == 20; req.ext_sig_i == 32'h0000_0000;})
      `uvm_do_with(req,{
        req.PADDR  == 12'h000;
        req.PWRITE == 0;
        req.delay == 20;
    })

    //--------------------------------------------
    // 2. Configure CFG Register for MODE=2
    //--------------------------------------------
    `uvm_do_with(req,{
      req.PADDR  == 12'h004;
      req.PWRITE == 1;
      req.PWDATA == 32'h0000_0206;   // SAW=1, INSEL=5, MODE=010 (Direct Level)
    })

      `uvm_do_with(req,{
        req.PADDR  == 12'h004;
        req.PWRITE == 0;
        req.delay == 20;
    })

    //--------------------------------------------
    // 3. Set Period Register
    //--------------------------------------------
    `uvm_do_with(req,{
      req.PADDR  == 12'h008;
      req.PWRITE == 1;
      req.PWDATA == 32'h0005_0000;
    })

      `uvm_do_with(req,{
        req.PADDR  == 12'h008;
        req.PWRITE == 0;
        req.delay == 20;
    })

    //--------------------------------------------
    // 4. Configure Channels (basic)
    //--------------------------------------------
    `uvm_do_with(req,{ req.PADDR==12'h00C; req.PWRITE==1; req.PWDATA==32'h0004_0000; }) 
      `uvm_do_with(req,{
        req.PADDR  == 12'h00C;
        req.PWRITE == 0;
        req.delay == 20;
    })
    `uvm_do_with(req,{ req.PADDR==12'h010; req.PWRITE==1; req.PWDATA==32'h0003_0005; }) 
    `uvm_do_with(req,{ req.PADDR==12'h014; req.PWRITE==1; req.PWDATA==32'h0004_0000; }) 
    `uvm_do_with(req,{ req.PADDR==12'h018; req.PWRITE==1; req.PWDATA==32'h0004_0000; }) 

    //--------------------------------------------
    // 5. Event Configuration
    //--------------------------------------------
    `uvm_do_with(req,{
      req.PADDR  == 12'h100;
      req.PWRITE == 1;
      req.PWDATA == 32'h0002_0010;
    })

    //--------------------------------------------
    // 6. Enable Clock
    //--------------------------------------------
    `uvm_do_with(req,{req.PADDR==12'h104; req.PWRITE==1; req.PWDATA==32'h0000_0001;})

    `uvm_do_with(req,{
    req.PADDR  == 12'h000;
    req.PWRITE == 1;
    req.PWDATA == 32'h0000_0004;   // UPDATE
    req.delay  == 20;
})

    //--------------------------------------------
    // 7. Start Timer
    //--------------------------------------------
    `uvm_do_with(req,{req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001; req.delay==10;})

    //============================================================
    // 8. Drive Input Signal for MODE=2 Testing
    //============================================================

    `uvm_info(get_type_name(), "Driving Input HIGH → Timer SHOULD COUNT", UVM_LOW)
    repeat(10) begin
      `uvm_do_with(req,{req.ext_sig_i == 32'h0000_0040; req.delay==50; req.PSEL == 0;})  // bit5 = 1
      `uvm_do_with(req,{req.ext_sig_i == 32'h0000_0000; req.delay==50; req.PSEL == 0;})  // bit5 = 0
      //`uvm_do_with(req,{req.ext_sig_i == 32'h0000_0040; req.delay==50; req.PSEL == 0;})
    end

    `uvm_info(get_type_name(), "=== MODE=2 (DIRECT LEVEL) TEST COMPLETED ===", UVM_LOW)

  endtask

endclass

///////////////////////////////////////////////////////////////////////

class input_stage_mode_3_rising_edge_timer0_seq extends apb_base_seq;

  `uvm_object_utils(input_stage_mode_3_rising_edge_timer0_seq)

  function new(string name = "input_stage_mode_3_rising_edge_timer0_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(), "=== MODE=3 (RISING EDGE) TEST START ===", UVM_LOW)

    //--------------------------------------------
    // 1. Reset Timer0
    //--------------------------------------------
    `uvm_do_with(req,{req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay == 20; req.ext_sig_i == 32'h0000_0000;})

    //--------------------------------------------
    // 2. Configure CFG Register for MODE=3
    //--------------------------------------------
    `uvm_do_with(req,{
      req.PADDR  == 12'h004;
      req.PWRITE == 1;
      req.PWDATA == 32'h0000_0307;   // SAW=1, INSEL=5, MODE=011 (Rising Edge)
    })

    //--------------------------------------------
    // 3. Set Period Register
    //--------------------------------------------
    `uvm_do_with(req,{
      req.PADDR  == 12'h008;
      req.PWRITE == 1;
      req.PWDATA == 32'h0010_0000;
    })

    //--------------------------------------------
    // 4. Configure Channels (basic)
    //--------------------------------------------
    `uvm_do_with(req,{ req.PADDR==12'h00C; req.PWRITE==1; req.PWDATA==32'h0004_0000; }) 
    `uvm_do_with(req,{ req.PADDR==12'h010; req.PWRITE==1; req.PWDATA==32'h0003_0005; }) 
    `uvm_do_with(req,{ req.PADDR==12'h014; req.PWRITE==1; req.PWDATA==32'h0004_0000; }) 
    `uvm_do_with(req,{ req.PADDR==12'h018; req.PWRITE==1; req.PWDATA==32'h0004_0000; }) 

    //--------------------------------------------
    // 5. Event Configuration
    //--------------------------------------------
    `uvm_do_with(req,{
      req.PADDR  == 12'h100;
      req.PWRITE == 1;
      req.PWDATA == 32'h0002_0010;
    })

    //--------------------------------------------
    // 6. Enable Clock
    //--------------------------------------------
    `uvm_do_with(req,{req.PADDR==12'h104; req.PWRITE==1; req.PWDATA==32'h0000_0001;})

    `uvm_do_with(req,{
    req.PADDR  == 12'h000;
    req.PWRITE == 1;
    req.PWDATA == 32'h0000_0004;   // UPDATE
    req.delay  == 20;
})

    //--------------------------------------------
    // 7. Start Timer
    //--------------------------------------------
    `uvm_do_with(req,{req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001; req.delay==10;})

    //============================================================
    // 8. Drive Rising Edges for MODE=3 Testing
    //============================================================

    `uvm_info(get_type_name(), "Generating Rising Edges on ext_sig_i[7] → events_o[1] should pulse", UVM_LOW)

    repeat(90) begin
      `uvm_do_with(req,{req.ext_sig_i == 32'h0000_0000; req.delay==20; req.PSEL == 0;})  // Stable Low
      `uvm_do_with(req,{req.ext_sig_i == 32'h0000_0080; req.delay==10; req.PSEL == 0;})  // Rising Edge
      //`uvm_do_with(req,{req.ext_sig_i == 32'h0000_0000; req.delay==30; req.PSEL == 0;})  // Stable Low again
    end

    `uvm_info(get_type_name(), "=== MODE=3 (RISING EDGE) TEST COMPLETED ===", UVM_LOW)

  endtask

endclass

////////////////////////////////////////////////////////////////////////////////

class input_stage_mode_4_falling_edge_timer0_seq extends apb_base_seq;

  `uvm_object_utils(input_stage_mode_4_falling_edge_timer0_seq)

  function new(string name = "input_stage_mode_4_falling_edge_timer0_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(), "=== MODE=4 (FALLING EDGE) TEST START ===", UVM_LOW)

    //--------------------------------------------
    // 1. Reset Timer0
    //--------------------------------------------
    `uvm_do_with(req,{req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay == 20; req.ext_sig_i == 32'h0000_0000;})

    //--------------------------------------------
    // 2. Configure CFG Register for MODE=4
    //--------------------------------------------
    `uvm_do_with(req,{
      req.PADDR  == 12'h004;
      req.PWRITE == 1;
      req.PWDATA == 32'h0000_1408;   // SAW=1, INSEL=5, MODE=100 (Falling Edge)
    })

    //--------------------------------------------
    // 3. Set Period Register
    //--------------------------------------------
    `uvm_do_with(req,{
      req.PADDR  == 12'h008;
      req.PWRITE == 1;
      req.PWDATA == 32'h0010_0000;
    })

    //--------------------------------------------
    // 4. Configure Channels (basic)
    //--------------------------------------------
    `uvm_do_with(req,{ req.PADDR==12'h00C; req.PWRITE==1; req.PWDATA==32'h0004_0000; }) 
    `uvm_do_with(req,{ req.PADDR==12'h010; req.PWRITE==1; req.PWDATA==32'h0003_0005; }) 
    `uvm_do_with(req,{ req.PADDR==12'h014; req.PWRITE==1; req.PWDATA==32'h0004_0000; }) 
    `uvm_do_with(req,{ req.PADDR==12'h018; req.PWRITE==1; req.PWDATA==32'h0004_0000; }) 

    //--------------------------------------------
    // 5. Event Configuration
    //--------------------------------------------
    `uvm_do_with(req,{
      req.PADDR  == 12'h100;
      req.PWRITE == 1;
      req.PWDATA == 32'h0002_0010;
    })

    //--------------------------------------------
    // 6. Enable Clock
    //--------------------------------------------
    `uvm_do_with(req,{req.PADDR==12'h104; req.PWRITE==1; req.PWDATA==32'h0000_0001;})

    `uvm_do_with(req,{
    req.PADDR  == 12'h000;
    req.PWRITE == 1;
    req.PWDATA == 32'h0000_0004;   // UPDATE
    req.delay  == 20;
})

    //--------------------------------------------
    // 7. Start Timer
    //--------------------------------------------
    `uvm_do_with(req,{req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001; req.delay==10;})

    //============================================================
    // 8. Drive Falling Edges for MODE=4 Testing
    //============================================================

    `uvm_info(get_type_name(), "Generating Falling Edges on ext_sig_i[5] → events_o[1] should pulse", UVM_LOW)

    repeat(90) begin
      `uvm_do_with(req,{req.ext_sig_i == 32'h0000_0100; req.delay==20; req.PSEL == 0;})  // Stable High
      `uvm_do_with(req,{req.ext_sig_i == 32'h0000_0000; req.delay==10; req.PSEL == 0;})  // Falling Edge
      // Stable Low (optional)
    end

    `uvm_info(get_type_name(), "=== MODE=4 (FALLING EDGE) TEST COMPLETED ===", UVM_LOW)

  endtask


endclass

////////////////////////////////////////////

class input_stage_mode_5_both_edges_timer0_seq extends apb_base_seq;

  `uvm_object_utils(input_stage_mode_5_both_edges_timer0_seq)

  function new(string name = "input_stage_mode_5_both_edges_timer0_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(), "=== MODE=5 (BOTH EDGES - Rising and Falling) TEST START ===", UVM_LOW)

    //--------------------------------------------
    // 1. Reset Timer0
    //--------------------------------------------
    `uvm_do_with(req,{req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay == 20; req.ext_sig_i == 32'h0000_0000;})

    //--------------------------------------------
    // 2. Configure CFG Register for MODE=5
    //--------------------------------------------
    `uvm_do_with(req,{
      req.PADDR  == 12'h004;
      req.PWRITE == 1;
      req.PWDATA == 32'h0000_1509;   // SAW=1, INSEL=5, MODE=101 (Both Edges)
    })

    //--------------------------------------------
    // 3. Set Period Register
    //--------------------------------------------
    `uvm_do_with(req,{
      req.PADDR  == 12'h008;
      req.PWRITE == 1;
      req.PWDATA == 32'h0010_0000;
    })

    //--------------------------------------------
    // 4. Configure Channels (basic)
    //--------------------------------------------
    `uvm_do_with(req,{ req.PADDR==12'h00C; req.PWRITE==1; req.PWDATA==32'h0004_0000; }) 
    `uvm_do_with(req,{ req.PADDR==12'h010; req.PWRITE==1; req.PWDATA==32'h0003_0005; }) 
    `uvm_do_with(req,{ req.PADDR==12'h014; req.PWRITE==1; req.PWDATA==32'h0004_0000; }) 
    `uvm_do_with(req,{ req.PADDR==12'h018; req.PWRITE==1; req.PWDATA==32'h0004_0000; }) 

    //--------------------------------------------
    // 5. Event Configuration
    //--------------------------------------------
    `uvm_do_with(req,{
      req.PADDR  == 12'h100;
      req.PWRITE == 1;
      req.PWDATA == 32'h0002_0010;
    })

    //--------------------------------------------
    // 6. Enable Clock
    //--------------------------------------------
    `uvm_do_with(req,{req.PADDR==12'h104; req.PWRITE==1; req.PWDATA==32'h0000_0001;})

    `uvm_do_with(req,{
    req.PADDR  == 12'h000;
    req.PWRITE == 1;
    req.PWDATA == 32'h0000_0004;   // UPDATE
    req.delay  == 20;
})

    //--------------------------------------------
    // 7. Start Timer
    //--------------------------------------------
    `uvm_do_with(req,{req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001; req.delay==10;})

    //============================================================
    // 8. Drive Both Rising and Falling Edges for MODE=5 Testing
    //============================================================

    `uvm_info(get_type_name(), "Generating Both Rising & Falling Edges on ext_sig_i[5] → events_o[1] should pulse on every edge", UVM_LOW)

    repeat(80) begin
      `uvm_do_with(req,{req.ext_sig_i == 32'h0000_0000; req.delay==15; req.PSEL == 0;})  // Stable Low
      `uvm_do_with(req,{req.ext_sig_i == 32'h0000_0200; req.delay==10; req.PSEL == 0;})  // Rising Edge
      //`uvm_do_with(req,{req.ext_sig_i == 32'h0000_0200; req.delay==15; req.PSEL == 0;})  // Stable High
      //`uvm_do_with(req,{req.ext_sig_i == 32'h0000_0000; req.delay==10; req.PSEL == 0;})  // Falling Edge
    end

    `uvm_info(get_type_name(), "=== MODE=5 (BOTH EDGES) TEST COMPLETED ===", UVM_LOW)

  endtask

endclass

class input_stage_mode_6_rising_armed_timer0_seq extends apb_base_seq;

  `uvm_object_utils(input_stage_mode_6_rising_armed_timer0_seq)

  function new(string name = "input_stage_mode_6_rising_armed_timer0_seq");
    super.new(name);
  endfunction

task body();

    `uvm_info(get_type_name(), "=== MODE=6 (ARMED RISING EDGE) TEST START ===", UVM_LOW)

    // 1. Reset Timer0
    `uvm_do_with(req,{req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay == 20; req.ext_sig_i == 32'h0000_0000;})

    // 2. Configure CFG Register for MODE=6
    `uvm_do_with(req,{
      req.PADDR  == 12'h004;
      req.PWRITE == 1;
      req.PWDATA == 32'h0000_0605;   // SAW=1, INSEL=5, MODE=110 (Armed Rising)
    })

    // 3. Set Period Register
    `uvm_do_with(req,{
      req.PADDR  == 12'h008;
      req.PWRITE == 1;
      req.PWDATA == 32'h0010_0000;
    })

    // 4. Basic Channel Configuration
    `uvm_do_with(req,{ req.PADDR==12'h00C; req.PWRITE==1; req.PWDATA==32'h0004_0000; }) 
    `uvm_do_with(req,{ req.PADDR==12'h010; req.PWRITE==1; req.PWDATA==32'h0003_0005; }) 
    `uvm_do_with(req,{ req.PADDR==12'h014; req.PWRITE==1; req.PWDATA==32'h0004_0000; }) 
    `uvm_do_with(req,{ req.PADDR==12'h018; req.PWRITE==1; req.PWDATA==32'h0004_0000; }) 

    // 5. Event Configuration
    `uvm_do_with(req,{
      req.PADDR  == 12'h100;
      req.PWRITE == 1;
      req.PWDATA == 32'h0002_0010;
    })

    // 6. Enable Clock
    `uvm_do_with(req,{req.PADDR==12'h104; req.PWRITE==1; req.PWDATA==32'h0000_0001;})

    `uvm_do_with(req,{
    req.PADDR  == 12'h000;
    req.PWRITE == 1;
    req.PWDATA == 32'h0000_0004;   // UPDATE
    req.delay  == 20;
})

    // 7. Start Timer (without ARM yet)
    `uvm_do_with(req,{req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001; req.delay==20;}) // ARM + START

    `uvm_do_with(req,{req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_00015;req.delay == 20; })

    // 8. Set ARM bit

    `uvm_info(get_type_name(), "ARM=1 + Generating Rising Edges → Should trigger", UVM_LOW)

    repeat(20) begin
      `uvm_do_with(req,{req.ext_sig_i == 32'h0000_0000; req.delay==25; req.PSEL == 0;})
      `uvm_do_with(req,{req.ext_sig_i == 32'h0000_0020; req.delay==10; req.PSEL == 0;})  // Rising Edge
      `uvm_do_with(req,{req.ext_sig_i == 32'h0000_0000; req.delay==30; req.PSEL == 0;})
    end

    `uvm_info(get_type_name(), "=== MODE=6 (ARMED RISING EDGE) TEST COMPLETED ===", UVM_LOW)

  endtask

endclass

///////////////////////////////////////////////////////////////////////////////////////////////////////

class input_stage_mode_7_falling_armed_timer0_seq extends apb_base_seq;

  `uvm_object_utils(input_stage_mode_7_falling_armed_timer0_seq)

  function new(string name = "input_stage_mode_7_falling_armed_timer0_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(), "=== MODE=7 (ARMED FALLING EDGE) TEST START ===", UVM_LOW)

    // 1. Reset Timer0
    `uvm_do_with(req,{req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay == 20; req.ext_sig_i == 32'h0000_0000;})

    // 2. Configure CFG Register for MODE=7
    `uvm_do_with(req,{
      req.PADDR  == 12'h004;
      req.PWRITE == 1;
      req.PWDATA == 32'h0000_0707;   // SAW=1, INSEL=5, MODE=111 (Armed Falling)
    })

    // 3. Set Period Register
    `uvm_do_with(req,{
      req.PADDR  == 12'h008;
      req.PWRITE == 1;
      req.PWDATA == 32'h0010_0000;
    })

    // 4. Basic Channel Configuration
    `uvm_do_with(req,{ req.PADDR==12'h00C; req.PWRITE==1; req.PWDATA==32'h0004_0000; }) 
    `uvm_do_with(req,{ req.PADDR==12'h010; req.PWRITE==1; req.PWDATA==32'h0003_0005; }) 
    `uvm_do_with(req,{ req.PADDR==12'h014; req.PWRITE==1; req.PWDATA==32'h0004_0000; }) 
    `uvm_do_with(req,{ req.PADDR==12'h018; req.PWRITE==1; req.PWDATA==32'h0004_0000; }) 

    // 5. Event Configuration
    `uvm_do_with(req,{
      req.PADDR  == 12'h100;
      req.PWRITE == 1;
      req.PWDATA == 32'h0002_0010;
    })

    // 6. Enable Clock
    `uvm_do_with(req,{req.PADDR==12'h104; req.PWRITE==1; req.PWDATA==32'h0000_0001;})

    `uvm_do_with(req,{
    req.PADDR  == 12'h000;
    req.PWRITE == 1;
    req.PWDATA == 32'h0000_0004;   // UPDATE
    req.delay  == 20;
})

    // 7. Start Timer
    `uvm_do_with(req,{req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001; req.delay==10;})

    // 8. Set ARM bit
    `uvm_do_with(req,{req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0011;}) // ARM + START
    //repeat(20) @(posedge vif.HCLK);

    `uvm_info(get_type_name(), "ARM=1 + Generating Falling Edges → Should trigger", UVM_LOW)

    repeat(60) begin
      `uvm_do_with(req,{req.ext_sig_i == 32'h0000_0080; req.delay==20; req.PSEL == 0;})  // Stable High
      `uvm_do_with(req,{req.ext_sig_i == 32'h0000_0000; req.delay==10; req.PSEL == 0;})  // Falling Edge
      `uvm_do_with(req,{req.ext_sig_i == 32'h0000_0080; req.delay==25; req.PSEL == 0;})
    end

    `uvm_info(get_type_name(), "=== MODE=7 (ARMED FALLING EDGE) TEST COMPLETED ===", UVM_LOW)

  endtask

endclass

//////////////////////////////////////////

class event_generation_timer0_ch0_seq extends apb_base_seq;

  `uvm_object_utils(event_generation_timer0_ch0_seq)

  function new(string name = "event_generation_timer0_ch0_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(), "=== EVENT GENERATION TEST (Timer0 Ch0 → events_o[0]) START ===", UVM_LOW)

    // 1. Reset Timer0

    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay==10;})
    //repeat(20) @(posedge vif.HCLK);

    // 2. Configure Timer0: Sawtooth + OP_TOG (good for clean rising edges)
    `uvm_do_with(req,{ req.PADDR==12'h004; req.PWRITE==1; req.PWDATA==32'h0000_1000;}) // SAWTOOTH=1, PRESC=0, MODE=0
    `uvm_do_with(req,{ req.PADDR==12'h008; req.PWRITE==1; req.PWDATA==32'h0030_0000;}) // Period = 0x20 (32 cycles)
    `uvm_do_with(req,{ req.PADDR==12'h00C; req.PWRITE==1; req.PWDATA==32'h0003_0010;}) // COMP_OP=011 (TOG), TH=0x10
    `uvm_do_with(req,{ req.PADDR==12'h010; req.PWRITE==1; req.PWDATA==32'h0003_0012;})
    `uvm_do_with(req,{ req.PADDR==12'h014; req.PWRITE==1; req.PWDATA==32'h0003_0014;})
    `uvm_do_with(req,{ req.PADDR==12'h018; req.PWRITE==1; req.PWDATA==32'h0003_0016;})
     // 4. Configure Event Generation - MOST IMPORTANT
    `uvm_do_with(req,{
        req.PADDR  == 12'h100;           
        req.PWRITE == 1;
        req.PWDATA == 32'h000F_0000;     // event_en[0] = 1, select ch_o[0] as source
    })


    // 3. Enable Timer0 clock and start
    `uvm_do_with(req,{ req.PADDR==12'h104; req.PWRITE==1; req.PWDATA==32'h0000_0001;}) // Clock/CH_EN
    `uvm_do_with(req,{ req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001; req.delay==200;}) // START=1  and after 4 cycle counter is starting.


    `uvm_info(get_type_name(), "=== EVENT GENERATION TEST COMPLETED ===", UVM_LOW);
  endtask
endclass

////////////////////////////////////////////////////////////////////////


class update_sig_timer0_seq extends apb_base_seq;

  `uvm_object_utils(update_sig_timer0_seq)

  function new(string name = "update_sig_timer0_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(), "=== UPDATE SIGNAL FUNCTIONALITY TEST START ===", UVM_LOW)

    // 1. Reset Timer0
    `uvm_do_with(req,{req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay == 20;})

    // 2. Configure CFG, Period and Channels (without UPDATE)
    `uvm_do_with(req,{
      req.PADDR  == 12'h004;
      req.PWRITE == 1;
      req.PWDATA == 32'h0000_1505;   // SAW=1, INSEL=5, MODE=101 (example)
    })

    `uvm_do_with(req,{
      req.PADDR  == 12'h008;
      req.PWRITE == 1;
      req.PWDATA == 32'h0020_0000;
    })

    `uvm_do_with(req,{ req.PADDR==12'h00C; req.PWRITE==1; req.PWDATA==32'h0003_0010; }) // CH0

    // 3. Enable Clock
    `uvm_do_with(req,{req.PADDR==12'h104; req.PWRITE==1; req.PWDATA==32'h0000_0001;})

    // 4. Start Timer WITHOUT UPDATE
    `uvm_do_with(req,{req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0001; req.delay==30;})

    `uvm_info(get_type_name(), "Timer started WITHOUT UPDATE - No effect expected", UVM_LOW)
    `uvm_do_with(req,{req.delay==50;})
   
    // 5. Now Apply UPDATE → This is the key step
    `uvm_do_with(req,{req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0005; req.delay==20;}) 
    // UPDATE (bit2) + START (bit0)

    `uvm_info(get_type_name(), "UPDATE Applied → Configurations should now take effect", UVM_LOW)
    `uvm_do_with(req,{req.delay==50;})

    // 6. Change configuration again and apply UPDATE
    `uvm_do_with(req,{
      req.PADDR  == 12'h00C;
      req.PWRITE == 1;
      req.PWDATA == 32'h0050_0000;   // Change threshold
    })

    `uvm_do_with(req,{req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0005; req.delay==20;}) // UPDATE again

    repeat(60) begin
      //`uvm_do_with(req,{req.ext_sig_i == 32'h0000_0080; req.delay==20; req.PSEL == 0;})  // Stable High
      `uvm_do_with(req,{req.ext_sig_i == 32'h0000_0000; req.delay==10; req.PSEL == 0;})  // Falling Edge
      `uvm_do_with(req,{req.ext_sig_i == 32'h0000_0020; req.delay==25; req.PSEL == 0;})
    end

    `uvm_info(get_type_name(), "Second UPDATE Applied with new threshold", UVM_LOW)
    `uvm_do_with(req,{req.delay==50;})

    `uvm_info(get_type_name(), "=== UPDATE SIGNAL FUNCTIONALITY TEST COMPLETED ===", UVM_LOW)

  endtask
endclass

////////////////////////////////////////////////////////////////////

class pwm_comp_op_default_illegal_timer0_ch0_seq extends apb_base_seq;

  `uvm_object_utils(pwm_comp_op_default_illegal_timer0_ch0_seq)

  function new(string name = "pwm_comp_op_default_illegal_timer0_ch0_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(), "=== PWM COMP_OP=111 (DEFAULT/ILLEGAL) COVERAGE TEST START ===", UVM_LOW)

    // 1. Reset Timer0
    // PWDATA = 0x8 → RESET bit[3] = 1
    `uvm_do_with(req,{req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay == 40;})
    // repeat(60) @(posedge vif.HCLK);

    `uvm_do_with(req,{
      req.PADDR  == 12'h004;
      req.PWRITE == 1;
      req.PWDATA == 32'h0000_1000;
    })


    `uvm_do_with(req,{
      req.PADDR  == 12'h008;
      req.PWRITE == 1;
      req.PWDATA == 32'h0020_0000;
    })

    `uvm_do_with(req,{
      req.PADDR  == 12'h00C;
      req.PWRITE == 1;
      req.PWDATA == 32'h0007_0010;
    })

    // 5. REG_TIM0_CH1_TH → COMP_OP=3'b111, THRESHOLD=0x0010
    `uvm_do_with(req,{
      req.PADDR  == 12'h010;
      req.PWRITE == 1;
      req.PWDATA == 32'h0007_0010;
    })

    // 6. REG_TIM0_CH2_TH → COMP_OP=3'b111, THRESHOLD=0x0010
    `uvm_do_with(req,{
      req.PADDR  == 12'h014;
      req.PWRITE == 1;
      req.PWDATA == 32'h0007_0010;
    })

    // 7. REG_TIM0_CH3_TH → COMP_OP=3'b111, THRESHOLD=0x0010
    `uvm_do_with(req,{
      req.PADDR  == 12'h018;
      req.PWRITE == 1;
      req.PWDATA == 32'h0007_0010;
    })

    `uvm_info(get_type_name(), "All 4 channels configured with COMP_OP=111 (default/illegal)", UVM_LOW)

    // 8. REG_EVENT_CFG
    `uvm_do_with(req,{
      req.PADDR  == 12'h100;
      req.PWRITE == 1;
      req.PWDATA == 32'h000F_3210;
    })

    // 9. REG_CH_EN → Enable Timer0 clock only
    `uvm_do_with(req,{
      req.PADDR  == 12'h104;
      req.PWRITE == 1;
      req.PWDATA == 32'h0000_0001;
    })

    `uvm_do_with(req,{
      req.PADDR  == 12'h000;
      req.PWRITE == 1;
      req.PWDATA == 32'h0000_0001;
    })

   `uvm_do_with(req,{req.delay == 600; req.PSEL == 0;}) 

    `uvm_info(get_type_name(), "=== PWM COMP_OP=111 (DEFAULT/ILLEGAL) COVERAGE TEST COMPLETED ===", UVM_LOW)

  endtask
endclass

/////////////////////////////////////////////////////////////

class apb_timer0_clockgate_seq extends apb_base_seq;

    `uvm_object_utils(apb_timer0_clockgate_seq)

    function new(string name = "apb_timer0_clockgate_seq");
        super.new(name);
    endfunction

    task body();

       `uvm_info(get_type_name(), "=== CLOCK GATE TEST_EN_I TOGGLE COVERAGE SEQUENCE START ===", UVM_LOW);


       `uvm_do_with(req,{req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay == 40;})

        // Enable Timer0 (so clock gate is active)
        `uvm_do_with(req, {req.PADDR==12'h104; req.PWRITE==1; req.PWDATA==32'h0000_0001; req.delay == 30; })

        `uvm_do_with(req, {req.PADDR==12'h008; req.PWRITE==1; req.PWDATA==32'h0040_0000; req.delay == 20;}) // Period

    `uvm_do_with(req, {req.PADDR==12'h00C; req.PWRITE==1; req.PWDATA==32'h0000_0010; req.delay == 20;}) // CH0: OP_SET, TH=0x0010
    `uvm_do_with(req, {req.PADDR==12'h010; req.PWRITE==1; req.PWDATA==32'h0001_0010; req.delay == 20;}) // CH1
    `uvm_do_with(req, {req.PADDR==12'h014; req.PWRITE==1; req.PWDATA==32'h0001_0010; req.delay == 20;}) // CH2
    `uvm_do_with(req, {req.PADDR==12'h018; req.PWRITE==1; req.PWDATA==32'h0001_0010; req.delay == 20;}) // CH3

    `uvm_do_with(req, {req.PADDR==12'h100; req.PWRITE==1; req.PWDATA==32'h000F_3210; req.delay == 20;}) // Event Config

        `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0005; req.delay == 40;})

        // ==================== TOGGLE test_en_i ====================
        repeat(7) begin
            // tim_vif.dft_cg_enable_i <= 1'b0;   // test_en_i = 0
          `uvm_do_with(req,{req.dft_cg_enable_i == 1'b0; req.delay==40; req.PSEL == 0;})
          `uvm_do_with(req,{req.dft_cg_enable_i == 1'b1; req.delay==20; req.PSEL == 0;})
        end

         `uvm_do_with(req,{req.dft_cg_enable_i == 1'b0; req.delay==50; req.PSEL == 0;})
          `uvm_do_with(req, {req.PADDR==12'h104; req.PWRITE==1; req.PWDATA==32'h0000_0000; req.delay == 30;})

         //`uvm_do_with(req,{req.dft_cg_enable_i == 1'b1; req.delay==100; req.PSEL == 0;})

        `uvm_info(get_type_name(), "=== CLOCK GATE TEST_EN_I TOGGLE COVERAGE SEQUENCE COMPLETED ===", UVM_LOW);

        // Stop Timer0
        `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0002;})

       // `uvm_do_with(req, {req.PADDR==12'h104; req.PWRITE==1; req.PWDATA==32'h0000_0000; req.delay == 30;})

        // #5000;

    endtask
endclass

//////////////////////////////////////////

class apb_timer0_full_register_access_seq extends apb_base_seq;

  `uvm_object_utils(apb_timer0_full_register_access_seq)

  //virtual apb_interface   vif;
  bit [31:0] rd_data;

  function new(string name = "apb_timer0_full_register_access_seq");
    super.new(name);
  endfunction

  task body();

    
    `uvm_info(get_type_name(), "=== FULL REGISTER ACCESS TEST (LUT + COUNTER + GLOBAL) START ===", UVM_LOW)
    //--------------------------------------------
    // 1. Reset Timer0
    //--------------------------------------------
    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0008; req.delay == 20;})
    // repeat(50) @(posedge vif.HCLK);

    //--------------------------------------------
    // 2. Enable Timer0 Clock
    //--------------------------------------------
    `uvm_do_with(req, {req.PADDR==12'h104; req.PWRITE==1; req.PWDATA==32'h0000_0001;})
    // repeat(20) @(posedge vif.HCLK)

    //--------------------------------------------
    // 3. GLOBAL REGISTERS
    //--------------------------------------------
    `uvm_do_with(req, {req.PADDR==12'h100; req.PWRITE==1; req.PWDATA==32'h000F_3210;}) // EVENT_CFG
    `uvm_do_with(req, {req.PADDR==12'h100; req.PWRITE==0;}) rd_data = req.PRDATA;

    `uvm_do_with(req, {req.PADDR==12'h104; req.PWRITE==1; req.PWDATA==32'h0000_0001;}) // CH_EN
    `uvm_do_with(req, {req.PADDR==12'h104; req.PWRITE==0;}) rd_data = req.PRDATA;

    //--------------------------------------------
    // 4. TIMER0 REGISTERS
    //--------------------------------------------
    // CMD Register
    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_001F;})
    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==0;}) rd_data = req.PRDATA;

    // CFG Register
    `uvm_do_with(req, {req.PADDR==12'h004; req.PWRITE==1; req.PWDATA==32'h0001_13FF;})
    `uvm_do_with(req, {req.PADDR==12'h004; req.PWRITE==0;}) rd_data = req.PRDATA;

    // TH Register
    `uvm_do_with(req, {req.PADDR==12'h008; req.PWRITE==1; req.PWDATA==32'hABCD_EF01;})
    `uvm_do_with(req, {req.PADDR==12'h008; req.PWRITE==0;}) rd_data = req.PRDATA;

    //--------------------------------------------
    // 5. LUT REGISTERS
    //--------------------------------------------
    `uvm_do_with(req, {req.PADDR==12'h01C; req.PWRITE==1; req.PWDATA==32'h0000_FFFF;}) // CH0_LUT
    `uvm_do_with(req, {req.PADDR==12'h020; req.PWRITE==1; req.PWDATA==32'h0000_AAAA;}) // CH1_LUT
    `uvm_do_with(req, {req.PADDR==12'h024; req.PWRITE==1; req.PWDATA==32'h0000_5555;}) // CH2_LUT
    `uvm_do_with(req, {req.PADDR==12'h028; req.PWRITE==1; req.PWDATA==32'h0000_1234;}) // CH3_LUT

    // Read back LUT registers
    `uvm_do_with(req, {req.PADDR==12'h01C; req.PWRITE==0;}) rd_data = req.PRDATA;
    `uvm_do_with(req, {req.PADDR==12'h020; req.PWRITE==0;}) rd_data = req.PRDATA;
    `uvm_do_with(req, {req.PADDR==12'h024; req.PWRITE==0;}) rd_data = req.PRDATA;
    `uvm_do_with(req, {req.PADDR==12'h028; req.PWRITE==0;}) rd_data = req.PRDATA;

    //--------------------------------------------
    // 6. CHANNEL REGISTERS
    //--------------------------------------------
    `uvm_do_with(req, {req.PADDR==12'h00C; req.PWRITE==1; req.PWDATA==32'h0003_1234;}) // CH0
    `uvm_do_with(req, {req.PADDR==12'h010; req.PWRITE==1; req.PWDATA==32'h0005_5678;}) // CH1
    `uvm_do_with(req, {req.PADDR==12'h014; req.PWRITE==1; req.PWDATA==32'h0002_9ABC;}) // CH2
    `uvm_do_with(req, {req.PADDR==12'h018; req.PWRITE==1; req.PWDATA==32'h0006_DEF0;}) // CH3

    //--------------------------------------------
    // 7. COUNTER (Read Only)
    //--------------------------------------------
    `uvm_do_with(req, {req.PADDR==12'h02C; req.PWRITE==0;}) rd_data = req.PRDATA;
    `uvm_info(get_type_name(), $sformatf("COUNTER after config = 0x%08h", rd_data), UVM_MEDIUM)

    // Start Timer to run counter
    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0005; req.delay == 200;}) // UPDATE + START
    // repeat(300) @(posedge vif.HCLK);

    `uvm_do_with(req, {req.PADDR==12'h02C; req.PWRITE==0;}) rd_data = req.PRDATA;
    `uvm_info(get_type_name(), $sformatf("COUNTER after running = 0x%08h", rd_data), UVM_MEDIUM)

    // Final Stop
    `uvm_do_with(req, {req.PADDR==12'h000; req.PWRITE==1; req.PWDATA==32'h0000_0002;})

    `uvm_info(get_type_name(), "=== FULL REGISTER ACCESS TEST (LUT + COUNTER + GLOBAL) COMPLETED ===", UVM_LOW)

  endtask
endclass

////////////////////////////////////////////////////////
class apb_prescaler_test_seq extends apb_base_seq;

  `uvm_object_utils(apb_prescaler_test_seq)

  function new(string name="apb_prescaler_test_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(), "=== PRESCALER TEST (PRESC=3) - Timer0 START ===", UVM_LOW)

    // 1. Reset Timer0
    `uvm_do_with(req, {
        req.PADDR  == 12'h000;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0008;
        req.delay  == 30;
    })

    // 2. Configure REG_TIMx_CFG:
    //    - PRESC[23:16] = 3  → divide by 4
    //    - SAWTOOTH = 1
    //    - CLKSEL = 0 (HCLK)
    //    - MODE = 0 (continuous)
    `uvm_do_with(req, {
        req.PADDR  == 12'h004;
        req.PWRITE == 1;
        req.PWDATA == 32'h0003_1000;     // PRESC=3, SAWTOOTH=1
    })

    // 3. Set Counter Limits (reasonable period for observation)
    `uvm_do_with(req, {
        req.PADDR  == 12'h008;
        req.PWRITE == 1;
        req.PWDATA == 32'h0080_0000;     // COUNT_START=0, COUNT_END=0x80
    })

    // 4. Configure Channel 0 (Toggle mode) - easy to observe in waveform
    `uvm_do_with(req, {
        req.PADDR  == 12'h00C;
        req.PWRITE == 1;
        req.PWDATA == 32'h0003_0040;     // COMP_OP=011 (TOG), TH=0x40
    })

    // 5. Event Generation (optional but useful)
    `uvm_do_with(req, {
        req.PADDR  == 12'h100;
        req.PWRITE == 1;
        req.PWDATA == 32'h000F_0000;     // Enable events for ch_o[0]
    })

    // 6. Enable Timer0 Clock
    `uvm_do_with(req, {
        req.PADDR  == 12'h104;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0001;
    })

    // 7. Start Timer0
    `uvm_do_with(req, {
        req.PADDR  == 12'h000;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0001;
        req.delay  == 800;               // Enough time to observe prescaling effect
    })

    `uvm_info(get_type_name(), "=== PRESCALER TEST (PRESC=3) COMPLETED ===", UVM_LOW);

  endtask
endclass

class timer0_full_flow_seq extends apb_base_seq;

  `uvm_object_utils(timer0_full_flow_seq)

  function new(string name = "timer0_full_flow_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(), "=== TIMER0 FULL FLOW TEST (All Blocks: InputStage → Prescaler → Counter → Comparators) START ===", UVM_LOW)

    // 1. Reset Timer0
    `uvm_do_with(req, {
        req.PADDR  == 12'h000;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0008;   // RESET
        req.delay  == 30;
    })

    // 2. Configure REG_TIM0_CFG (Input Stage + Prescaler + Clock + Mode + Sawtooth)
    //    PRESC=3 (divide by 4), SAWTOOTH=1, CLKSEL=0 (HCLK), MODE=0 (continuous), INSEL=0 (default input)
    `uvm_do_with(req, {
        req.PADDR  == 12'h004;
        req.PWRITE == 1;
        req.PWDATA == 32'h0003_1000;     // PRESC=3, SAWTOOTH=1, others default
    })

    // 3. Configure Counter Limits (Up-Down Counter)
    `uvm_do_with(req, {
        req.PADDR  == 12'h008;
        req.PWRITE == 1;
        req.PWDATA == 32'h0080_0000;     // COUNT_START=0x0000, COUNT_END=0x0080
    })

    // 4. Configure All 4 Comparators with different COMP_OP for better coverage
    `uvm_do_with(req, {req.PADDR==12'h00C; req.PWRITE==1; req.PWDATA==32'h0000_0020;}) // Ch0: OP_SET (000), TH=0x20
    `uvm_do_with(req, {req.PADDR==12'h010; req.PWRITE==1; req.PWDATA==32'h0003_0040;}) // Ch1: OP_TOG (011), TH=0x40
    `uvm_do_with(req, {req.PADDR==12'h014; req.PWRITE==1; req.PWDATA==32'h0004_0060;}) // Ch2: OP_RST (100), TH=0x60
    `uvm_do_with(req, {req.PADDR==12'h018; req.PWRITE==1; req.PWDATA==32'h0002_0070;}) // Ch3: OP_SETRST(010), TH=0x70

    // 5. Event Generation Configuration (optional but useful)
    `uvm_do_with(req, {
        req.PADDR  == 12'h100;
        req.PWRITE == 1;
        req.PWDATA == 32'h000F_0000;     // Enable events for all ch_o[3:0]
    })

    // 6. Enable Timer0 Clock Gate
    `uvm_do_with(req, {
        req.PADDR  == 12'h104;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0001;
    })

    // 7. Start Timer0
    `uvm_do_with(req, {
        req.PADDR  == 12'h000;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0001;
        req.delay  == 1200;              // Enough time to see multiple periods
    })

    `uvm_info(get_type_name(), "=== TIMER0 FULL FLOW TEST COMPLETED ===", UVM_LOW);

  endtask
endclass

class input_stage_full_coverage_seq extends apb_base_seq;

  `uvm_object_utils(input_stage_full_coverage_seq)

  function new(string name = "input_stage_full_coverage_seq");
    super.new(name);
  endfunction

  task body();
    int m, s, inclk, ch;

    `uvm_info(get_type_name(),
              "=== INPUT_STAGE FULL TOGGLE COVERAGE SEQUENCE START ===", UVM_LOW)

    // ------------------------------------------------------------------
    // 1. Reset + Clock Enable
    // ------------------------------------------------------------------
    `uvm_do_with(req, {
        req.PADDR  == 12'h000;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0008;   // RESET
        req.delay  == 30;
    })

    `uvm_do_with(req, {
        req.PADDR  == 12'h104;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0001;   // REG_CH_EN[0] = 1
    })

    // ------------------------------------------------------------------
    // 2. Basic period + channel thresholds
    //    (so ch_o toggles → feedback path in_sel = 32..35 is live)
    // ------------------------------------------------------------------
    `uvm_do_with(req, {
        req.PADDR  == 12'h008;
        req.PWRITE == 1;
        req.PWDATA == 32'h00FF_0000;   // end=0x00FF, start=0x0000
    })

    for (ch = 0; ch < 4; ch++) begin
      `uvm_do_with(req, {
          req.PADDR  == 12'h00C + (ch*4);
          req.PWRITE == 1;
          req.PWDATA == 32'h0000_0080; // mid-range, mode SET
      })
    end

    // ------------------------------------------------------------------
    // 3. Full matrix: mode × in_sel × in_clk
    //    Covers cfg_mode_i / r_mode, cfg_sel_i / r_sel, cfg_sel_clk_i
    // ------------------------------------------------------------------
    for (m = 0; m < 8; m++) begin
      for (s = 0; s < 36; s++) begin          // 0..31 ext + 32..35 ch_o
        for (inclk = 0; inclk < 2; inclk++) begin

          // STOP
          `uvm_do_with(req, {
              req.PADDR  == 12'h000;
              req.PWRITE == 1;
              req.PWDATA == 32'h0000_0002;
              req.delay  == 5;
          })

          // CFG: presc=0, saw=0, in_clk, mode, in_sel
          `uvm_do_with(req, {
              req.PADDR  == 12'h004;
              req.PWRITE == 1;
              req.PWDATA == {8'h00, 8'h00, 3'h0, 1'b0, inclk[0], m[2:0], s[7:0]};
              req.delay  == 3;
          })

          // UPDATE (loads r_mode / r_sel)
          `uvm_do_with(req, {
              req.PADDR  == 12'h000;
              req.PWRITE == 1;
              req.PWDATA == 32'h0000_0004;
              req.delay  == 5;
          })

          // START
          `uvm_do_with(req, {
              req.PADDR  == 12'h000;
              req.PWRITE == 1;
              req.PWDATA == 32'h0000_0001;
              req.delay  == 10;
          })

          // Armed modes need ARM + long run for cnt_end clear
          if (m == 6 || m == 7) begin
            `uvm_do_with(req, {
                req.PADDR  == 12'h000;
                req.PWRITE == 1;
                req.PWDATA == 32'h0000_0010;   // ARM
                req.delay  == 10;
            })
            // Env must produce the required edge on the selected source
            // while armed. Long delay also lets cnt_end_i fire.
            #600;
          end else begin
            // Env must toggle the selected source (ext_sig_i[s] or ch_o)
            // and pulse ls_clk_i when inclk==1
            #350;
          end

          if (inclk) #250;   // extra time for ls_clk edges

          // STOP
          `uvm_do_with(req, {
              req.PADDR  == 12'h000;
              req.PWRITE == 1;
              req.PWDATA == 32'h0000_0002;
              req.delay  == 5;
          })
        end
      end
    end

    // ------------------------------------------------------------------
    // 4. Dedicated window for every ext_sig_i bit to toggle
    //    (closes holes on signal_i[4:1] and signal_i[30:10])
    // ------------------------------------------------------------------
    `uvm_do_with(req, {
        req.PADDR  == 12'h000;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0002;
        req.delay  == 5;
    })

    `uvm_do_with(req, {
        req.PADDR  == 12'h004;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0200;   // mode=direct(010), in_sel=0, in_clk=0
        req.delay  == 3;
    })

    `uvm_do_with(req, {
        req.PADDR  == 12'h000;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0004;
        req.delay  == 5;
    })

    `uvm_do_with(req, {
        req.PADDR  == 12'h000;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0001;
        req.delay  == 10;
    })

    // Long window – concurrent env process must walk every bit of
    // ext_sig_i (and a few multi-bit patterns) during this time
    #2500;

    `uvm_do_with(req, {
        req.PADDR  == 12'h000;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0002;
        req.delay  == 5;
    })

    // ------------------------------------------------------------------
    // 5. Final armed + long run (extra safety for r_armed / r_event)
    // ------------------------------------------------------------------
    `uvm_do_with(req, {
        req.PADDR  == 12'h000;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0002;
        req.delay  == 5;
    })

    `uvm_do_with(req, {
        req.PADDR  == 12'h004;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0605;   // mode=armed-rising(110), in_sel=5
        req.delay  == 3;
    })

    `uvm_do_with(req, {
        req.PADDR  == 12'h000;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0004;
        req.delay  == 5;
    })

    `uvm_do_with(req, {
        req.PADDR  == 12'h000;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0001;
        req.delay  == 10;
    })

    `uvm_do_with(req, {
        req.PADDR  == 12'h000;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0010;   // ARM
        req.delay  == 10;
    })

    // Env toggles ext_sig_i[5]; long delay lets cnt_end clear armed state
    #800;

    `uvm_do_with(req, {
        req.PADDR  == 12'h000;
        req.PWRITE == 1;
        req.PWDATA == 32'h0000_0002;
        req.delay  == 5;
    })

    `uvm_info(get_type_name(),
              "=== INPUT_STAGE FULL TOGGLE COVERAGE SEQUENCE COMPLETED ===", UVM_LOW)
    `uvm_info(get_type_name(),
              "NOTE: Concurrent env must drive ext_sig_i[31:0] and ls_clk_i", UVM_LOW)

  endtask

endclass