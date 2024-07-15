`ifndef RISCV_ITEM_SV
`define RISCV_ITEM_SV
class riscv_item extends uvm_sequence_item;

//Add a sequence item definition

// Variables a randomizar
rand int iteracion;
rand logic[6:0] opcode;
rand logic [4:0] rd;
rand logic [4:0] rs1;
rand logic [4:0] rs2;
rand logic [2:0] funct3;
rand logic [6:0] funct7;
rand logic [11:0] inm12;
rand logic [2:0] funct3_s;
rand logic [11:0] inm12_4;
rand logic [2:0] funct3_b;
rand logic [19:0] inm_20;
rand logic [19:0] inm_20_4;
rand logic [2:0] funct3_lw;


logic reset;
int num = 101;
int index = 0;
logic [6:0] opcode_rg = 7'b0010011; 		// Opoce I-type
logic [2:0] funct3_rg = 3'b000;			// funct3 del ADDI

logic [31:0] instruction_send;
logic [31:0] reg_file_send [31:0];


rand logic [31:0] rand_instruction;		// Instruccion randomizada

rand logic [31:0] rand_register;			// Instruccion para generar registros random

`uvm_object_utils_begin(riscv_item)

`uvm_field_int(iteracion, UVM_DEFAULT)
`uvm_field_int(opcode, UVM_DEFAULT)
`uvm_field_int(rd, UVM_DEFAULT)
`uvm_field_int(rs1, UVM_DEFAULT)
`uvm_field_int(rs2, UVM_DEFAULT)
`uvm_field_int(funct3, UVM_DEFAULT)
`uvm_field_int(funct7, UVM_DEFAULT)
`uvm_field_int(inm12, UVM_DEFAULT)
`uvm_field_int(funct3_s, UVM_DEFAULT)
`uvm_field_int(inm12_4, UVM_DEFAULT)
`uvm_field_int(funct3_b, UVM_DEFAULT)
`uvm_field_int(inm_20, UVM_DEFAULT)
`uvm_field_int(inm_20_4, UVM_DEFAULT)
`uvm_field_int(funct3_lw, UVM_DEFAULT)
`uvm_field_int(opcode_rg, UVM_DEFAULT)
`uvm_field_int(funct3_rg, UVM_DEFAULT)
`uvm_field_int(rand_instruction, UVM_DEFAULT)
`uvm_field_int(rand_register, UVM_DEFAULT)

`uvm_object_utils_end

function new(string name = "risc_item");
  super.new(name);
endfunction

// Opcode's del RiscV
constraint opcode_ins {
    opcode dist {7'b0110011 	:=100, 		// R_type
                   7'b0010011 :=100,		// I_type (ADDI, XORI, ...)
                   7'b0000011 :=100,		// Load (lw, lb, lh, ...)
                   7'b0100011 :=100,		// Store (sw, sb, sh)
                   7'b1100011 :=0,		// Branch
                   7'b1101111 :=0,        // JAL
                   7'b0110111 :=100,		// LUI
                   7'b0010111 :=0       	// AUIPC
                   };
    }

  // Funct3 para R-type y I-type
constraint funct3_ins{
        funct3 <= 7;
        funct3 >= 0;
    }
    
  // Funct3 para S-type	
constraint funct3_ins_s{
    funct3_s dist {3'b000 :=100, 			 // sb
                       3'b001 :=100, 			// sh 
                       3'b010 :=100 			// sw
                      };
    }	

  // Funct3 para B_type
constraint funt3_ins_b{
        funct3_b dist {3'b000, 			// beq 
                       3'b001, 			// bne 
                       3'b100, 			// blt 
                       3'b110, 			// bltu 
                       3'b101, 			// bge 
                       3'b111 			// bgeu
                      };
    }	

  // Funct3 para Load_type
constraint funt3_ins_lw{
    funct3_lw dist {3'b000 := 100, 		// lb 
                        3'b001 :=100, 			// lh 
                        3'b010 :=100, 			// lw 
                        3'b100 :=100, 			// lbu 
                        3'b101 :=100			// lhu
                       };
    }

  // Para R-TYPE variacion de funct7: 0x20
constraint funt7_ins {
    
        if (funct3 == 3'b000){
          
            funct7 dist {7'b0000000, 		// add, srl 
                         7'b0100000 		// sub, sra (no implementada)
                        };
        } else {
          
            funct7 == 7'b0000000;
          
          }
  }
  
// Posibles registros
constraint regs_ins {
          rd  <= 31; rd  >= 1;
          rs1 <= 31; rs1 >= 0;
          rs2 <= 31; rs2 >= 0;
   }
          
