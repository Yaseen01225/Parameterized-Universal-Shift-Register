`timescale 1ns/1ps
// Project: Parameterized Universal Shift Register
// File: usr_hold.v
// Developer: Ghulam Yaseen Nangraj
// Date: October 22, 2026
// Purpose: Combinational hold datapath.

module usr_hold #(parameter WIDTH = 8) (
    input  wire [WIDTH-1:0] q,
    output wire [WIDTH-1:0] hold_data
);
    assign hold_data = q;
endmodule
