class risc_item extends uvm_sequence_item;

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
  
  logic [6:0] opcode_rg = 7'b0010011; 		// Opoce I-type
  logic [2:0] funct3_rg = 3'b000;			// funct3 del ADDI
  
  rand logic [31:0] rand_instruction;		// Instruccion randomizada
  
  rand logic [31:0] rand_register;			// Instruccion para generar registros random
  
  `uvm_object_utils_begin(risc_item)
  
  `uvm_object_utils_end

  function new(string name = "risc_item");
    super.new(name);
  endfunction
  
	// Opcode's del RiscV
	constraint opcode_ins {
        opcode dist {7'b0110011 :=100, 		// R_type
                     7'b0010011 :=100,		// I_type (ADDI, XORI, ...)
                     7'b0000011 :=0,		// Load (lw, lb, lh, ...)
                     7'b0100011 :=0,		// Store (sw, sb, sh)
                     7'b1100011 :=0,		// Branch
                     7'b1101111 :=0,        // JAL
                     7'b0110111 :=0,		// LUI
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
      	  funct3_s dist {3'b000, 			// sb
                         3'b001, 			// sh 
                         3'b010 			// sw
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
      	  funct3_lw dist {3'b000, 			// lb 
                          3'b001, 			// lh 
                          3'b010, 			// lw 
                          3'b100, 			// lbu 
                          3'b101 			// lhu
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




// Sequence
          
class gen_item_seq extends uvm_sequence;
  `uvm_object_utils(gen_item_seq)
  function new(string name="gen_item_seq");
    super.new(name);
  endfunction

  rand int num; 	// Config total number of items to be sent

  constraint c1 { num inside {[2:5]}; }

  virtual task body();
    risc_item f_item = risc_item::type_id::create("f_item");
    for (int i = 0; i < num; i ++) begin
        start_item(f_item);
      f_item.randomize(); //with {iteracion == num};  
    	`uvm_info("SEQ", $sformatf("Generate new item: "), UVM_LOW)
    	f_item.print();
        finish_item(f_item);
      //`uvm_do(f_item); hace el start_item, f_item.randomiz y el finish_item(f_item); automticamente
    end
    `uvm_info("SEQ", $sformatf("Done generation of %0d items", num), UVM_LOW)
  endtask
endclass

      
      
      

// Driver
class arb_driver extends uvm_driver #(risc_item);

  `uvm_component_utils (arb_driver)
   function new (string name = "fifo_driver", uvm_component parent = null);
     super.new (name, parent);
   endfunction

   virtual intf_cnt intf;

   virtual function void build_phase (uvm_phase phase);
     super.build_phase (phase);
     if(uvm_config_db #(virtual intf_cnt)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
       `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
     end
   endfunction
   
   virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      risc_item f_item;
      `uvm_info("DRV", $sformatf("Wait for item from sequencer"), UVM_LOW)
      seq_item_port.get_next_item(f_item);
      fork
        reset();
        register(f_item);
        instruction(f_item);
      join
    seq_item_port.item_done();
    end
  endtask
  
  task reset();
    begin
      	//tb_clk = 0;
    	intf.reset = 1;
    	#25 intf.reset =0;  
    end
  endtask
  
  task register(risc_item f_item);
    begin
  		//sti = new();
      	top_hdl.riscV.dp.instr_mem.Inst_mem[0] = 32'h00007033;
      	//sb.instruction_queue.push_front(32'h00007033);
      	//for (int i = 1; i < 7; i = i + 1) begin
      		//if(sti.randomize())
      	top_hdl.riscV.dp.instr_mem.Inst_mem[1] = f_item.rand_register;
      		//sb.instruction_queue.push_front(sti.rand_register);
    	//end
    end
	endtask
    
  
  	// Generador de instrucciones    
	task instruction(risc_item f_item);
    begin
    	//sti = new();
     // for (int i = 7; i < 50; i = i + 1) begin
    		//if(sti.randomize())
      top_hdl.riscV.dp.instr_mem.Inst_mem[2] = f_item.rand_instruction;
      		//sb.instruction_queue.push_front(sti.rand_instruction); 

	   	//end
  	end
    endtask
              
  
endclass
