interface intf_cnt(input tb_clk);
  
  logic reset;
  logic [31:0] tb_WB_Data;
  logic [31:0] instruction_queue;
  logic [31:0] reg_file_monitor[31:0];

endinterface
