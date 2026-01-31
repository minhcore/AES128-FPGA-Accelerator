`timescale 1ns / 1ps
module sync_fifo_tb;

  localparam DW = 8;
  localparam L2 = 3;  // depth = 8
  localparam DEPTH = 1 << L2;

  reg clk = 0, reset_n = 0;
  reg write_enable = 0, read_enable = 0;
  reg  [DW-1:0] data_in = 0;
  wire [DW-1:0] data_out;
  wire full, empty;

  sync_fifo #(
      .DATA_WIDTH(DW),
      .DEPTH_LOG2(L2)
  ) dut (
      .clk(clk),
      .reset_n(reset_n),
      .write_enable(write_enable),
      .data_in(data_in),
      .read_enable(read_enable),
      .data_out(data_out),
      .full(full),
      .empty(empty)
  );

  always #5 clk = ~clk;

  integer i;
  integer exp;

  // -----------------------------
  // WRITE 1-CYCLE PULSE
  // -----------------------------
  task fifo_write(input [DW-1:0] v);
    begin
      @(posedge clk);
      write_enable <= 1;
      data_in      <= v;
      @(posedge clk);
      write_enable <= 0;
    end
  endtask

  // -----------------------------
  // READ 1-CYCLE PULSE
  // data_out valid NEXT cycle
  // -----------------------------
  task fifo_read;
    begin
      @(posedge clk);
      read_enable <= 1;
      @(posedge clk);
      read_enable <= 0;
    end
  endtask

  initial begin
    // reset
    repeat (3) @(posedge clk);
    reset_n = 1;

    // =====================
    // FILL FIFO
    // =====================
    for (i = 0; i < DEPTH; i = i + 1) fifo_write(i);

    @(posedge clk);
    if (!full) $fatal(1, "NOT FULL");

    // =====================
    // DRAIN FIFO
    // =====================
    exp = 0;

    while (!empty) begin
      fifo_read();

      // data_out is valid AFTER read pulse
      @(posedge clk);
      if (data_out !== exp) $fatal(1, "DATA ERROR exp=%0d got=%0d", exp, data_out);
      exp = exp + 1;
    end

    if (!empty) $fatal(1, "NOT EMPTY");

    $display("PASS");
    $finish;
  end

endmodule
