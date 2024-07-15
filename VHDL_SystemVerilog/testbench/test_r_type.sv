`ifndef TEST_R_TYPE_SV
`define TEST_R_TYPE_SV
class test_r_type extends test_basic;

  `uvm_component_utils(test_r_type)
  
  function new (string name="test_r_type", uvm_component parent=null);
    super.new (name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
       
    // Get handle to the singleton factory instance
    uvm_factory factory = uvm_factory::get();
    
    super.build_phase(phase);
    
    
    factory.set_type_override_by_name("riscv_item", "riscv_item_R");
    
    factory.print();
  endfunction
  

endclass



class riscv_item_R extends riscv_item;
  
  `uvm_object_utils(riscv_item_R)

  function new(string name = "riscv_item_R");
    super.new(name);
  endfunction

  constraint opcode_ins {
    opcode dist {7'b0110011 :=100,         // R_type
                     7'b0010011 :=0,        // I_type (ADDI, XORI, ...)
                     7'b0000011 :=0,        // Load (lw, lb, lh, ...)
                     7'b0100011 :=0,        // Store (sw, sb, sh)
                     7'b1100011 :=0,        // Branch
                     7'b1101111 :=0,        // JAL
                     7'b0110111 :=0,        // LUI
                     7'b0010111 :=0           // AUIPC
                     };
      }
  
  constraint special_instruction {
    if (index == 95) {
      opcode == 7'b0110011; 
      funct3 == 3'b000;  
      rd == 5'b00101;     
      rs1 == 5'b01111; 
      rs2 == 5'b01100; 
      funct7 == 7'b0000000;
      
    } else if (index == 96) {
      opcode == 7'b0110011; 
      funct3 == 3'b101;  
      rd == 5'b00111;       
      rs1 == 5'b01011; 
      rs2 == 5'b01101; 
      funct7 == 7'b0000000;
      
    } else if (index == 97) {
      opcode == 7'b0110011; 
      funct3 == 3'b010;  
      rd == 5'b00001;       
      rs1 == 5'b00010; 
      rs2 == 5'b01111; 
      funct7 == 7'b0000000;
      
    } else if (index == 98) {
      opcode == 7'b0110011; 
      funct3 == 3'b100;  
      rd == 5'b00100;       
      rs1 == 5'b01010; 
      rs2 == 5'b11110; 
      funct7 == 7'b0000000;
      
    } else if (index == 99) {
      opcode == 7'b0110011; 
      funct3 == 3'b111;  
      rd == 5'b10010;       
      rs1 == 5'b10010; 
      rs2 == 5'b00111; 
      funct7 == 7'b0000000;
      
    }
    }
      

endclass
`endif //