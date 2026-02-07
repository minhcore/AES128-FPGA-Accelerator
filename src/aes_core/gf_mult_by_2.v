module gf_mult_by_2 (
    input  [7:0] a,
    output [7:0] result
);

    assign result = (a[7] == 1) ? (a << 1) ^ 8'h1b : a << 1;

endmodule
