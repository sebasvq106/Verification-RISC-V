`timescale 1ns / 1ps

module datamemory#(
    parameter DM_ADDRESS = 32 ,
    parameter DATA_W = 32
    )(
    input logic clk,
    input logic rst,
	input logic MemRead , // comes from control unit
    input logic MemWrite , // Comes from control unit
    input logic [ 32:0] a , // Read / Write address - 9 LSB bits of the ALU output
    input logic [ 32 -1:0] wd , // Write Data
    output logic [ 32 -1:0] rd // Read Data
    );
    
    logic [32-1:0] mem[4197:0];
    
  /*  always @(negedge clk) begin
        if(rst==1'b1)
        for (int i = 0; i < 4195; i = i + 1)
          mem[i] <= 32'hAAAAAAAA;
    end*/
    
    always_comb 
    begin
       if(MemRead)
            rd = mem[a];
	end
    
    always @(posedge clk) begin
       if (MemWrite)
            mem[a] = wd;
    end
    
endmodule

