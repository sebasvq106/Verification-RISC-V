`ifndef TEST_LUI_SV
`define TEST_LUI_SV
class test_lui_type extends test_basic;

  `uvm_component_utils(test_lui_type)
  
  function new (string name="test_lui_type", uvm_component parent=null);
    super.new (name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
       
    // Get handle to the singleton factory instance
    uvm_factory factory = uvm_factory::get();
    
    super.build_phase(phase);
    
    // Factory to override 'riscv_item' by 'riscv_item2' by name
    factory.set_type_override_by_name("riscv_item", "riscv_item_lui");

    // Print factory configuration
    factory.print();
  endfunction

endclass

class riscv_item_lui extends riscv_item;
  
  `uvm_object_utils(riscv_item_lui)

  function new(string name = "riscv_item_lui");
    super.new(name);
  endfunction

  constraint opcode_ins {
    opcode dist {7'b0110011 :=0,         // R_type
                     7'b0010011 :=0,        // I_type (ADDI, XORI, ...)
                     7'b0000011 :=0,        // Load (lw, lb, lh, ...)
                     7'b0100011 :=0,        // Store (sw, sb, sh)
                     7'b1100011 :=0,        // Branch
                     7'b1101111 :=0,        // JAL
                     7'b0110111 :=100,        // LUI
                     7'b0010111 :=0           // AUIPC
                     };
      }

endclass

`endif // 