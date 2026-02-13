module width_converter_128to8 (
    input              clk,
    input              reset_n,
    input      [127:0] in,
    input              valid_in,
    input              fifo_full,
    output reg [  7:0] out,
    output reg         write_enable,
    output             busy
);

    reg [127:0] buffer;
    reg [3:0] counter;
    reg active;

    assign busy = active;

    always @(posedge clk) begin
        if (!reset_n) begin
            active       <= 0;
            counter      <= 0;
            write_enable <= 0;
        end else begin
            if (valid_in && !active) begin
                buffer  <= in;
                active  <= 1;
                counter <= 0;
            end else if (active && !fifo_full) begin
                out          <= buffer[127:120];
                write_enable <= 1'b1;
                buffer       <= buffer << 8;
                counter      <= counter + 1;

                if (counter == 15) begin
                    active <= 0;
                end
            end else begin
                write_enable <= 0;
            end
        end
    end

endmodule
