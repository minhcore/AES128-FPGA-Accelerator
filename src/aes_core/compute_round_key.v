module compute_round_key (
    input              clk,
    input              reset_n,
    input              start,
    input      [127:0] old_key,
    input      [  3:0] round_num,
    output     [127:0] new_key,
    output reg         valid
);

    localparam WAIT_G = 0;
    localparam COMPUTE = 1;

    reg state;
    reg [31:0] g_reg;
    wire [31:0] w0_prev, w1_prev, w2_prev, w3_prev;
    reg [31:0] w0_new, w1_new, w2_new, w3_new;
    wire [31:0] g_function_out;
    wire g_function_valid;

    assign w0_prev = old_key[127:96];
    assign w1_prev = old_key[95:64];
    assign w2_prev = old_key[63:32];
    assign w3_prev = old_key[31:0];

    g_function u0 (
        .clk      (clk),
        .reset_n  (reset_n),
        .start    (start),
        .word_in  (w3_prev),
        .round_num(round_num),
        .word_out (g_function_out),
        .valid    (g_function_valid)
    );

    always @(posedge clk) begin
        if (!reset_n) begin
            state <= WAIT_G;
            valid <= 1'b0;
        end else begin
            valid <= 1'b0;
            case (state)
                WAIT_G: begin
                    if (g_function_valid) begin
                        g_reg <= g_function_out;
                        state <= COMPUTE;
                    end
                end

                COMPUTE: begin
                    w0_new <= w0_prev ^ g_reg;
                    w1_new <= w1_prev ^ (w0_prev ^ g_reg);
                    w2_new <= w2_prev ^ (w1_prev ^ (w0_prev ^ g_reg));
                    w3_new <= w3_prev ^ (w2_prev ^ (w1_prev ^ (w0_prev ^ g_reg)));
                    state  <= WAIT_G;
                    valid  <= 1'b1;
                end
            endcase
        end
    end

    assign new_key = {w0_new, w1_new, w2_new, w3_new};

endmodule
