`timescale 1ns/1ps
// Project: Parameterized Universal Shift Register (1-128 bits)
// File: parameterized_universal_shift_register.v
// Developer: Ghulam Yaseen Nangraj
// Date: October 22, 2026
// HDL: Verilog-2001
// Purpose: Integrates hold, shift, parallel-load, selection, and storage modules.

module parameterized_universal_shift_register #(parameter WIDTH = 8) (
    input  wire             clk,
    input  wire             rst,
    input  wire             enable,
    input  wire [1:0]       sel,
    input  wire [WIDTH-1:0] parallel_in,
    input  wire             serial_in_left,
    input  wire             serial_in_right,
    output wire [WIDTH-1:0] q,
    output wire             serial_out_left,
    output wire             serial_out_right
);
    wire [WIDTH-1:0] hold_data;
    wire [WIDTH-1:0] shift_right_data;
    wire [WIDTH-1:0] shift_left_data;
    wire [WIDTH-1:0] parallel_load_data;
    wire [WIDTH-1:0] next_data;

    // Candidate next-state datapaths.
    usr_hold #(WIDTH) u_hold (
        .q(q), .hold_data(hold_data)
    );

    usr_shift_right #(WIDTH) u_shift_right (
        .q(q),
        .serial_in_right(serial_in_right),
        .shift_right_data(shift_right_data)
    );

    usr_shift_left #(WIDTH) u_shift_left (
        .q(q),
        .serial_in_left(serial_in_left),
        .shift_left_data(shift_left_data)
    );

    usr_parallel_load #(WIDTH) u_parallel_load (
        .parallel_in(parallel_in),
        .parallel_load_data(parallel_load_data)
    );

    usr_operation_selector #(WIDTH) u_operation_selector (
        .sel(sel),
        .hold_data(hold_data),
        .shift_right_data(shift_right_data),
        .shift_left_data(shift_left_data),
        .parallel_load_data(parallel_load_data),
        .next_data(next_data)
    );

    usr_register_storage #(WIDTH) u_register_storage (
        .clk(clk), .rst(rst), .enable(enable),
        .next_data(next_data), .q(q)
    );

    // Serial observations continuously reflect the current register state.
    assign serial_out_left  = q[WIDTH-1];
    assign serial_out_right = q[0];

    // WIDTH is intended to be 1..128; enforce this in your build/verification flow.
endmodule
