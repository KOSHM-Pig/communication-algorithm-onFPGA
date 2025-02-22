module sine_lut_5MHz (
    input   wire        sys_clk,     // 50MHz时钟
    input   wire        sys_rst_n,   // 复位
    output  reg [15:0]  sine_out     // Q1.15格式正弦波输出
);

//===== 参数定义 =====//
parameter CLK_FREQ  = 50_000_000;  // 50MHz
parameter WAVE_FREQ = 5_000_000;  // 目标频率10MHz
parameter LUT_POINTS = 16;         // 16点LUT（减少资源）

//----- 相位累加器步长计算 -----//
// 公式：Phase_Step = (WAVE_FREQ * 2^32) / CLK_FREQ
localparam PHASE_STEP = (WAVE_FREQ * 64'd4294967296) / CLK_FREQ;  // 858,993,459

//===== 相位累加器 =====//
reg [31:0] phase_acc;

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)
        phase_acc <= 32'd0;
    else
        phase_acc <= phase_acc + PHASE_STEP[31:0];
end

//===== LUT索引生成（取高4位）=====//
wire [3:0] lut_index = phase_acc[31:28];  // 16点LUT需要4位地址

//===== 16点正弦波LUT（Q1.15格式）=====//
always @(posedge sys_clk) begin
    case(lut_index)
        4'd0:  sine_out <= 16'h0000;  4'd1:  sine_out <= 16'h30FB;
        4'd2:  sine_out <= 16'h5A82;  4'd3:  sine_out <= 16'h7641;
        4'd4:  sine_out <= 16'h7FF6;  4'd5:  sine_out <= 16'h7641;
        4'd6:  sine_out <= 16'h5A82;  4'd7:  sine_out <= 16'h30FB;
        4'd8:  sine_out <= 16'h0000;  4'd9:  sine_out <= 16'hCF05;
        4'd10: sine_out <= 16'hA57E;  4'd11: sine_out <= 16'h89BF;
        4'd12: sine_out <= 16'h800A;  4'd13: sine_out <= 16'h89BF;
        4'd14: sine_out <= 16'hA57E;  4'd15: sine_out <= 16'hCF05;
        default: sine_out <= 16'h0000;
    endcase
end

endmodule