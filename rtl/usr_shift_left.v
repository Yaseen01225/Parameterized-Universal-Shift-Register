`timescale 1ns/1ps
// Project: Parameterized Universal Shift Register
// File: usr_shift_left.v
// Developer: Ghulam Yaseen Nangraj
// Date: October 22, 2026
// Purpose: Combinational logical shift-left datapath with serial insertion at LSB.

module usr_shift_left #(parameter WIDTH = 8) (
    input  wire [WIDTH-1:0] q,
    input  wire             serial_in_left,
    output wire [WIDTH-1:0] shift_left_data
);
    generate
        if (WIDTH == 1) begin : gen_width_one
            assign shift_left_data = serial_in_left;
        end else begin : gen_width_many
            assign shift_left_data = {q[WIDTH-2:0], serial_in_left};
        end
    endgenerate
endmodule
