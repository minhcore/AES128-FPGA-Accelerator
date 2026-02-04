`timescale 1ns / 1ps

module aes_key_expand_tb ();

  reg [127:0] key_example;
  reg clk = 0;
  reg kld = 0;
  reg next_key = 0;
  reg [3:0] round_num;
  wire [127:0] key_out;

  integer i;

  aes_key_expand u0 (
      .clk(clk),
      .reset_n(1'd1),
      .kld(kld),
      .key_in(key_example),
      .next_key(next_key),
      .round_num(round_num),
      .key_out(key_out)
  );

  always #1 clk = ~clk;

  initial begin
    $dumpfile("aes_key_expand_tb.vcd");
    $dumpvars(0, aes_key_expand_tb);
  end

  initial begin
    // init key
    key_example = 128'h2b7e1516_28aed2a6_abf71588_09cf4f3c;

    kld = 1;
    round_num = 0;
    next_key = 0;
    #2;
    kld = 0;

    for (i = 0; i < 10; i++) begin
      next_key  = 1;
      round_num = i + 1;
      #2;
      next_key = 0;
      #4;
    end

    #1000;
    $finish;
  end


endmodule
