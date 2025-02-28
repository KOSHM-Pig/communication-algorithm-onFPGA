`timescale 1ns/1ns

module tb_fsk2_tx();

reg sys_clk;
reg sys_rst_n;
reg [15:0] data_in;

wire tx_flag;
wire [15:0] tx;

wire [15:0] filter_wave;
initial begin
    sys_clk = 1'b1;
    sys_rst_n <= 1'b0;
    data_in   <= 16'b0;
    #30
    sys_rst_n <= 1'b1;



    #200
    data_in<= 16'b1111_1110_1100_1000;
    #(50 * 16* 20)

    #400
    data_in<= 16'b0111_1110_1111_0000;

end

always #10 sys_clk = ~sys_clk;


fsk2_tx fsk2_tx_inst(
    .sys_clk     (sys_clk   ),
    .sys_rst_n   (sys_rst_n ),
    .data_in     (data_in   ),

    .tx_flag     (tx_flag   ),
    .tx          (tx        )
);

fir_lowpassfilter fir_lowpassfilter_inst(
    .sys_clk     (sys_clk  ),
    .sys_rst_n   (sys_rst_n),
    .x           (tx       ),
    .y           (filter_wave)
);

endmodule