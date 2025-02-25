module fsk2_tx (
    input   wire                sys_clk     ,
    input   wire                sys_rst_n   ,
    input   wire    [15:0]      data_in     ,

    output  reg                 tx_flag     ,
    output  wire    [31:0]      tx          
);

parameter FREQ_CNT_MAX = 50; // 50MHZ / 50 = 1MHZ



reg [15:0]  data_in_reg     ;
reg         work_en         ;
reg [4:0]   bit_cnt         ;
reg         sine_1MHz_toggle;
reg         sine_2MHz_toggle;
reg [5:0]   freq_cnt        ;
wire [31:0]  sine_1MHz      ;
wire [31:0]  sine_2MHz      ;

//data_in_reg 打拍输入数据
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (~sys_rst_n) begin
        data_in_reg <= 16'b0;
    end
    else 
        data_in_reg <= data_in;
end


//work_en 输入数据有效使能
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (~sys_rst_n) begin
        work_en <= 'b0;
    end
    else if ((data_in != data_in_reg) && freq_cnt == FREQ_CNT_MAX && bit_cnt == 'd0) begin
        work_en <= 'b1;
    end
    else if (freq_cnt == FREQ_CNT_MAX && bit_cnt == 'd16) begin
        work_en <= 'b0;
    end
    else
        work_en <= work_en;
end

//bit_cnt 下一个周期显示data的位数
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (~sys_rst_n) begin
        bit_cnt <= 'd0;
    end
    else if ((data_in != data_in_reg) && (freq_cnt == FREQ_CNT_MAX)) begin
        bit_cnt <= 'd1;
    end
    else if (bit_cnt == 'd16 && (freq_cnt == FREQ_CNT_MAX)) begin
        bit_cnt <= 'd0;
    end
    else if ((freq_cnt == FREQ_CNT_MAX)) begin
        bit_cnt <= bit_cnt + 'd1;
    end
    else 
        bit_cnt <= bit_cnt;
end

//sine_1MHz_toggle 1MHZ正弦波的开启信号
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (~sys_rst_n) begin
        sine_1MHz_toggle <= 1'b0;
    end
    else if (tx_flag && (~data_in_reg['d15 - bit_cnt])) begin
        sine_1MHz_toggle <= 1'b1;
    end
    else 
        sine_1MHz_toggle <= 1'b0;
end

//sine_2MHz_toggle 2MHZ正弦波的开启信号
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (~sys_rst_n) begin
        sine_2MHz_toggle <= 1'b0;
    end
    else if (tx_flag && (data_in_reg['d15 - bit_cnt])) begin
        sine_2MHz_toggle <= 1'b1;
    end
    else
        sine_2MHz_toggle <= 1'b0;
end

//freq_cnt 一个周期的计数
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (~sys_rst_n) begin
        freq_cnt <= 'd0;
    end
    else if (freq_cnt == FREQ_CNT_MAX) begin
        freq_cnt <= 'd0;
    end
    else
        freq_cnt <= freq_cnt + 'd1;
end

//tx_flag 一个周期的发起信号
always @(posedge tx_flag or negedge sys_rst_n) begin
    if (~sys_rst_n) begin
        tx_flag <=1'b0;
    end
    else if (freq_cnt == FREQ_CNT_MAX) begin
        tx_flag <=1'b1;
    end
    else
        tx_flag <=1'b0;
end

//tx 发送正弦点
assign tx = sine_2MHz_toggle ? sine_2MHz : sine_1MHz;


//sine_1MHz 1MHZ的正弦信号
sine_lut_1MHz sine_lut_1MHz_inst(
    .sys_clk        (sys_clk    ),     // 50MHz时钟
    .sys_rst_n      (sys_rst_n  ),     // 复位

    .q              (sine_1MHz  )      // Q1.15格式正弦波输出
);

//sine_2MHz 2MHZ的正弦信号
sine_lut_2MHz sine_lut_2MHz_inst(
    .sys_clk        (sys_clk    ),     // 50MHz时钟
    .sys_rst_n      (sys_rst_n  ),     // 复位

    .q              (sine_2MHz  )      // Q1.15格式正弦波输出
);

endmodule