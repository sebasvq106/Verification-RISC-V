class arb_env extends uvm_env;

  `uvm_component_utils(arb_env)

  function new (string name = "fifo_env", uvm_component parent = null);
    super.new (name, parent);
  endfunction
  
  virtual intf_cnt intf;
  arb_driver arb_drv;
  uvm_sequencer #(risc_item)	arb_seqr;
  

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(uvm_config_db #(virtual intf_cnt)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
    end
    
    arb_drv = arb_driver::type_id::create ("arb_drv", this); 
    
    arb_seqr = uvm_sequencer#(risc_item)::type_id::create("arb_seqr", this);
    
    
    //uvm_config_db #(virtual fifo_intf)::set (null, "uvm_test_top.*", "VIRTUAL_INTERFACE", intf);    
      
    uvm_report_info(get_full_name(),"End_of_build_phase", UVM_LOW);
    print();

  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    arb_drv.seq_item_port.connect(arb_seqr.seq_item_export);
  endfunction

endclass