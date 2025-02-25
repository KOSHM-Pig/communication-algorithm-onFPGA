`timescale 1ns/1ns

module tb_dds_sine();

reg sys_clk;
reg sys_rst_n;
reg toggle;

wire [15:0] sine_out_1MHZ;
wire [15:0] sine_out_2MHZ;

initial begin
    sys_clk = 1'b1;
    sys_rst_n <= 1'b0;
    #30
    sys_rst_n <=1'b1;
    #10
    toggle <= 1'b1;
    #20
    toggle <= 1'b0;
end

always #10 sys_clk = ~sys_clk;

dds_sine 
#(
    . SINE_FREQ ( 'd1_000_000       ), //目标正弦波频率1MHZ
    .INCLK_FREQ ( 'd50_000_000      ),//输入时钟频率1MHZ
    .SAMPLE_MAX ( 'd1024            )

)
dds_sine_1MHZ
(
    .sys_clk     (sys_clk   ),
    .sys_rst_n   (sys_rst_n ),
    .toggle      (toggle    ),

    .sine_out    (sine_out_1MHZ  )
);


dds_sine 
#(
    . SINE_FREQ ( 'd2_000_000       ), //目标正弦波频率1MHZ
    .INCLK_FREQ ( 'd50_000_000      ),//输入时钟频率1MHZ
    .SAMPLE_MAX ( 'd1024            )

)
dds_sine_2MHZ
(
    .sys_clk     (sys_clk   ),
    .sys_rst_n   (sys_rst_n ),
    .toggle      (toggle    ),

    .sine_out    (sine_out_2MHZ  )
);

endmodule