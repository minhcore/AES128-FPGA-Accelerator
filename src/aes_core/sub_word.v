module sub_word (
    input             clk,
    input             reset_n,
    input             start,
    input      [31:0] in,
    output reg [31:0] out,
    output reg        valid
);

    wire [7:0] sbox_out[3:0];
    wire sbox_valid[3:0];
    reg sbox_start;
    reg [1:0] state;

    localparam IDLE = 0;
    localparam WAIT_SBOX = 1;
    localparam DONE = 2;

    sbox u0 (
        .clk    (clk),
        .reset_n(reset_n),
        .start  (sbox_start),
        .in     (in[7:0]),
        .out    (sbox_out[0]),
        .valid  (sbox_valid[0])
    );

    sbox u1 (
        .clk    (clk),
        .reset_n(reset_n),
        .start  (sbox_start),
        .in     (in[15:8]),
        .out    (sbox_out[1]),
        .valid  (sbox_valid[1])
    );

    sbox u2 (
        .clk    (clk),
        .reset_n(reset_n),
        .start  (sbox_start),
        .in     (in[23:16]),
        .out    (sbox_out[2]),
        .valid  (sbox_valid[2])
    );

    sbox u3 (
        .clk    (clk),
        .reset_n(reset_n),
        .start  (sbox_start),
        .in     (in[31:24]),
        .out    (sbox_out[3]),
        .valid  (sbox_valid[3])
    );

    always @(posedge clk) begin
        if (!reset_n) begin
            state      <= IDLE;
            sbox_start <= 1'b0;
            out        <= 32'h0;
            valid      <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    valid <= 1'b0;
                    if (start) begin
                        sbox_start <= 1'b1;
                        state      <= WAIT_SBOX;
                    end
                end

                WAIT_SBOX: begin
                    sbox_start <= 1'b0;
                    if (sbox_valid[0] && sbox_valid[1] && sbox_valid[2] && sbox_valid[3]) begin
                        out   <= {sbox_out[3], sbox_out[2], sbox_out[1], sbox_out[0]};
                        valid <= 1'b1;
                        state <= DONE;
                    end
                end

                DONE: begin
                    valid <= 1'b0;
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
