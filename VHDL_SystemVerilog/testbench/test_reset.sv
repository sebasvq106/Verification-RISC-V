`ifndef TEST_RESET_SV
`define TEST_RESET_SV
class test_reset extends test_basic;

  `uvm_component_utils(test_reset)
  
  function new (string name="test_reset", uvm_component parent=null);
    super.new (name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
       
    // Get handle to the singleton factory instance
    uvm_factory factory = uvm_factory::get();
    
    super.build_phase(phase);
    
    // Factory to override 'riscv_item' by 'riscv_item2' by name
    factory.set_type_override_by_name("riscv_item", "riscv_item_reset");

    // Print factory configuration
    factory.print();
  endfunction
  
   virtual task run_phase(uvm_phase phase);

    phase.raise_objection (this);
    
    uvm_report_info(get_full_name(),"Init Start", UVM_LOW);
    
    env.riscv_ag_active.riscv_drv.reset();
    
    uvm_report_info(get_full_name(),"Init Done", UVM_LOW);

    seq = gen_item_seq::type_id::create("seq");
    
    seq.randomize();
    seq.start(env.riscv_ag_active.riscv_seqr);
     
    uvm_report_info(get_full_name(),"Reset 2", UVM_LOW);
    
    env.riscv_ag_active.riscv_drv.reset();
    
    
    phase.drop_objection (this);
     
  endtask

endclass

class riscv_item_reset extends riscv_item;
  
  `uvm_object_utils(riscv_item_reset)

  function new(string name = "riscv_item_reset");
    super.new(name);
  endfunction

 int num = 50;

endclass
`endif // 
