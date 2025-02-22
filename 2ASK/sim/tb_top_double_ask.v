`timescale 1ns/1ns
module tb_top_double_ask();

//===== 参数定义 =====//
parameter CLK_PERIOD = 20;  // 50MHz时钟周期

//===== 信号声明 =====//
reg         sys_clk;
reg         sys_rst_n;
reg  [15:0] data_in;
wire        data_out;
wire        data_valid;

//===== 顶层模块实例化 =====//
top_double_ask uut (
    .sys_clk    (sys_clk),
    .sys_rst_n  (sys_rst_n),
    .data_in    (data_in),
    .data_out   (data_out),
    .data_valid (data_valid)
);

//===== 时钟生成 =====//
initial begin
    sys_clk = 1'b0;
    forever #(CLK_PERIOD/2) sys_clk = ~sys_clk;
end

//===== 测试激励生成 =====//
initial begin
    // 初始化
    sys_rst_n = 1'b0;
    data_in = 16'h0000;
    #100
    sys_rst_n = 1'b1;
    
    // 测试用例1：发送16'hABCD
    #(20*16*50) 
    data_in = 16'hABCD;
    #(20*16*50)  // 等待1us（1个符号周期）

    data_in = 16'h1234;
    
end

//===== 波形监视 =====//
initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_top_double_ask);
    $monitor("Time=%t, DataIn=%h, DataOut=%b, Valid=%b", 
             $time, data_in, data_out, data_valid);
end

endmodule