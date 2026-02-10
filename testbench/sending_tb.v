`timescale 1ns / 1ps

module sending_tb;

    reg clk = 0;
    reg reset_n;
    reg [127:0] cipher_data;
    reg cipher_valid;

    wire uart_tx;
    wire can_accept;

    // Clock 27MHz
    always #18.5 clk = ~clk;  // 37ns period

    sending dut (
        .clk         (clk),
        .reset_n     (reset_n),
        .cipher_data (cipher_data),
        .cipher_valid(cipher_valid),
        .uart_tx     (uart_tx),
        .can_accept  (can_accept)
    );

    initial begin
        $dumpfile("sending_tb.vcd");
        $dumpvars(0, sending_tb);

        // Reset
        reset_n      = 0;
        cipher_valid = 0;
        cipher_data  = 0;
        #200;
        reset_n = 1;
        #200;

        // Test 1: Single packet
        $display("=== Test 1: Single packet ===");
        cipher_data  = 128'h0123456789ABCDEF_FEDCBA9876543210;
        cipher_valid = 1;
        #37;
        cipher_valid = 0;

        #1000;  // Chờ gửi xong

        // Test 2: Two packets back-to-back
        $display("=== Test 2: Two packets ===");
        cipher_data  = 128'hAAAAAAAAAAAAAAAA_AAAAAAAAAAAAAAAA;
        cipher_valid = 1;
        #37;
        cipher_valid = 0;

        #1000;

        cipher_data  = 128'hBBBBBBBBBBBBBBBB_BBBBBBBBBBBBBBBB;
        cipher_valid = 1;
        #37;
        cipher_valid = 0;

        #2000000000;

        $display("=== Test complete ===");
        $finish;
    end

    // Monitor
    always @(posedge clk) begin
        if (cipher_valid) $display("Time=%0t: AES send packet, can_accept=%b", $time, can_accept);
        if (dut.write_enable)
            $display("Time=%0t: Converter write byte 0x%02h to FIFO", $time, dut.converter_out);
        if (dut.tx_start) $display("Time=%0t: UART TX start, data=0x%02h", $time, dut.tx_data_reg);
    end

endmodule
