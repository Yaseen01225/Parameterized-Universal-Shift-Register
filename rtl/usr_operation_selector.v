`timescale 1ns/1ps
// Project: Parameterized Universal Shift Register
// File: usr_operation_selector.v
// Developer: Ghulam Yaseen Nangraj
// Date: October 22, 2026
// Purpose: Selects the next-state candidate based on sel.
// sel=00 hold, 01 shift right, 10 shift left, 11 parallel load.

module usr_operation_selector #(parameter WIDTH = 8) (
    input  wire [1:0]        sel,
    input  wire [WIDTH-1:0]  hold_data,
    input  wire [WIDTH-1:0]  shift_right_data,
    input  wire [WIDTH-1:0]  shift_left_data,
    input  wire [WIDTH-1:0]  parallel_load_data,
    output reg  [WIDTH-1:0]  next_data
);
    always @(*) begin
        case (sel)
            2'b00: next_data = hold_data;
            2'b01: next_data = shift_right_data;
            2'b10: next_data = shift_left_data;
            2'b11: next_data = parallel_load_data;
            default: next_data = {WIDTH{1'b0}};
        endcase
    end
endmodule
