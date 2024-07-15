`timescale 1ns / 1ps

module adder_32
    #(parameter WIDTH = 32)
    (input logic [32-1:0] a, b,
     output logic [32-1:0] y);


assign y = a + b;

endmodule
