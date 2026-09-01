/*-------------------------------------------------------------------------
File name   : scoreboard.sv
Project     : SPI VIP
---------------------------------------------------------------------------*/
import spi_pkg::spi_transaction;

`uvm_analysis_imp_decl(_wb_drv)
`uvm_analysis_imp_decl(_wb_mon)
`uvm_analysis_imp_decl(_spi_drv)
`uvm_analysis_imp_decl(_spi_mon)

class scoreboard extends uvm_scoreboard;
	int i=0;
	  
  `uvm_component_utils(scoreboard)

	// Analysis imports
	uvm_analysis_imp_wb_mon#(wb_transaction, scoreboard) wb_mon_export;
	uvm_analysis_imp_spi_mon#(spi_transaction, scoreboard) spi_mon_export;
	uvm_analysis_imp_wb_drv#(wb_transaction, scoreboard) wb_drv_export;
	uvm_analysis_imp_spi_drv#(spi_transaction, scoreboard) spi_drv_export;
	// tlm fifos
	uvm_tlm_fifo #(wb_transaction) wb_outfifo;
	uvm_tlm_fifo #(wb_transaction) wb_expfifo;
	uvm_tlm_fifo #(spi_transaction) spi_outfifo;
	uvm_tlm_fifo #(spi_transaction) spi_expfifo;
	// temporary memories
	bit [31:0] wb_mem [0:255];
	bit [31:0] spi_mem [0:255];
	//int num_pass, num_fail;
	
	function new(string name, uvm_component parent);
		super.new(name,parent);
		wb_mon_export = new("wb_mon_export", this);
		wb_drv_export = new("wb_drv_export", this);
		spi_drv_export = new("spi_drv_export", this);
		spi_mon_export = new("spi_mon_export", this);

		wb_outfifo = new("wb_outfifo", this);
		wb_expfifo = new("wb_expfifo", this);
		spi_outfifo = new("spi_outfifo", this);
		spi_expfifo = new("spi_expfifo", this);
	endfunction
	
	// write functions
	extern function void write_wb_mon(wb_transaction tr);
	extern function void write_spi_mon(spi_transaction t);
	extern function void write_wb_drv(wb_transaction tr);
	extern function void write_spi_drv(spi_transaction t);
	extern function void report_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);
	extern function void update_wb_mem(wb_transaction tr);
	extern function void update_spi_mem(wb_transaction tr);
	extern virtual task compare(wb_transaction tr1,spi_transaction tr2,int a);
	extern virtual task compare_miso(wb_transaction tr1,spi_transaction tr2,int a);
endclass:scoreboard


  function void scoreboard::write_wb_mon(wb_transaction tr);
	
	`uvm_info(get_type_name(), $sformatf("write wb_mon: \n%s",tr.sprint()), UVM_LOW) 
	if(wb_outfifo.is_empty()) begin
		`uvm_info(get_type_name(), $sformatf("write wb_mon: wb_outfifo is empty put %d ",i), UVM_LOW) 
	end
	else begin
		`uvm_info(get_type_name(), $sformatf("write wb_mon: wb_outfifo is not empty put %d ",i), UVM_LOW) 
	end
	`uvm_info(get_type_name(), $sformatf("write wb_mon: wb_outfifo size put %d",wb_outfifo.size()), UVM_LOW) 

	void'(wb_outfifo.try_put(tr));
	update_spi_mem(tr);
	i++;
  endfunction 

  function void scoreboard::write_spi_mon(spi_transaction t);
	`uvm_info(get_type_name(), $sformatf("write spi_mon: \n%s",t.sprint()), UVM_LOW)
	void'(spi_outfifo.try_put(t));
  endfunction 

  function void scoreboard::write_wb_drv(wb_transaction tr);
	`uvm_info(get_type_name(), $sformatf("write wb_drv: \n%s",tr.sprint()), UVM_LOW)
	void'(wb_expfifo.try_put(tr));
	update_wb_mem(tr);
  endfunction 
  function void scoreboard::write_spi_drv(spi_transaction t);
	`uvm_info(get_type_name(), $sformatf("write spi_drv: \n%s",t.sprint()), UVM_LOW)
	void'(spi_expfifo.try_put(t));
  endfunction
	function void scoreboard::update_wb_mem(wb_transaction tr);
		if(tr.wb_write==1) begin
			`uvm_info(get_type_name(), $sformatf("\n wb_mem[%h]: = %h \n",tr.wb_addr,tr.wb_data), UVM_LOW)
			wb_mem[tr.wb_addr] = tr.wb_data;
		end
	endfunction
	function void scoreboard::update_spi_mem(wb_transaction tr);
		if(tr.wb_write==0) begin
			`uvm_info(get_type_name(), $sformatf("\n spi_mem[%h]: = %h \n",tr.wb_addr,tr.wb_data), UVM_LOW)

			spi_mem[tr.wb_addr] = tr.wb_data;
			`uvm_info(get_type_name(), $sformatf("\n spi_mem[%h]: = %h \n",tr.wb_addr,spi_mem[tr.wb_addr]), UVM_LOW)
		end
		endfunction
	 task scoreboard::compare(wb_transaction tr1,spi_transaction tr2,int a);
		bit [127:0] expected_data;
		int length;
		//if(tr1.wb_write==0) begin
		expected_data = {wb_mem['hc],wb_mem['h8],wb_mem['h4],wb_mem['h0]};

		if(a[6:0]==0)
		length = 128;
		else
		length = a[6:0];

		for(int i=0; i <length; i++) begin
			if (tr2.rec_data[i] == expected_data[i]) begin
				`uvm_info (get_type_name(),$sformatf("\nData Match [MOSI] \nExpected 0x%h \nActual 0x%h", expected_data, tr2.rec_data),UVM_NONE)
			end
			else begin
				`uvm_error (get_type_name(),$sformatf("\nData MisMatch [MOSI] \nExpected: 0x%h \nActual: 0x%h \n Char_length: 0x%h", expected_data, tr2.rec_data, length))
			end
		end
		//end 
		/*else begin 
			if (tr1.wb_data == tr2.wb_data) begin
				`uvm_info (get_type_name(),$sformatf("\nData Match [WRITE] \nExpected %h \nActual %h", tr1.wb_data, tr2.wb_data), UVM_NONE)
			end
			else begin
				`uvm_error (get_type_name(),$sformatf("\nData MisMatch \nExpected %h \nActual %h", tr1.wb_data, tr2.wb_data))
			end
		//end*/
		
	 endtask
	 task scoreboard::compare_miso(wb_transaction tr1,spi_transaction tr2,int a);
		bit [31:0] actual_data;
		bit [31:0] actual_data1;
		bit [31:0] actual_data2;
		bit [31:0] actual_data3;
		int j=0;
		int length;
		//if(tr1.wb_write==0) begin
		actual_data = spi_mem[0]; //spi_mem[0][i]
		actual_data1 = spi_mem['h4];
		actual_data2 = spi_mem['h8];
		actual_data3 = spi_mem['hc];
		//if (a [6:0] >=1 && a[6:0] <=32 ) begin
		if(a[6:0]==0)
		length = 128;
		else
		length = a[6:0];

			for(int i=0; i <length; i++) begin
				if (tr2.trans_data[i] == spi_mem[(i/32)*4][j]) begin
					`uvm_info (get_type_name(),$sformatf("\nData Match [MISO] \nActual (spi_mem[%0d]) 0x%h \nExpected 0x%h", (i/32)*4,spi_mem[(i/32)*4], tr2.trans_data),UVM_NONE)
					`uvm_info(get_type_name(), $sformatf("\n spi_mem[%0d][%0d] = 0x%h: trans2[%0d]= 0x%h \n",(i/32)*4,j,spi_mem[(i/32)*4][j],i,tr2.trans_data[i]), UVM_LOW)
				end
					else begin
					`uvm_error (get_type_name(),$sformatf("\nData MisMatch [MISO] \nActual ((spi_mem[%0d])) 0x%h \nExpected 0x%h \n Char_length: 0x%h", (i/32)*4,spi_mem[(i/32)*4], tr2.trans_data, length[6:0]))
					`uvm_info(get_type_name(), $sformatf("\n spi_mem[%0d][%0d] = 0x%h: trans2[%0d]= 0x%h \n",(i/32)*4,j,spi_mem[(i/32)*4][j],i,tr2.trans_data[i]), UVM_LOW)
				end
				j++;
				if (j==32)
					j=0;
				
			end
		//end
		/*else if (a [6:0] >=33 && a[6:0] <=64 ) begin
			for(int i=0; i <a[6:0]-32; i++) begin
				if (tr2.trans_data[i] == actual_data[i]) begin
					`uvm_info (get_type_name(),$sformatf("\nData Match [MISO] \nActual %h \nExpected %h", actual_data, tr2.trans_data),UVM_NONE)
				end
				else begin
					`uvm_error (get_type_name(),$sformatf("\nData MisMatch [MISO] \nActual %h \nExpected %h", actual_data, tr2.trans_data))
				end
			end
			for(int i=32; i <a[6:0]; i++) begin
				if (tr2.trans_data[i] == actual_data1[i-32]) begin
					`uvm_info (get_type_name(),$sformatf("\nData Match [MISO] \nActual1 %h \nExpected %h", actual_data1, tr2.trans_data),UVM_NONE)
				end
				else begin
					`uvm_error (get_type_name(),$sformatf("\nData MisMatch [MISO] \nActual1 %h \nExpected %h", actual_data1, tr2.trans_data))
				end
			end
		end*/
	 endtask
  task scoreboard::run_phase(uvm_phase phase);
	
	int wb_data;
	int length;
	int j=0;
	wb_transaction wb_exp_tr, wb_out_tr;
	spi_transaction spi_out_tr, spi_exp_tr ;
	super.run_phase(phase);
	`uvm_info(get_type_name(),"scoreboard run phase",UVM_NONE)
	forever begin

	`uvm_info(get_type_name(),"00",UVM_NONE)
		wb_expfifo.get(wb_exp_tr); // wb trans collected in driver
	`uvm_info(get_type_name(),"01",UVM_NONE)
		spi_expfifo.get(spi_exp_tr); // spi trans collected in driver
		
	`uvm_info(get_type_name(),"02",UVM_NONE)
		spi_outfifo.get(spi_out_tr); // spi trans collected in monitor
	`uvm_info(get_type_name(),"03",UVM_NONE)
	// if (!uvm_resource_db#(int)::read_by_name("uvm_test_top.env.scb", "wb_data", wb_data))begin
	// 	//wb_data = -1;
	// 	`uvm_error (get_type_name(), "ERROR")
	// 	end
	// 	else begin
	// 	`uvm_info(get_name(), $sformatf("wb_data = %01h", wb_data), UVM_LOW)
	// end

	if(!uvm_config_db#(int)::get(this, "", "wb_data", wb_data))
	`uvm_fatal(get_name(),"No wb_data is set for this instance")
	else 
	`uvm_info(get_name(), $sformatf("wb_data = %01h", wb_data), UVM_LOW)

	if(wb_data[6:0]==0)
	 	length =128;
	else 
		length = wb_data[6:0];
	for(int i=0; i<=3; i++) begin
		if(wb_outfifo.is_empty()) begin
			`uvm_info(get_type_name(), $sformatf("write wb_mon: wb_outfifo is empty befor get "), UVM_LOW) 
		end
		else begin
			`uvm_info(get_type_name(), $sformatf("write wb_mon: wb_outfifo is not empty befor get"), UVM_LOW) 
		end
		wb_outfifo.get(wb_out_tr); // wb trans collected in monitor
		`uvm_info(get_type_name(),"04",UVM_NONE)
		if(wb_outfifo.is_empty()) begin
			`uvm_info(get_type_name(), $sformatf("write wb_mon: wb_outfifo is empty after get %0d ",j), UVM_LOW) 
		end
		else begin
			`uvm_info(get_type_name(), $sformatf("write wb_mon: wb_outfifo is not empty after get %0d ",j), UVM_LOW) 
		end
	    `uvm_info(get_type_name(), $sformatf("wb_out_tr: \n%s",wb_out_tr.sprint()), UVM_LOW) 


	end
	`uvm_info(get_name(), $sformatf("Before compare"), UVM_LOW)
	
	
		compare(wb_exp_tr,spi_out_tr,wb_data); 
	`uvm_info(get_name(), $sformatf("After compare"), UVM_LOW)

		
		compare_miso(wb_out_tr,spi_exp_tr,wb_data);
		//spi_outfifo.get(out_tr);		// SPI trans collected in driver
		//if (spi_exp_tr.wb_data == spi_out_tr.wb_data) begin
		//	`uvm_info (get_type_name(),$sformatf("Data Match %s",spi_out_tr.sprint()),UVM_NONE)
		//end
		
	end
	
  endtask   

//   function void scoreboard::report_phase(uvm_phase phase);
// 	//`uvm_info(get_type_name(), $sformatf("Report: Number of tests passed: %0d", num_pass), UVM_LOW);
//   endfunction
  

  function void scoreboard::report_phase(uvm_phase phase);
    uvm_report_server svr;
    super.report_phase(phase);
     svr = uvm_report_server::get_server();
//`uvm_info(get_type_name(), "----------TEST PASS------------------", UVM_NONE)
if(svr.get_severity_count(UVM_FATAL)+svr.get_severity_count(UVM_ERROR)>0)
 begin
        `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
        `uvm_info(get_type_name(), "----            TEST FAIL          ----", UVM_NONE)
        `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
     end
   else
 begin
        `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
        `uvm_info(get_type_name(), "----           TEST PASS           ----", UVM_NONE)
        `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
     end
 endfunction