module width_converter_tb;

    reg clk = 0;
    reg reset_n;
    reg [127:0] in;
    reg valid_in;
    reg fifo_full;
    wire [7:0] out;
    wire write_enable;
    wire busy;

    always #5 clk = ~clk;  // 10ns period

    width_converter_128to8 dut (
        .clk         (clk),
        .reset_n     (reset_n),
        .in          (in),
        .valid_in    (valid_in),
        .fifo_full   (fifo_full),
        .out         (out),
        .write_enable(write_enable),
        .busy        (busy)
    );

    initial begin
        $dumpfile("width_converter_tb.vcd");
        $dumpvars(0, width_converter_tb);

        // Reset
        reset_n   = 0;
        valid_in  = 0;
        fifo_full = 0;
        in        = 0;
        #20;
        reset_n = 1;
        #10;

        // Test 1: Gửi 1 packet
        in       = 128'h0123456789ABCDEF_FEDCBA9876543210;
        valid_in = 1;
        #10;
        valid_in = 0;

        // Chờ 16 cycles ghi xong
        #200;

        // Test 2: FIFO full giữa chừng
        in       = 128'hAAAAAAAAAAAAAAAA_BBBBBBBBBBBBBBBB;
        valid_in = 1;
        #10;
        valid_in = 0;

        #50;  // Sau 5 bytes
        fifo_full = 1;  // FIFO đầy
        #40;  // Chờ 4 cycles
        fifo_full = 0;  // FIFO rảnh

        #200;

        $finish;
    end

    // Monitor
    always @(posedge clk) begin
        if (write_enable) begin
            $display("Time=%0t: Write byte[%0d] = 0x%02h", $time, dut.counter, out);
        end
    end

endmodule
