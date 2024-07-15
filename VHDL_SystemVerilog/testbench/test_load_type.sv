`ifndef TEST_LOAD_TYPE_SV
`define TEST_LOAD_TYPE_SV
class test_load_type extends test_basic;

  `uvm_component_utils(test_load_type)
  
  function new (string name="test_load_type", uvm_component parent=null);
    super.new (name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
       
    // Get handle to the singleton factory instance
    uvm_factory factory = uvm_factory::get();
    
    super.build_phase(phase);
    
    // Factory to override 'riscv_item' by 'riscv_item2' by name
    factory.set_type_override_by_name("riscv_item", "riscv_item_load");

    // Print factory configuration
    factory.print();
  endfunction

endclass

class riscv_item_load extends riscv_item;
  
  `uvm_object_utils(riscv_item_load)

  function new(string name = "riscv_item_load");
    super.new(name);
  endfunction

  constraint opcode_ins {
    opcode dist {7'b0110011 :=0,         // R_type
                     7'b0010011 :=0,        // I_type (ADDI, XORI, ...)
                     7'b0000011 :=100,        // Load (lw, lb, lh, ...)
                     7'b0100011 :=0,        // Store (sw, sb, sh)
                     7'b1100011 :=0,        // Branch
                     7'b1101111 :=0,        // JAL
                     7'b0110111 :=0,        // LUI
                     7'b0010111 :=0           // AUIPC
                     };
      }
  
  
  constraint special_instruction {
    
    // Lw
    if (index == 95) {
      opcode == 7'b0000011; 
      funct3_lw == 3'b010;      
      rd == 5'b00010; 
      rs1 == 5'b00110; 
      inm12_4 == 12'd0;
      
    } 
      
    // LB
    else if (index == 96) {
      opcode == 7'b0000011;
      funct3_lw == 3'b000; 
      rd == 5'b00110; 
      rs1 == 5'b00110; 
      inm12_4 == 12'd0;
      
    } 
      
    // LBU
    else if (index == 97) {
      opcode == 7'b0000011; 
      funct3_lw == 3'b100;
      rd == 5'b00011; 
      rs1 == 5'b00110; 
      inm12_4 == 12'd0;
	
      
    } 
    
    // LH
    else if (index == 98) {
      opcode == 7'b0000011; 
      funct3_lw == 3'b001;
      rd == 5'b00111; 
      rs1 == 5'b00110; 
      inm12_4 == 12'd0;
      
    } 
     
    // LW
    else if (index == 99) {
      opcode == 7'b0000011; 
      funct3_lw == 3'b010;
      rd == 5'b01000; 
      rs1 == 5'b00110; 
      inm12_4 == 12'd0;

    }
  }
      
endclass
`endif // 