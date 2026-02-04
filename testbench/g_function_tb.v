module g_function_tb ();

  reg  [31:0] word_in;
  reg  [ 3:0] round_num;
  wire [31:0] word_out;

  g_function u0 (
      .word_in  (word_in),
      .round_num(round_num),
      .word_out (word_out)
  );

  task check;
    input [31:0] got;
    input [31:0] exp;
    begin
      if (got === exp) begin
        $display("TRUE: got = %h, exp = %h", got, exp);
      end else begin
        $display("FALSE: got = %h, exp = %h", got, exp);
      end
    end
  endtask

  initial begin
    $display("Starting g_function simulation!");
    $display("Test 1:");
    word_in   = 32'h09CF4F3C;
    round_num = 4'd1;
    #1 check(word_out, 32'h8B84EB01);

    $display("Test 2:");
    word_in   = 32'h2A6C7605;
    round_num = 4'd2;
    #1 check(word_out, 32'h52386BE5);

    $display("Test 3:");
    word_in   = 32'hFF000000;
    round_num = 4'd3;
    #1 check(word_out, 32'h67636316);

    $finish;

  end

endmodule
