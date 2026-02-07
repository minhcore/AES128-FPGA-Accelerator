module mix_columns (
    input  [127:0] in,
    output [127:0] out
);

    mix_single_column mix_single_column_u0 (
        .s0    (in[127:120]),
        .s1    (in[119:112]),
        .s2    (in[111:104]),
        .s3    (in[103:96]),
        .s0_out(out[127:120]),
        .s1_out(out[119:112]),
        .s2_out(out[111:104]),
        .s3_out(out[103:96])
    );

    mix_single_column mix_single_column_u1 (
        .s0    (in[95:88]),
        .s1    (in[87:80]),
        .s2    (in[79:72]),
        .s3    (in[71:64]),
        .s0_out(out[95:88]),
        .s1_out(out[87:80]),
        .s2_out(out[79:72]),
        .s3_out(out[71:64])
    );

    mix_single_column mix_single_column_u2 (
        .s0    (in[63:56]),
        .s1    (in[55:48]),
        .s2    (in[47:40]),
        .s3    (in[39:32]),
        .s0_out(out[63:56]),
        .s1_out(out[55:48]),
        .s2_out(out[47:40]),
        .s3_out(out[39:32])
    );

    mix_single_column mix_single_column_u3 (
        .s0    (in[31:24]),
        .s1    (in[23:16]),
        .s2    (in[15:8]),
        .s3    (in[7:0]),
        .s0_out(out[31:24]),
        .s1_out(out[23:16]),
        .s2_out(out[15:8]),
        .s3_out(out[7:0])
    );


endmodule
