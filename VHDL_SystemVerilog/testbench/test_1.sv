`ifndef TEST_1_SV
`define TEST_1_SV
class test_basic extends uvm_test;

`uvm_component_utils(test_basic)

function new (string name="test_basic", uvm_component parent=null);
  super.new (name, parent);
endfunction : new

virtual intf_cnt intf;
riscv_env env;  

virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
  if(uvm_config_db #(virtual intf_cnt)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
    end
    
  env  = riscv_env::type_id::create ("env", this);
// para darle acceso a todos a la base de datos
  uvm_config_db #(virtual intf_cnt)::set (null, "uvm_test_top.*", "VIRTUAL_INTERFACE", intf);
    
endfunction

virtual function void end_of_elaboration_phase(uvm_phase phase);
  uvm_report_info(get_full_name(),"End_of_elaboration", UVM_LOW);
  print();
  
endfunction : end_of_elaboration_phase

gen_item_seq seq;

virtual task run_phase(uvm_phase phase);

  phase.raise_objection (this);
  
  uvm_report_info(get_full_name(),"Init Start", UVM_LOW);
  
  env.riscv_ag_active.riscv_drv.reset();
  
  uvm_report_info(get_full_name(),"Init Done", UVM_LOW);

  seq = gen_item_seq::type_id::create("seq");
  
  seq.randomize();
  seq.start(env.riscv_ag_active.riscv_seqr);
  
  phase.drop_objection (this);
endtask

endclass

`endif // 