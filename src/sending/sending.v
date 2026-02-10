module sending (
    input clk,
    input reset_n,

    input [127:0] cipher_data,
    input         cipher_valid,

    output uart_tx,
    output can_accept
);

    wire fifo_full;
    wire fifo_empty;
    wire [7:0] converter_out;
    wire converter_busy;
    wire write_enable;
    wire [7:0] fifo_data_out;
    wire tx_done;
    wire tx_busy;

    reg [2:0] state;
    reg [7:0] tx_data_reg;
    reg tx_start;
    reg fifo_read_enable;


    localparam IDLE = 0;
    localparam READ_FIFO = 1;
    localparam LATCH_DATA = 2;
    localparam START_TX = 3;
    localparam WAIT_TX = 4;

    width_converter_128to8 width_converter (
        .clk         (clk),
        .reset_n     (reset_n),
        .in          (cipher_data),
        .valid_in    (cipher_valid),
        .fifo_full   (fifo_full),
        .out         (converter_out),
        .write_enable(write_enable),
        .busy        (converter_busy)
    );

    sync_fifo #(
        .DATA_WIDTH(8),
        .DEPTH_LOG2(5)
    ) fifo (
        .clk         (clk),
        .reset_n     (reset_n),
        .write_enable(write_enable),
        .data_in     (converter_out),
        .read_enable (fifo_read_enable),
        .data_out    (fifo_data_out),
        .full        (fifo_full),
        .empty       (fifo_empty)
    );

    uart_tx tx (
        .clk     (clk),
        .reset_n (reset_n),
        .tx_start(tx_start),
        .tx_data (tx_data_reg),
        .tx_out  (uart_tx),
        .tx_busy (tx_busy),
        .tx_done (tx_done)
    );

    assign can_accept = !fifo_full && !converter_busy;

    always @(posedge clk) begin
        if (!reset_n) begin
            state            <= IDLE;
            tx_start         <= 0;
            fifo_read_enable <= 0;
        end else begin
            fifo_read_enable <= 1'b0;
            tx_start         <= 1'b0;
            case (state)
                IDLE: begin
                    if (!fifo_empty && !tx_busy) begin
                        state <= READ_FIFO;
                    end
                end

                READ_FIFO: begin
                    fifo_read_enable <= 1'b1;
                    state            <= LATCH_DATA;
                end

                LATCH_DATA: begin
                    tx_data_reg <= fifo_data_out;
                    state       <= START_TX;
                end

                START_TX: begin
                    tx_start <= 1'b1;
                    state    <= WAIT_TX;
                end

                WAIT_TX: begin
                    if (tx_done) begin
                        state <= IDLE;
                    end
                end

            endcase
        end
    end

endmodule
