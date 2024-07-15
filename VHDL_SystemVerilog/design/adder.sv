`timescale 1ns / 1ps

module adder
    #(parameter WIDTH = 8)
    (input logic [8-1:0] a, b,
     output logic [8-1:0] y);


assign y = a + b;

endmodule
