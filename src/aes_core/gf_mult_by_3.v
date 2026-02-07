module gf_mult_by_3 (
    input  [7:0] a,
    output [7:0] result
);

    wire [7:0] a_times_2;

    gf_mult_by_2 mult2 (
        .a     (a),
        .result(a_times_2)
    );

    assign result = a_times_2 ^ a;

endmodule
