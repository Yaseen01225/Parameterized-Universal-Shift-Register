`timescale 1ns/1ps
// Project: Parameterized Universal Shift Register
// File: usr_shift_right.v
// Developer: Ghulam Yaseen Nangraj
// Date: October 22, 2026
// Purpose: Combinational logical shift-right datapath with serial insertion at MSB.

module usr_shift_right #(parameter WIDTH = 8) (
    input  wire [WIDTH-1:0] q,
    input  wire             serial_in_right,
    output wire [WIDTH-1:0] shift_right_data
);
    generate
        if (WIDTH == 1) begin : gen_width_one
            assign shift_right_data = serial_in_right;
        end else begin : gen_width_many
            assign shift_right_data = {serial_in_right, q[WIDTH-1:1]};
        end
    endgenerate
endmodule
