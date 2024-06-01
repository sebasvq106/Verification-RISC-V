// Conexion con el riscV
`timescale 1ns / 1ps

module tb_top;
  
  //clock and reset signal declaration
  reg tb_clk = 0;
  
  always #10 tb_clk = ~tb_clk;
  
  //Interface
  intf_cnt intf(tb_clk);

  //reset Generation
  initial begin
    tb_clk = 0;
    intf.reset = 1;
    #25 intf.reset =0;  
    $display("Simulation starts!");
    $dumpfile("tianrenz.vcd");
    $dumpvars();
	
  end
  
  // Instancia del RiscV
  riscv riscV(
    .clk(intf.tb_clk),
    .reset(intf.reset),
    .WB_Data(intf.tb_WB_Data)      
   );
  
 	//Test case
	testcase test(intf);

endmodule