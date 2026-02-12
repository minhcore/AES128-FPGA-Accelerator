`timescale 1ns / 1ps

module top_tb ();

    // Clock và reset
    reg  clk;
    reg  reset_n;

    // UART signals
    reg  uart_rx;
    wire uart_tx;

    // Tham số UART (27MHz, baudrate 115200)
    localparam CLK_FREQ = 27_000_000;
    localparam BAUD_RATE = 115200;
    localparam BIT_PERIOD = CLK_FREQ / BAUD_RATE;  // ~234 clock cycles per bit

    // Định nghĩa protocol
    localparam KEY_HEADER = 8'hBB;
    localparam DATA_HEADER = 8'hAA;
    localparam FOOTER = 8'h55;

    // Instantiate DUT
    top dut (
        .uart_rx(uart_rx),
        .clk    (clk),
        .reset_n(reset_n),
        .uart_tx(uart_tx)
    );

    // Clock generation - 27MHz (~37.04ns period)
    initial begin
        clk = 0;
        forever #18.52 clk = ~clk;  // 37.04ns / 2 = 18.52ns
    end

    // Task: Gửi 1 byte qua UART
    task send_uart_byte;
        input [7:0] data;
        integer i;
        begin
            // Start bit
            uart_rx = 0;
            #(BIT_PERIOD * 37.04);  // 234 clocks * 37.04ns

            // Data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                uart_rx = data[i];
                #(BIT_PERIOD * 37.04);
            end

            // Stop bit
            uart_rx = 1;
            #(BIT_PERIOD * 37.04);
        end
    endtask

    // Task: Tính checksum (XOR)
    function [7:0] calc_checksum;
        input [7:0] header;
        input [127:0] data;
        integer i;
        begin
            calc_checksum = header;
            for (i = 0; i < 16; i = i + 1) begin
                calc_checksum = calc_checksum ^ data[i*8+:8];
            end
        end
    endfunction

    // Task: Gửi 1 packet (Header + 16 bytes data + Checksum + Footer)
    task send_packet;
        input [7:0] header;
        input [127:0] data;
        reg [7:0] checksum;
        integer i;
        begin
            $display("[TB %0t] Sending packet with header 0x%02X", $time, header);

            // Tính checksum
            checksum = calc_checksum(header, data);

            // Gửi Header
            send_uart_byte(header);

            // Gửi 16 bytes data (từ byte thấp đến cao)
            for (i = 0; i < 16; i = i + 1) begin
                send_uart_byte(data[i*8+:8]);
                $display("[TB %0t]   Data[%0d] = 0x%02X ('%c')", $time, i, data[i*8+:8],
                         data[i*8+:8]);
            end

            // Gửi Checksum
            send_uart_byte(checksum);
            $display("[TB %0t]   Checksum = 0x%02X", $time, checksum);

            // Gửi Footer
            send_uart_byte(FOOTER);
            $display("[TB %0t]   Footer = 0x%02X", $time, FOOTER);

            $display("[TB %0t] Packet sent complete!\n", $time);
        end
    endtask

    // Test stimulus
    initial begin
        // Dump waveform
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);

        // Initial values
        uart_rx = 1;  // UART idle state
        reset_n = 0;

        $display("========================================");
        $display("  AES UART Communication Testbench");
        $display("  Clock: 27MHz, Baudrate: 115200");
        $display("  Bit Period: %0d clocks", BIT_PERIOD);
        $display("========================================\n");

        // Reset
        #200;
        reset_n = 1;
        #200;
        $display("[TB %0t] Reset released\n", $time);

        // Đợi hệ thống ổn định
        #2000;

        // ======================================
        // BƯỚC 1: Gửi KEY
        // ======================================
        $display("[TB %0t] ========== STEP 1: SEND KEY ==========", $time);
        $display("[TB %0t] Key = '0123456789ABCDEF' (ASCII)\n", $time);
        // Key = "0123456789ABCDEF" (ASCII)
        // Byte order: '0'=0x30, '1'=0x31, ..., 'F'=0x46
        send_packet(KEY_HEADER, 128'h46454443_42413938_37363534_33323130);

        // Đợi xử lý
        #100000;

        // ======================================
        // BƯỚC 2: Gửi DATA
        // ======================================
        $display("[TB %0t] ========== STEP 2: SEND DATA ==========", $time);
        $display("[TB %0t] Data = 'HELLO WORLD, AES' (ASCII)\n", $time);
        // Data = "HELLO WORLD, AES" (ASCII)
        // 'H'=0x48, 'E'=0x45, 'L'=0x4C, 'O'=0x4F, ' '=0x20, 'W'=0x57, 
        // ','=0x2C, 'A'=0x41, 'S'=0x53
        send_packet(DATA_HEADER, 128'h53454120_2C444C52_4F57204F_4C4C4548);

        // Đợi AES encrypt + gửi cipher về
        #3000000;

        $display("\n[TB %0t] ========== SIMULATION COMPLETE ==========", $time);

        #200000;
        $finish;
    end

    // Monitor UART TX output
    reg [7:0] rx_byte;
    integer bit_count;
    integer byte_count;

    initial begin
        byte_count = 0;
        forever begin
            @(negedge uart_tx);  // Detect start bit
            if (uart_tx == 0) begin
                #(BIT_PERIOD * 37.04 * 1.5);  // Sample tại giữa bit

                // Đọc 8 data bits
                for (bit_count = 0; bit_count < 8; bit_count = bit_count + 1) begin
                    rx_byte[bit_count] = uart_tx;
                    #(BIT_PERIOD * 37.04);
                end

                $display("[TB %0t] UART TX byte[%0d] = 0x%02X", $time, byte_count, rx_byte);
                byte_count = byte_count + 1;
            end
        end
    end

    // Timeout watchdog
    initial begin
        #20_000_000;  // 20ms timeout
        $display("\n[ERROR] Simulation timeout!");
        $finish;
    end

endmodule