// Inm de 12 bits
constraint inm_ins {
    if (funct3 == 3'b001 ) {
      
      inm12 <= 31;
      inm12 >= 0;
      
    } else if (funct3 == 3'b101) {
      inm12[11:5] dist {7'b0000000 		// srli 
                        //7'b0100000 		// srai (no implementada)
                       };
      inm12[4:0] <= 31;
      inm12[4:0] >= 0; 
      
    } else {
        inm12 <= 4095;
        inm12 >= 0;
    }
   }
   
  // Inm de 12 bits multiplo de 4
constraint inm_ins_4 {
        inm12_4 <= 4095;
        inm12_4 >= 0;
        inm12_4 % 4 == 0;
   }
          
  // Inm de 20 bits
constraint inm_ins_20 {
        inm_20 <= (2**20)-1;  
          inm_20 >= 0;
   }
          
  // Inm de 20 bits  multiplo de 4
constraint inm_ins_20_4 {
        inm_20_4 <= (2**20)-1;
        inm_20_4 >= 0;
       inm_20_4 % 4 == 0;
   }
      
 constraint special_instruction {
   //addi r5, r0, 10
   if (index == 94) {
  opcode == 7'b0010011;
  funct3 ==3'b000;
  rd 	== 5'b00101;
  rs1	==5'b00000;
  inm12  ==12'b000000001010;

  }
    
   // addi r30, r0, 314
   else if (index == 95) {
  opcode == 7'b0010011;
  funct3 ==3'b000;
  rd 	== 5'b11110;
  rs1	==5'b00000;
  inm12  ==12'b000100111010;
  }
     
     // sw r30,34(r0)
    else if (index == 96) {
  opcode == 7'b0100011;
  funct3_s ==3'b010;
  rs2 	== 5'b11110;
  rs1	==5'b00000;
  inm12_4  ==12'd36;
  }
      
     // sll r5, r30, r6 
     else if (index == 97) {
  opcode == 7'b0110011;
  funct3 ==3'b001;
  rd 	== 5'b00101;
  rs1	==5'b11110;
      rs2 == 5'b00110;
      funct7 == 7'b0000000;  
  } 
             
     // lui r5, 10
     else if (index == 98) {
  opcode == 7'b0110111;
  rd 	== 5'b00101;
  inm_20_4  ==20'b00000000000000001100;
  }               
               
       //lb r5, 34(0)
     else if (index == 99) {
  opcode == 7'b0000011;
  rd 	== 5'b00101;
      funct3_lw == 3'b000;
      rs1 == 5'b00000;
  inm12  ==12'd36;
  }
        
 }

  // Construcción de la instrucción      
  constraint inst {
    
      // R-Type
      if (opcode ==  7'b0110011) {
        rand_instruction == {funct7, rs2, rs1, funct3, rd, opcode};
      }
        
      // I-type RTypeI
      else if(opcode == 7'b0010011) {
        rand_instruction == {inm12, rs1, funct3, rd, opcode};
      }
        
      // Load  I-type
      else if(opcode == 7'b0000011) {
        rand_instruction == {inm12_4, rs1, funct3_lw, rd, opcode};
      }
        
      // Store S-type
      else if(opcode == 7'b0100011 ) {
        rand_instruction == {inm12_4[11:5], rs2, rs1, funct3_s, inm12_4[4:0], opcode};
      }
        
      // Branch 
      else if(opcode == 7'b1100011 ) {
        rand_instruction == {inm12_4[11], inm12_4[9:4], rs2, rs1, funct3_b, inm12_4[3:0] ,inm12_4[10], opcode};
      }
        
      // JAL
      else if(opcode == 7'b1101111 ) {
        rand_instruction == {inm_20_4[19], inm_20_4[9:0], inm_20_4[10], inm_20_4[18:11], rd, opcode};
      }
        
      // JALR (actualmente comentada para no generar errores)
      // else if(opcode == 7'b1101111 && funct3 == 3'b000) {
      //   rand_instruction == {inm12_4, rs1, funct3, rd, opcode};
      // }
        
        
      // LUI
      /* **** revisar el inm ya que lo tenemos que sea multiplo de 4 ****/
      else if(opcode == 7'b0110111) {
        rand_instruction == {inm_20_4, rd, opcode};
      }
        
        
      // AUIPC
      else if(opcode == 7'b0010111 ) {
        rand_instruction == {inm_20_4, rd, opcode};
      }
   }

  // Registros
constraint regs {
       rand_register == {inm12, rs1, funct3_rg, rd, opcode_rg};
     }
      
    

endclass
`endif // RISCV_ITEM_SV