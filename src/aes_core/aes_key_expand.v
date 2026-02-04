module aes_key_expand (
    input clk,
    input reset_n,
    input kld,
    input [127:0] key_in,
    input next_key,
    input [3:0] round_num,
    output [127:0] key_out
);

  reg  [127:0] key_reg;
  wire [127:0] key_new;

  compute_round_key u0 (
      .old_key  (key_reg),
      .round_num(round_num),
      .new_key  (key_new)
  );

  always @(posedge clk) begin
    if (!reset_n) begin
      key_reg <= 128'd0;
    end else begin
      if (kld) begin
        key_reg <= key_in;
      end else if (next_key) begin
        key_reg <= key_new;
      end
    end
  end

  assign key_out = key_reg;

endmodule
