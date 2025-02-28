module full_wave_rectifier (
    //全波整流器
    input  wire [15:0] ac_signal,  // 交流输入（有符号数）
    output wire [15:0] dc_output   // 整流后输出（绝对值）
);

assign dc_output = ac_signal[15] ? (~ac_signal) : ac_signal ; 

endmodule