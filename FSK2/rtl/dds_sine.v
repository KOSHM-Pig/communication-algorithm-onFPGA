module dds_sine
#(
    parameter  SINE_FREQ = 'd1_000_000 , //目标正弦波频率1MHZ
    parameter INCLK_FREQ = 'd50_000_000,//输入时钟频率1MHZ
    parameter SAMPLE_MAX = 'd1024      ,
    parameter GEN_CNT_MAX= 'd1         ,
    parameter GEN_MOD    = 'b0          //生成模式 0 为循环模式 1为单触发

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
reg [5:0]   gen_cnt     ;
reg [9:0]   address     ;
wire [15:0] q           ;

//freq_cnt 频率计数
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (~sys_rst_n) begin
        freq_cnt <= 'd0;
    end
    else if (toggle) begin//作为外来信号触发器
        freq_cnt <= 'd1;
    end
    else if (freq_cnt == FREQ_CNT_MAX) begin
        if (GEN_MOD && gen_cnt == GEN_CNT_MAX) begin // 多次单处发过程 触发次数达到要求
            freq_cnt <= 'd0;//回到零 使得工作使能拉低
        end
        else if ((GEN_MOD && (gen_cnt != GEN_CNT_MAX)) )begin//处于多次单触发过程 继续进行
            freq_cnt <= 'd1;//回到1 使得work_en持续
        end
        else
            freq_cnt <= 'd1;//默认的循环模式
        
    end
    else if (freq_cnt >= 'd1 && freq_cnt <= FREQ_CNT_MAX) begin
        freq_cnt <= freq_cnt + 'd1;
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

//gen_cnt 生成次数计数
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (~sys_rst_n) begin
        gen_cnt <= 'd0;
    end
    else if (GEN_MOD) begin
        if (toggle) begin
        gen_cnt <= 'd1;
        end
        else if (freq_cnt == FREQ_CNT_MAX && gen_cnt == GEN_CNT_MAX) begin
            gen_cnt <= 'd0;
        end
        else if (freq_cnt == FREQ_CNT_MAX) begin
            gen_cnt <= gen_cnt +'d1;
        end
        else
            gen_cnt <= gen_cnt;
    end
    
end

//address 地址信号 
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (~sys_rst_n) begin
        address <= 'd0;
    end
    else if (((freq_cnt >=1) && (freq_cnt <=FREQ_CNT_MAX - 'd1))) begin
        address <= address + phase_step;
    end
    else if (toggle || freq_cnt == FREQ_CNT_MAX) begin
        address <= 'd0    ;
    end
    else if (~work_en ) begin
        address <= 'd0;
    end
    else
        address <= address + 'd1;
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