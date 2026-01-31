module uart_echo_tb ();

  reg  clk = 0;
  reg  reset_n = 1;
  reg  rx = 1;
  wire tx;

  top_uart_echo #(8'd8) u0 (
      .clk(clk),
      .reset_n(reset_n),
      .rx(rx),
      .tx(tx)
  );

  always #1 clk = ~clk;

  initial begin
    #10 reset_n = 0;
    #16 reset_n = 1;
    #16 rx = 0;  // startbit
    #16 rx = 1;
    #16 rx = 0;
    #16 rx = 1;
    #16 rx = 0;
    #16 rx = 1;
    #16 rx = 0;
    #16 rx = 1;
    #16 rx = 0;
    #16 rx = 1;  //stopbit
    #16 rx = 0;  // startbit
    #16 rx = 0;
    #16 rx = 1;
    #16 rx = 0;
    #16 rx = 1;
    #16 rx = 0;
    #16 rx = 1;
    #16 rx = 0;
    #16 rx = 1;
    #16 rx = 1;  //stopbit
    #1000 $finish;

  end

  initial begin
    $dumpfile("uart_echo_tb");
    $dumpvars(0, uart_echo_tb);
  end

endmodule
