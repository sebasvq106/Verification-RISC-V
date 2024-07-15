

module top_hdl();
  reg tb_clk = 0;
  initial // clock generator
  forever #10 tb_clk = ~tb_clk;
  
   
  // Interface
  
  // DUT connection
 	// Instancia del RiscV
  riscv riscV(
    .clk(tb_clk),
    .reset(),
    .WB_Data()      
   );
	
  
  
initial begin
  $dumpfile("dump.vcd"); 
  $dumpvars;
   
  	
end
  
endmodule
  