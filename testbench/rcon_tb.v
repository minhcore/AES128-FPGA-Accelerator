module rcon_tb ();

  reg  [3:0] round_num = 0;
  wire [7:0] rcon;

  rcon u0 (
      .round_num(round_num),
      .out(rcon)
  );

  integer i;

  initial begin
    $display("Starting rcon simulation!");
    #1;

    for (i = 0; i < 11; i++) begin
      round_num = i;
      #1 $display("round_num = %d, rcon = 0x%h", round_num, rcon);
      #1;
    end

    $finish;

  end

endmodule
