`timescale 1ns/1ps
// Project: Parameterized Universal Shift Register
// File: usr_register_storage.v
// Developer: Ghulam Yaseen Nangraj
// Date: October 22, 2026
// Purpose: Clocked register storage with synchronous active-high reset and enable.

module usr_register_storage #(parameter WIDTH = 8) (
    input  wire             clk,
    input  wire             rst,
    input  wire             enable,
    input  wire [WIDTH-1:0] next_data,
    output reg  [WIDTH-1:0] q
);
    always @(posedge clk) begin
        if (rst)
            q <= {WIDTH{1'b0}};
        else if (enable)
            q <= next_data;
    end
endmodule
