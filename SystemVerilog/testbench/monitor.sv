class monitor;
  
  scoreboard sb;
  virtual intf_cnt intf;

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
  logic [31:0] mem_ref [(2**32)-1:0];		// Memoria de refrencia
  logic	[31:0] Imm_out;						// Inm extendido a 31 bits
  
  
  // Constructor
  function new(virtual intf_cnt intf,scoreboard sb);
    this.intf = intf;
    this.sb = sb;
    for (int i = 0; i < 32; i = i + 1) begin
        reg_ref[i] = 32'h00000000;
    end
  endfunction
	
  
  // Checker
  task check();
    error_count = 0;
    forever
      begin
        @ (negedge intf.tb_clk) begin
          	
          	instruction = sb.instruction_queue.pop_back();	// Se obtiene la instrucción desde el scorevboard
          	opcode = instruction[6:0];
          
         	//$display(" * Opcode is %b ",opcode);
        	// $display(" * INST is %b ",instruction);
          
            // Modelo de Referencia
          
          	//R-type
          	if (opcode == 7'b0110011 )begin
                rd = instruction[11:7];
                rs1 = instruction[19:15];
                rs2 = instruction[24:20];
                funct3 = instruction[14:12];
                funct7 = instruction[31:25];
            
				
            //  $display(" * rs1 is %d :: contiene %d ",rs1, $signed(reg_ref[rs1]));
            //  $display(" * rs2 is %d :: contiene %d",rs2, $signed(reg_ref[rs2]));
            //  $display(" * rd is %d :: contiene %d",rd, $signed(reg_ref[rd]));

                //add 
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
            
                  // $display(" * rs1 is %d :: contiene %d ",rs1, $signed(reg_ref[rs1]));
              	  // $display(" * inm is  ", $signed(Imm_out));
              	  // $display(" * rd is %d :: contiene %d",rd, $signed(reg_ref[rd]));
              
                  //addi
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
          
          
          /*
          	 // LUI-type //
          else if(opcode == 7'b0110111) begin
            rd = instruction[11:7];
            reg_ref[rd] = {instruction[31:12], 12'b0}
          end
          
          */
          
          
          
          	// Load_type
          /*
          else if (opcode == 7'b0000011) begin
        		   rd = instruction[11:7];
                   rs1 = instruction[19:15];
            	   inm = instruction[31:20];
                   funct3 = instruction[14:12];
            	   Imm_out = {inm[11]? {20{1'b1}}:20'b0 , inm[11:0]};
            if(funct3 == 3'b010)begin
              reg_ref[rd] = mem_ref[reg_ref[rs1] + Imm_out];
            end
            
          end
 		*/
         
          // Verifica todos los registros
          for (int i=0; i < 32; i=i+1) begin
            if (tb_top.riscV.dp.rf.register_file[i] != reg_ref[i]) begin
              	$display(" * ----------ERROR *");
              	$display(" El registro %d no coincide", i);
                $display(" DUT data is %d :: SB data is %d ", $signed(tb_top.riscV.dp.rf.register_file[i]),$signed(reg_ref[i]));
            	error_count++;
              	error_found = 1;
              	break;
            end
          end
          if (error_found == 0) begin 
          	$display(" * PASS * DUT data is %d :: SB data is %d ", $signed(tb_top.riscV.dp.rf.register_file[rd]),$signed(reg_ref[rd]));
          end
          error_found = 0;
    	end
  	end
 endtask

endclass