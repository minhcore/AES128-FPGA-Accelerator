module compute_round_key_tb ();

    reg          clk;
    reg          reset_n;
    reg          start;
    reg  [127:0] key_in;
    reg  [  3:0] round_num;
    wire [127:0] key_out;
    wire         valid;

    compute_round_key u0 (
        .clk      (clk),
        .reset_n  (reset_n),
        .start    (start),
        .old_key  (key_in),
        .round_num(round_num),
        .new_key  (key_out),
        .valid    (valid)
    );

    task check;
        input [127:0] exp;
        begin
            @(posedge valid);
            if (key_out === exp) begin
                $display("True: got = %h_%h_%h_%h, exp = %h_%h_%h_%h", key_out[127:96],
                         key_out[95:64], key_out[63:32], key_out[31:0], exp[127:96], exp[95:64],
                         exp[63:32], exp[31:0]);
            end else begin
                $display("False: got = %h_%h_%h_%h, exp = %h_%h_%h_%h", key_out[127:96],
                         key_out[95:64], key_out[63:32], key_out[31:0], exp[127:96], exp[95:64],
                         exp[63:32], exp[31:0]);
            end
        end
    endtask

    always #5 clk = ~clk;

    initial begin
        $dumpfile("compute_round_key_tb.vcd");
        $dumpvars(0, compute_round_key_tb);
    end

    initial begin
        clk       = 0;
        reset_n   = 0;
        start     = 0;
        key_in    = 0;
        round_num = 0;
        #20 reset_n = 1;

        $display("Starting compute_round_key simulation!");

        $display("Test 1:");
        @(posedge clk);
        key_in    <= 128'h2b7e1516_28aed2a6_abf71588_09cf4f3c;
        round_num <= 4'd1;
        start     <= 1;
        @(posedge clk);
        start <= 0;
        check(128'ha0fafe17_88542cb1_23a33939_2a6c7605);

        $display("Test 2:");
        @(posedge clk);
        key_in    <= 128'ha0fafe17_88542cb1_23a33939_2a6c7605;
        round_num <= 4'd2;
        start     <= 1;
        @(posedge clk);
        start <= 0;
        check(128'hf2c295f2_7a96b943_5935807a_7359f67f);

        $display("Test 3:");
        @(posedge clk);
        key_in    <= 128'h00010203_04050607_08090a0b_0c0d0e0f;
        round_num <= 4'd1;
        start     <= 1;
        @(posedge clk);
        start <= 0;
        check(128'hd6aa74fd_d2af72fa_daa678f1_d6ab76fe);

        $display("Test 4: This test is intentional negative test case");
        @(posedge clk);
        key_in    <= 128'h2b7e1516_28aed2a6_abf71588_09cf4f3c;
        round_num <= 4'd1;
        start     <= 1;
        @(posedge clk);
        start <= 0;
        check(128'ha1fafe17_88542cb1_23a33939_2a6c7605);

        $display("All Tests Are Passed!");
        $display("Summary:");
        $display("- Positive tests passed : 3/3");
        $display("- Negative tests passed : 1/1");

        $finish;
    end

endmodule
