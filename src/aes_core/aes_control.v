module aes_control (
    input              clk,
    input              reset_n,
    input      [127:0] data_in,
    input              data_valid,
    input              key_valid,
    input              error_flag,
    output     [127:0] cipher_text,
    output             cipher_valid,
    output             busy,
    output reg         valid,
    output             error
);

    localparam IDLE = 0;
    localparam LOAD_KEY = 1;
    localparam LOAD_DATA = 2;
    localparam INIT = 3;
    localparam SUB_BYTE = 4;
    localparam SHIFT_ROWS = 5;
    localparam MIX_COLUMNS = 6;
    localparam WAIT_ROUND_KEY = 7;
    localparam ADD_ROUND_KEY = 8;
    localparam CHECK_ROUND = 9;
    localparam DONE = 10;

    reg [3:0] state;
    reg key_ready;
    reg data_ready;
    reg [127:0] data;
    reg [127:0] key;
    reg [3:0] counter;
    reg [127:0] buffer;
    reg error_process;
    reg [127:0] round_key;
    reg key_load;
    reg next_key;
    reg [3:0] round_num;

    wire [127:0] sub_byte_out;
    wire sub_byte_valid;
    wire [127:0] shift_rows_out;
    wire [127:0] mix_columns_out;
    wire [127:0] key_expand_out;
    wire key_expand_valid;

    sub_byte sub_byte (
        .clk    (clk),
        .reset_n(reset_n),
        .start  (),
        .in     (buffer),
        .out    (sub_byte_out),
        .valid  (sub_byte_valid)
    );

    shift_rows shift_rows (
        .in (buffer),
        .out(shift_rows_out)
    );

    mix_columns mix_columns (
        .in (buffer),
        .out(mix_columns_out)
    );

    aes_key_expand aes_key_expand (
        .clk      (clk),
        .reset_n  (reset_n),
        .kld      (key_load),
        .key_in   (data_in),
        .next_key (next_key),
        .round_num(round_num),
        .key_out  (key_expand_out),
        .valid    (key_expand_valid)
    );

    assign round_num = counter + 1;

    always @(posedge clk) begin
        if (!reset_n) begin
            state      <= IDLE;
            key_ready  <= 1'b0;
            data_ready <= 1'b0;
            data       <= 128'h0;
            key        <= 128'h0;
            counter    <= 4'd0;
            error_flag <= 1'b0;
            key_load   <= 1'b0;
            next_key   <= 1'b0;
            valid      <= 1'b0;
        end else begin

            case (state)
                IDLE: begin
                    data       <= 128'h0;
                    counter    <= 4'd0;
                    data_ready <= 1'b0;
                    key_load   <= 1'b0;
                    next_key   <= 1'b0;
                    valid      <= 1'b0;
                    if (key_valid) begin
                        state    <= LOAD_KEY;
                        key_load <= 1'b1;
                    end else if (data_valid) begin
                        state <= LOAD_DATA;
                    end
                end

                LOAD_KEY: begin
                    key       <= data_in;
                    key_ready <= 1'b1;
                    if (data_valid) begin
                        state <= LOAD_DATA;
                    end
                end

                LOAD_DATA: begin
                    data       <= data_in;
                    data_ready <= 1'b1;
                    state      <= INIT;
                end

                INIT: begin
                    if (key_ready && data_ready) begin
                        buffer <= data ^ key;
                        state  <= SUB_BYTE;
                    end else begin
                        error_process <= 1'b1;
                    end
                end

                SUB_BYTE: begin
                    if (sub_byte_valid) begin
                        buffer <= sub_byte_out;
                        state  <= SHIFT_ROWS;
                    end
                end

                SHIFT_ROWS: begin
                    buffer <= shift_rows_out;
                    if (counter < 4'd9) begin
                        state <= MIX_COLUMNS;
                    end else if (counter == 4'd9) begin
                        state    <= WAIT_ROUND_KEY;
                        next_key <= 1'b1;
                    end
                end

                MIX_COLUMNS: begin
                    buffer   <= mix_columns_out;
                    state    <= WAIT_ROUND_KEY;
                    next_key <= 1'b1;
                end

                WAIT_ROUND_KEY: begin
                    if (key_expand_valid) begin
                        round_key <= key_expand_out;
                        state     <= ADD_ROUND_KEY;
                    end
                end

                ADD_ROUND_KEY: begin
                    buffer <= round_key ^ buffer;
                    if (counter == 4'd9) begin
                        state <= DONE;
                    end else begin
                        counter <= counter + 1;
                        state   <= CHECK_ROUND;
                    end
                end

                CHECK_ROUND: begin
                    if (counter == 4'd9) begin
                        state <= DONE;
                    end else if (counter < 4'd9) begin
                        state <= SUB_BYTE;
                    end
                end

                DONE: begin
                    valid <= 1'b1;
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
