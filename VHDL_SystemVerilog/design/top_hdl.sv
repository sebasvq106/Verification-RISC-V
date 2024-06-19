`include "/home/sebasvq/Escritorio/Verificacion/Verification-RISC-V/VHDL_SystemVerilog/testbench/tesbench.sv"
`include "/home/sebasvq/Escritorio/Verificacion/Verification-RISC-V/VHDL_SystemVerilog/design/RISC_V.sv"

import uvm_pkg::*;

module top_hdl();

  reg tb_clk = 0;
  initial // clock generator
  forever #10 tb_clk = ~tb_clk;
  
   
  // Interface
  intf_cnt intf(tb_clk);
  
  // DUT connection
 	// Instancia del RiscV
  riscv riscV(
    .clk(tb_clk),
    .reset(intf.reset),
    .WB_Data(intf.tb_WB_Data)      
   );
	
 assign intf.reg_file_monitor = riscV.dp.rf.register_file;
  
  
initial begin
  $dumpfile("dump.vcd"); 
  $dumpvars;
   
  uvm_config_db #(virtual intf_cnt)::set (null, "uvm_test_top", "VIRTUAL_INTERFACE", intf);
  	
end
  
endmodule