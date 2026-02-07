module shift_rows_tb ();

    reg  [127:0] in;
    wire [127:0] out;

    shift_rows dut (
        .in (in),
        .out(out)
    );

    initial begin
        $display("Starting shift_rows simulation!");
        in = 128'h090862bf_6f28e304_2c747fee_da4a6a47;
        #1;
        if (out == 128'h09287f47_6f746abf_2c4a6204_da08e3ee) begin
            $display("True");
        end else begin
            $display("False");
        end

        $display("in = %h", in);
        $display("out = %h", out);
        $display("exp = %h", 128'h09287f47_6f746abf_2c4a6204_da08e3ee);

        #1000;
        $finish;
    end

endmodule
