module mix_columns_tb ();

    reg  [127:0] in;
    wire [127:0] out;
    reg  [127:0] exp;

    mix_columns dut (
        .in (in),
        .out(out)
    );

    initial begin
        $display("Starting mix_columns simulation!");
        in  = 128'h09287F47_6F746ABF_2C4A6204_DA08E3EE;
        exp = 128'h529F16C2_978615CA_E01AAE54_BA1A2659;
        #1;
        if (out == exp) begin
            $display("--------> TRUE !");
        end else begin
            $display("--------> FALSE !");
        end
        $display("in    =0x%h", in);
        $display("out   =0x%h", out);
        $display("exp=  =0x%h", exp);

        #1000;
        $finish;
    end

    initial begin
        $dumpfile("mix_columns_tb.vcd");
        $dumpvars(0, mix_columns_tb);
    end
endmodule
