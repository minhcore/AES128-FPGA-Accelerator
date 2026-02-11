module sbox (
    input            clk,
    input            reset_n,
    input            start,
    input      [7:0] in,
    output reg [7:0] out,
    output reg       valid
);

    (* syn_ramstyle = "block_ram" *)
    reg [7:0] sbox_mem[0:255];
    reg [7:0] addr;
    reg valid_delay;

    initial begin
        $readmemh("src/aes_core/sbox.mem", sbox_mem);
    end

    always @(posedge clk) begin
        if (!reset_n) begin
            addr        <= 8'h00;
            valid_delay <= 1'b0;
        end else if (start) begin
            addr        <= in;
            valid_delay <= 1'b1;
        end else begin
            valid_delay <= 1'b0;
        end
    end

    always @(posedge clk) begin
        if (!reset_n) begin
            valid <= 1'b0;
        end else begin
            valid <= valid_delay;
        end
    end

    always @(posedge clk) begin
        out <= sbox_mem[addr];
    end
endmodule
