`timescale 1ns/1ns

module tb_sine_lut();

reg sys_clk     ;
reg sys_rst_n   ;
wire [15:0] sine_wave  ;

initial begin
    sys_clk = 1'b1;
    sys_rst_n <= 1'b0;
    #20
    sys_rst_n <= 1'b1;
end

always #10 sys_clk = ~sys_clk;


sine_lut sine_lut_inst(
    .sys_clk     (sys_clk   ),
    .sys_rst_n   (sys_rst_n ),

    .q           (sine_wave         )
);
endmodule