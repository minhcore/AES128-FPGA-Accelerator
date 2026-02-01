`default_nettype none

module uart_rx #(
    parameter DELAY_FRAMES = 234  // 27 MHZ / 115200
) (
    input clk,
    input reset_n,
    input uart_rx,
    output reg [7:0] rx_data,
    output reg rx_done,
    output rx_busy
);

  localparam HALF_DELAY_WAIT = (DELAY_FRAMES / 2);

  reg [2:0] rx_current_state = 0;
  reg [2:0] rx_next_state = 0;
  reg [7:0] rx_counter = 0;
  reg [2:0] rx_bit_number = 0;
  reg [7:0] data_in = 0;
  reg byte_ready = 0;
  reg rx_sync1 = 1;
  reg rx_sync2 = 1;

  localparam RX_STATE_IDLE = 0;
  localparam RX_STATE_START = 1;
  localparam RX_STATE_READ_WAIT = 2;
  localparam RX_STATE_READ = 3;
  localparam RX_STATE_STOP = 4;

  // sync rx signal
  always @(posedge clk) begin
    if (!reset_n) begin
      rx_sync1 <= 1;
      rx_sync2 <= 1;
    end else begin
      rx_sync1 <= uart_rx;
      rx_sync2 <= rx_sync1;
    end
  end

  // state transition logic
  always @(*) begin
    rx_next_state = rx_current_state;
    case (rx_current_state)
      RX_STATE_IDLE: begin
        if (rx_sync2 == 0) begin
          rx_next_state = RX_STATE_START;
        end
      end

      RX_STATE_START: begin
        if (rx_counter == HALF_DELAY_WAIT) begin
          rx_next_state = RX_STATE_READ_WAIT;
        end
      end

      RX_STATE_READ_WAIT: begin
        if (rx_counter == (DELAY_FRAMES - 1)) begin
          rx_next_state = RX_STATE_READ;
        end
      end

      RX_STATE_READ: begin
        if (rx_bit_number == 3'b111) begin
          rx_next_state = RX_STATE_STOP;
        end else begin
          rx_next_state = RX_STATE_READ_WAIT;
        end
      end

      RX_STATE_STOP: begin
        if (rx_counter == (DELAY_FRAMES - 1)) begin
          rx_next_state = RX_STATE_IDLE;
        end
      end
    endcase
  end

  always @(posedge clk) begin
    if (!reset_n) begin
      rx_current_state <= RX_STATE_IDLE;
    end else begin
      rx_current_state <= rx_next_state;
    end
  end

  // state logic
  always @(posedge clk) begin
    case (rx_current_state)
      RX_STATE_IDLE: begin
        rx_counter <= 0;
        rx_bit_number <= 0;
        byte_ready <= 0;
      end

      RX_STATE_START: begin
        if (rx_counter == HALF_DELAY_WAIT) begin
          rx_counter <= 1;
        end else begin
          rx_counter <= rx_counter + 1;
        end
      end

      RX_STATE_READ_WAIT: begin
        rx_counter <= rx_counter + 1;
      end

      RX_STATE_READ: begin
        rx_counter <= 1;
        rx_data <= {rx_sync2, rx_data[7:1]};
        rx_bit_number <= rx_bit_number + 1;
      end

      RX_STATE_STOP: begin
        rx_counter <= rx_counter + 1;
        if (rx_counter == DELAY_FRAMES - 1) begin
          rx_counter <= 0;
          byte_ready <= 1;
        end
      end
    endcase
  end

  // logic for rx_done
  always @(posedge clk) begin
    if (!reset_n) begin
      rx_done <= 0;
    end else if (rx_current_state == RX_STATE_STOP && rx_counter == (HALF_DELAY_WAIT - 1)) begin
      if (rx_sync2 == 1) begin
        rx_done <= 1;
      end else begin
        rx_done <= 0;
      end
    end else begin
      rx_done <= 0;
    end
  end

  assign rx_busy = (rx_current_state != RX_STATE_IDLE);

endmodule
