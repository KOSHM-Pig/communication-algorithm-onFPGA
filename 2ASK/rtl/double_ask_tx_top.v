module double_ask_tx_top (
    input   wire                sys_clk     ,
    input   wire                sys_rst_n   ,
    input   wire    [15:0]      data_in     ,

    output  wire    [15:0]      tx          
);

wire [15:0]          sine_val    ;

double_ask_tx double_ask_tx_inst(
    .sys_clk         (sys_clk   ),
    .sys_rst_n       (sys_rst_n ),
    .sine_val        (sine_val  ),
    .data_in         (data_in   ),

    .mod_out         (tx        )
);

sine_lut sine_lut_inst(
    .sys_clk         (sys_clk   ),
    .sys_rst_n       (sys_rst_n ),

    .q               (sine_val  )
);





endmodule