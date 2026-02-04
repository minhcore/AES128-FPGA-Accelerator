module compute_round_key (
    input  [127:0] old_key,
    input  [  3:0] round_num,
    output [127:0] new_key
);

  wire [31:0] w0_prev, w1_prev, w2_prev, w3_prev;
  wire [31:0] w0_new, w1_new, w2_new, w3_new;
  wire [31:0] g_function_out;

  assign w0_prev = old_key[127:96];
  assign w1_prev = old_key[95:64];
  assign w2_prev = old_key[63:32];
  assign w3_prev = old_key[31:0];

  g_function u0 (
      .word_in  (w3_prev),
      .round_num(round_num),
      .word_out (g_function_out)
  );

  assign w0_new  = w0_prev ^ g_function_out;
  assign w1_new  = w1_prev ^ w0_new;
  assign w2_new  = w2_prev ^ w1_new;
  assign w3_new  = w3_prev ^ w2_new;

  assign new_key = {w0_new, w1_new, w2_new, w3_new};

endmodule
