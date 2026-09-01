

/*------------------------------------------------------------
  Per Timer Reset Test - Timer0
------------------------------------------------------------*/

import apb_pkg::clock_selection_low_speed_seq;

class clock_selection_low_speed_test extends uvm_test;

    `uvm_component_utils(clock_selection_low_speed_test)

    clock_selection_low_speed_seq reset_seq;
    top_config cfg;
    top_env env;
    virtual apb_interface vif;
    int i = 1;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        if (!uvm_config_db#(virtual apb_interface)::get(this, "", "vif", vif)) begin
            `uvm_fatal("TEST", "No virtual interface is set for this instance")
        end

        uvm_config_db#(virtual apb_interface)::set(null, "*", "vif", vif);

        reset_seq = clock_selection_low_speed_seq::type_id::create("reset_seq");
        env       = top_env::type_id::create("env", this);
        uvm_config_db#(top_config)::set(null, "uvm_test_top", "cfg", cfg);
    endfunction

    task run_phase(uvm_phase phase);
        repeat(1) begin
            `uvm_info(get_type_name(), $sformatf("Starting test no %d", i), UVM_NONE)
            phase.raise_objection(this);

            reset_seq.start(env.apb.agents[0].sqr);

            `uvm_info(get_type_name(), "Sequence finished", UVM_LOW)

            phase.drop_objection(this);
            i++;
        end
    endtask

endclass: clock_selection_low_speed_test