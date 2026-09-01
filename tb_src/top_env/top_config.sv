class top_config extends uvm_object;

    //timer_config tim_cfg;
    apb_config  apb_cfg;

    `uvm_object_utils(top_config)

    //----------------------Constructor----------------------
    function new(string name = "env_config");
    super.new(name);
	//tim_cfg = timer_config::type_id::create("tim_cfg");
    apb_cfg = apb_config::type_id::create("apb_cfg");
    endfunction
    
endclass:top_config
