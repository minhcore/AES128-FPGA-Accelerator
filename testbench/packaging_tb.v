`timescale 1ns / 1ps

module packaging_tb;

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

  // --- Internal Test Variables ---
  reg [7:0] test_data[0:19];  // Mảng chứa đúng 1 gói tin (19 byte)
  integer read_ptr = 0;

  // --- Instantiate DUT ---
  packaging uut (
      .clk(clk),
      .reset_n(reset_n),
      .fifo_data_in(fifo_data_in),
      .fifo_empty(fifo_empty),
      .fifo_read_enable(fifo_read_enable),
      .data_out(data_out),
      .data_valid(data_valid),
      .key_valid(key_valid),
      .error_flag(error_flag)
  );

  // --- Clock Generation ---
  always #5 clk = ~clk;  // 100MHz

  // --- SIMPLIFIED FIFO MODEL (Latency = 1) ---
  // Đây là mấu chốt: FIFO thật luôn có độ trễ.
  // Nếu cậu đọc sai ở đây, waveform sẽ hiện ra ngay lập tức.
  always @(posedge clk) begin
    if (!reset_n) begin
      fifo_data_in <= 0;
      read_ptr <= 0;
      fifo_empty <= 0;  // Giả sử FIFO luôn có hàng cho test này
    end else begin
      // Nếu DUT đòi đọc (rd_en = 1), thì cycle sau mới đưa data ra
      if (fifo_read_enable) begin
        if (read_ptr < 19) begin
          fifo_data_in <= test_data[read_ptr];
          read_ptr <= read_ptr + 1;
        end else begin
          fifo_empty   <= 1;  // Hết 19 byte thì báo rỗng
          fifo_data_in <= 8'h00;
        end
      end
    end
  end

  // --- MAIN TEST ---
  integer i;
  reg [7:0] calc_checksum;

  // --- SAFETY & WAVEFORM CONTROL ---
  initial begin
    // 1. Setup file ghi sóng (VCD)
    $dumpfile("packaging_tb.vcd");
    $dumpvars(0, packaging_tb);  // Chỉ dump biến trong module này và con cháu nó

    // 2. TIMEOUT CỨNG
    // Chạy tối đa 5000ns (tương đương 500 chu kỳ clock 100MHz).
    // Quá thời gian này mà chưa $finish ở chỗ khác thì Force Stop.
    #5000;

    $display("\n==================================================");
    $display("FATAL ERROR: SIMULATION TIMEOUT!");
    $display("Code của cậu đã bị kẹt hoặc chạy quá lâu.");
    $display("Dừng simulation ngay lập tức để bảo vệ máy.");
    $display("==================================================\n");
    $finish;  // Lệnh này bắt buộc simulator dừng lại.
  end

  initial begin
    // 1. Setup Waveform & Init
    clk = 0;
    reset_n = 0;
    fifo_empty = 0;
    fifo_data_in = 0;

    // 2. Chuẩn bị gói tin hoàn hảo trong RAM
    // Header
    test_data[0] = 8'hAA;
    calc_checksum = 8'hAA;

    // 16 Byte Data (0x01 -> 0x10)
    for (i = 1; i <= 16; i = i + 1) begin
      test_data[i]  = i[7:0];
      calc_checksum = calc_checksum ^ i[7:0];
    end

    // Checksum
    test_data[17] = calc_checksum;

    // Footer
    test_data[18] = 8'h55;

    // 3. Bắt đầu Test
    $display("--- START SIMPLE TEST ---");
    #20 reset_n = 1;  // Thả reset

    // Chờ tối đa 100 clock. Nếu module chạy đúng, nó phải xong trong khoảng 40 clock.
    wait (data_valid);

    $display("--- RESULTS ---");
    $display("Time: %t", $time);

    // Check kết quả
    if (data_out === 128'h0102030405060708090A0B0C0D0E0F10) begin
      $display("SUCCESS: Data Output matches expected value.");
    end else begin
      $display("FAILURE: Data Output WRONG!");
      $display("Expected: 0102030405060708090A0B0C0D0E0F10");
      $display("Got     : %h", data_out);
    end



    $finish;
  end
endmodule
