module sub_word (
    input  [31:0] in,
    output [31:0] out
);

  sbox u0 (
      .in (in[7:0]),
      .out(out[7:0])
  );

  sbox u1 (
      .in (in[15:8]),
      .out(out[15:8])
  );

  sbox u2 (
      .in (in[23:16]),
      .out(out[23:16])
  );

  sbox u3 (
      .in (in[31:24]),
      .out(out[31:24])
  );

endmodule
