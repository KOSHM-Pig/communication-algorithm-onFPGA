module fsk2_tx (
    input   wire                sys_clk     ,
    input   wire                sys_rst_n   ,
    input   wire    [15:0]      data_in     ,

    output  reg                 tx_flag     ,
    output  wire    [15:0]      tx          
);

parameter FREQ_CNT_MAX = 49; // 50MHZ / 50 = 1MHZ 3为周期延迟



reg [15:0]  data_in_reg     ;
reg         work_en         ;
reg [4:0]   bit_cnt         ;
reg         sine_1MHz_toggle;
reg         sine_2MHz_toggle;
reg [5:0]   freq_cnt        ;
reg [5:0]   freq_cnt_reg1   ;
reg [5:0]   freq_cnt_reg2   ;
reg [5:0]   freq_cnt_reg3   ;
wire [15:0]  sine_1MHz      ;
wire [15:0]  sine_2MHz      ;

//data_in_reg 打拍输入数据
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (~sys_rst_n) begin
        data_in_reg <= 16'b0;
    end
    else if (~work_en) begin
        data_in_reg <= data_in;
    end
    else
        data_in_reg <= data_in_reg;
end


//work_en 输入数据有效使能
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (~sys_rst_n) begin
        work_en <= 'b0;
    end
    else if ((data_in != data_in_reg) && (bit_cnt=='d0)) begin
        work_en <= 'b1;
    end
    else if ((freq_cnt_reg3 == FREQ_CNT_MAX && bit_cnt == 'd16)) begin
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
    else if ( work_en && (freq_cnt_reg3 == FREQ_CNT_MAX) && bit_cnt == 1'd0) begin
        bit_cnt <= 'd1;
    end
    else if (bit_cnt == 'd16 && (freq_cnt_reg3 == FREQ_CNT_MAX)) begin
        bit_cnt <= 'd0;
    end
    else if ((bit_cnt>='d1) && (bit_cnt <= 'd15) && (freq_cnt_reg3 == FREQ_CNT_MAX)) begin
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
    else if (tx_flag && (~data_in_reg['d16 - bit_cnt])) begin
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

//freq_cnt_reg1~3 打拍
always @(posedge sys_clk) begin
    freq_cnt_reg1 <= freq_cnt;
    freq_cnt_reg2 <= freq_cnt_reg1;
    freq_cnt_reg3 <= freq_cnt_reg2;
end

//tx_flag 一个周期的发起信号
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (~sys_rst_n) begin
        tx_flag <=1'b0;
    end
    else if (work_en && freq_cnt == FREQ_CNT_MAX && bit_cnt == 'd0) begin
        tx_flag <=1'b1;
    end
    else
        tx_flag <=1'b0;
end

//tx 发送正弦点
assign tx = (bit_cnt>='d1 && bit_cnt <= 'd16) ? (data_in_reg['d16 -bit_cnt] ? sine_2MHz : sine_1MHz) : sine_1MHz;


//sine_1MHz 1MHZ的正弦信号
dds_sine 
#(
    . SINE_FREQ ( 'd1_000_000  ), //目标正弦波频率1MHZ
    .INCLK_FREQ ( 'd50_000_000 ),//输入时钟频率50MHZ
    .SAMPLE_MAX ( 'd1024       ),
    .GEN_CNT_MAX( 'd16         ),
    .GEN_MOD    ( 'b0          ) //循环生成模式
)
sine_lut_1MHz_inst
(
    .sys_clk        (sys_clk    ),     // 50MHz时钟
    .sys_rst_n      (sys_rst_n  ),     // 复位
    .toggle         (tx_flag    ),
    .sine_out       (sine_1MHz  )      // Q1.15格式正弦波输出
);


//sine_2MHz 2MHZ的正弦信号
dds_sine 
#(
    . SINE_FREQ ( 'd2_000_000  ), //目标正弦波频率2MHZ
    .INCLK_FREQ ( 'd50_000_000 ),//输入时钟频率50MHZ
    .SAMPLE_MAX ( 'd1024       ),
    .GEN_CNT_MAX( 'd32         ),
    .GEN_MOD    ( 'b0          )//循环生成模式
)sine_lut_2MHz_inst(
    .sys_clk        (sys_clk    ),     // 50MHz时钟
    .sys_rst_n      (sys_rst_n  ),     // 复位
    .toggle         (tx_flag    ),
    .sine_out       (sine_2MHz  )      // Q1.15格式正弦波输出
);

endmodule