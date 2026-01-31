module uart_tx_tb ();
  reg clk = 0;
  reg reset_n = 1;
  reg tx_start = 0;
  reg [7:0] data = 0;
  wire tx_out;
  wire tx_busy;
  wire tx_done;

  uart_tx #(8'd8) u (
      clk,
      reset_n,
      tx_start,
      data,
      tx_out,
      tx_busy,
      tx_done
  );

  always #1 clk = ~clk;

  initial begin
    #10 reset_n = 0;
    #10 reset_n = 1;
    #10 data = 8'h55;
    #16 tx_start = 1;
    #2 tx_start = 0;

    @(posedge tx_done);
    data = 8'b1010_1010;
    #10 tx_start = 1;
    #2 tx_start = 0;

    #1000 $finish;

  end

  initial begin
    $dumpfile("uart_tx_tb.vcd");
    $dumpvars(0, uart_tx_tb);
  end

endmodule
