/*---------------------------------------------------------------------------/
File name   : apb_write_seq.sv
Project     : SPI VIP
/---------------------------------------------------------------------------*/
import apb_pkg::apb_timer0_clockgate_seq;

class apb_timer0_clockgate_test  extends uvm_test;
    
    `uvm_component_utils(apb_timer0_clockgate_test)
    apb_timer0_clockgate_seq  apb_seq;
    top_config cfg;
    top_env env;
    virtual apb_interface vif;
    // virtual timer_interface tim_vif;
    int i = 1;

	//virtual spi_interface spi_vif;
    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        if (!uvm_config_db#(virtual apb_interface)::get(this, "", "vif", vif)) begin
            `uvm_fatal("TEST", "No virtual interface is set for this instance")
        end

        //  if (!uvm_config_db#(virtual timer_interface)::get(this, "", "tim_vif", tim_vif)) begin
        //     `uvm_fatal("TEST", "No virtual interface is set for this instance")
        // end

        //uvm_config_db#(virtual apb_interface)::set(null, "*", "vif", vif);

        apb_seq = apb_timer0_clockgate_seq::type_id::create("apb_seq");
        env     = top_env::type_id::create("env", this);
        uvm_config_db#(top_config)::set(null, "uvm_test_top", "cfg", cfg);  
    endfunction

    task run_phase(uvm_phase phase);
        repeat(1) begin
            `uvm_info(get_type_name(), $sformatf("Starting test no %d", i), UVM_NONE)
            phase.raise_objection(this);

            apb_seq.start(env.apb.agents[0].sqr);   // ← this will now execute

            `uvm_info(get_type_name(), "Sequence finished", UVM_LOW)

            phase.drop_objection(this);
            i++;
        end
    endtask

endclass:apb_timer0_clockgate_test  

///////////////////////////////////////////////////////

