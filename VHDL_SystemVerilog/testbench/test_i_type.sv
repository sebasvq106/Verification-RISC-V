`ifndef TEST_I_TYPE_SV
`define TEST_I_TYPE_SV
class test_i_type extends test_basic;

  `uvm_component_utils(test_i_type)
  
  function new (string name="test_i_type", uvm_component parent=null);
    super.new (name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
       
    
    uvm_factory factory = uvm_factory::get();
    
    super.build_phase(phase);
    
    
    factory.set_type_override_by_name("riscv_item", "riscv_item_I");
    
    factory.print();
  endfunction
  

endclass



class riscv_item_I extends riscv_item;
  
  `uvm_object_utils(riscv_item_I)

  function new(string name = "riscv_item_I");
    super.new(name);
  endfunction

  constraint opcode_ins {
    opcode dist {7'b0110011 :=0,         // R_type
                     7'b0010011 :=100,        // I_type (ADDI, XORI, ...)
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
      opcode == 7'b0010011; 
      inm12 == 12'b10101100;
      rs1 == 5'b00011;
      funct3 == 3'b000;
      rd == 5'b11111;
      
    } else if (index == 96) {
      opcode == 7'b0010011; 
      inm12 == 12'b0101101011;
      rs1 == 5'b10111;
      funct3 == 3'b110;
      rd == 5'b00001;
      
    } else if (index == 97) {
      opcode == 7'b0010011; 
      inm12 == 12'b1011010;
      rs1 == 5'b00111;
      funct3 == 3'b111;
      rd == 5'b10101;
      
    } else if (index == 98) {
      opcode == 7'b0010011; 
      inm12 == 12'b11101011;
      rs1 == 5'b0011;
      funct3 == 3'b011;
      rd == 5'b00001;
      
    } else if (index == 99) {
      opcode == 7'b0010011; 
      inm12 == 12'b10101011;
      rs1 == 5'b01111;
      funct3 == 3'b100;
      rd == 5'b00011;
      
    }
    }
endclass

`endif //