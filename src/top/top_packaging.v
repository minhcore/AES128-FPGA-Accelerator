module top_packaging (
    input clk,
    input reset_n,
    input rx,
    output [2:0] led
);

  wire data_valid;
  wire key_valid;
  wire error_flag;
  wire fifo_empty;

  wire rx_done;
  wire [7:0] rx_data;
  wire [7:0] fifo_data_out;
  wire fifo_read_enable;


  uart_rx uart_u0 (
      .clk(clk),
      .reset_n(reset_n),
      .uart_rx(rx),
      .rx_data(rx_data),
      .rx_done(rx_done),
      .rx_busy()
  );

  sync_fifo fifo_u0 (
      .clk(clk),
      .reset_n(reset_n),
      .write_enable(rx_done),
      .data_in(rx_data),
      .read_enable(fifo_read_enable),
      .data_out(fifo_data_out),
      .full(),
      .empty(fifo_empty)
  );

  packaging packaging_u0 (
      .clk(clk),
      .reset_n(reset_n),
      .fifo_data_in(fifo_data_out),
      .fifo_empty(fifo_empty),
      .fifo_read_enable(fifo_read_enable),
      .data_out(),
      .data_valid(data_valid),
      .key_valid(key_valid),
      .error_flag(error_flag)
  );

  pulse_stretcher led_zero (
      .clk(clk),
      .reset_n(reset_n),
      .signal_in(data_valid),
      .led_out(led[0])
  );

  pulse_stretcher led_one (
      .clk(clk),
      .reset_n(reset_n),
      .signal_in(key_valid),
      .led_out(led[1])
  );

  pulse_stretcher led_two (
      .clk(clk),
      .reset_n(reset_n),
      .signal_in(error_flag),
      .led_out(led[2])
  );


endmodule
