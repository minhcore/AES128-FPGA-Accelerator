module add_round_key_tb ();

    reg clk = 0;
    reg [127:0] data_in;
    wire [127:0] key;
    reg [127:0] exp;
    wire [127:0] out;
    reg start;
    wire valid;
    reg [127:0] new_key;
    reg reset_n;

    add_round_key dut (
        .data_in(data_in),
        .key    (new_key),
        .out    (out)
    );

    compute_round_key get_key (
        .clk      (clk),
        .reset_n  (reset_n),
        .start    (start),
        .old_key  (128'h2B7E1516_28AED2A6_ABF71588_09CF4F3C),
        .round_num(4'd1),
        .new_key  (key),
        .valid    (valid)
    );

    always #1 clk = ~clk;

    initial begin
        $display("Starting add_round_key simulation!");
        reset_n = 1'b0;
        #10;
        reset_n = 1'b1;
        #2;

        data_in = 128'h529f16c2_978615ca_e01aae54_ba1a2659;
        exp     = 128'hF265E8D5_1FD2397B_C3B9976D_9076505C;
        #2;

        start = 1'b1;
        #2;
        start = 1'b0;

        wait (valid);
        new_key = key;

        #1;
        if (out == exp) begin
            $display("--------->TRUE!");
        end else begin
            $display("--------->FALSE!");
        end
        $display("in = %h", data_in);
        $display("key = %h", new_key);
        $display("out = %h", out);
        $display("exp = %h", exp);

        #1000;
        $finish;
    end

    initial begin
        $dumpfile("add_round_key_tb.vcd");
        $dumpvars(0, add_round_key_tb);
    end

endmodule
