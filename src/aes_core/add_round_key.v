module add_round_key (
    input  [127:0] data_in,
    input  [127:0] key,
    output [127:0] out
);

    assign out = data_in ^ key;

endmodule
