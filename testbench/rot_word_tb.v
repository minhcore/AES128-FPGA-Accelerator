module rot_word_tb ();

  reg  [31:0] in;
  wire [31:0] out;

  rot_word u0 (
      .in (in),
      .out(out)
  );

  initial begin
    $display("Starting rot_word simulation!");
    in = 32'haa_bb_ee_ff;
    #1 $display("in = 0x%h, out = 0x%h", in, out);
    $finish;
  end

endmodule
