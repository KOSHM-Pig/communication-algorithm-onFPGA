module double_ask_rx (
    input   wire        sys_clk,      // 50MHz系统时钟
    input   wire        sys_rst_n,    // 异步复位
    input   wire [15:0] rx_signal,    // 接收信号（来自发射端tx）
    output  reg         data_out,     // 解调数据输出
    output  reg         data_valid    // 数据有效标志
);

//===== 参数定义 =====//
parameter SYMBOL_PERIOD  = 50;        // 符号周期（50个时钟=1us）
parameter THRESHOLD      = 32'd0001_0000; // 判决门限（需根据实际调整）

//===== 信号声明 =====//
wire [15:0] rectified;                // 整流后信号
reg  [31:0] integrator;               // 积分器（32位防止溢出）
reg  [15:0] symbol_counter;           // 符号周期计数器
wire [31:0] averaged;                 // 积分平均值

//===== 全波整流模块实例化 =====//
full_wave_rectifier rectifier (
    .ac_signal(rx_signal),
    .dc_output(rectified)
);

//===== 积分与判决逻辑 =====//
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        integrator      <= 32'd0;
        symbol_counter  <= 16'd0;
        data_out        <= 1'b0;
        data_valid      <= 1'b0;
    end else begin
        // 积分器累加
        integrator <= integrator + {16'd0, rectified};
        
        // 符号周期计数
        if (symbol_counter == SYMBOL_PERIOD-1) begin
            // 计算平均值并判决
            data_out   <= (averaged > THRESHOLD) ? 1'b1 : 1'b0;
            data_valid <= 1'b1;
            
            // 复位计数器
            symbol_counter <= 16'd0;
            integrator     <= 32'd0;
        end else begin
            symbol_counter <= symbol_counter + 16'd1;
            data_valid     <= 1'b0;
        end
    end
end

//===== 积分平均值计算 =====//
assign averaged = integrator / SYMBOL_PERIOD;

endmodule