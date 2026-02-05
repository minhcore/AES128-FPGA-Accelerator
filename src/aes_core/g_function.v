module g_function (
    input             clk,
    input             reset_n,
    input             start,
    input      [31:0] word_in,
    input      [ 3:0] round_num,
    output reg [31:0] word_out,
    output reg        valid
);

    wire [31:0] out_rot_in_sub;
    wire [7:0] rcon;
    wire [31:0] sub_out;
    wire sub_word_valid;

    rcon u0 (
        .round_num(round_num),
        .out      (rcon)
    );

    rot_word u1 (
        .in (word_in),
        .out(out_rot_in_sub)
    );

    sub_word u2 (
        .clk    (clk),
        .reset_n(reset_n),
        .start  (start),
        .in     (out_rot_in_sub),
        .out    (sub_out),
        .valid  (sub_word_valid)
    );

    always @(posedge clk) begin
        if (!reset_n) begin
            valid <= 1'b0;
        end else if (sub_word_valid) begin
            word_out <= sub_out ^ {rcon, 24'h000000};
            valid    <= 1'b1;
        end else begin
            valid <= 'b0;
        end
    end

endmodule
