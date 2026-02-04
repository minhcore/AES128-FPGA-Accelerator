module sub_word_tb ();

  reg  [31:0] in;
  wire [31:0] out;

  sub_word u0 (
      .in (in),
      .out(out)
  );

  initial begin
    $display("Starting sub_word simulation!");
    in = 32'hff_aa_77_66;
    #1
    $display(
        "in = 0x_%h_%h_%h_%h, out = 0x_%h_%h_%h_%h",
        in[31:24],
        in[23:16],
        in[15:8],
        in[7:0],
        out[31:24],
        out[23:16],
        out[15:8],
        out[7:0]
    );

    $finish;
  end

endmodule
