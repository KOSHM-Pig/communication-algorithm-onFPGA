module fsk2_rx
#(
    parameter DELAY_CNT_MAX = 'd20,
    parameter SYS_CLK_FREQ = 'd5_000_000, //系统5MHZ
    parameter SAMPLE_CNT_MAX = 'd50 , //你的正弦函数 频率/2 一个周期 需要多少个周期采样点
    parameter GATE_LIMIT = 'd28 //判决门限
)
(
    input   wire                        sys_clk     ,
    input   wire                        sys_rst_n   ,
    input   wire                        tx_flag     ,
    input   wire    [15:0]              tx          ,

    output  reg                        rx_out
);


//接收到tx_flag 延时1000ns处理
reg [5:0] delay_cnt ;
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (~sys_rst_n) begin
        delay_cnt <= 'd0;
    end
    else if (tx_flag) begin
        delay_cnt <= 'd1;
    end
    else if (delay_cnt == DELAY_CNT_MAX) begin
        delay_cnt <= 'd0;
    end
    else if (delay_cnt >= 'd1 && delay_cnt <= DELAY_CNT_MAX - 1) begin
        delay_cnt <= delay_cnt + 'd1;
    end
    else
        delay_cnt <= delay_cnt;
        
end

//delay_flag 标志delay完成
reg delay_flag;
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (~sys_rst_n) begin
        delay_flag <= 1'b0;
    end
    else if (delay_cnt == DELAY_CNT_MAX -1 ) begin
        delay_flag <= 1'b1;
    end
    else
        delay_flag <= 1'b0;
end

//检测到delay完成 则开始判决取点 在这之前 我们先进行计数
reg [5:0] sample_cnt;
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (~sys_rst_n) begin
        sample_cnt <= 'd0;
    end
    else if (delay_flag) begin
        sample_cnt <= 'd1;
    end
    else if (sample_cnt == SAMPLE_CNT_MAX) begin
        sample_cnt <= 'd1;
    end
    else if ((sample_cnt >= 'd1) && (sample_cnt <= SAMPLE_CNT_MAX -'d1)) begin
        sample_cnt <= sample_cnt + 'd1;
    end
    else
        sample_cnt <= sample_cnt;
end

//用于计数 便于观察周期
reg [2:0] times_cnt;
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (~sys_rst_n) begin
        times_cnt <= 'd0;
    end
    else if (delay_flag) begin
        times_cnt <= 'd1;
    end
    else if (sample_cnt == SAMPLE_CNT_MAX ) begin
        if (times_cnt == 'd4) begin
            times_cnt <= 'd1;
        end
        else
            times_cnt <= times_cnt + 'd1;
    end
    else 
        times_cnt <= times_cnt;
end


//采样
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (~sys_rst_n) begin
        rx_out <= 1'b0;
    end
    else if ((sample_cnt==SAMPLE_CNT_MAX) ) begin
        if (tx > GATE_LIMIT) begin
            rx_out <= 1'b0;
        end
        else if (tx <= GATE_LIMIT) begin
            rx_out <= 1'b1;
        end
        else
            rx_out <= 1'b0;
        end
            
    else
            rx_out <= rx_out;
end


endmodule