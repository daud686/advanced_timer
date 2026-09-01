/*-------------------------------------------------------------------------
File name   : pt_seq_lib.sv
Project     : SPI UVC
---------------------------------------------------------------------------*/

    // Add more classes of sequences below
class slave_seq extends uvm_sequence#(timer_transaction);

    `uvm_object_utils(slave_seq)

    function new(string name = "slave_seq");
        super.new(name);
    endfunction
    task body();  
        //`uvm_do_with(req,{ req.trans_data==32'h12345678; })
        // `uvm_do_with(req,{ req.trans_data==128'h12345678cafefeed12345678cafefeed; })
        `uvm_do_with(req,{})
    endtask

endclass:slave_seq

