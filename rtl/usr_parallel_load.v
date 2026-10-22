`timescale 1ns/1ps
// Project: Parameterized Universal Shift Register
// File: usr_parallel_load.v
// Developer: Ghulam Yaseen Nangraj
// Date: October 22, 2026
// Purpose: Combinational parallel-load datapath.

module usr_parallel_load #(parameter WIDTH = 8) (
    input  wire [WIDTH-1:0] parallel_in,
    output wire [WIDTH-1:0] parallel_load_data
);
    assign parallel_load_data = parallel_in;
endmodule
