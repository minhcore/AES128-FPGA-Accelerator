module rcon (
    input [3:0] round_num,
    output reg [7:0] out
);

  always @(*) begin
    case (round_num)
      4'd1: out = 8'h01;
      4'd2: out = 8'h02;
      4'd3: out = 8'h04;
      4'd4: out = 8'h08;
      4'd5: out = 8'h10;
      4'd6: out = 8'h20;
      4'd7: out = 8'h40;
      4'd8: out = 8'h80;
      4'd9: out = 8'h1b;
      4'd10: out = 8'h36;
      default: out = 8'h00;
    endcase
  end

endmodule
