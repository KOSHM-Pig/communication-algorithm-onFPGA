`timescale 1ns/1ns

module tb_double_ask_tx_top();

reg sys_clk     ;
reg sys_rst_n   ;
reg  [15:0] data_in          ;

wire [15:0] tx               ;


initial begin
    sys_clk = 1'b1;
    sys_rst_n <= 1'b0;
    data_in <= 16'b1111_1111_1111_1111;
    #(20)
    sys_rst_n <= 1'b1;
    data_in <= 16'b1111_1110_1100_1000;
    #(20*50*16)
    data_in <= 16'b0000_0001_0011_0111;
    #(20*50*16)
    data_in <= 16'b1111_0000_1111_0000;
end

always #10 sys_clk = ~sys_clk;


double_ask_tx_top double_ask_tx_top_inst(
    .sys_clk     (sys_clk   ),
    .sys_rst_n   (sys_rst_n ),
    .data_in     (data_in   ),

    .tx          (tx        )
);
endmodule