`timescale 1ns / 1ps

module sub_byte_tb;

    reg          clk;
    reg          reset_n;
    reg          start;
    reg  [127:0] in;
    wire [127:0] out;
    wire         valid;

    sub_byte dut (
        .clk    (clk),
        .reset_n(reset_n),
        .start  (start),
        .in     (in),
        .out    (out),
        .valid  (valid)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // Initialize
        reset_n = 0;
        start   = 0;
        in      = 128'h0;

        #20;
        reset_n = 1;
        #10;

        // ===== Test 1: Standard AES Test Vector =====
        $display("=== Test 1: AES SubBytes ===");
        in    = 128'h40BFABF406EE4D3042CA6B997A5C5816;
        start = 1;
        #10;
        start = 0;

        wait (valid == 1'b1);
        #1;

        $display("INPUT : %h", in);
        $display("OUTPUT: %h", out);
        $display("EXPECT: 638293C31BFC33F5C4EEACEA4BC12816");

        if (out == 128'h090862BF6F28E3042C747FEEDA4A6A47) begin
            $display("Test 1 PASSED!\n");
        end else begin
            $display("Test 1 FAILED!");
            $display("  First 4 bytes: %h (expect 090862bf)\n", out[127:96]);
        end

        wait (valid == 1'b0);
        #20;

        // ===== Test 2: All Zeros =====
        $display("=== Test 2: All Zeros ===");
        in    = 128'h0;
        start = 1;
        #10;
        start = 0;

        wait (valid == 1'b1);
        #1;

        $display("INPUT : %h", in);
        $display("OUTPUT: %h", out);
        $display("EXPECT: 63636363636363636363636363636363");

        if (out == 128'h63636363636363636363636363636363) begin
            $display("Test 2 PASSED!\n");
        end else begin
            $display("Test 2 FAILED!\n");
        end

        #50;
        $finish;
    end

    // Timeout protection
    initial begin
        #5000;
        $display("ERROR: Timeout!");
        $finish;
    end

endmodule
