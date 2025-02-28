module fir_lowpassfilter (
    input   wire                sys_clk     ,
    input   wire                sys_rst_n   ,
    input   wire    [15:0]      x           ,

    output  wire    [15:0]      y           
);

// 定义滤波器系数数组
reg signed [7:0] h [0:31];


reg signed [15:0] x_reg [31:0]  ;

wire signed [23:0] xh_mul [31:0] ;


//复位初始化抽头系数
always @(posedge sys_clk or posedge sys_rst_n) begin
    if (sys_rst_n) begin
        h[0] <= -54;  h[1] <= 40;   h[2] <= 31;   h[3] <= 25;   h[4] <= 22;
        h[5] <= 21;   h[6] <= 21;   h[7] <= 21;   h[8] <= 22;   h[9] <= 22;
        h[10] <= 23;  h[11] <= 24;  h[12] <= 25;  h[13] <= 25;  h[14] <= 25;
        h[15] <= 25;  h[16] <= 25;  h[17] <= 25;  h[18] <= 25;  h[19] <= 25;h[20] <= 24;
        h[21] <= 23;  h[22] <= 22;  h[23] <= 22;  h[24] <= 21;  h[25] <= 21;
        h[26] <= 21;  h[27] <= 22;  h[28] <= 25;  h[29] <= 31;  h[30] <= 40;
        h[31] <= -54;
    end
end





//x_reg 打拍获取数据 滑动操作
genvar i;
generate

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (~sys_rst_n) 
            x_reg[0] <= 'd0 ;
        else 
            x_reg[0] <= x   ;
    end

    for (i = 1;i<32 ; i=i+1) begin : x_reg1to31
        //循环生成类似结构的电路模块 滑块操作
        always @(posedge sys_clk or negedge sys_rst_n) begin
        if (~sys_rst_n) 
            x_reg[i] <= 'd0;
        else
            x_reg[i] <= x_reg[i-1];
        end
    end



endgenerate

//xh_mul乘法操作
genvar j;
generate

    for (j = 0;j<32 ;j=j+1 ) begin : xh_mul0to31
                
                mult_x16_h8_xh20	mult_x16_h8_xh20_inst (
	                                .clock ( sys_clk ),
	                                .dataa ( x_reg[j] ),
	                                .datab ( h[j] ),
	                                .result ( xh_mul[j] )
	                                );

    end

endgenerate






// 第一级流水：分组相加（4输入加法器）
integer jk;
reg signed  [22+1:0] stage1 [7:0]; // N为原始位宽，每组4个相加
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        
        for (jk=0; jk<8; jk=jk+1) stage1[jk] <= 'd0;
    end else begin
        // 每组4个元素相加（共8组）
        stage1[0] <= xh_mul[0]  + xh_mul[1]  + xh_mul[2]  + xh_mul[3];
        stage1[1] <= xh_mul[4]  + xh_mul[5]  + xh_mul[6]  + xh_mul[7];
        stage1[2] <= xh_mul[8]  + xh_mul[9]  + xh_mul[10] + xh_mul[11];
        stage1[3] <= xh_mul[12] + xh_mul[13] + xh_mul[14] + xh_mul[15];
        stage1[4] <= xh_mul[16] + xh_mul[17] + xh_mul[18] + xh_mul[19];
        stage1[5] <= xh_mul[20] + xh_mul[21] + xh_mul[22] + xh_mul[23];
        stage1[6] <= xh_mul[24] + xh_mul[25] + xh_mul[26] + xh_mul[27];
        stage1[7] <= xh_mul[28] + xh_mul[29] + xh_mul[30] + xh_mul[31];
    end
end

// 第二级流水：中间相加（4输入加法器）
reg signed [22+3:0] stage2 [1:0];
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        stage2[0] <= 'd0;
        stage2[1] <= 'd0;
    end else begin
        // 将8组分为2组相加
        stage2[0] <= stage1[0] + stage1[1] + stage1[2] + stage1[3];
        stage2[1] <= stage1[4] + stage1[5] + stage1[6] + stage1[7];
    end
end

// 第三级流水：最终相加
reg signed [22+4:0] xh_add;
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        xh_add <= 'd0;
    end
    else begin
        xh_add <= stage2[0] + stage2[1];
    end
end


assign y = xh_add[26:11];

endmodule