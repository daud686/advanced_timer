/*-------------------------------------------------------------------------
File name   : top_env.sv
Project     : SPI VIP
---------------------------------------------------------------------------*/
//import timer_pkg::timer_env; 
//import clk_pkg::clk_env; 

class top_env extends uvm_env;

top_config cfg;

//timer_env tim_e;
apb_env apb;
//spi_env spi;
//clk_env clk;
//scoreboard scb;
//coverage_collector cov;

`uvm_component_utils(top_env)

function new(string name, uvm_component parent);
    super.new(name,parent);
endfunction

extern virtual function void build_phase(uvm_phase phase);
extern virtual function void connect_phase(uvm_phase phase);

endclass:top_env

function void top_env::build_phase(uvm_phase phase);

    if(!uvm_config_db #(top_config)::get(null,"uvm_test_top","cfg",cfg))begin
        `uvm_fatal("ENV","No config object is set for this instance")
    end
    

    //tim_e = timer_env::type_id::create("tim_e",this);
    apb = apb_env::type_id::create("apb",this);
    //spi = spi_env::type_id::create("spi",this); 
    //clk = clk_env::type_id::create("clk",this); 

    //scb = scoreboard::type_id::create("scb",this);

endfunction

function void top_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
   // apb.agents[0].drv.item_derived_port.connect(scb.apb_drv_export);
    //apb.agents[0].mon.item_collected_port.connect(scb.apb_mon_export);
   // wb.agents[0].mon.item_collected_port.connect(scb.wb_mon_export);
    //wb.agents[0].drv.item_derived_port.connect(scb.wb_drv_export);
    //spi.agents[0].mon.item_collected_port.connect(scb.spi_mon_export);
    //spi.agents[0].drv.item_derived_port.connect(scb.spi_drv_export);

endfunction
