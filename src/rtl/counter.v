module counter
(
    input clk,
    output [5:0] led
);

localparam WAIT_TIME = 13500000;
reg [23:0] counter = 0;
reg [5:0] led_counter = 0;

always @(posedge clk) begin
    counter <= counter + 1;
    if (counter == WAIT_TIME) begin
        led_counter <= led_counter + 1;
    end
end

assign led = ~led_counter;

endmodule