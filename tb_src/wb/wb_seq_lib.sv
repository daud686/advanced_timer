/*-------------------------------------------------------------------------
File name   : wb_seq_lib.sv
Project     : WB UVC
---------------------------------------------------------------------------*/

    // Add more classes of sequences below

class base_seq extends uvm_sequence#(apb_transaction);

   `uvm_object_utils(base_seq)
    static int pre_value=9;
    function new(string name = "base_seq");
        super.new(name);
    endfunction
    task body();        
    endtask

endclass:base_seq

class transfer_seq_8_msb extends base_seq;

    `uvm_object_utils(transfer_seq_8_msb)
    uvm_event ev2;

    function new(string name = "transfer_seq_8_msb");
        super.new(name);
    endfunction

    task body();
        `uvm_do_with(req,{ req.wb_addr == 32'h18; req.wb_data == 32'h01; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h14; req.wb_data == 32'h0; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h00; req.wb_data == 32'h5a; req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h10; req.wb_data[31:8] == 24'h2; req.wb_data[7]==1'b0; req.wb_data[6:0]==7'h08; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        pre_value = req.wb_data;        
    endtask
endclass:transfer_seq_8_msb

class transfer_seq_64_msb extends base_seq;

    `uvm_object_utils(transfer_seq_64_msb)
    uvm_event ev2;

    function new(string name = "transfer_seq_64_msb");
        super.new(name);
    endfunction

    task body();
        `uvm_do_with(req,{ req.wb_addr == 32'h18; req.wb_data == 32'h01; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h14; req.wb_data == 32'h0; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h00; req.wb_data == 32'ha5a5a5a5; req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h04; req.wb_data == 32'ha5a5a5a5; req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h10; req.wb_data[31:8] == 24'h2; req.wb_data[7]==1'b0; req.wb_data[6:0]==7'h40; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        pre_value = req.wb_data;      
    endtask

endclass:transfer_seq_64_msb

class transfer_seq_96_msb extends base_seq;

    `uvm_object_utils(transfer_seq_96_msb)
    uvm_event ev2;

    function new(string name = "transfer_seq_96_msb");
        super.new(name);
    endfunction

    task body();
        `uvm_do_with(req,{ req.wb_addr == 32'h18; req.wb_data == 32'h01; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h14; req.wb_data == 32'h0; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h00; req.wb_data == 32'h5a5a5a5a; req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h04; req.wb_data == 32'h5a5a5a5a; req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h08; req.wb_data == 32'h5a5a5a5a; req.wb_select == 4'h1111; req.wb_write == 1'b1;})          `uvm_do_with(req,{ req.wb_addr == 32'h10; req.wb_data[31:8] == 24'h2; req.wb_data[7]==1'b0; req.wb_data[6:0]==7'h60; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h10; req.wb_data[31:8] == 24'h2; req.wb_data[7]==1'b0; req.wb_data[6:0]==7'h60; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        pre_value = req.wb_data;       
    endtask

endclass:transfer_seq_96_msb

class transfer_seq_127_msb extends base_seq;

    `uvm_object_utils(transfer_seq_127_msb)
    uvm_event ev2;

    function new(string name = "transfer_seq_127_msb");
        super.new(name);
    endfunction
    task body();
        `uvm_do_with(req,{ req.wb_addr == 32'h18; req.wb_data == 32'h01; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h14; req.wb_data == 32'h0; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h00; req.wb_data == 32'h5a5a5a5a; req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h04; req.wb_data == 32'h5a5a5a5a; req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h08; req.wb_data == 32'h5a5a5a5a; req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h0c; req.wb_data == 32'h5a5a5a5a; req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h10; req.wb_data[31:8] == 24'h2; req.wb_data[7]==1'b0; req.wb_data[6:0]==7'h7f; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        pre_value = req.wb_data;
        endtask

endclass:transfer_seq_127_msb

class transfer_seq_128_msb extends base_seq;
    `uvm_object_utils(transfer_seq_128_msb)
    uvm_event ev2;
    function new(string name = "transfer_seq_128_msb");
        super.new(name);
    endfunction
    task body();
        `uvm_do_with(req,{ req.wb_addr == 32'h18; req.wb_data == 32'h01; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h14; req.wb_data == 32'h0; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h00; req.wb_data == 32'h5a5a5a5a; req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h04; req.wb_data == 32'h5a5a5a5a; req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h08; req.wb_data == 32'h5a5a5a5a; req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h0c; req.wb_data == 32'h5a5a5a5a; req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h10; req.wb_data[31:8] == 24'h2; req.wb_data[7]==1'b0; req.wb_data[6:0]==7'h00; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        pre_value = req.wb_data;       
    endtask
endclass:transfer_seq_128_msb

class transfer_seq_128_msb_negedge extends base_seq;
    `uvm_object_utils(transfer_seq_128_msb_negedge)
    uvm_event ev2;
    function new(string name = "transfer_seq_128_msb_negedge");
        super.new(name);
    endfunction
    task body();
        `uvm_do_with(req,{ req.wb_addr == 32'h18; req.wb_data == 32'h01; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h14; req.wb_data == 32'h0; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h00; req.wb_data == 32'h5a5a5a5a; req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h04; req.wb_data == 32'h5a5a5a5a; req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h08; req.wb_data == 32'h5a5a5a5a; req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h0c; req.wb_data == 32'h5a5a5a5a; req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h10; req.wb_data[31:8] == 24'h4; req.wb_data[7]==1'b0; req.wb_data[6:0]==7'h00; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        pre_value = req.wb_data;     
    endtask
endclass:transfer_seq_128_msb_negedge

class transfer_seq_32_lsb extends base_seq;

    `uvm_object_utils(transfer_seq_32_lsb)
    uvm_event ev2;

    function new(string name = "transfer_seq_32_lsb");
        super.new(name);
    endfunction

    task body();
        `uvm_do_with(req,{ req.wb_addr == 32'h18; req.wb_data == 32'h01; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h14; req.wb_data == 32'h0; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h00; req.wb_data == 32'ha5123456; req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h10; req.wb_data[31:8] == 24'ha; req.wb_data[7]==1'b0; req.wb_data[6:0]==7'h20; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        pre_value = req.wb_data;
        
    endtask

endclass:transfer_seq_32_lsb

class transfer_seq_128_lsb extends base_seq;

    `uvm_object_utils(transfer_seq_128_lsb)
    uvm_event ev2;

    function new(string name = "transfer_seq_128_lsb");
        super.new(name);
    endfunction

    task body();
        `uvm_do_with(req,{ req.wb_addr == 32'h18; req.wb_data == 32'h01; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h14; req.wb_data == 32'h0; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h00; req.wb_data == 32'ha5123456; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h04; req.wb_data == 32'ha5789abc; req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h08; req.wb_data == 32'ha5123456; req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h0c; req.wb_data == 32'ha5789abc; req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h10; req.wb_data[31:8] == 24'ha; req.wb_data[7]==1'b0; req.wb_data[6:0]==7'h00; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        pre_value = req.wb_data;
        
    endtask

endclass:transfer_seq_128_lsb

class transfer_seq_128_lsb_negedge extends base_seq;

    `uvm_object_utils(transfer_seq_128_lsb_negedge)
    uvm_event ev2;

    function new(string name = "transfer_seq_128_lsb_negedge");
        super.new(name);
    endfunction

    task body();
        `uvm_do_with(req,{ req.wb_addr == 32'h18; req.wb_data == 32'h01; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h14; req.wb_data == 32'h0; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h00; req.wb_data == 32'ha5123456; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h04; req.wb_data == 32'ha5789abc; req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h08; req.wb_data == 32'ha5123456; req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h0c; req.wb_data == 32'ha5789abc; req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h10; req.wb_data[31:8] == 24'hc; req.wb_data[7]==1'b0; req.wb_data[6:0]==7'h00; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        pre_value = req.wb_data;
        
    endtask

endclass:transfer_seq_128_lsb_negedge

class transfer_seq_127_lsb_negedge extends base_seq;

    `uvm_object_utils(transfer_seq_127_lsb_negedge)
    uvm_event ev2;

    function new(string name = "transfer_seq_127_lsb_negedge");
        super.new(name);
    endfunction

    task body();
        `uvm_do_with(req,{ req.wb_addr == 32'h18; req.wb_data == 32'h01; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h14; req.wb_data == 32'h0; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h00; req.wb_data == 32'ha5123456; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h04; req.wb_data == 32'ha5789abc; req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h08; req.wb_data == 32'ha5123456; req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h0c; req.wb_data == 32'ha5789abc; req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h10; req.wb_data[31:8] == 24'hc; req.wb_data[7]==1'b0; req.wb_data[6:0]==7'h7f; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        pre_value = req.wb_data;
        
    endtask

endclass:transfer_seq_127_lsb_negedge

class transfer_seq_64_lsb extends base_seq;

    `uvm_object_utils(transfer_seq_64_lsb)
    uvm_event ev2;

    function new(string name = "transfer_seq_64_lsb");
        super.new(name);
    endfunction

    task body();
        `uvm_do_with(req,{ req.wb_addr == 32'h18; req.wb_data == 32'h01; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h14; req.wb_data == 32'h0; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h00; req.wb_data == 32'ha5123456; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h04; req.wb_data == 32'ha5789abc; req.wb_select == 4'h1111; req.wb_write == 1'b1;})    
        `uvm_do_with(req,{ req.wb_addr == 32'h10; req.wb_data[31:8] == 24'ha; req.wb_data[7]==1'b0; req.wb_data[6:0]==7'h40; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        pre_value = req.wb_data;
        
    endtask

endclass:transfer_seq_64_lsb


class transfer_seq_random_msb_posedge extends base_seq;

    `uvm_object_utils(transfer_seq_random_msb_posedge)
    uvm_event ev2;

    function new(string name = "transfer_seq_random_msb_posedge");
        super.new(name);
    endfunction

    task body();
        `uvm_do_with(req,{ req.wb_addr == 32'h18; req.wb_data == 32'h01; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h14; req.wb_data == 32'h0; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h00; req.wb_data == 32'h5a; req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h10; req.wb_data[31:8] == 24'h2; req.wb_data[7]==1'b0; /*req.wb_data[6:0]==7'd0;*/ req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        pre_value = req.wb_data;
        
    endtask

endclass:transfer_seq_random_msb_posedge

// class transfer_seq_random_msb_pn extends base_seq;

//     `uvm_object_utils(transfer_seq_random_msb_pn)
//     uvm_event ev2;

//     function new(string name = "transfer_seq_random_msb_pn");
//         super.new(name);
//     endfunction

//     task body();

//         `uvm_do_with(req,{ req.wb_addr == 32'h18; req.wb_data == 32'h01; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
//         `uvm_do_with(req,{ req.wb_addr == 32'h14; req.wb_data == 32'h0; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
//         `uvm_do_with(req,{ req.wb_addr == 32'h00; req.wb_data == 32'h5a; req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
//         `uvm_do_with(req,{ req.wb_addr == 32'h10; req.wb_data[31:11] == 21'h0; req.wb_data[8:7]==1'b0; req.wb_data[10:9]!=2'b00; req.wb_data[10:9]!=2'b11; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
//         pre_value = req.wb_data;        
//     endtask

// endclass:transfer_seq_random_msb_pn

class transfer_seq_random_msb_negedge extends base_seq;

    `uvm_object_utils(transfer_seq_random_msb_negedge)
    uvm_event ev2;

    function new(string name = "transfer_seq_random_msb_negedge");
        super.new(name);
    endfunction

    task body();

        `uvm_do_with(req,{ req.wb_addr == 32'h18; req.wb_data == 32'h01; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h14; req.wb_data == 32'h0; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        //`uvm_do_with(req,{ req.wb_addr == 32'h00; req.wb_data == 32'h5a; req.wb_select == 4'h1111; req.wb_write == 1'b1;})  
        `uvm_do_with(req,{ req.wb_addr == 32'h00; req.wb_data == 32'h5a; req.wb_select == 4'h1111; req.wb_write == 1'b1;}) 
        `uvm_do_with(req,{ req.wb_addr == 32'h04; req.wb_data == 32'h5a; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h08; req.wb_data == 32'h5a; req.wb_select == 4'h1111; req.wb_write == 1'b1;}) 
        `uvm_do_with(req,{ req.wb_addr == 32'h10; req.wb_data[31:11] == 22'h0; req.wb_data[10:9] == 2'b10; req.wb_data[8:7]==2'b00; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        pre_value = req.wb_data;        
    endtask

endclass:transfer_seq_random_msb_negedge

class transfer_seq_random_lsb_posedge extends base_seq;

    `uvm_object_utils(transfer_seq_random_lsb_posedge)
    uvm_event ev2;

    function new(string name = "transfer_seq_random_lsb_posedge");
        super.new(name);
    endfunction

    task body();
     
         `uvm_info(get_type_name(),$sformatf(" LSB POSEDGE"),UVM_LOW)

        `uvm_do_with(req,{ req.wb_addr == 32'h18; req.wb_data == 32'h01; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h14; req.wb_data == 32'h0; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        //`uvm_do_with(req,{ req.wb_addr == 32'h00; req.wb_data == 32'h5a; req.wb_select == 4'h1111; req.wb_write == 1'b1;})  
        `uvm_do_with(req,{ req.wb_addr == 32'h00; req.wb_data == 32'h5a; req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h10; req.wb_data[31:12] == 21'd0; req.wb_data[6:0]!=7'h00;  req.wb_data[11] == 1'b1; req.wb_data[10:9] == 2'b01; req.wb_data[8:7]==2'b00; req.wb_select == 4'h1111; req.wb_write == 1'b1; })
       
        pre_value = req.wb_data;        
    endtask

endclass:transfer_seq_random_lsb_posedge

class transfer_seq_random_lsb_negedge extends base_seq;

    `uvm_object_utils(transfer_seq_random_lsb_negedge)
    uvm_event ev2;

    function new(string name = "transfer_seq_random_lsb_negedge");
        super.new(name);
    endfunction

    task body();
         `uvm_info(get_type_name(),$sformatf(" LSB POSEDGE"),UVM_LOW)

        `uvm_do_with(req,{ req.wb_addr == 32'h18; req.wb_data == 32'h01; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h14; req.wb_data == 32'h0; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h00; req.wb_data == 32'h5a; req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h10; req.wb_data[31:12] == 21'd0;  req.wb_data[11] == 1'b1; req.wb_data[10:9] == 2'b10; req.wb_data[8:7]==2'b00; req.wb_select == 4'h1111; req.wb_write == 1'b1; })
        pre_value = req.wb_data;
             
    endtask

endclass:transfer_seq_random_lsb_negedge

class transfer_seq_random_rnd_sb_negedge extends base_seq;

    `uvm_object_utils(transfer_seq_random_rnd_sb_negedge)
    uvm_event ev2;

    function new(string name = "transfer_seq_random_rnd_sb_negedge");
        super.new(name);
    endfunction

    task body();

        `uvm_do_with(req,{ req.wb_addr == 32'h18; req.wb_data == 32'h01; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h14; req.wb_data == 32'h0; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h00; req.wb_data == 32'h5a; req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h10; req.wb_data[31:12] == 21'd0; req.wb_data[6:0]!=7'h00; req.wb_data[10:9] == 2'b10; req.wb_data[8:7]==2'b00; req.wb_select == 4'h1111; req.wb_write == 1'b1; })
       
        pre_value = req.wb_data;
        
    endtask

endclass:transfer_seq_random_rnd_sb_negedge

class transfer_seq_random_rnd_sb_posedge extends base_seq;

    `uvm_object_utils(transfer_seq_random_rnd_sb_posedge)
    uvm_event ev2;

    function new(string name = "transfer_seq_random_rnd_sb_posedge");
        super.new(name);
    endfunction

    task body();


        `uvm_do_with(req,{ req.wb_addr == 32'h18; req.wb_data == 32'h01; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h14; req.wb_data == 32'h0; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h00; req.wb_data == 32'h5a; req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h10; req.wb_data[31:12] == 21'd0; req.wb_data[6:0]!=7'h00; req.wb_data[10:9] == 2'b01; req.wb_data[8:7]==2'b00; req.wb_select == 4'h1111; req.wb_write == 1'b1; })       
        pre_value = req.wb_data;

    endtask

endclass:transfer_seq_random_rnd_sb_posedge

class transfer_seq_random_rnd_sb_ran_edge extends base_seq;

    `uvm_object_utils(transfer_seq_random_rnd_sb_ran_edge)
    uvm_event ev2;

    function new(string name = "transfer_seq_random_rnd_sb_ran_edge");
        super.new(name);
    endfunction

    task body();


        `uvm_do_with(req,{ req.wb_addr == 32'h18; req.wb_data == 32'h01; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h14; req.wb_data == 32'h0; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h00; req.wb_data == 32'h5a; req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h10; req.wb_data[31:12] == 21'd0; req.wb_data[6:0]!=7'h00; req.wb_data[8:7]==2'b00; req.wb_select == 4'h1111; req.wb_write == 1'b1; })      
        pre_value = req.wb_data;

    endtask

endclass:transfer_seq_random_rnd_sb_ran_edge

class transfer_seq_random_all_interrupt extends base_seq;

    `uvm_object_utils(transfer_seq_random_all_interrupt)
    uvm_event ev2;

    function new(string name = "transfer_seq_random_all_interrupt");
        super.new(name);
    endfunction

    task body();


        `uvm_do_with(req,{ req.wb_addr == 32'h18; req.wb_data[31:8]== 24'h0; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h14; req.wb_data == 32'h0; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h00; req.wb_data == 32'h5a5a5a5a; req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h04; req.wb_data == 32'h5a5a5a5a; req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h08; req.wb_data == 32'h5a5a5a5a; req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h0c; req.wb_data == 32'h5a5a5a5a; req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h10; req.wb_data[31:14] == 20'd0;  req.wb_data[12] == 1'd1; req.wb_data[6:0]!=7'h00; req.wb_data[8:7]==2'b00; req.wb_data[10:9]!=2'b00; req.wb_data[10:9]!=2'b11; req.wb_select == 4'h1111; req.wb_write == 1'b1; })
       
        pre_value = req.wb_data;

    endtask

endclass:transfer_seq_random_all_interrupt

class fully_random_seq extends base_seq;

    `uvm_object_utils(fully_random_seq)
    uvm_event ev2;

    function new(string name = "fully_random_seq");
        super.new(name);
    endfunction

    task body();


        `uvm_do_with(req,{ req.wb_addr == 32'h18;  req.wb_data[31:8]== 24'h0;req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h14;  req.wb_data[31:3]== 29'h0;req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h00;  req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h04;  req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h08;  req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h0c;  req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h10; req.wb_data[31:14] == 20'd0; req.wb_data[6:0]!=7'h00; req.wb_data[8:7]==2'b00; req.wb_data[10:9]!=2'b00; req.wb_data[10:9]!=2'b11; req.wb_select == 4'h1111; req.wb_write == 1'b1; })
       
        pre_value = req.wb_data;

    endtask

endclass:fully_random_seq

class transfer_seq_random_all_ass extends base_seq;

    `uvm_object_utils(transfer_seq_random_all_ass)
    uvm_event ev2;

    function new(string name = "transfer_seq_random_all_ass");
        super.new(name);
    endfunction

    task body();


        `uvm_do_with(req,{ req.wb_addr == 32'h18; req.wb_data == 32'h01; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h14; req.wb_data == 32'h0; req.wb_select == 4'h1111; req.wb_write == 1'b1;})
        `uvm_do_with(req,{ req.wb_addr == 32'h00; req.wb_data == 32'h5a5a5a5a; req.wb_select == 4'h1111; req.wb_write == 1'b1;})  
        `uvm_do_with(req,{ req.wb_addr == 32'h04; req.wb_data == 32'h5a5a5a5a; req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h08; req.wb_data == 32'h5a5a5a5a; req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h0c; req.wb_data == 32'h5a5a5a5a; req.wb_select == 4'h1111; req.wb_write == 1'b1;})   
        `uvm_do_with(req,{ req.wb_addr == 32'h10; req.wb_data[31:14] == 20'd0; req.wb_data[13] == 1'd1;  req.wb_data[6:0]!=7'h00; req.wb_data[8:7]==2'b00; req.wb_data[10:9]!=2'b00; req.wb_data[10:9]!=2'b11; req.wb_select == 4'h1111; req.wb_write == 1'b1; })
       
        pre_value = req.wb_data;

    endtask

endclass:transfer_seq_random_all_ass

    // Add more classes of sequences below
class go_busy_seq extends base_seq;
//int pre_value;

    `uvm_object_utils(go_busy_seq)
    base_seq s;

    function new(string name = "go_busy_seq");
        super.new(name);
    endfunction
    //
    
    task body();
        `uvm_info(get_type_name(), $sformatf("pre_value = %0h", pre_value), UVM_LOW)
         //`uvm_do_with(req,{ req.wb_addr == 32'h10; req.wb_data == 32'h308; req.wb_select == 4'h1111; req.wb_write == 1'b1;})       
        `uvm_do_with(req,{ req.wb_addr == 32'h10; req.wb_data[31:9] == pre_value[31:9]; req.wb_data[8] == 1'b1; req.wb_data[6:0]==pre_value[6:0]; req.wb_data[7]==1'b0; req.wb_select == 4'h1111; req.wb_write == 1'b1;})       
    endtask

endclass:go_busy_seq

// class go2_busy_seq extends uvm_sequence#(wb_transaction);

//     `uvm_object_utils(go2_busy_seq)

//     function new(string name = "go2_busy_seq");
//         super.new(name);
//     endfunction

//     task body();
//         `uvm_do_with(req,{ req.wb_addr == 32'h10; req.wb_data == 32'h360; req.wb_select == 4'h1111; req.wb_write == 1'b1;})       
//     endtask

// endclass:go2_busy_seq

// class rx_read_seq extends uvm_sequence#(wb_transaction);

//     `uvm_object_utils(rx_read_seq)

//     function new(string name = "rx_read_seq");
//         super.new(name);
//     endfunction

//     task body();
//         `uvm_do_with(req,{ req.wb_addr == 32'h0; req.wb_select == 4'h1111; req.wb_write == 1'b0;})
//         `uvm_do_with(req,{ req.wb_addr == 32'h4; req.wb_select == 4'h1111; req.wb_write == 1'b0;})
//         `uvm_do_with(req,{ req.wb_addr == 32'h8; req.wb_select == 4'h1111; req.wb_write == 1'b0;})
//         `uvm_do_with(req,{ req.wb_addr == 32'hc; req.wb_select == 4'h1111; req.wb_write == 1'b0;}) 
//     endtask

// endclass:rx_read_seq

// class config_seq extends uvm_sequence#(wb_transaction);

//     `uvm_object_utils(config_seq)

//     function new(string name = "config_seq");
//         super.new(name);
//     endfunction

//     task body();
//         `uvm_do_with(req,{ req.wb_addr == 32'h0; req.wb_data == 32'h11; req.wb_select == 4'b1111; req.wb_write == 1'b1;})
//         `uvm_do_with(req,{ req.wb_addr == 32'h0;  req.wb_select == 4'b1111; req.wb_write == 1'b0;})
//         `uvm_do_with(req,{ req.wb_addr == 32'h4; req.wb_data == 32'h11; req.wb_select == 4'b1111; req.wb_write == 1'b1;})
//         `uvm_do_with(req,{ req.wb_addr == 32'h4; req.wb_select == 4'b1111; req.wb_write == 1'b0;})
//         `uvm_do_with(req,{ req.wb_addr == 32'h8; req.wb_data == 32'h11; req.wb_select == 4'b1111; req.wb_write == 1'b1;})
//         `uvm_do_with(req,{ req.wb_addr == 32'h8; req.wb_select == 4'b1111; req.wb_write == 1'b0;})
//         `uvm_do_with(req,{ req.wb_addr == 32'hc; req.wb_data == 32'h11; req.wb_select == 4'b1111; req.wb_write == 1'b1;})
//         `uvm_do_with(req,{ req.wb_addr == 32'hc; req.wb_select == 4'b1111; req.wb_write == 1'b0;})
//         `uvm_do_with(req,{ req.wb_addr == 32'h14;  req.wb_select == 4'b1111; req.wb_write == 1'b1;})
//         `uvm_do_with(req,{ req.wb_addr == 32'h14;  req.wb_select == 4'b1111; req.wb_write == 1'b0;})
//         `uvm_do_with(req,{ req.wb_addr == 32'h18;  req.wb_select == 4'b1111; req.wb_write == 1'b1;})
//         `uvm_do_with(req,{ req.wb_addr == 32'h18;  req.wb_select == 4'b1111; req.wb_write == 1'b0;})
//         `uvm_do_with(req,{ req.wb_addr == 32'h10;  req.wb_select == 4'b1111; req.wb_write == 1'b1;})
//         `uvm_do_with(req,{ req.wb_addr == 32'h10;  req.wb_select == 4'b1111; req.wb_write == 1'b0;})
        
        

//     endtask

// endclass:config_seq
