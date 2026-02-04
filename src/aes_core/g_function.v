module g_function (
    input  [31:0] word_in,
    input  [ 3:0] round_num,
    output [31:0] word_out
);

  wire [31:0] out_rot_in_sub;
  wire [ 7:0] rcon;
  wire [31:0] sub_out;

  rcon u0 (
      .round_num(round_num),
      .out(rcon)
  );

  rot_word u1 (
      .in (word_in),
      .out(out_rot_in_sub)
  );

  sub_word u2 (
      .in (out_rot_in_sub),
      .out(sub_out)
  );

  assign word_out = sub_out ^ {rcon, 24'h000000};

endmodule
