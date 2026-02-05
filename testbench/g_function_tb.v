module g_function_tb ();

    reg         clk;
    reg         reset_n;
    reg         start;
    reg  [31:0] word_in;
    reg  [ 3:0] round_num;
    wire [31:0] word_out;
    wire        valid;

    g_function u0 (
        .clk      (clk),
        .reset_n  (reset_n),
        .start    (start),
        .word_in  (word_in),
        .round_num(round_num),
        .word_out (word_out),
        .valid    (valid)
    );

    task check;
        input [31:0] exp;
        begin
            @(posedge valid);
            if (word_out === exp) $display("TRUE: got = %h, exp = %h", word_out, exp);
            else $display("FALSE: got = %h, exp = %h", word_out, exp);
        end
    endtask

    always #5 clk = ~clk;

    initial begin
        clk       = 0;
        reset_n   = 0;
        start     = 0;
        word_in   = 0;
        round_num = 0;
        #20 reset_n = 1;

        $display("Starting g_function simulation!");

        $display("Test 1:");
        @(posedge clk);
        word_in   <= 32'h09CF4F3C;
        round_num <= 4'd1;
        start     <= 1;
        @(posedge clk);
        start <= 0;
        check(32'h8B84EB01);

        $display("Test 2:");
        @(posedge clk);
        word_in   <= 32'h2A6C7605;
        round_num <= 4'd2;
        start     <= 1;
        @(posedge clk);
        start <= 0;
        check(32'h52386BE5);

        $display("Test 3:");
        @(posedge clk);
        word_in   <= 32'hFF000000;
        round_num <= 4'd3;
        start     <= 1;
        @(posedge clk);
        start <= 0;
        check(32'h67636316);

        $finish;
    end

endmodule
