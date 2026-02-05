module sub_word_tb ();

    reg [31:0] in;
    wire [31:0] out;
    reg clk = 0;
    reg reset_n;
    reg start;
    wire valid;

    sub_word u0 (
        .clk    (clk),
        .reset_n(reset_n),
        .start  (start),
        .in     (in),
        .out    (out),
        .valid  (valid)
    );

    always #5 clk = ~clk;

    initial begin
        $display("Starting sub_word simulation!");
        reset_n = 0;
        start   = 0;
        in      = 32'h0;

        #20;
        reset_n = 1;

        @(posedge clk);
        in    = 32'hff_aa_77_66;
        start = 1'b1;

        @(posedge clk);
        start = 1'b0;

        wait (valid == 1'b1);
        $display("in = 0x_%h_%h_%h_%h, out = 0x_%h_%h_%h_%h", in[31:24], in[23:16], in[15:8],
                 in[7:0], out[31:24], out[23:16], out[15:8], out[7:0]);
        #20;
        $finish;
    end

    initial begin
        $dumpfile("sub_word_tb.vcd");
        $dumpvars(0, sub_word_tb);
    end

endmodule
