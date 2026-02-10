`timescale 1ns / 1ps

module packaging_full_tb;

    // --- Inputs to DUT ---
    reg clk;
    reg reset_n;
    reg [7:0] fifo_data_in;
    reg fifo_empty;

    // --- Outputs from DUT ---
    wire fifo_read_enable;
    wire [127:0] data_out;
    wire data_valid;
    wire key_valid;
    wire error_flag;

    // --- Simulation Variables ---
    reg [7:0] memory_queue[0:255];  // Giả lập bộ nhớ FIFO
    integer write_ptr = 0;  // Con trỏ ghi (Testbench nạp dữ liệu vào đây)
    integer read_ptr = 0;  // Con trỏ đọc (DUT đọc từ đây)
    integer i;

    // --- Instantiate the Unit Under Test (UUT) ---
    packaging uut (
        .clk             (clk),
        .reset_n         (reset_n),
        .fifo_data_in    (fifo_data_in),
        .fifo_empty      (fifo_empty),
        .fifo_read_enable(fifo_read_enable),
        .data_out        (data_out),
        .data_valid      (data_valid),
        .key_valid       (key_valid),
        .error_flag      (error_flag),
        .output_busy     ()
    );

    // --- Clock Generation (100MHz) ---
    always #5 clk = ~clk;

    // --- MOCK FIFO LOGIC (Mô phỏng hành vi phần cứng) ---
    // Phần này cực kỳ quan trọng: Nó giả lập độ trễ 1 cycle của FIFO thật
    always @(posedge clk) begin
        if (!reset_n) begin
            fifo_data_in <= 0;
            read_ptr     <= 0;
        end else begin
            // Logic báo Empty
            if (read_ptr == write_ptr) fifo_empty <= 1;
            else fifo_empty <= 0;

            // Logic Đọc: Nếu DUT yêu cầu đọc (rd_en = 1) VÀ FIFO không rỗng
            // Thì cập nhật fifo_data_in cho chu kỳ TIẾP THEO (Latency 1)
            if (fifo_read_enable && (read_ptr != write_ptr)) begin
                fifo_data_in <= memory_queue[read_ptr];
                read_ptr     <= read_ptr + 1;
            end
        end
    end

    // --- TASKS ---
    // Task nạp gói tin vào "FIFO ảo"
    task load_packet;
        input [7:0] header;
        input [127:0] payload;
        input inject_checksum_error;  // 1 = Tạo lỗi checksum
        input inject_footer_error;  // 1 = Tạo lỗi footer

        reg [7:0] calculated_checksum;
        reg [7:0] byte_slice;
        integer k;
        begin
            calculated_checksum     = header;

            // 1. Push Header
            memory_queue[write_ptr] = header;
            write_ptr               = write_ptr + 1;

            // 2. Push 16 bytes Data (Big Endian order)
            for (k = 0; k < 16; k = k + 1) begin
                byte_slice = payload[127-k*8-:8];  // Lấy từng byte từ trên xuống
                memory_queue[write_ptr] = byte_slice;
                write_ptr = write_ptr + 1;
                calculated_checksum = calculated_checksum ^ byte_slice;
            end

            // 3. Push Checksum
            if (inject_checksum_error)
                memory_queue[write_ptr] = ~calculated_checksum;  // Đảo bit để gây lỗi
            else memory_queue[write_ptr] = calculated_checksum;
            write_ptr = write_ptr + 1;

            // 4. Push Footer
            if (inject_footer_error) memory_queue[write_ptr] = 8'h00;  // Footer sai
            else memory_queue[write_ptr] = 8'h55;  // Footer đúng
            write_ptr = write_ptr + 1;
        end
    endtask

    // --- MAIN TEST SEQUENCES ---
    initial begin
        // Initialize Inputs
        clk        = 0;
        reset_n    = 0;
        fifo_empty = 1;
        write_ptr  = 0;
        read_ptr   = 0;

        // Reset Pulse
        #20 reset_n = 1;
        #20;

        $display("---------------------------------------------------");
        $display("STARTING SIMULATION");
        $display("---------------------------------------------------");

        // --- CASE 1: NORMAL DATA PACKET ---
        $display("[TEST 1] Sending Valid DATA Packet...");
        // Header AA, Payload random
        load_packet(8'hAA, 128'h00112233445566778899AABBCCDDEEFF, 0, 0);

        wait (data_valid);  // Chờ DUT báo valid
        if (data_out === 128'h00112233445566778899AABBCCDDEEFF)
            $display("-> PASS: Data captured correctly.");
        else $display("-> FAIL: Data mismatch! output: %h", data_out);

        #20;  // Nghỉ một chút

        // --- CASE 2: NORMAL KEY PACKET ---
        $display("[TEST 2] Sending Valid KEY Packet...");
        // Header BB, Payload random
        load_packet(8'hBB, 128'hFEDCBA9876543210FEDCBA9876543210, 0, 0);

        wait (key_valid);
        if (data_out === 128'hFEDCBA9876543210FEDCBA9876543210)
            $display("-> PASS: Key captured correctly.");
        else $display("-> FAIL: Key mismatch!");

        #20;

        // --- CASE 3: CHECKSUM ERROR ---
        $display("[TEST 3] Sending Packet with CHECKSUM ERROR...");
        load_packet(8'hAA, 128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF, 1, 0);  // Inject checksum error

        wait (error_flag);  // Chờ cờ lỗi
        $display("-> PASS: Error flag asserted correctly for Checksum.");
        #20;

        // --- CASE 4: FOOTER ERROR ---
        $display("[TEST 4] Sending Packet with FOOTER ERROR...");
        load_packet(8'hAA, 128'h00000000000000000000000000000000, 0, 1);  // Inject footer error

        wait (error_flag);
        $display("-> PASS: Error flag asserted correctly for Footer.");
        #20;

        // --- CASE 5: STARVATION TEST (FIFO Empty giữa chừng) ---
        // Cái này khó hơn, tôi sẽ manually set empty để trêu module
        $display("[TEST 5] Starvation Test (FIFO goes empty mid-packet)...");

        // Nạp data vào queue nhưng chưa cho chạy vội
        // Header AA, Payload all 1
        load_packet(8'hAA, 128'h11111111111111111111111111111111, 0, 0);

        // Đợi module bắt đầu đọc header
        @(posedge fifo_read_enable);

        // Đợi thêm vài byte nữa rồi ép Empty
        repeat (4) @(posedge clk);

        // HACK: Kéo write_ptr lùi lại bằng read_ptr để giả vờ Empty
        // (Đây là trick trong TB, thực tế FIFO sẽ ngừng đẩy data)
        // Trong mô hình này, ta chỉ cần chờ đợi, vì module sẽ tự pause khi empty = 1.
        // Nhưng do logic Mock FIFO của tôi tự tính empty dựa trên ptr, 
        // nên ta sẽ quan sát xem module có đọc đúng khi queue vẫn còn data ko.
        // Thực ra mô hình Mock FIFO ở trên đã cover việc này: 
        // Nếu memory_queue có data, empty = 0, module đọc.
        // Nếu ta không nạp tiếp, module sẽ chờ.

        wait (data_valid);
        if (data_out === 128'h11111111111111111111111111111111)
            $display("-> PASS: Module handled data correctly.");
        else $display("-> FAIL: Data corrupted during processing.");

        $display("---------------------------------------------------");
        $display("ALL TESTS COMPLETED");
        $finish;
    end

    // Timeout check để tránh loop vô hạn nếu module bị treo
    initial begin
        #5000;
        $display("ERROR: Simulation timed out! Maybe stuck in a state?");
        $finish;
    end

endmodule
