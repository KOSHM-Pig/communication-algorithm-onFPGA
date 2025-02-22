`timescale 1ns/1ns

module tb_lowpass_filter();

reg sys_clk         ;        
reg sys_rst_n       ;
wire [15:0] sine_1MHZ;
wire [15:0] sine_5MHZ;
wire [32:0] sine_plus;

wire [31:0] sine_out_filter;
initial begin
    sys_clk = 1'b1;
    sys_rst_n <= 1'b0;
    #20
    sys_rst_n = 1'b1;
end

always #10 sys_clk = ~sys_clk;

sine_lut sine_lut_inst(
    .sys_clk     (sys_clk      ),     // 50MHz时钟
    .sys_rst_n   (sys_rst_n    ),   // 复位
    .q           (sine_1MHZ    )     // Q1.15格式正弦波输出
);

sine_lut_5MHz sine_lut_5MHZ_inst(
    .sys_clk     (sys_clk      ),     // 50MHz时钟
    .sys_rst_n   (sys_rst_n    ),   // 复位
    .sine_out    (sine_5MHZ    )     // Q1.15格式正弦波输出
);

assign sine_plus = sine_1MHZ * sine_5MHZ;



LowPassFilter_10MHz_50M LowPassFilter_10MHz_50M_inst(
    .sys_clk    (sys_clk    ),          // 50MHz时钟
    .sys_rst_n  (sys_rst_n  ),      // 异步复位
    .data_in    (sine_plus[31:16]),  // 输入信号（16位有符号）
    .data_out   (sine_out_filter)  // 输出信号（32位有符号）
);
endmodule