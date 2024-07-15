`ifndef TEST_STORE_TYPE_SV
`define TEST_STORE_TYPE_SV
class test_store_type extends test_basic;

  `uvm_component_utils(test_store_type)
  
  function new (string name="test_store_type", uvm_component parent=null);
    super.new (name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
       
    // Get handle to the singleton factory instance
    uvm_factory factory = uvm_factory::get();
    
    super.build_phase(phase);
    
    // Factory to override 'riscv_item' by 'riscv_item2' by name
    factory.set_type_override_by_name("riscv_item", "riscv_item_store");

    // Print factory configuration
    factory.print();
  endfunction

endclass

class riscv_item_store extends riscv_item;
  
  `uvm_object_utils(riscv_item_store)

  function new(string name = "riscv_item_store");
    super.new(name);
  endfunction

  constraint opcode_ins {
    opcode dist {7'b0110011 :=0,         // R_type
                     7'b0010011 :=0,        // I_type (ADDI, XORI, ...)
                     7'b0000011 :=0,        // Load (lw, lb, lh, ...)
                     7'b0100011 :=100,        // Store (sw, sb, sh)
                     7'b1100011 :=0,        // Branch
                     7'b1101111 :=0,        // JAL
                     7'b0110111 :=0,        // LUI
                     7'b0010111 :=0           // AUIPC
                     };
      }
  
  
  constraint special_instruction {
    
    // SH
    if (index == 95) {
      opcode == 7'b0100011; 
      funct3_s == 3'b001;      
      rs1 == 5'b00010; 
      rs2 == 5'b00110; 
      inm12_4 == 12'd0;
      
    } 
      
    // SW
    else if (index == 96) {
      opcode == 7'b0100011;
      funct3_s == 3'b010;      
      rs1 == 5'b00011; 
      rs2 == 5'b00110; 
      inm12_4 == 12'd0;
      
    } 
      
    // SB
    else if (index == 97) {
      opcode == 7'b0100011; 
      funct3_s == 3'b000;      
      rs1 == 5'b00110; 
      rs2 == 5'b00110; 
      inm12_4 == 12'd0;
      
    } 
    
    // SB
    else if (index == 98) {
      opcode == 7'b0100011; 
      funct3_s == 3'b000;      
      rs1 == 5'b00111; 
      rs2 == 5'b00110; 
      inm12_4 == 12'd0;
      
    } 
     
    // SW
    else if (index == 99) {
      opcode == 7'b0100011; 
      funct3_s == 3'b010;      
      rs1 == 5'b01111; 
      rs2 == 5'b00110; 
      inm12_4 == 12'd0; 
    }
    }
      
endclass
`endif // 