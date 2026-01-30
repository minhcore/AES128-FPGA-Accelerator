module uart_rx_tb ();
  reg clk = 0;
  reg uart_rx = 1;
  reg reset_n = 1;
  wire [7:0] data;
  wire done;
  wire busy;

  uart_rx #(8'd8) u0 (
      clk,
      reset_n,
      uart_rx,
      data,
      done,
      busy
  );

  always #1 clk = ~clk;

  initial begin
    $display("Starting UART RX");
    $monitor("Data Value %b", data);
    #10 uart_rx = 0;
    #16 uart_rx = 1;
    #16 uart_rx = 0;
    #16 uart_rx = 1;
    #16 uart_rx = 0;
    #16 uart_rx = 1;
    #16 uart_rx = 0;
    #16 uart_rx = 1;
    #16 uart_rx = 0;
    #16 uart_rx = 1;
    #1000 $finish;
  end

  initial begin
    $dumpfile("uart_rx_tb.vcd");
    $dumpvars(0, uart_rx_tb);
  end
endmodule
