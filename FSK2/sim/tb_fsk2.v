`timescale 1ns/1ns

module tb_fsk2();

reg sys_clk;
reg sys_rst_n;
reg [15:0] data_in;

wire rx_out;

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


fsk2 fsk2_inst(
    .sys_clk  ( sys_clk   )       ,
    .sys_rst_n( sys_rst_n )       ,
    .data_in  ( data_in   )       ,

    .rx_out   ( rx_out    )       
);

endmodule