`timescale 1ns / 1ps

module aes_key_expand_tb ();

    reg          clk = 0;
    reg          reset_n;
    reg          kld;
    reg          next_key;
    reg  [127:0] key_example;
    reg  [  3:0] round_num;
    wire [127:0] key_out;
    wire         valid;

    aes_key_expand dut (
        .clk      (clk),
        .reset_n  (reset_n),
        .kld      (kld),
        .key_in   (key_example),
        .next_key (next_key),
        .round_num(round_num),
        .key_out  (key_out),
        .valid    (valid)
    );

    task check;
        input [127:0] exp;
        begin
            @(posedge valid);
            @(posedge clk);  // Đợi thêm 1 clock sau valid
            if (key_out === exp)
                $display(
                    "PASS: got = %h_%h_%h_%h",
                    key_out[127:96],
                    key_out[95:64],
                    key_out[63:32],
                    key_out[31:0]
                );
            else
                $display(
                    "FAIL: got = %h_%h_%h_%h, exp = %h_%h_%h_%h",
                    key_out[127:96],
                    key_out[95:64],
                    key_out[63:32],
                    key_out[31:0],
                    exp[127:96],
                    exp[95:64],
                    exp[63:32],
                    exp[31:0]
                );
        end
    endtask

    always #1 clk = ~clk;

    initial begin
        $dumpfile("aes_key_expand_tb.vcd");
        $dumpvars(0, aes_key_expand_tb);
    end

    initial begin
        reset_n     = 0;
        kld         = 0;
        next_key    = 0;
        key_example = 0;
        round_num   = 0;

        #4 reset_n = 1;
        @(posedge clk);

        // Load initial key
        key_example = 128'h2b7e1516_28aed2a6_abf71588_09cf4f3c;
        kld         = 1;
        @(posedge clk);
        kld = 0;
        @(posedge clk);

        // Test 1: Round 1
        $display("Test 1: Round 1");
        round_num = 1;
        next_key  = 1;
        @(posedge clk);
        next_key = 0;
        check(128'ha0fafe17_88542cb1_23a33939_2a6c7605);
        @(posedge clk);

        // Test 2: Round 2
        $display("Test 2: Round 2");
        round_num = 2;
        next_key  = 1;
        @(posedge clk);
        next_key = 0;
        check(128'hf2c295f2_7a96b943_5935807a_7359f67f);
        @(posedge clk);

        // Test 3: Round 3
        $display("Test 3: Round 3");
        round_num = 3;
        next_key  = 1;
        @(posedge clk);
        next_key = 0;
        check(128'h3d80477d_4716fe3e_1e237e44_6d7a883b);
        @(posedge clk);

        // Test 4: Round 4
        $display("Test 4: Round 4");
        round_num = 4;
        next_key  = 1;
        @(posedge clk);
        next_key = 0;
        check(128'hef44a541_a8525b7f_b671253b_db0bad00);

        @(posedge clk);
        $display("=== All tests completed ===");
        $finish;
    end

endmodule
