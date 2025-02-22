module sine_lut (
    input   wire        sys_clk,     // 50MHz时钟
    input   wire        sys_rst_n,   // 复位

    output  reg [15:0]  q     // Q1.15格式正弦波输出
);

//===== 参数定义 =====//
parameter CLK_FREQ  = 50_000_000;  // 50MHz
parameter WAVE_FREQ = 1_000_000;   // 目标频率1MHz
parameter LUT_POINTS = 32;         // 32点LUT

//----- 相位累加器步长计算 -----//
// 公式：Phase_Step = (WAVE_FREQ * 2^32) / CLK_FREQ
localparam PHASE_STEP = (WAVE_FREQ * 64'd4294967296) / CLK_FREQ;  // 计算结果：85,899,345

//===== 相位累加器 =====//
reg [31:0] phase_acc;  // 32位相位累加器

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)
        phase_acc <= 32'd0;
    else
        phase_acc <= phase_acc + PHASE_STEP;  // 相位累加
end

//===== LUT索引生成（取高5位）=====//
wire [4:0] lut_index = phase_acc[31:27];  // 32点LUT需要5位地址

//===== 32点正弦波LUT（Q1.15格式）=====//
always @(posedge sys_clk) begin
    case(lut_index)
        5'd0:  q <= 16'h0000;  5'd1:  q <= 16'h18F9;
        5'd2:  q <= 16'h30FB;  5'd3:  q <= 16'h471C;
        5'd4:  q <= 16'h5A82;  5'd5:  q <= 16'h6A6D;
        5'd6:  q <= 16'h7641;  5'd7:  q <= 16'h7D89;
        5'd8:  q <= 16'h7FF6;  5'd9:  q <= 16'h7D89;
        5'd10: q <= 16'h7641;  5'd11: q <= 16'h6A6D;
        5'd12: q <= 16'h5A82;  5'd13: q <= 16'h471C;
        5'd14: q <= 16'h30FB;  5'd15: q <= 16'h18F9;
        5'd16: q <= 16'h0000;  5'd17: q <= 16'hE707;
        5'd18: q <= 16'hCF05;  5'd19: q <= 16'hB8E4;
        5'd20: q <= 16'hA57E;  5'd21: q <= 16'h9593;
        5'd22: q <= 16'h89BF;  5'd23: q <= 16'h8277;
        5'd24: q <= 16'h800A;  5'd25: q <= 16'h8277;
        5'd26: q <= 16'h89BF;  5'd27: q <= 16'h9593;
        5'd28: q <= 16'hA57E;  5'd29: q <= 16'hB8E4;
        5'd30: q <= 16'hCF05;  5'd31: q <= 16'hE707;
        default: q <= 16'h0000;
    endcase
end


endmodule