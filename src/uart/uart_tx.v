module uart_tx #(
    parameter DELAY_FRAMES = 234  // 27 MHZ / 115200
) (
    input            clk,
    input            reset_n,
    input            tx_start,
    input      [7:0] tx_data,
    output           tx_out,
    output           tx_busy,
    output reg       tx_done
);

    localparam HALF_DELAY_WAIT = (DELAY_FRAMES / 2);

    reg [2:0] tx_state = 0;
    reg [7:0] tx_counter = 0;
    reg [7:0] data_out = 0;
    reg tx_pin_register = 1;
    reg [2:0] tx_bit_number = 0;

    assign tx_out  = tx_pin_register;
    assign tx_busy = (tx_state != TX_STATE_IDLE);

    localparam TX_STATE_IDLE = 0;
    localparam TX_STATE_START_BIT = 1;
    localparam TX_STATE_WRITE = 2;
    localparam TX_STATE_STOP = 3;

    always @(posedge clk) begin
        if (!reset_n) begin
            tx_state      <= TX_STATE_IDLE;
            tx_counter    <= 0;
            tx_bit_number <= 0;
            tx_done       <= 0;
        end else begin
            tx_done <= 0;
            case (tx_state)
                TX_STATE_IDLE: begin
                    if (tx_start == 1) begin
                        tx_state      <= TX_STATE_START_BIT;
                        data_out      <= tx_data;
                        tx_counter    <= 0;
                        tx_bit_number <= 0;
                    end else begin
                        tx_pin_register <= 1;
                    end
                end

                TX_STATE_START_BIT: begin
                    tx_pin_register <= 0;
                    if (tx_counter == DELAY_FRAMES - 1) begin
                        tx_state      <= TX_STATE_WRITE;
                        tx_bit_number <= 0;
                        tx_counter    <= 0;
                    end else begin
                        tx_counter <= tx_counter + 1;
                    end
                end

                TX_STATE_WRITE: begin
                    tx_pin_register <= data_out[tx_bit_number];
                    if (tx_counter == DELAY_FRAMES - 1) begin
                        if (tx_bit_number == 3'b111) begin
                            tx_state <= TX_STATE_STOP;
                        end else begin
                            tx_state      <= TX_STATE_WRITE;
                            tx_bit_number <= tx_bit_number + 1;
                        end
                        tx_counter <= 0;
                    end else begin
                        tx_counter <= tx_counter + 1;
                    end
                end

                TX_STATE_STOP: begin
                    tx_pin_register <= 1;
                    if (tx_counter == HALF_DELAY_WAIT - 1) begin
                        tx_state <= TX_STATE_IDLE;
                        tx_done  <= 1;
                    end else begin
                        tx_counter <= tx_counter + 1;
                    end
                end
            endcase
        end
    end
endmodule
