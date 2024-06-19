`ifndef SCOREBOARD_SV
`define SCOREBOARD_SV
`uvm_analysis_imp_decl( _drv )
`uvm_analysis_imp_decl( _mon ) 

class riscv_scoreboard extends uvm_scoreboard;
  	`uvm_component_utils (riscv_scoreboard)

    function new (string name, uvm_component parent=null);
		super.new (name, parent);
	endfunction
  // para recibir el dato del agente activo
  uvm_analysis_imp_drv #(riscv_item, riscv_scoreboard) riscv_drv;
  // para recibir los datos del agen passive
  uvm_analysis_imp_mon #(riscv_item, riscv_scoreboard) riscv_mon;

  	logic [31:0] instruction_ref [$];  
    logic error_count;						// Contador de errores
  	logic error_found = 0;					// Se pone en 1 cuando hay un error
  	logic [31:0] instruction;					// Instrucción obtenida del scoreboard
  
    // Modelo de referencia
    logic [4:0] rd, rs1, rs2;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic [11:0] inm;
    logic [6:0] opcode;
    logic [31:0] reg_ref [31:0];				// Registros de referencia 
    logic [31:0] mem_ref [(2**32)-1:0];			// Memoria de refrencia
    logic	[31:0] Imm_out;						// Inm extendido a 31 bits
    
  
  
	function void build_phase (uvm_phase phase);
      riscv_drv = new ("riscv_drv", this);
      riscv_mon = new ("riscv_mon", this);
       
       // se inician todod los reg de ref en cero
       for (int i = 0; i < 32; i++) begin
            reg_ref[i] = 32'h00000000;
        end
      
	endfunction

  // para recibir la instruccion del driver o agente passivo
  virtual function void write_drv (riscv_item item);
    //`uvm_info ("drv", $sformatf("Data received = %h ", item.instruction_send), UVM_MEDIUM);
    instruction_ref.push_front(item.instruction_send);
	endfunction
  
  // Para comparar.
  virtual function void write_mon (riscv_item item);
    			
      instruction = instruction_ref.pop_back();
    
    `uvm_info ("drv", $sformatf("Instruction recibida en el scoreboard por parte del drv= %h", instruction), UVM_MEDIUM)
    
      		opcode = instruction[6:0];
    


          	//R-type
          	if (opcode == 7'b0110011 )begin
                rd = instruction[11:7];
                rs1 = instruction[19:15];
                rs2 = instruction[24:20];
                funct3 = instruction[14:12];
                funct7 = instruction[31:25];

                if (funct3 == 3'b000 && funct7 == 7'b000000 )begin
                      reg_ref[rd] = reg_ref[rs1] + reg_ref[rs2];
                end

                //sub  
                else if (funct3 == 3'b000 && funct7 == 7'b0100000 )begin 
                  reg_ref[rd] = reg_ref[rs1] - reg_ref[rs2];
                end

                //xor
                else if (funct3 == 3'b100) begin
                  reg_ref[rd] = reg_ref[rs1] ^ reg_ref[rs2];
                end

                //or
                else if(funct3 == 3'b110) begin
                  reg_ref[rd] = reg_ref[rs1] | reg_ref[rs2];
                end

                //and
                else if (funct3 == 3'b111) begin
                  reg_ref[rd] = reg_ref[rs1] & reg_ref[rs2];

                end

                //sll    
                else if (funct3 == 3'b001) begin 
                  reg_ref[rd] = reg_ref[rs1] << reg_ref[rs2];
                end

                //srl 
                else if (funct3 == 3'b101) begin 
                  reg_ref[rd] = reg_ref[rs1] >> reg_ref[rs2];
                end

                //sra msb-extends 
                else if (funct3 == 3'b101 && funct7 == 7'b0100000) begin 
                  reg_ref[rd] = reg_ref[rs1][30:0] >> reg_ref[rs2] ;
                end

                //slt 
                else if (funct3 == 3'b010)begin 
                  reg_ref[rd] = ($signed(reg_ref[rs1]) < $signed(reg_ref[rs2]))?1:0;
                end

                //sltu zero-extends
                else if (funct3 == 3'b011) begin 
                  reg_ref[rd] = (reg_ref[rs1] < reg_ref[rs2])?1:0 ;
                end

          	end

          	//I-type
          	else if(opcode == 7'b0010011) begin
                   rd = instruction[11:7];
                   rs1 = instruction[19:15];
            	   inm = instruction[31:20];
                   funct3 = instruction[14:12];
            	   Imm_out = {inm[11]? {20{1'b1}}:20'b0 , inm[11:0]};

                  if (funct3 == 3'b000 ) begin
                    reg_ref[rd] = reg_ref[rs1] + $signed(Imm_out);
                  end

                  //xori   
                  else if (funct3 == 3'b100)begin
                    reg_ref[rd] = reg_ref[rs1] ^ $signed(Imm_out);
                  end

                  //ori 
                  else if (funct3 == 3'b110) begin
                    reg_ref[rd] = reg_ref[rs1] | $signed(Imm_out);
                  end

                  //andi
                  else if (funct3 == 3'b111) begin
                    reg_ref[rd] = reg_ref[rs1] & $signed(Imm_out);
                  end

                  //slli
                  else if (funct3 == 3'b001) begin
                    reg_ref[rd] = reg_ref[rs1] << $signed(Imm_out[4:0]);

                  end

                  //srli   
                  else if (funct3 == 3'b101) begin
                    reg_ref[rd] = reg_ref[rs1] >> $signed(Imm_out[4:0]);
                  end

                  //srai:  msb-extends
                  else if (funct3 == 3'b101) begin
                    reg_ref[rd] = reg_ref[rs1] >>> $signed(Imm_out[4:0]);
                  end

                  //slti 
                  else if (funct3 == 3'b010) begin
                    reg_ref[rd] = ($signed(reg_ref[rs1]) < $signed(Imm_out))?1:0;
                  end

                  //sltiu: zero-extends
                  else if (funct3 == 3'b011) begin
                    reg_ref[rd] = (reg_ref[rs1] < Imm_out)?1:0;
                  end 
          	end
    `uvm_info("rd de la instrccion ejecutada", $sformatf("Este es rd %d", rd), UVM_MEDIUM);
       
       for (int i=0; i < 32; i=i+1) begin
        	
      `uvm_info("comparacion", $sformatf("DUT reg[ %0d] = %0d :: SB reg[ %0d] = %0d", i, $signed(top_hdl.riscV.dp.rf.register_file[i]), i, $signed(reg_ref[i])), UVM_MEDIUM)


            	     
        end
        
    
    	for (int i=0; i < 32; i=i+1) begin
          if (top_hdl.riscV.dp.rf.register_file[i] != reg_ref[i]) begin
              	`uvm_error("SB error", "Data mismatch");
            	`uvm_info("Info error", $sformatf("El registro = %d no coincide", i), UVM_MEDIUM);
            	`uvm_info("Info error", $sformatf("DUT data is %d :: SB data is %d", top_hdl.riscV.dp.rf.register_file[i], reg_ref[i]), UVM_MEDIUM);
            	error_count++;
              	error_found = 1;
              	break;
            end
          end
          if (error_found == 0) begin 
            `uvm_info("SB PASS", $sformatf("DUT data is %d :: SB data is %d", $signed(top_hdl.riscV.dp.rf.register_file[rd]),$signed(reg_ref[rd])), UVM_MEDIUM);
          end
          error_found = 0;
      
    endfunction

	virtual task run_phase (uvm_phase phase);
		
	endtask

endclass
`endif //