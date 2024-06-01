class driver;
  
  // Instanciacion de Stimulus
  stimulus sti;
  
  // Instanciacion del scoreboard
  scoreboard sb;
  
  
  // Instanciacion de la interface
  virtual intf_cnt intf;
  
  
  	// Constructor del driver
	function new(virtual intf_cnt intf, scoreboard sb);
    	this.intf = intf;
    	this.sb = sb;
    endfunction
  
  
    // Generador de contenido de registros
	task register();
    begin
  		sti = new();
    	$display("Executing Register\n");
      	tb_top.riscV.dp.instr_mem.Inst_mem[0] = 32'h00007033;
      	sb.instruction_queue.push_front(32'h00007033);
      	for (int i = 1; i < 7; i = i + 1) begin
      		if(sti.randomize())
        	tb_top.riscV.dp.instr_mem.Inst_mem[i] = sti.rand_register;
      		sb.instruction_queue.push_front(sti.rand_register);
    	end
    end
	endtask
    
  
  	// Generador de instrucciones    
	task instruction();
    begin
    	sti = new();
    	$display("Executing Instruction\n");
      	for (int i = 7; i < 50; i = i + 1) begin
    		if(sti.randomize())
        	tb_top.riscV.dp.instr_mem.Inst_mem[i] = sti.rand_instruction;
      		sb.instruction_queue.push_front(sti.rand_instruction); 

	   	end
  	end
    endtask
  
endclass 