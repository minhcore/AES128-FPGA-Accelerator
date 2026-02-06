module sub_byte (
    input              clk,
    input              reset_n,
    input              start,
    input      [127:0] in,
    output reg [127:0] out,
    output reg         valid
);

    localparam IDLE = 0;
    localparam LOAD0 = 1;
    localparam PHASE0 = 2;
    localparam LOAD1 = 3;
    localparam PHASE1 = 4;
    localparam LOAD2 = 5;
    localparam PHASE2 = 6;
    localparam LOAD3 = 7;
    localparam PHASE3 = 8;
    localparam DONE = 9;

    reg [3:0] state;
    reg [127:0] in_reg;
    reg sbox_start;

    reg [7:0] sbox_in_reg[3:0];

    wire [7:0] sbox_out[3:0];
    wire sbox_valid[3:0];

    sbox sbox0 (
        .clk    (clk),
        .reset_n(reset_n),
        .start  (sbox_start),
        .in     (sbox_in_reg[0]),
        .out    (sbox_out[0]),
        .valid  (sbox_valid[0])
    );

    sbox sbox1 (
        .clk    (clk),
        .reset_n(reset_n),
        .start  (sbox_start),
        .in     (sbox_in_reg[1]),
        .out    (sbox_out[1]),
        .valid  (sbox_valid[1])
    );

    sbox sbox2 (
        .clk    (clk),
        .reset_n(reset_n),
        .start  (sbox_start),
        .in     (sbox_in_reg[2]),
        .out    (sbox_out[2]),
        .valid  (sbox_valid[2])
    );

    sbox sbox3 (
        .clk    (clk),
        .reset_n(reset_n),
        .start  (sbox_start),
        .in     (sbox_in_reg[3]),
        .out    (sbox_out[3]),
        .valid  (sbox_valid[3])
    );

    always @(posedge clk) begin
        if (!reset_n) begin
            sbox_start <= 1'b0;
            valid      <= 1'b0;
            out        <= 128'b0;
            in_reg     <= 128'b0;
            state      <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    valid <= 1'b0;
                    if (start) begin
                        in_reg <= in;
                        state  <= LOAD0;
                    end
                end

                LOAD0: begin
                    sbox_in_reg[0] <= in_reg[127:120];
                    sbox_in_reg[1] <= in_reg[119:112];
                    sbox_in_reg[2] <= in_reg[111:104];
                    sbox_in_reg[3] <= in_reg[103:96];
                    sbox_start     <= 1'b1;
                    state          <= PHASE0;
                end

                PHASE0: begin
                    sbox_start <= 1'b0;
                    if (sbox_valid[0] && sbox_valid[1] && sbox_valid[2] && sbox_valid[3]) begin
                        out[127:120] <= sbox_out[0];
                        out[119:112] <= sbox_out[1];
                        out[111:104] <= sbox_out[2];
                        out[103:96]  <= sbox_out[3];
                        state        <= LOAD1;
                    end
                end

                LOAD1: begin
                    sbox_in_reg[0] <= in_reg[95:88];
                    sbox_in_reg[1] <= in_reg[87:80];
                    sbox_in_reg[2] <= in_reg[79:72];
                    sbox_in_reg[3] <= in_reg[71:64];
                    sbox_start     <= 1'b1;
                    state          <= PHASE1;
                end

                PHASE1: begin
                    sbox_start <= 1'b0;
                    if (sbox_valid[0] && sbox_valid[1] && sbox_valid[2] && sbox_valid[3]) begin
                        out[95:88] <= sbox_out[0];
                        out[87:80] <= sbox_out[1];
                        out[79:72] <= sbox_out[2];
                        out[71:64] <= sbox_out[3];
                        state      <= LOAD2;
                    end
                end

                LOAD2: begin
                    sbox_in_reg[0] <= in_reg[63:56];
                    sbox_in_reg[1] <= in_reg[55:48];
                    sbox_in_reg[2] <= in_reg[47:40];
                    sbox_in_reg[3] <= in_reg[39:32];
                    sbox_start     <= 1'b1;
                    state          <= PHASE2;
                end

                PHASE2: begin
                    sbox_start <= 1'b0;
                    if (sbox_valid[0] && sbox_valid[1] && sbox_valid[2] && sbox_valid[3]) begin
                        out[63:56] <= sbox_out[0];
                        out[55:48] <= sbox_out[1];
                        out[47:40] <= sbox_out[2];
                        out[39:32] <= sbox_out[3];
                        state      <= LOAD3;
                    end
                end

                LOAD3: begin
                    sbox_in_reg[0] <= in_reg[31:24];
                    sbox_in_reg[1] <= in_reg[23:16];
                    sbox_in_reg[2] <= in_reg[15:8];
                    sbox_in_reg[3] <= in_reg[7:0];
                    sbox_start     <= 1'b1;
                    state          <= PHASE3;
                end

                PHASE3: begin
                    sbox_start <= 1'b0;
                    if (sbox_valid[0] && sbox_valid[1] && sbox_valid[2] && sbox_valid[3]) begin
                        out[31:24] <= sbox_out[0];
                        out[23:16] <= sbox_out[1];
                        out[15:8]  <= sbox_out[2];
                        out[7:0]   <= sbox_out[3];
                        state      <= DONE;
                    end
                end

                DONE: begin
                    valid <= 1'b1;
                    if (!start) begin
                        state <= IDLE;
                    end
                end
            endcase
        end
    end

endmodule
