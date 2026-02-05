module aes_key_expand (
    input              clk,
    input              reset_n,
    input              kld,
    input      [127:0] key_in,
    input              next_key,
    input      [  3:0] round_num,
    output     [127:0] key_out,
    output reg         valid
);

    localparam IDLE = 0;
    localparam COMPUTE = 1;

    reg [127:0] key_reg;
    wire [127:0] key_new;
    wire compute_valid;
    reg state;
    reg compute_start;

    compute_round_key compute_module (
        .clk      (clk),
        .reset_n  (reset_n),
        .start    (compute_start),
        .old_key  (key_reg),
        .round_num(round_num),
        .new_key  (key_new),
        .valid    (compute_valid)
    );

    always @(posedge clk) begin
        if (!reset_n) begin
            state         <= IDLE;
            valid         <= 1'b0;
            compute_start <= 1'b0;
        end else begin
            valid         <= 1'b0;
            compute_start <= 1'b0;
            case (state)
                IDLE: begin
                    if (kld) begin
                        key_reg <= key_in;
                    end else if (next_key) begin
                        state         <= COMPUTE;
                        compute_start <= 1'b1;
                    end
                end

                COMPUTE: begin
                    if (compute_valid) begin
                        key_reg <= key_new;
                        valid   <= 1'b1;
                        state   <= IDLE;
                    end
                end

            endcase
        end
    end

    assign key_out = key_reg;

endmodule
