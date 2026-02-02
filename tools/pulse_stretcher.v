module pulse_stretcher (
    input      clk,
    input      reset_n,
    input      signal_in,  // Tín hiệu xung ngắn (1 cycle) từ module Packaging
    output reg led_out     // Tín hiệu ra LED (Active Low: 0 sáng, 1 tắt)
);
  // Bộ đếm 23 bit (đủ đếm tới ~8 triệu). 
  // Nếu clock 27MHz, 8 triệu ~ 0.3 giây -> Đủ để mắt thấy.
  reg [22:0] counter;

  always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      counter <= 0;
      led_out <= 1;  // Tắt LED (Active Low)
    end else begin
      if (signal_in) begin
        counter <= 23'h7FFFFF;  // Nạp giá trị lớn khi có tín hiệu vào
        led_out <= 0;  // Bật LED (Sáng)
      end else if (counter > 0) begin
        counter <= counter - 1;  // Đếm lùi dần
        led_out <= 0;  // Vẫn giữ LED sáng
      end else begin
        led_out <= 1;  // Hết giờ -> Tắt LED
      end
    end
  end
endmodule
