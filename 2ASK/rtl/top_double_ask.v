module top_double_ask (
    input   wire        sys_clk,     // 50MHz系统时钟
    input   wire        sys_rst_n,   // 异步复位
    input   wire [15:0] data_in,     // 输入数据
    output  wire        data_out,    // 解调输出
    output  wire        data_valid   // 数据有效标志
);

//===== 内部信号声明 =====//
wire [15:0] tx_signal;  // 发射信号

//===== 发射端实例化 =====//
double_ask_tx_top tx_inst (
    .sys_clk    (sys_clk),
    .sys_rst_n  (sys_rst_n),
    .data_in    (data_in),
    .tx         (tx_signal)
);

//===== 接收端实例化 =====//
double_ask_rx rx_inst (
    .sys_clk    (sys_clk),
    .sys_rst_n  (sys_rst_n),
    .rx_signal  (tx_signal),  // 直接连接发射输出到接收输入
    .data_out   (data_out),
    .data_valid (data_valid)
);

endmodule