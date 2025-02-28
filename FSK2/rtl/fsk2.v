module fsk2 (
    input   wire                sys_clk         ,
    input   wire                sys_rst_n       ,
    input   wire   [15:0]             data_in         ,

    output  wire                rx_out          
);

wire                tx_flag     ;
wire    [15:0]      tx          ;

wire    [15:0]      wave_out    ;
wire    [15:0]      filter_out  ;
wire    [15:0]      filter_out1  ;
fsk2_tx fsk2_tx_inst(
    .sys_clk     (sys_clk  ),
    .sys_rst_n   (sys_rst_n),
    .data_in     (data_in  ),

    .tx_flag     (tx_flag  ),
    .tx          (tx       )
);

full_wave_rectifier full_wave_rectifier_inst(
    //全波整流器
    .ac_signal   (  filter_out       ),  // 交流输入（有符号数）
    .dc_output   (  wave_out )   // 整流后输出（绝对值）
);

fir_lowpassfilter fir_lowpassfilter_inst(
    //低通滤波器
    .sys_clk     (sys_clk    ),
    .sys_rst_n   (sys_rst_n  ),
    .x           (tx   ),

    .y           (filter_out )
);

fir_lowpassfilter fir_lowpassfilter_inst1(
    //低通滤波器
    .sys_clk     (sys_clk    ),
    .sys_rst_n   (sys_rst_n  ),
    .x           (wave_out   ),

    .y           (filter_out1 )
);

fsk2_rx fsk2_rx_inst(
    .sys_clk     (sys_clk    ),
    .sys_rst_n   (sys_rst_n  ),
    .tx_flag     (tx_flag    ),
    .tx          (filter_out1 ),
        
    .rx_out      (rx_out     )
);

endmodule