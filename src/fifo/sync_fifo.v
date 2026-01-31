module sync_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH_LOG2 = 5
) (
    input clk,
    input reset_n,
    input write_enable,
    input [DATA_WIDTH-1:0] data_in,
    input read_enable,
    output reg [DATA_WIDTH-1:0] data_out,
    output full,
    output empty
);

  reg [DATA_WIDTH-1:0] mem[0:(1<<DEPTH_LOG2)-1];
  reg [DEPTH_LOG2:0] write_ptr;
  reg [DEPTH_LOG2:0] read_ptr;

  always @(posedge clk) begin
    if (!reset_n) begin
      write_ptr <= 0;
      read_ptr  <= 0;
    end else begin
      if (write_enable && !full) begin
        mem[write_ptr[DEPTH_LOG2-1:0]] <= data_in;
        write_ptr <= write_ptr + 1;
      end

      if (read_enable && !empty) begin
        data_out <= mem[read_ptr[DEPTH_LOG2-1:0]];
        read_ptr <= read_ptr + 1;
      end
    end
  end

  assign empty = (write_ptr == read_ptr);
  assign full = (write_ptr[DEPTH_LOG2] != read_ptr[DEPTH_LOG2]) && (write_ptr[DEPTH_LOG2-1:0] == read_ptr[DEPTH_LOG2-1:0]);

endmodule
