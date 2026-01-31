module top_uart_echo #(
    parameter DELAY_FRAMES = 234
) (
    input  clk,
    input  reset_n,
    input  rx,
    output tx
);

  wire rx_done_tx_start;
  wire tx_done;
  wire [7:0] rx_data;


  uart_rx #(DELAY_FRAMES) recieve_module (
      .clk(clk),
      .reset_n(reset_n),
      .uart_rx(rx),
      .rx_data(rx_data),
      .rx_done(rx_done_tx_start),
      .rx_busy()
  );

  uart_tx #(DELAY_FRAMES) send_module (
      .clk(clk),
      .reset_n(reset_n),
      .tx_start(rx_done_tx_start),
      .tx_data(rx_data),
      .tx_out(tx),
      .tx_busy(),
      .tx_done(tx_done)
  );



endmodule
