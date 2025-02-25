module dds_sine
#(
    parameter  SINE_FREQ = 'd1_000_000, //目标正弦波频率1MHZ
    parameter INCLK_FREQ = 'd50_000_000,//输入时钟频率1MHZ
    parameter SAMPLE_MAX = 'd1024

)
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire            toggle      ,

    output  wire    [15:0]  sine_out    
);

parameter phase_step = SAMPLE_MAX / ( INCLK_FREQ  / SINE_FREQ )  ;
parameter FREQ_CNT_MAX = (INCLK_FREQ / SINE_FREQ );

reg [5:0]   freq_cnt    ;
wire        work_en     ;
reg         work_en_reg ;
reg [9:0]   address     ;
wire [15:0] q           ;

//freq_cnt 频率计数
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (~sys_rst_n) begin
        freq_cnt <= 'd0;
    end
    else if (freq_cnt == FREQ_CNT_MAX) begin
        freq_cnt <= 'd0;
    end
    else if (freq_cnt >= 'd1 && freq_cnt <= FREQ_CNT_MAX) begin
        freq_cnt <= freq_cnt + 'd1;
    end
    else if (toggle) begin
        freq_cnt <= 'd1;
    end
    else
        freq_cnt <= freq_cnt;
end

//work_en 正弦波工作使能
assign work_en = ((freq_cnt >= 'd1) && (freq_cnt <= FREQ_CNT_MAX)) ? 1'b1 : 1'b0;

//work_en_reg 打拍对齐时序
always @(posedge sys_clk) begin
    work_en_reg <= work_en;
end

//address 地址信号 
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (~sys_rst_n) begin
        address <= 'd0;
    end
    else if (toggle || ((freq_cnt >=1) && (freq_cnt <=FREQ_CNT_MAX - 'd1))) begin
        address <= address + phase_step;
    end
    else if (freq_cnt == FREQ_CNT_MAX) begin
        address <= 'd0;
    end
    else
        address <= address;
end


//sine_out
assign sine_out = work_en_reg ? q : 'd0;

sine_lut_1024x16	sine_lut_1024x16_inst (
	.address ( address ),
	.clock ( sys_clk ),
	.rden ( 1 ),
	.q ( q )
	);


endmodule