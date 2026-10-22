`timescale 1ns/1ps
// Project: Parameterized Universal Shift Register
// File: tb_parameterized_universal_shift_register.v
// Developer: Ghulam Yaseen Nangraj
// Date: October 22, 2026
// Purpose: Self-checking testbench for the default 8-bit configuration.

module tb_parameterized_universal_shift_register;
    localparam WIDTH = 8;

    reg clk;
    reg rst;
    reg enable;
    reg [1:0] sel;
    reg [WIDTH-1:0] parallel_in;
    reg serial_in_left;
    reg serial_in_right;

    wire [WIDTH-1:0] q;
    wire serial_out_left;
    wire serial_out_right;

    integer errors;

    parameterized_universal_shift_register #(.WIDTH(WIDTH)) dut (
        .clk(clk), .rst(rst), .enable(enable), .sel(sel),
        .parallel_in(parallel_in),
        .serial_in_left(serial_in_left),
        .serial_in_right(serial_in_right),
        .q(q), .serial_out_left(serial_out_left),
        .serial_out_right(serial_out_right)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    task check_q;
        input [WIDTH-1:0] expected;
        input [8*48-1:0] test_name;
        begin
            if (q !== expected) begin
                $display("FAIL: %0s expected=%b actual=%b at %0t", test_name, expected, q, $time);
                errors = errors + 1;
            end else begin
                $display("PASS: %0s q=%b at %0t", test_name, q, $time);
            end
        end
    endtask

    task tick;
        begin
            @(posedge clk);
            #1;
        end
    endtask

    initial begin
        errors = 0;
        rst = 1'b0;
        enable = 1'b0;
        sel = 2'b00;
        parallel_in = {WIDTH{1'b0}};
        serial_in_left = 1'b0;
        serial_in_right = 1'b0;

        // Synchronous reset clears q at the next rising edge.
        rst = 1'b1;
        enable = 1'b1;
        tick;
        check_q(8'b00000000, "synchronous reset");
        rst = 1'b0;

        // Parallel load.
        parallel_in = 8'b10110010;
        sel = 2'b11;
        enable = 1'b1;
        tick;
        check_q(8'b10110010, "parallel load");

        // Hold current value.
        sel = 2'b00;
        tick;
        check_q(8'b10110010, "hold operation");

        // Shift right; serial input enters the MSB.
        sel = 2'b01;
        serial_in_right = 1'b0;
        tick;
        check_q(8'b01011001, "shift right with serial zero");

        // Reload before testing shift left.
        sel = 2'b11;
        parallel_in = 8'b10110010;
        tick;
        check_q(8'b10110010, "reload before shift left");

        // Shift left; serial input enters the LSB.
        sel = 2'b10;
        serial_in_left = 1'b1;
        tick;
        check_q(8'b01100101, "shift left with serial one");

        // Disabled register must hold regardless of selected mode.
        enable = 1'b0;
        sel = 2'b11;
        parallel_in = 8'b11111111;
        tick;
        check_q(8'b01100101, "enable low holds state");

        // Reset takes priority over enable.
        rst = 1'b1;
        enable = 1'b1;
        tick;
        check_q(8'b00000000, "reset priority over enable");

        if (errors == 0)
            $display("ALL TESTS PASSED.");
        else
            $display("TESTBENCH FAILED: %0d error(s).", errors);

        $finish;
    end
endmodule
