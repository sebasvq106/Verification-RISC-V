`ifndef ASSERTIONS_SV
`define ASSERTIONS_SV
`define DUV top_hdl

module whitebox();
  
  // PC
  property check_PC_plus_4;
    @(posedge `DUV.tb_clk)
    disable iff (`DUV.intf.reset)
    `DUV.riscV.dp.PC == 0 |-> ##1 (`DUV.riscV.dp.PC == $past(`DUV.riscV.dp.PC) + 4);
  endproperty
  
  // Tipo R
   property check_R_type_controller;
    @(posedge `DUV.tb_clk)
    disable iff (`DUV.intf.reset)
     (`DUV.riscV.opcode == 7'b0110011) |-> 
     (`DUV.riscV.c.RegWrite == 1 && `DUV.riscV.c.ALUOp[1] == 1);
  endproperty
 
  // Tipo I
   property check_I_type_controller;
    @(posedge `DUV.tb_clk)
    disable iff (`DUV.intf.reset)
    (`DUV.riscV.opcode == 7'b0010011) |-> 
    (`DUV.riscV.c.ALUSrc == 1 && `DUV.riscV.c.RegWrite == 1 && `DUV.riscV.c.OpI == 1);
  endproperty
  
  // Tipo Load
  property check_load_controller;
    @(posedge `DUV.tb_clk)
    disable iff (`DUV.intf.reset)
    (`DUV.riscV.opcode == 7'b0000011) |-> 
    (`DUV.riscV.c.ALUSrc == 1 && `DUV.riscV.c.MemtoReg == 1 && `DUV.riscV.c.Mem == 1 && `DUV.riscV.c.MemRead == 1);
  endproperty
  
  // Tipo Sotre
  property check_store_controller;
    @(posedge `DUV.tb_clk)
    disable iff (`DUV.intf.reset)
    (`DUV.riscV.opcode == 7'b0100011) |-> 
    (`DUV.riscV.c.ALUSrc == 1 && `DUV.riscV.c.RegtoMem == 1 && `DUV.riscV.c.Mem == 1 && `DUV.riscV.c.MemWrite == 1);
  endproperty
  // Tipo Lui
  property check_Lui_controller;
    @(posedge `DUV.tb_clk)
    disable iff (`DUV.intf.reset)
    (`DUV.riscV.opcode == 7'b0110111) |-> 
    (`DUV.riscV.c.RegWrite == 1 && `DUV.riscV.c.Con_LUI == 1);
  endproperty
  
	
  // Reset

  property check_registers_after_reset;
       @(posedge `DUV.tb_clk)
    (`DUV.riscV.reset == 1) |-> 
   	( 	`DUV.riscV.dp.rf.register_file[0] == 0 &&
        `DUV.riscV.dp.rf.register_file[1] == 0 &&
        `DUV.riscV.dp.rf.register_file[2] == 0 &&
        `DUV.riscV.dp.rf.register_file[3] == 0 &&
        `DUV.riscV.dp.rf.register_file[4] == 0 &&
        `DUV.riscV.dp.rf.register_file[5] == 0 &&
        `DUV.riscV.dp.rf.register_file[6] == 0 &&
        `DUV.riscV.dp.rf.register_file[7] == 0 &&
        `DUV.riscV.dp.rf.register_file[8] == 0 &&
        `DUV.riscV.dp.rf.register_file[9] == 0 &&
        `DUV.riscV.dp.rf.register_file[10] == 0 &&
        `DUV.riscV.dp.rf.register_file[11] == 0 &&
        `DUV.riscV.dp.rf.register_file[12] == 0 &&
        `DUV.riscV.dp.rf.register_file[13] == 0 &&
        `DUV.riscV.dp.rf.register_file[14] == 0 &&
        `DUV.riscV.dp.rf.register_file[15] == 0 &&
        `DUV.riscV.dp.rf.register_file[16] == 0 &&
        `DUV.riscV.dp.rf.register_file[17] == 0 &&
        `DUV.riscV.dp.rf.register_file[18] == 0 &&
        `DUV.riscV.dp.rf.register_file[19] == 0 &&
        `DUV.riscV.dp.rf.register_file[20] == 0 &&
        `DUV.riscV.dp.rf.register_file[21] == 0 &&
        `DUV.riscV.dp.rf.register_file[22] == 0 &&
        `DUV.riscV.dp.rf.register_file[23] == 0 &&
        `DUV.riscV.dp.rf.register_file[24] == 0 &&
        `DUV.riscV.dp.rf.register_file[25] == 0 &&
        `DUV.riscV.dp.rf.register_file[26] == 0 &&
        `DUV.riscV.dp.rf.register_file[27] == 0 &&
        `DUV.riscV.dp.rf.register_file[28] == 0 &&
        `DUV.riscV.dp.rf.register_file[29] == 0 &&
        `DUV.riscV.dp.rf.register_file[30] == 0 &&
        `DUV.riscV.dp.rf.register_file[31] == 0 );

  endproperty

  
  /////////////////////////////////////////////////////////////////////////////////////////
   // PC
  assert_check_PC_plus_4: assert property (check_PC_plus_4)
    else begin
      $display("Error: EL PC no suma 4 despues de un ciclo");
      $fatal(1,"Error fatal: EL PC no suma 4 despues de un ciclo");
    end
    
  // Tipo R
  assert_check_R_type_controller: assert property (check_R_type_controller)
    else begin
      $display("Error: No se cumplieron las señales necesarias para el R Type");
      $display("Valores de señales en el fallo:");
      $display("RegWrite: %d", `DUV.riscV.c.RegWrite);
      $display("ALUOp[1]: %d", `DUV.riscV.c.ALUOp[1]);
      $fatal(1,"Error fatal: No se cumplieron las señales necesarias para el R Type");
    end
     // Tipo I
    assert_check_I_type_controller: assert property (check_I_type_controller)
    else begin
      $display("Error: No se cumplieron las señales necesarias para el I Type");
      $display("Valores de señales en el fallo:");
      $display("ALUSrc: %d", `DUV.riscV.c.ALUSrc);
      $display("RegWrite: %d", `DUV.riscV.c.RegWrite);
      $display("OpI: %d", `DUV.riscV.c.OpI);
      $fatal(1,"Error fatal: No se cumplieron las señales necesarias para el I Type");
    end
  // Tipo Load   
  assert_check_load_controller: assert property (check_load_controller)
    else begin
      $display("Error: No se cumplieron las señales necesarias para el Load");
      $display("Valores de señales en el fallo:");
      $display("ALUSrc: %d", `DUV.riscV.c.ALUSrc);
      $display("MemtoReg: %d", `DUV.riscV.c.MemtoReg);
      $display("Mem: %d", `DUV.riscV.c.Mem);
      $display("MemRead: %d", `DUV.riscV.c.MemRead);
      $fatal(1,"Error fatal: No se cumplieron las señales necesarias para el Load");
    end
   // Tipo Store
    assert_check_store_controller: assert property (check_store_controller)
    else begin
      $display("Error: No se cumplieron las señales necesarias para el Store");
      $display("Valores de señales en el fallo:");
      $display("ALUSrc: %d", `DUV.riscV.c.ALUSrc);
      $display("RegtoMem: %d", `DUV.riscV.c.RegtoMem);
      $display("Mem: %d", `DUV.riscV.c.Mem);
      $display("MemWrite: %d", `DUV.riscV.c.MemWrite);
      $fatal(1,"Error fatal: No se cumplieron las señales necesarias para el Store");
    end
    // Tipo Lui
      assert_check_Lui_controller: assert property (check_Lui_controller)
    else begin
      $display("Error: No se cumplieron las señales necesarias para el Lui");
      $display("Valores de señales en el fallo:");
      $display("RegWrite: %d", `DUV.riscV.c.RegWrite);
      $display("Con_LUI: %d", `DUV.riscV.c.Con_LUI);
      $fatal(1,"Error fatal: No se cumplieron las señales necesarias para el Lui");
    end
	
    // Reset
        
     assert_check_registers_after_reset: assert property (check_registers_after_reset)
    else begin
      $display("Error: Los registros no son 0 despues de un reset");
      $fatal(1,"Error: Los registros no son 0 despues de un reset");
    end
endmodule
`endif // 