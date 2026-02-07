module mix_single_column (
    input  [7:0] s0,
    s1,
    s2,
    s3,
    output [7:0] s0_out,
    s1_out,
    s2_out,
    s3_out
);

    wire [7:0] mult_2_result[3:0];
    wire [7:0] mult_3_result[3:0];

    // s0_out
    gf_mult_by_2 mult2_u0 (
        .a     (s0),
        .result(mult_2_result[0])
    );
    gf_mult_by_3 mult3_u0 (
        .a     (s1),
        .result(mult_3_result[0])
    );

    // s1_out
    gf_mult_by_2 mult2_u1 (
        .a     (s1),
        .result(mult_2_result[1])
    );
    gf_mult_by_3 mult3_u1 (
        .a     (s2),
        .result(mult_3_result[1])
    );

    // s2_out
    gf_mult_by_2 mult2_u2 (
        .a     (s2),
        .result(mult_2_result[2])
    );
    gf_mult_by_3 mult3_u2 (
        .a     (s3),
        .result(mult_3_result[2])
    );

    // s3_out
    gf_mult_by_2 mult2_u3 (
        .a     (s3),
        .result(mult_2_result[3])
    );
    gf_mult_by_3 mult3_u3 (
        .a     (s0),
        .result(mult_3_result[3])
    );

    assign s0_out = mult_2_result[0] ^ mult_3_result[0] ^ s2 ^ s3;
    assign s1_out = s0 ^ mult_2_result[1] ^ mult_3_result[1] ^ s3;
    assign s2_out = s0 ^ s1 ^ mult_2_result[2] ^ mult_3_result[2];
    assign s3_out = mult_3_result[3] ^ s1 ^ s2 ^ mult_2_result[3];


endmodule
