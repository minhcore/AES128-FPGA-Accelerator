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
    localparam ALREADY_KEY = 2;
    localparam WAIT_DATA_VALID = 3;
    localparam LOAD_DATA = 4;
    localparam INIT = 5;
    localparam SUB_BYTE = 6;
    localparam SHIFT_ROWS = 7;
    localparam MIX_COLUMNS = 8;
    localparam WAIT_ROUND_KEY = 9;
    localparam ADD_ROUND_KEY = 10;
    localparam CHECK_ROUND = 11;
    localparam DONE = 12;

    reg [3:0] state;
    reg key_ready;
    reg data_ready;
    reg [127:0] data;
    reg [127:0] key;
    reg sub_byte_start;
    reg [3:0] counter;
    reg [127:0] buffer;
    reg error_process;
    reg [127:0] round_key;
    reg key_load;
    reg next_key;

    wire [127:0] sub_byte_out;
    wire sub_byte_valid;
    wire [127:0] shift_rows_out;
    wire [127:0] mix_columns_out;
    wire [127:0] key_expand_out;
    wire key_expand_valid;
    wire [3:0] round_num;
    wire [127:0] aes_key_expand_in;

    sub_byte sub_byte (
        .clk    (clk),
        .reset_n(reset_n),
        .start  (sub_byte_start),
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
        .key_in   (aes_key_expand_in),
        .next_key (next_key),
        .round_num(round_num),
        .key_out  (key_expand_out),
        .valid    (key_expand_valid)
    );

    assign round_num         = counter + 1;
    assign error             = error_process;
    assign cipher_text       = buffer;
    assign aes_key_expand_in = (state != ALREADY_KEY) ? data_in : key;

    always @(posedge clk) begin
        if (!reset_n) begin
            state          <= IDLE;
            sub_byte_start <= 1'b0;
            key_ready      <= 1'b0;
            data_ready     <= 1'b0;
            data           <= 128'h0;
            key            <= 128'h0;
            counter        <= 4'd0;
            error_process  <= 1'b0;
            key_load       <= 1'b0;
            next_key       <= 1'b0;
            valid          <= 1'b0;
        end else begin
            sub_byte_start <= 1'b0;
            valid          <= 1'b0;
            next_key       <= 1'b0;
            key_load       <= 1'b0;
            case (state)
                IDLE: begin  // state 0
                    sub_byte_start <= 1'b0;
                    data           <= 128'h0;
                    counter        <= 4'd0;
                    data_ready     <= 1'b0;
                    key_load       <= 1'b0;
                    next_key       <= 1'b0;
                    valid          <= 1'b0;
                    if (key_valid) begin
                        state    <= LOAD_KEY;
                        key_load <= 1'b1;
                    end else if (key_ready) begin
                        state    <= ALREADY_KEY;
                        key_load <= 1'b1;
                    end
                end

                LOAD_KEY: begin  // state 1
                    key       <= data_in;
                    key_ready <= 1'b1;
                    state     <= WAIT_DATA_VALID;
                end

                ALREADY_KEY: begin  // state 2
                    state <= WAIT_DATA_VALID;
                end

                WAIT_DATA_VALID: begin  // state 3
                    if (data_valid) begin
                        state <= LOAD_DATA;
                    end
                end

                LOAD_DATA: begin  // state 4
                    data       <= data_in;
                    data_ready <= 1'b1;
                    state      <= INIT;
                end

                INIT: begin  // state 5
                    if (key_ready && data_ready) begin
                        buffer         <= data ^ key;
                        sub_byte_start <= 1'b1;
                        state          <= SUB_BYTE;
                    end else begin
                        error_process <= 1'b1;
                    end
                end

                SUB_BYTE: begin  // state 6
                    if (sub_byte_valid) begin
                        buffer <= sub_byte_out;
                        state  <= SHIFT_ROWS;
                    end
                end

                SHIFT_ROWS: begin  // state 7
                    buffer <= shift_rows_out;
                    if (counter < 4'd9) begin
                        state <= MIX_COLUMNS;
                    end else if (counter == 4'd9) begin
                        state    <= WAIT_ROUND_KEY;
                        next_key <= 1'b1;
                    end
                end

                MIX_COLUMNS: begin  // state 8
                    buffer   <= mix_columns_out;
                    state    <= WAIT_ROUND_KEY;
                    next_key <= 1'b1;
                end

                WAIT_ROUND_KEY: begin  // state 9
                    if (key_expand_valid) begin
                        round_key <= key_expand_out;
                        state     <= ADD_ROUND_KEY;
                    end
                end

                ADD_ROUND_KEY: begin  // state 10
                    buffer <= round_key ^ buffer;
                    if (counter == 4'd10) begin
                        state <= DONE;
                    end else begin
                        counter <= counter + 1;
                        state   <= CHECK_ROUND;
                    end
                end

                CHECK_ROUND: begin  // state 11
                    if (counter == 4'd10) begin
                        state <= DONE;
                    end else if (counter < 4'd10) begin
                        sub_byte_start <= 1'b1;
                        state          <= SUB_BYTE;
                    end
                end

                DONE: begin  // state 12
                    valid <= 1'b1;
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
