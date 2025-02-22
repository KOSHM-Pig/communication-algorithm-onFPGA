module double_ask_tx
#(
    parameter B_FREQ = 'd49
)
(
    input   wire                sys_clk         ,
    input   wire                sys_rst_n       ,
    input   wire    [15:0]      sine_val        ,
    input   wire    [15:0]      data_in         ,

    output  wire    [15:0]      mod_out         
);

reg [15:0]  data_in_reg     ;
reg [4:0]   data_cnt        ;
reg [5:0]   freq_cnt        ;
wire        data_valid      ;
wire        st_sign         ;


//data_in_reg 对data_in打拍 同步时序
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (~sys_rst_n) begin
        data_in_reg <= 'b0;
    end
    else
        data_in_reg <= data_in;
end

//data_cnt  取单极性非零信号
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (~sys_rst_n) begin
        data_cnt <= 'd0; 
    end
    else if (data_in != data_in_reg ) begin //在这里已经写了data_valid拉高判据 为了保持持续 使用计数器作为data_valid的高电平判据  当新数据到来时重置计数器为1
        data_cnt <= 'd1;
    end
    else if (data_cnt >= 'd0 && data_cnt <= 'd16 && freq_cnt == B_FREQ) begin
        data_cnt <= data_cnt + 'd1;
    end
    else
        data_cnt <= data_cnt;
end


//freq_cnt 周期计数 用于载波扩展  50 MHZ / 50
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (~sys_rst_n) begin
        freq_cnt <= 'd0;
    end
    else if ((data_in !=data_in_reg) || freq_cnt == B_FREQ) begin
        freq_cnt <= 'd0;
    end
    else
        freq_cnt <= freq_cnt + 'd1;
end

//data_valid 第一次新传入数据有效时拉高
assign data_valid =  (data_cnt>= 'd1 && data_cnt <='d16) ? 1'b1 : 1'b0;

//输出st信号 测试用
assign st_sign = data_valid ? (data_in_reg[16 - data_cnt]): 1'b1 ; 

//mod_out 数据有效data_valid高电平则使用data_in 无则默认1调制
assign mod_out  = data_valid ? (data_in_reg[16 - data_cnt] ?  sine_val : 'b0) : sine_val ; 
endmodule