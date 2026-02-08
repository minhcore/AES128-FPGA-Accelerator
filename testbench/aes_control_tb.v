`timescale 1ns / 1ps

module aes_control_tb;

    reg clk;
    reg reset_n;
    reg [127:0] data_in;
    reg data_valid;
    reg key_valid;
    reg error_flag;

    wire [127:0] cipher_text;
    wire cipher_valid;
    wire busy;
    wire valid;
    wire error;

    reg [127:0] expected_cipher;
    integer test_count;
    integer pass_count;

    aes_control dut (
        .clk         (clk),
        .reset_n     (reset_n),
        .data_in     (data_in),
        .data_valid  (data_valid),
        .key_valid   (key_valid),
        .error_flag  (error_flag),
        .cipher_text (cipher_text),
        .cipher_valid(cipher_valid),
        .busy        (busy),
        .valid       (valid),
        .error       (error)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        #500000;
        $display("TIMEOUT! Test failed.");
        $finish;
    end

    initial begin
        $dumpfile("aes_control_tb.vcd");
        $dumpvars(0, aes_control_tb);

        reset_n    = 0;
        data_in    = 128'h0;
        data_valid = 0;
        key_valid  = 0;
        error_flag = 0;
        test_count = 0;
        pass_count = 0;

        #20;
        reset_n = 1;
        #20;

        data_in   = 128'h2B7E1516_28AED2A6_ABF71588_09CF4F3C;
        key_valid = 1;
        #10;
        key_valid = 0;
        #100;

        // Test 1
        data_in         = 128'h6BC1BEE2_2E409F96_E93D7E11_7393172A;
        expected_cipher = 128'h3AD77BB4_0D7A3660_A89ECAF3_2466EF97;
        test_count      = test_count + 1;
        data_valid      = 1;
        #10;
        data_valid = 0;
        wait (valid);
        if (cipher_text == expected_cipher) pass_count = pass_count + 1;
        else $display("Test 1 FAILED");
        #50;

        // Test 2
        data_in         = 128'hAE2D8A57_1E03AC9C_9EB76FAC_45AF8E51;
        expected_cipher = 128'hF5D3D585_03B9699D_E785895A_96FDBAAF;
        test_count      = test_count + 1;
        data_valid      = 1;
        #10;
        data_valid = 0;
        wait (valid);
        if (cipher_text == expected_cipher) pass_count = pass_count + 1;
        else $display("Test 2 FAILED");
        #50;

        // Test 3
        data_in         = 128'h30C81C46_A35CE411_E5FBC119_1A0A52EF;
        expected_cipher = 128'h43B1CD7F_598ECE23_881B00E3_ED030688;
        test_count      = test_count + 1;
        data_valid      = 1;
        #10;
        data_valid = 0;
        wait (valid);
        if (cipher_text == expected_cipher) pass_count = pass_count + 1;
        else $display("Test 3 FAILED");
        #50;

        // Test 4
        data_in         = 128'hF69F2445_DF4F9B17_AD2B417B_E66C3710;
        expected_cipher = 128'h7B0C785E_27E8AD3F_82232071_04725DD4;
        test_count      = test_count + 1;
        data_valid      = 1;
        #10;
        data_valid = 0;
        wait (valid);
        if (cipher_text == expected_cipher) pass_count = pass_count + 1;
        else $display("Test 4 FAILED");
        #50;

        if (pass_count == test_count) begin
            $display("==============================================");
            $display("ALL TESTS PASSED! (%0d/%0d)", pass_count, test_count);
            $display("==============================================");
        end else begin
            $display("TESTS FAILED: %0d/%0d passed", pass_count, test_count);
        end

        $finish;
    end

endmodule
