module packaging (
    input              clk,
    input              reset_n,
    input      [  7:0] fifo_data_in,
    input              fifo_empty,
    input              output_busy,
    output reg         fifo_read_enable,
    output reg [127:0] data_out,
    output reg         data_valid,
    output reg         key_valid,
    output reg         error_flag
);

    localparam IDLE = 0;
    localparam WAIT_HEADER = 1;
    localparam GET_HEADER = 2;
    localparam REQ_DATA = 3;
    localparam WAIT_DATA = 4;
    localparam GET_DATA = 5;
    localparam REQ_CHECK_SUM = 6;
    localparam WAIT_CHECK_SUM = 7;
    localparam CHECK_SUM = 8;
    localparam REQ_FOOTER = 9;
    localparam WAIT_FOOTER = 10;
    localparam CHECK_FOOTER = 11;

    localparam DATA_HEADER = 8'hAA;
    localparam KEY_HEADER = 8'hBB;
    localparam FOOTER = 8'h55;

    reg [3:0] state = 0;
    reg [3:0] byte_count = 0;
    reg [7:0] check_sum_result = 0;
    reg is_key = 0;

    always @(posedge clk) begin
        if (!reset_n) begin
            state            <= IDLE;
            byte_count       <= 0;
            check_sum_result <= 0;
            data_valid       <= 0;
            key_valid        <= 0;
            error_flag       <= 0;
            fifo_read_enable <= 0;
        end else begin
            data_valid       <= 0;
            key_valid        <= 0;
            error_flag       <= 0;
            fifo_read_enable <= 0;
            case (state)
                IDLE: begin
                    byte_count       <= 0;
                    check_sum_result <= 0;
                    if (!fifo_empty && !output_busy) begin
                        fifo_read_enable <= 1;
                        state            <= WAIT_HEADER;
                    end
                end

                WAIT_HEADER: begin
                    state <= GET_HEADER;
                end

                GET_HEADER: begin
                    if (fifo_data_in == DATA_HEADER) begin
                        is_key           <= 0;
                        check_sum_result <= fifo_data_in;
                        state            <= REQ_DATA;
                    end else if (fifo_data_in == KEY_HEADER) begin
                        is_key           <= 1;
                        check_sum_result <= fifo_data_in;
                        state            <= REQ_DATA;
                    end else begin
                        error_flag <= 1;
                        state      <= IDLE;
                    end
                end

                REQ_DATA: begin
                    if (!fifo_empty) begin
                        fifo_read_enable <= 1;
                        state            <= WAIT_DATA;
                    end
                end

                WAIT_DATA: begin
                    state <= GET_DATA;
                end

                GET_DATA: begin
                    data_out         <= {data_out[119:0], fifo_data_in};
                    check_sum_result <= check_sum_result ^ fifo_data_in;
                    byte_count       <= byte_count + 1;
                    if (byte_count == 4'b1111) begin
                        state <= REQ_CHECK_SUM;
                    end else begin
                        state <= REQ_DATA;
                    end
                end

                REQ_CHECK_SUM: begin
                    if (!fifo_empty) begin
                        fifo_read_enable <= 1;
                        state            <= WAIT_CHECK_SUM;
                    end
                end

                WAIT_CHECK_SUM: begin
                    state <= CHECK_SUM;
                end

                CHECK_SUM: begin
                    if (fifo_data_in == check_sum_result) begin
                        state <= REQ_FOOTER;
                    end else begin
                        error_flag <= 1;
                        state      <= IDLE;
                    end
                end

                REQ_FOOTER: begin
                    if (!fifo_empty) begin
                        fifo_read_enable <= 1;
                        state            <= WAIT_FOOTER;
                    end
                end

                WAIT_FOOTER: begin
                    state <= CHECK_FOOTER;
                end

                CHECK_FOOTER: begin
                    if (fifo_data_in == FOOTER) begin
                        if (is_key) begin
                            key_valid  <= 1;
                            data_valid <= 0;
                        end else begin
                            key_valid  <= 0;
                            data_valid <= 1;
                        end
                        state <= IDLE;
                    end else begin
                        error_flag <= 1;
                        state      <= IDLE;
                    end
                end
            endcase
        end
    end

endmodule
