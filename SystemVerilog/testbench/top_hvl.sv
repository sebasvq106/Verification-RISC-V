`include "uvm.sv"
import uvm_pkg::*;

module top_hvl();

initial begin 
  run_test();	
  #1010;       		      
  $finish;
end
  
endmodule