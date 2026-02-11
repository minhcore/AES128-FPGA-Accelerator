module top (
    input uart_rx,
    input clk,
    input reset_n,

    output uart_tx
);

    wire [7:0] rx_data;
    wire rx_done;
    wire rx_busy;
    wire fifo_input_full;
    wire fifo_input_empty;
    wire [7:0] fifo_input_data_out;
    wire fifo_read_enable;
    wire packaging_error_flag;
    wire [127:0] packaging_data_out;
    wire packaging_data_valid;
    wire packaging_key_valid;
    wire [127:0] cipher_text;
    wire aes_busy;
    wire aes_error;
    wire cipher_valid;
    wire output_busy;

    uart_rx rx (
        .clk    (clk),
        .reset_n(reset_n),
        .uart_rx(uart_rx),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .rx_busy(rx_busy)
    );

    sync_fifo fifo_input (
        .clk         (clk),
        .reset_n     (reset_n),
        .write_enable(rx_done),
        .data_in     (rx_data),
        .read_enable (fifo_read_enable),
        .data_out    (fifo_input_data_out),
        .full        (fifo_input_full),
        .empty       (fifo_input_empty)
    );

    packaging packaging (
        .clk             (clk),
        .reset_n         (reset_n),
        .fifo_data_in    (fifo_input_data_out),
        .fifo_empty      (fifo_input_empty),
        .output_busy     (output_busy),
        .fifo_read_enable(fifo_read_enable),
        .data_out        (packaging_data_out),
        .data_valid      (packaging_data_valid),
        .key_valid       (packaging_key_valid),
        .error_flag      (packaging_error_flag)
    );

    aes_control aes_core (
        .clk         (clk),
        .reset_n     (reset_n),
        .data_in     (packaging_data_out),
        .data_valid  (packaging_data_valid),
        .key_valid   (packaging_key_valid),
        .error_flag  (packaging_error_flag),
        .cipher_text (cipher_text),
        .cipher_valid(cipher_valid),
        .busy        (),
        .error       ()
    );

    sending sending (
        .clk         (clk),
        .reset_n     (reset_n),
        .cipher_data (cipher_text),
        .cipher_valid(cipher_valid),
        .uart_tx     (uart_tx),
        .can_accept  (output_busy)
    );

endmodule
